
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

    -- Ensure the realm exists in our database.
    VaultSCANDB[realmName] = VaultSCANDB[realmName] or {}

    -- Create or update the character's record.
    VaultSCANDB[realmName][characterName] = {
        copper = totalCopper
    }
end
