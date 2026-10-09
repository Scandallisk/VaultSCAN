
-- VaultSCAN
-- Version: 0.1.0

local addonName = ...

-- Create a frame to listen for game events.
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event)

    -- Initialize our saved database.
    VaultSCANDB = VaultSCANDB or {}

    local characterName = UnitName("player")
    local realmName = GetRealmName()
    local totalCopper = GetMoney()

    local totalGold = math.floor(totalCopper / 10000)
    local formattedGold = BreakUpLargeNumbers(totalGold)

    print("|cffFFD700" .. addonName .. "|r successfully loaded! Welcome to Azeroth.")
    print("VaultSCAN detected character: " .. (characterName or "Unknown"))
    print("VaultSCAN detected realm: " .. (realmName or "Unknown"))
    print("VaultSCAN detected gold: |cffffd700" .. formattedGold .. "|r")

    -- Create a realm entry if one doesn't already exist.
    VaultSCANDB[realmName] = VaultSCANDB[realmName] or {}

    -- Save the current character's wealth.
    VaultSCANDB[realmName][characterName] = {
        copper = totalCopper
    }

    print("VaultSCAN saved character data!")

end)
