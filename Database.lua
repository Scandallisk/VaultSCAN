
--[[
    VaultSCAN
    File: Database.lua
    Version: 0.2.0

    Handles character data storage and retrieval.
]]

local addonName, VaultSCAN = ...


-- ============================================================
-- SAVE CHARACTER DATA
-- ============================================================

function VaultSCAN.SaveCharacterWealth()

    VaultSCANDB = VaultSCANDB or {}

    local characterName = UnitName("player")
    local realmName = GetRealmName()

    if not characterName or not realmName then
        return
    end

    local totalCopper = GetMoney()
    local _, equippedItemLevel = GetAverageItemLevel()
    local _, classFile = UnitClass("player")
    local faction = UnitFactionGroup("player")

    -- Store each character under its realm.
    VaultSCANDB[realmName] = VaultSCANDB[realmName] or {}

    VaultSCANDB[realmName][characterName] = {
        copper = totalCopper,
        itemLevel = equippedItemLevel,
        class = classFile,
        faction = faction
    }

end


-- ============================================================
-- RETRIEVE SAVED CHARACTERS
-- ============================================================

function VaultSCAN.GetAllCharacters()

    local characters = {}

    if type(VaultSCANDB) ~= "table" then
        return characters
    end

    -- Collect character records from every realm.
    for realmName, realmCharacters in pairs(VaultSCANDB) do

        if type(realmCharacters) == "table" then

            for characterName, characterData in pairs(realmCharacters) do

                if type(characterName) == "string"
                    and type(characterData) == "table" then

                    local copper = 0

                    if type(characterData.copper) == "number" then
                        copper = characterData.copper
                    end

                    table.insert(characters, {
                        name = characterName,
                        realm = realmName,
                        copper = copper,
                        itemLevel = characterData.itemLevel,
                        class = characterData.class,
                        faction = characterData.faction
                    })

                end

            end

        end

    end


    -- ========================================================
    -- SORT BY EQUIPPED ITEM LEVEL
    -- ========================================================

    -- Highest item level first; missing values last.
    -- Break ties alphabetically by realm and character name.
    table.sort(characters, function(a, b)

        local itemLevelA = type(a.itemLevel) == "number"
            and a.itemLevel or -1

        local itemLevelB = type(b.itemLevel) == "number"
            and b.itemLevel or -1

        if itemLevelA ~= itemLevelB then
            return itemLevelA > itemLevelB
        end

        if a.realm ~= b.realm then
            return a.realm < b.realm
        end

        return a.name < b.name

    end)

    return characters

end
