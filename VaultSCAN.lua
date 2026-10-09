
-- VaultSCAN
-- Version: 0.1.0

local addonName, VaultSCAN = ...

-- Create a frame to listen for game events.
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_MONEY")

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

    end
end)

-- Register the VaultSCAN slash command.
SLASH_VAULTSCAN1 = "/vaultscan"


SlashCmdList["VAULTSCAN"] = function()
    print("|cffFFD700VaultSCAN - Character Wealth|r")

    local totalCopper = 0

    for realmName, characters in pairs(VaultSCANDB or {}) do
        if type(characters) == "table" then
            for characterName, data in pairs(characters) do
                if type(data) == "table" and type(data.copper) == "number" then
                    local gold = math.floor(data.copper / 10000)

                    print(realmName .. " / " .. characterName .. ": "
                        .. BreakUpLargeNumbers(gold) .. " gold")

                    totalCopper = totalCopper + data.copper
                end
            end
        end
    end

    local totalGold = math.floor(totalCopper / 10000)

    print("|cffFFD700Total Wealth: "
        .. BreakUpLargeNumbers(totalGold) .. " gold|r")
end



