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
    record.class = class
    record.faction = UnitFactionGroup("player")
    VaultSCANDB[realm][name] = record
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
        if realm ~= "minimap" and type(records) == "table" then
            for name, data in pairs(records) do
                if type(name) == "string" and type(data) == "table" then
                    characters[#characters + 1] = {
                        name = name,
                        realm = realm,
                        copper = type(data.copper) == "number" and data.copper or 0,
                        itemLevel = data.itemLevel,
                        class = data.class,
                        faction = data.faction,
                        playedSeconds = type(data.playedSeconds) == "number" and data.playedSeconds or nil,
                    }
                end
            end
        end
    end
    return characters
end
