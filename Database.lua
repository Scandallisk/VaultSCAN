
--[[
    VaultSCAN
    File: Database.lua
    Version: 0.1.0

    Handles character data storage and retrieval.
]]

local addonName, VaultSCAN = ...


-- ============================================================
-- SAVE CHARACTER INFORMATION
-- ============================================================

function VaultSCAN.SaveCharacterWealth()

    VaultSCANDB = VaultSCANDB or {}

    local characterName = UnitName("player")
    local realmName = GetRealmName()

    if not characterName or not realmName then
        return
    end

    local totalCopper = GetMoney()

    -- Get the currently equipped average item level.
    local _, equippedItemLevel = GetAverageItemLevel()

    -- Get the class identifier, such as HUNTER or DRUID.
    local _, classFile = UnitClass("player")

    VaultSCANDB[realmName] = VaultSCANDB[realmName] or {}

    VaultSCANDB[realmName][characterName] = {
        copper = totalCopper,
        itemLevel = equippedItemLevel,
        class = classFile
    }

end


-- ============================================================
-- RETRIEVE ALL SAVED CHARACTERS
-- ============================================================

function VaultSCAN.GetAllCharacters()

    local characters = {}

    if type(VaultSCANDB) ~= "table" then
        return characters
    end

    -- Collect characters from every saved realm.
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
                        class = characterData.class
                    })

                end

            end

        end

    end


    -- ========================================================
    -- SORT BY ITEM LEVEL (HIGHEST FIRST)
    -- ========================================================

    table.sort(characters, function(a, b)

        -- Missing item levels receive -1 so they sort last.
        local itemLevelA = type(a.itemLevel) == "number"
            and a.itemLevel or -1

        local itemLevelB = type(b.itemLevel) == "number"
            and b.itemLevel or -1

        -- Higher equipped item level comes first.
        if itemLevelA ~= itemLevelB then
            return itemLevelA > itemLevelB
        end

        -- Sort tied characters by realm, then name.
        if a.realm ~= b.realm then
            return a.realm < b.realm
        end

        return a.name < b.name

    end)

    return characters

end
