local addonName, VaultSCAN = ...

function VaultSCAN.SaveCharacterWealth(isMoneyEvent)
    VaultSCANDB = VaultSCANDB or {}
    local name, realm = UnitName("player"), GetRealmName()
    if not name or not realm then return end

    VaultSCANDB[realm] = VaultSCANDB[realm] or {}
    local record = VaultSCANDB[realm][name]
    if type(record) ~= "table" then record = {} end

    local _, equippedLevel = GetAverageItemLevel()
    local _, class = UnitClass("player")
    local copper = GetMoney()
    local level = UnitLevel("player")
    if type(level) == "number" and level > 0 then record.level = level end
    if type(copper) == "number" and copper >= 0 then
        if isMoneyEvent or copper > 0 or type(record.copper) ~= "number" then
            record.copper = copper
        end
    end
    if type(equippedLevel) == "number" and equippedLevel > 0 then
        record.itemLevel = equippedLevel
    elseif type(record.itemLevel) ~= "number" then
        record.itemLevel = equippedLevel
    end
    -- Preserve older records and capture one snapshot per calendar week.
    if type(record.itemLevel) == "number" and record.itemLevel > 0 then
        local stamp = time()
        if type(stamp) == "number" and stamp > 0 then
            local week = date("%Y-W%W", stamp)
            record.history = type(record.history) == "table" and record.history or {}
            record.history[week] = { at = stamp, itemLevel = record.itemLevel }
            -- Keep the most recent 52 weeks to limit SavedVariables growth.
            local keys = {}
            for key, entry in pairs(record.history) do
                if type(entry) == "table" and type(entry.at) == "number" then
                    keys[#keys + 1] = key
                else
                    record.history[key] = nil
                end
            end
            table.sort(keys, function(a, b) return record.history[a].at > record.history[b].at end)
            for i = 53, #keys do record.history[keys[i]] = nil end
        end
    end
    record.class = class
    record.faction = UnitFactionGroup("player")
    VaultSCANDB[realm][name] = record
end

-- Only a viewable Warband Bank can verify a new balance. A successful
-- FetchDepositedMoney call by itself is NOT proof of bank availability:
-- it can return a misleading zero while the bank UI reports unavailable.
-- Never erase the last verified SavedVariables value on a failed scan.
function VaultSCAN.ScanWarbandWealth()
    if not (C_Bank and type(C_Bank.CanViewBank) == "function"
        and type(C_Bank.FetchDepositedMoney) == "function"
        and Enum and Enum.BankType and Enum.BankType.Account ~= nil) then
        return false
    end
    local bankType = Enum.BankType.Account
    local viewOK, canView = pcall(C_Bank.CanViewBank, bankType)
    if not viewOK or canView ~= true then return false end

    local ok, copper = pcall(C_Bank.FetchDepositedMoney, bankType)
    if not ok or type(copper) ~= "number" or copper < 0
        or copper ~= copper or copper == math.huge then return false end

    VaultSCANDB = VaultSCANDB or {}
    VaultSCANDB.warbandBank = VaultSCANDB.warbandBank or {}
    VaultSCANDB.warbandBank.copper = math.floor(copper)
    VaultSCANDB.warbandBank.lastScan = time()
    -- Session-only trust flag: intentionally NOT persisted across logins.
    VaultSCAN._warbandScannedThisSession = true
    VaultSCAN._warbandVerifiedDay = date("%Y-%m-%d")
    return true
end

function VaultSCAN.MarkWarbandUnavailable()
    -- A failed bank-open attempt invalidates this session's trust, but not
    -- the last known good amount saved in the database.
    VaultSCAN._warbandScannedThisSession = false
    VaultSCAN._warbandVerifiedDay = nil
end

function VaultSCAN.GetWarbandWealth()
    local data = type(VaultSCANDB) == "table" and VaultSCANDB.warbandBank
    if type(data) == "table" and type(data.copper) == "number" then
        return data.copper, data.lastScan
    end
    return nil, nil
end

-- A successful bank scan expires at the next calendar day. Otherwise leaving
-- the client running overnight could silently record tomorrow's snapshot with
-- yesterday's (unverified) Warband gold.
function VaultSCAN.IsWarbandWealthVerified()
    return VaultSCAN._warbandScannedThisSession == true
        and VaultSCAN._warbandVerifiedDay == date("%Y-%m-%d")
end

-- Any daily snapshot may now be either verified or estimated. For compatibility,
-- older entries (without status) are verified because v1.0.0 required a bank scan.
function VaultSCAN.HasTodayWealthSnapshot()
    local history = type(VaultSCANDB) == "table" and VaultSCANDB.wealthHistory
    if type(history) ~= "table" then return false end
    local today = date("%Y-%m-%d")
    local record = history[today]
    return type(record) == "table" and type(record.copper) == "number"
end

-- No daily reminder or modal dialog: the background monitor keeps retrying
-- while bank data is unavailable. Older reminder metadata is harmless.

-- Read-only consistency check for the current footer and today's saved snapshot.
-- A snapshot is a point-in-time record, not a live gold balance. A difference
-- between today's snapshot and current gold is informational, not an error.
function VaultSCAN.ValidateWealthState(characterCopper)
    local verified = VaultSCAN.IsWarbandWealthVerified()
    local bankCopper = VaultSCAN.GetWarbandWealth()
    local history = type(VaultSCANDB) == "table" and VaultSCANDB.wealthHistory
    local today = date("%Y-%m-%d")
    local snapshot = type(history) == "table" and history[today] or nil
    if type(snapshot) ~= "table" or type(snapshot.copper) ~= "number" then snapshot = nil end
    local liveCopper = nil
    if verified and type(bankCopper) == "number" and type(characterCopper) == "number" then
        liveCopper = math.floor(characterCopper + bankCopper)
    end
    return {
        verified = verified,
        bankCopper = bankCopper,
        liveCopper = liveCopper,
        snapshot = snapshot,
        snapshotStatus = snapshot and (snapshot.status or "verified") or nil,
        deltaCopper = (liveCopper and snapshot) and (liveCopper - snapshot.copper) or nil,
    }
end

function VaultSCAN.MarkCharacterLogin()
    VaultSCAN.SaveCharacterWealth()
    local name, realm = UnitName("player"), GetRealmName()
    if name and realm and VaultSCANDB[realm] and VaultSCANDB[realm][name] then
        VaultSCANDB[realm][name].lastPlayed = time()
    end
end

function VaultSCAN.SavePlayedTime(seconds)
    if type(seconds) ~= "number" or seconds < 0 then return end
    VaultSCAN.SaveCharacterWealth()
    local name, realm = UnitName("player"), GetRealmName()
    if name and realm and VaultSCANDB[realm] and VaultSCANDB[realm][name] then
        VaultSCANDB[realm][name].playedSeconds = math.floor(seconds)
    end
end

function VaultSCAN.DeleteCharacter(realm, name)
    if type(VaultSCANDB) ~= "table" or type(VaultSCANDB[realm]) ~= "table" then return end
    VaultSCANDB[realm][name] = nil
    if not next(VaultSCANDB[realm]) then VaultSCANDB[realm] = nil end
    if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
end

function VaultSCAN.GetAllCharacters()
    local characters = {}
    if type(VaultSCANDB) ~= "table" then return characters end

    for realm, records in pairs(VaultSCANDB) do
        if realm ~= "minimap" and realm ~= "warbandBank" and realm ~= "wealthHistory" and type(records) == "table" then
            for name, data in pairs(records) do
                if type(name) == "string" and type(data) == "table" then
                    characters[#characters + 1] = {
                        name = name,
                        realm = realm,
                        copper = type(data.copper) == "number" and data.copper or 0,
                        itemLevel = data.itemLevel,
                        level = type(data.level) == "number" and data.level or nil,
                        class = data.class,
                        faction = data.faction,
                        playedSeconds = type(data.playedSeconds) == "number" and data.playedSeconds or nil,
                        lastPlayed = type(data.lastPlayed) == "number" and data.lastPlayed or nil,
                        history = type(data.history) == "table" and data.history or nil,
                    }
                end
            end
        end
    end
    return characters
end

-- Account-wide wealth history; one observation per calendar day.
-- Verified = bank viewable and successfully scanned today.
-- Estimated = last verified bank balance + latest saved character gold.
-- Estimates may be replaced ONCE by a later verified observation the same day.
-- A verified observation is otherwise immutable for the rest of its day.
-- Pre-v1.0.1 records without status are treated as verified.
function VaultSCAN.RecordWealthSnapshot(characterCopper)
    local bankCopper, lastBankScan = VaultSCAN.GetWarbandWealth()
    if type(bankCopper) ~= "number" or type(characterCopper) ~= "number"
        or bankCopper < 0 or characterCopper < 0 then return false end
    local stamp = time()
    if type(stamp) ~= "number" or stamp <= 0 then return false end

    local verified = VaultSCAN.IsWarbandWealthVerified()
    local status = verified and "verified" or "estimated"
    VaultSCANDB = VaultSCANDB or {}
    VaultSCANDB.wealthHistory = type(VaultSCANDB.wealthHistory) == "table"
        and VaultSCANDB.wealthHistory or {}
    local history = VaultSCANDB.wealthHistory
    local day = date("%Y-%m-%d", stamp)
    local existing = history[day]
    local replaceEstimate = type(existing) == "table"
        and existing.status == "estimated" and verified
    if not existing or replaceEstimate then
        history[day] = {
            at = stamp,
            copper = math.floor(characterCopper + bankCopper),
            status = status,
            bankCopper = math.floor(bankCopper),
            bankLastVerifiedAt = lastBankScan,
        }
    end

    -- Keep at most 90 calendar days; never backfill missed days.
    local cutoff = stamp - 90 * 86400
    for key, entry in pairs(history) do
        if type(entry) ~= "table" or type(entry.at) ~= "number"
            or type(entry.copper) ~= "number" or entry.at < cutoff then
            history[key] = nil
        end
    end
    return true
end

-- Capture daily history even when the dashboard is never opened.
function VaultSCAN.UpdateDailyWealthSnapshot()
    local total = 0
    for _, character in ipairs(VaultSCAN.GetAllCharacters()) do
        total = total + character.copper
    end
    return VaultSCAN.RecordWealthSnapshot(total)
end

function VaultSCAN.GetWealthHistory(days)
    local results = {}
    if type(VaultSCANDB) ~= "table" or type(VaultSCANDB.wealthHistory) ~= "table" then
        return results
    end
    local now = time()
    local cutoff = now - (math.max(1, days or 30) - 1) * 86400
    for _, entry in pairs(VaultSCANDB.wealthHistory) do
        if type(entry) == "table" and type(entry.at) == "number"
            and type(entry.copper) == "number" and entry.at >= cutoff and entry.at <= now then
            results[#results + 1] = entry
        end
    end
    table.sort(results, function(a, b) return a.at < b.at end)
    return results
end
