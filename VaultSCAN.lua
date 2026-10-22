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

-- Attempt automatic verification without showing or opening the bank UI.
-- Blizzard may withhold account-bank data outside a viewable bank session;
-- in that case, leave cached money untouched and ask the player once.
StaticPopupDialogs["VAULTSCAN_BANK_VERIFY"] = {
    text = "Warband Bank verification failed. Please open your Warband Bank to verify today's new wealth snapshot.\n\nYour last recorded balance and wealth history are safe.",
    button1 = OKAY,
    button2 = LATER or CANCEL,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function AttemptAutoBankVerification()
    if VaultSCAN.HasTodayWealthSnapshot and VaultSCAN.HasTodayWealthSnapshot() then return true end
    local verified = VaultSCAN.ScanWarbandWealth()
    if verified and VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
    return verified
end

local function CheckDailyBankVerification()
    if AttemptAutoBankVerification() then return end
    -- Allow bank/account data to initialize before reporting a failure.
    C_Timer.After(5, function()
        if AttemptAutoBankVerification() then return end
        if VaultSCAN.ShouldRemindBankVerification and VaultSCAN.ShouldRemindBankVerification() then
            StaticPopup_Show("VAULTSCAN_BANK_VERIFY")
        end
    end)
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
        C_Timer.After(5, CheckDailyBankVerification)
        print("|cffffd100VaultSCAN v0.6.1:|r Ready.")
    elseif event == "TIME_PLAYED_MSG" then
        local totalSeconds = ...
        VaultSCAN.SavePlayedTime(totalSeconds)
        if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
    elseif event == "ACCOUNT_MONEY" or event == "BANKFRAME_OPENED" then
        if event == "BANKFRAME_OPENED" then
            -- The bank's viewable state may initialize slightly after opening.
            -- Never treat an early/unavailable reading as verified zero.
            C_Timer.After(0.5, function()
                if not VaultSCAN.ScanWarbandWealth() then
                    VaultSCAN.MarkWarbandUnavailable()
                end
                if VaultSCAN.IsWarbandWealthVerified() then
                    StaticPopup_Hide("VAULTSCAN_BANK_VERIFY")
                end
                if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
            end)
        else
            -- ACCOUNT_MONEY fires after bank changes; accept only if account
            -- bank visibility can be confirmed by the scanner.
            VaultSCAN.ScanWarbandWealth()
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
