
--[[
    VaultSCAN
    File: Database.lua
    Version: 0.1.0

    Purpose:
    Handles persistent character information storage
    and retrieval for the VaultSCAN addon.

    Responsibilities:
    - Save character wealth.
    - Save equipped item level.
    - Save character class.
    - Organize character data by realm.
    - Retrieve all saved characters.
    - Sort characters for consistent UI display.
]]

-- Retrieve the addon name and shared namespace.
local addonName, VaultSCAN = ...


-- ============================================================
-- SAVE CHARACTER INFORMATION
-- ============================================================

-- Save the currently logged-in character's information.
--
-- This function is called by VaultSCAN.lua when:
-- - The player logs in.
-- - The player's money changes.
-- - The player's equipment changes.
--
-- VaultSCANDB is a SavedVariables table that persists
-- between game sessions.
function VaultSCAN.SaveCharacterWealth()

    -- Initialize the database if it does not exist.
    VaultSCANDB = VaultSCANDB or {}

    -- Retrieve the current character's identity.
    local characterName = UnitName("player")
    local realmName = GetRealmName()

    -- Prevent saving if character information is unavailable.
    if not characterName or not realmName then
        return
    end

    -- Retrieve the character's current wealth in copper.
    local totalCopper = GetMoney()

    -- Retrieve equipped average item level.
    --
    -- GetAverageItemLevel() returns two values:
    -- 1. Overall average item level.
    -- 2. Equipped average item level.
    --
    -- We only need the second value.
    local _, equippedItemLevel = GetAverageItemLevel()

    -- Retrieve the character's class identifier.
    --
    -- UnitClass() returns:
    -- 1. Localized class name.
    -- 2. Class identifier, such as "HUNTER".
    local _, classFile = UnitClass("player")

    -- Ensure the current realm has a database table.
    VaultSCANDB[realmName] = VaultSCANDB[realmName] or {}

    -- Store the character's information.
    --
    -- Existing records for this character are updated
    -- whenever this function runs.
    VaultSCANDB[realmName][characterName] = {
        copper = totalCopper,
        itemLevel = equippedItemLevel,
        class = classFile
    }

end


-- ============================================================
-- RETRIEVE ALL SAVED CHARACTERS
-- ============================================================

-- Return a sorted list of every character stored in VaultSCANDB.
--
-- Each result contains:
-- name      = Character name.
-- realm     = Realm name.
-- copper    = Saved wealth in copper.
-- itemLevel = Saved equipped item level.
-- class     = Character class identifier.
--
-- This function only reads data. It does not modify
-- the SavedVariables database.
function VaultSCAN.GetAllCharacters()

    -- Create an empty list for our results.
    local characters = {}

    -- Return an empty list if the database is unavailable.
    if type(VaultSCANDB) ~= "table" then
        return characters
    end

    -- Loop through every saved realm.
    for realmName, realmCharacters in pairs(VaultSCANDB) do

        -- Verify the realm contains a character table.
        if type(realmCharacters) == "table" then

            -- Loop through each character on this realm.
            for characterName, characterData in pairs(realmCharacters) do

                -- Only include valid character records.
                if type(characterName) == "string"
                    and type(characterData) == "table" then

                    -- Use zero when a gold balance is unavailable.
                    local copper = 0

                    if type(characterData.copper) == "number" then
                        copper = characterData.copper
                    end

                    -- Create a character entry.
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

    -- Sort the character list alphabetically.
    --
    -- Characters are grouped by realm first,
    -- then sorted by name within each realm.
    --
    -- This ensures the dashboard displays characters
    -- in a predictable order.
    table.sort(characters, function(a, b)

        if a.realm == b.realm then
            return a.name < b.name
        end

        return a.realm < b.realm

    end)

    -- Return the completed character list.
    return characters

end
