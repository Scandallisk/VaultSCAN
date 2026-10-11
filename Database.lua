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

-- Warband bank money belongs to the account, never to a character record.
-- A nil value means no successful scan has occurred yet.
function VaultSCAN.ScanWarbandWealth()
    if not (C_Bank and type(C_Bank.FetchDepositedMoney) == "function"
        and Enum and Enum.BankType and Enum.BankType.Account ~= nil) then return false end
    local ok, copper = pcall(C_Bank.FetchDepositedMoney, Enum.BankType.Account)
    if not ok or type(copper) ~= "number" or copper < 0 then return false end
    VaultSCANDB = VaultSCANDB or {}
    VaultSCANDB.warbandBank = VaultSCANDB.warbandBank or {}
    VaultSCANDB.warbandBank.copper = copper
    VaultSCANDB.warbandBank.lastScan = time()
    return true
end

function VaultSCAN.GetWarbandWealth()
    local data = type(VaultSCANDB) == "table" and VaultSCANDB.warbandBank
    if type(data) == "table" and type(data.copper) == "number" then
        return data.copper, data.lastScan
    end
    return nil, nil
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
        if realm ~= "minimap" and realm ~= "warbandBank" and type(records) == "table" then
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
