local addonName, VaultSCAN = ...
local events = CreateFrame("Frame")
local PLAYED_REQUEST_COOLDOWN = 60
local lastPlayedRequest = -PLAYED_REQUEST_COOLDOWN

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
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("ACCOUNT_MONEY")
events:RegisterEvent("BANKFRAME_OPENED")
events:RegisterEvent("TIME_PLAYED_MSG")
events:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        VaultSCANDB = VaultSCANDB or {}
        VaultSCAN.MarkCharacterLogin()
        C_Timer.After(2, RequestPlayedTime)
        -- Bank data can become available after login; retry once after initialization.
        C_Timer.After(3, function()
            VaultSCAN.ScanWarbandWealth()
            if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
        end)
        print("|cffffd100VaultSCAN v0.6.1:|r Ready.")
    elseif event == "TIME_PLAYED_MSG" then
        local totalSeconds = ...
        VaultSCAN.SavePlayedTime(totalSeconds)
        if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
    elseif event == "ACCOUNT_MONEY" or event == "BANKFRAME_OPENED" then
        VaultSCAN.ScanWarbandWealth()
        if event == "BANKFRAME_OPENED" then
            C_Timer.After(0.5, function()
                VaultSCAN.ScanWarbandWealth()
                if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
            end)
        end
        if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
    elseif event == "PLAYER_MONEY" or event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYER_LEVEL_UP" then
        VaultSCAN.SaveCharacterWealth(event == "PLAYER_MONEY")
        if event == "PLAYER_LEVEL_UP" then
            -- PLAYER_LEVEL_UP supplies the new level even if UnitLevel lags this event.
            local newLevel = ...
            local name, realm = UnitName("player"), GetRealmName()
            local record = VaultSCANDB and VaultSCANDB[realm] and VaultSCANDB[realm][name]
            if record and type(newLevel) == "number" and newLevel > 0 then
                record.level = newLevel
            end
        end
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
