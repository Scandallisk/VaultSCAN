local addonName, VaultSCAN = ...
local events = CreateFrame("Frame")
local lastPlayedRequest = 0
local PLAYED_REQUEST_COOLDOWN = 60

local function RequestPlayedTime()
    local now = GetTime()
    if now - lastPlayedRequest < PLAYED_REQUEST_COOLDOWN then return end
    lastPlayedRequest = now
    RequestTimePlayed()
end

function VaultSCAN.RequestPlayedTime()
    RequestPlayedTime()
end

events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_MONEY")
events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
events:RegisterEvent("TIME_PLAYED_MSG")
events:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        VaultSCANDB = VaultSCANDB or {}
        VaultSCAN.SaveCharacterWealth()
        C_Timer.After(2, RequestPlayedTime)
        print("|cffffd100VaultSCAN|r v0.3.0 loaded. Type /vaultscan to open.")
    elseif event == "TIME_PLAYED_MSG" then
        local totalSeconds = ...
        VaultSCAN.SavePlayedTime(totalSeconds)
        if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
    elseif event == "PLAYER_MONEY" or event == "PLAYER_EQUIPMENT_CHANGED" then
        VaultSCAN.SaveCharacterWealth(event == "PLAYER_MONEY")
        if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
    end
end)

SLASH_VAULTSCAN1 = "/vaultscan"
SlashCmdList.VAULTSCAN = function() VaultSCAN.ToggleWindow() end

SLASH_VSDEBUG1 = "/vsdebug"
SlashCmdList.VSDEBUG = function()
    for _, character in ipairs(VaultSCAN.GetAllCharacters()) do
        print(string.format("%s-%s: %dg, iLvl %s, %s, played %s",
            character.name, character.realm, math.floor(character.copper / 10000),
            tostring(character.itemLevel or "?"), tostring(character.faction or "?"),
            tostring(character.playedSeconds or "unknown")))
    end
end
