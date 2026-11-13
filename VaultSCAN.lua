local addonName, VaultSCAN = ...
local events = CreateFrame("Frame")
local function CaptureLogin(attempt)
    if VaultSCAN.MarkCharacterLogin() then
        VaultSCAN.UpdateDailyWealthSnapshot()
        return
    end
    if attempt < 5 then C_Timer.After(1, function() CaptureLogin(attempt + 1) end) end
end
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
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_MONEY")
events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("TIME_PLAYED_MSG")
events:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        VaultSCANForeverDB = VaultSCANForeverDB or {}
        CaptureLogin(1)
        if VaultSCAN.UpdateDailyWealthSnapshot then VaultSCAN.UpdateDailyWealthSnapshot() end
        C_Timer.After(2, RequestPlayedTime)
        C_Timer.NewTicker(90, function()
            VaultSCAN.SaveCharacterWealth()
            VaultSCAN.UpdateDailyWealthSnapshot()
            if VaultSCANMainFrame and VaultSCANMainFrame:IsShown() then VaultSCAN.RefreshUI() end
        end)
        print("|cffffd100VaultSCAN v1.0.0:|r Forever ready. Character gold tracking active.")
    elseif event == "TIME_PLAYED_MSG" then
        local totalSeconds = ...
        VaultSCAN.SavePlayedTime(totalSeconds)
        if VaultSCAN.UpdateDailyWealthSnapshot then VaultSCAN.UpdateDailyWealthSnapshot() end
        if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(2, function()
            CaptureLogin(1)
            if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
        end)
    elseif event == "PLAYER_MONEY" or event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYER_LEVEL_UP" then
        VaultSCAN.SaveCharacterWealth(event == "PLAYER_MONEY")
        if event == "PLAYER_LEVEL_UP" then
            -- PLAYER_LEVEL_UP supplies the new level even if UnitLevel lags this event.
            local newLevel = ...
            local name, realm, key = VaultSCAN.GetPlayerIdentity()
            local record = key and VaultSCANForeverDB and VaultSCANForeverDB[realm] and VaultSCANForeverDB[realm][key]
            if record and type(newLevel) == "number" and newLevel > 0 then
                record.level = newLevel
            end
        end
        if VaultSCAN.UpdateDailyWealthSnapshot then VaultSCAN.UpdateDailyWealthSnapshot() end
        if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
    end
end)

SLASH_VAULTSCAN1 = "/vaultscan"
SlashCmdList.VAULTSCAN = function() VaultSCAN.ToggleWindow() end

SLASH_VSDEBUG1 = "/vsdebug"
SlashCmdList.VSDEBUG = function()
    VaultSCAN.SaveCharacterWealth()
    print("VaultSCAN Forever 1.0.0 | Current: " .. tostring(VaultSCAN.GetPlayerIdentity()) .. " | Realm: " .. tostring(GetRealmName()) .. " | Records: " .. #VaultSCAN.GetAllCharacters())
    for _, character in ipairs(VaultSCAN.GetAllCharacters()) do
        print(string.format("%s-%s: %s, iLvl %s, %s, played %s",
            character.name, character.realm, VaultSCAN.FormatMoney(character.copper),
            tostring(character.itemLevel or "?"), tostring(character.faction or "?"),
            tostring(character.playedSeconds or "unknown")))
    end
end

