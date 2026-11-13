local addonName, VaultSCAN = ...

function VaultSCAN.FormatMoney(copper)
    copper = type(copper) == "number" and copper or 0
    if copper ~= copper or copper == math.huge or copper == -math.huge then copper = 0 end
    copper = math.floor(math.max(0, copper))
    local gold = math.floor(copper / 10000)
    local silver = math.floor(copper / 100) % 100
    local coins = copper % 100
    return string.format("%sg %ds %dc", BreakUpLargeNumbers(gold), silver, coins)
end

function VaultSCAN.GetPlayerIdentity()
    local first, surname = UnitName("player")
    local realm = GetRealmName()
    local guid = type(UnitGUID) == "function" and UnitGUID("player") or nil
    if not first or first == "" or not realm or realm == "" or not guid then return nil end
    local fullName = first
    if type(surname) == "string" and surname ~= "" then fullName = first .. " " .. surname end
    return fullName, realm, guid, first
end

function VaultSCAN.SaveCharacterWealth(isMoneyEvent)
    VaultSCANForeverDB = VaultSCANForeverDB or {}
    local name, realm, key, first = VaultSCAN.GetPlayerIdentity()
    if not key then return false end

    VaultSCANForeverDB[realm] = VaultSCANForeverDB[realm] or {}
    -- Archive ambiguous first-name-only prototype data without assigning it to a character.
    if type(VaultSCANForeverDB[realm][first]) == "table" then
        VaultSCANForeverDB.legacyCharacters = VaultSCANForeverDB.legacyCharacters or {}
        VaultSCANForeverDB.legacyCharacters[realm] = VaultSCANForeverDB.legacyCharacters[realm] or {}
        VaultSCANForeverDB.legacyCharacters[realm][first] = VaultSCANForeverDB[realm][first]
        VaultSCANForeverDB[realm][first] = nil
    end
    local record = VaultSCANForeverDB[realm][key]
    if type(record) ~= "table" then record = {} end

    local equippedLevel
    if type(GetAverageItemLevel) == "function" then
        local ok, average, equipped = pcall(GetAverageItemLevel)
        if ok then equippedLevel = equipped or average end
    end
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
    record.name = name
    record.guid = key
    record.class = class
    record.faction = UnitFactionGroup("player")
    VaultSCANForeverDB[realm][key] = record
    return true
end

function VaultSCAN.MarkCharacterLogin()
    if not VaultSCAN.SaveCharacterWealth() then return false end
    local name, realm, key = VaultSCAN.GetPlayerIdentity()
    if key and VaultSCANForeverDB[realm] and VaultSCANForeverDB[realm][key] then
        VaultSCANForeverDB[realm][key].lastPlayed = time()
    end
    return true
end

function VaultSCAN.SavePlayedTime(seconds)
    if type(seconds) ~= "number" or seconds < 0 then return end
    VaultSCAN.SaveCharacterWealth()
    local name, realm, key = VaultSCAN.GetPlayerIdentity()
    if key and VaultSCANForeverDB[realm] and VaultSCANForeverDB[realm][key] then
        VaultSCANForeverDB[realm][key].playedSeconds = math.floor(seconds)
    end
end

function VaultSCAN.DeleteCharacter(realm, name)
    if type(VaultSCANForeverDB) ~= "table" or type(VaultSCANForeverDB[realm]) ~= "table" then return end
    VaultSCANForeverDB[realm][name] = nil
    if not next(VaultSCANForeverDB[realm]) then VaultSCANForeverDB[realm] = nil end
    if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
end

function VaultSCAN.GetAllCharacters()
    local characters = {}
    if type(VaultSCANForeverDB) ~= "table" then return characters end

    for realm, records in pairs(VaultSCANForeverDB) do
        if realm ~= "legacyCharacters" and realm ~= "minimap" and realm ~= "warbandBank" and realm ~= "wealthHistory" and type(records) == "table" then
            for name, data in pairs(records) do
                if type(name) == "string" and type(data) == "table" then
                    characters[#characters + 1] = {
                        name = data.name or name,
                        key = name,
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

-- Forever history records observed character balances only, never bank data.
function VaultSCAN.RecordWealthSnapshot(characterCopper)
    if type(characterCopper) ~= "number" or characterCopper < 0
        or characterCopper ~= characterCopper or characterCopper == math.huge then return false end
    local stamp = time()
    if type(stamp) ~= "number" or stamp <= 0 then return false end
    VaultSCANForeverDB = VaultSCANForeverDB or {}
    VaultSCANForeverDB.wealthHistory = type(VaultSCANForeverDB.wealthHistory) == "table" and VaultSCANForeverDB.wealthHistory or {}
    local history = VaultSCANForeverDB.wealthHistory
    local day = date("%Y-%m-%d", stamp)
    if not history[day] then
        history[day] = { at = stamp, copper = math.floor(characterCopper) }
    end
    local cutoff = stamp - 90 * 86400
    for key, entry in pairs(history) do
        if type(entry) ~= "table" or type(entry.at) ~= "number"
            or type(entry.copper) ~= "number" or entry.at < cutoff then history[key] = nil end
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
    if type(VaultSCANForeverDB) ~= "table" or type(VaultSCANForeverDB.wealthHistory) ~= "table" then
        return results
    end
    local now = time()
    local cutoff = now - (math.max(1, days or 30) - 1) * 86400
    for _, entry in pairs(VaultSCANForeverDB.wealthHistory) do
        if type(entry) == "table" and type(entry.at) == "number"
            and type(entry.copper) == "number" and entry.at >= cutoff and entry.at <= now then
            results[#results + 1] = entry
        end
    end
    table.sort(results, function(a, b) return a.at < b.at end)
    return results
end
