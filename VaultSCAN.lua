
--[[
    VaultSCAN
    File: VaultSCAN.lua
    Version: 0.1.0

    Handles game events and slash commands.
]]

local addonName, VaultSCAN = ...


-- ============================================================
-- GAME EVENTS
-- ============================================================

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_MONEY")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

eventFrame:SetScript("OnEvent", function(self, event)

    if event == "PLAYER_LOGIN" then

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

        VaultSCAN.SaveCharacterWealth()

        print("VaultSCAN saved character data!")


    elseif event == "PLAYER_MONEY" then

        -- Update stored wealth and refresh the dashboard.
        VaultSCAN.SaveCharacterWealth()
        VaultSCAN.RefreshUI()


    elseif event == "PLAYER_EQUIPMENT_CHANGED" then

        -- Update equipped item level and refresh the dashboard.
        VaultSCAN.SaveCharacterWealth()
        VaultSCAN.RefreshUI()

    end

end)


-- ============================================================
-- SLASH COMMANDS
-- ============================================================

-- Open or close the dashboard with /vaultscan.
SLASH_VAULTSCAN1 = "/vaultscan"

SlashCmdList["VAULTSCAN"] = function()
    VaultSCAN.ToggleWindow()
end


-- ============================================================
-- DEBUG COMMAND
-- ============================================================

-- Temporary diagnostic command for inspecting saved characters.
SLASH_VAULTSCANDEBUG1 = "/vsdebug"

SlashCmdList["VAULTSCANDEBUG"] = function()

    local characters = VaultSCAN.GetAllCharacters()

    print("VaultSCAN found " .. #characters .. " characters:")

    for index, character in ipairs(characters) do

        local gold = math.floor(character.copper / 10000)
        local itemLevel = "N/A"

        if type(character.itemLevel) == "number" then
            itemLevel = tostring(math.floor(character.itemLevel + 0.5))
        end

        print(
            index .. ". "
            .. character.name
            .. " - " .. character.realm
            .. " - " .. BreakUpLargeNumbers(gold) .. " gold"
            .. " - iLvl: " .. itemLevel
            .. " - Class: " .. (character.class or "Unknown")
        )

    end

end
