
-- VaultSCAN
-- Version: 0.1.0

local addonName, VaultSCAN = ...

-- Create a frame to listen for game events.
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_MONEY")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

eventFrame:SetScript("OnEvent", function(self, event)
    
    if event == "PLAYER_LOGIN" then

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

       -- Save the current character's wealth.
        VaultSCAN.SaveCharacterWealth()
        print("VaultSCAN saved character data!")

    -- Update the saved balance silently.
    
    elseif event == "PLAYER_MONEY" then

        -- Update the saved balance silently.
        VaultSCAN.SaveCharacterWealth()
        
        -- Refresh the UI to reflect the new balance.
        VaultSCAN.RefreshUI()

        -- Update character data when equipped gear changes.
        elseif event == "PLAYER_EQUIPMENT_CHANGED" then

            -- Save the latest equipped item level to VaultSCANDB.
            VaultSCAN.SaveCharacterWealth()

            -- Refresh the displayed item level and other character data.
            VaultSCAN.RefreshUI()

    end
end)

-- Register the VaultSCAN slash command.
SLASH_VAULTSCAN1 = "/vaultscan"

SlashCmdList["VAULTSCAN"] = function()
    VaultSCAN.ToggleWindow()
end



