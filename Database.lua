
-- VaultSCAN
-- Database.lua
-- Handles character wealth storage.

local addonName, VaultSCAN = ...

-- Save the current character's wealth.
function VaultSCAN.SaveCharacterWealth()
    VaultSCANDB = VaultSCANDB or {}

    local characterName = UnitName("player")
    local realmName = GetRealmName()
    local totalCopper = GetMoney()

    -- Retrieve the character's currently equipped average item level.
    -- GetAverageItemLevel() returns overall item level first,
    -- followed by equipped item level.
    local _, equippedItemLevel = GetAverageItemLevel()

    -- Retrieve the character's class identifier.
    -- Example: "DRUID", "HUNTER", or "MAGE".
    local _, classFile = UnitClass("player")


    -- Ensure the realm exists in our database.
    VaultSCANDB[realmName] = VaultSCANDB[realmName] or {}

    -- Store the character's wealth, equipment level, and class.
    VaultSCANDB[realmName][characterName] = {
        copper = totalCopper,
        itemLevel = equippedItemLevel,
        class = classFile
    }

end
