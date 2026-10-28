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

-- Background Warband monitor: avoids a daily player-facing reminder.
-- This is best-effort. Blizzard's bank API does not guarantee usable balances
-- when the account bank is not viewable. Repeated untrusted reads must NEVER
-- overwrite the last verified bank gold or create a historical snapshot.
local BANK_POLL_INTERVAL = 90 -- seconds, low frequency while playing
local monitorStarted = false
local lastBankAttempt = nil
local lastBankSuccess = nil

local function AttemptBankVerification(reason)
    lastBankAttempt = GetTime()
    local verified = VaultSCAN.ScanWarbandWealth()
    if verified then
        lastBankSuccess = GetTime()
        if VaultSCAN.UpdateDailyWealthSnapshot then VaultSCAN.UpdateDailyWealthSnapshot() end
        if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
    end
    return verified
end

local function PollBankIfNeeded()
    -- The day-aware check also makes continuous overnight sessions safe.
    -- Once today's balance is verified, money/bank events refresh it instead.
    if not VaultSCAN.IsWarbandWealthVerified() then
        AttemptBankVerification("background")
    end
    -- Estimated daily observation when the last bank amount is cached.
    -- A later verified scan upgrades today's estimate in place.
    if VaultSCAN.UpdateDailyWealthSnapshot then VaultSCAN.UpdateDailyWealthSnapshot() end
end

local function StartWarbandMonitor()
    if monitorStarted then return end
    monitorStarted = true
    C_Timer.After(5, PollBankIfNeeded)
    C_Timer.NewTicker(BANK_POLL_INTERVAL, PollBankIfNeeded)
end

-- Passive diagnostic command: allows us to test if Blizzard exposes a
-- usable account-bank reading when the bank UI is closed. It never saves it.
local function DebugBankAvailability()
    if not (C_Bank and Enum and Enum.BankType and Enum.BankType.Account ~= nil) then
        print("|cffffd100VaultSCAN:|r Bank API unavailable")
        return
    end
    local bankType = Enum.BankType.Account
    local function Probe(fn)
        if type(fn) ~= "function" then return "missing" end
        local ok, value = pcall(fn, bankType)
        return ok and tostring(value) or "error"
    end
    local canView = Probe(C_Bank.CanViewBank)
    local canUse = Probe(C_Bank.CanUseBank)
    local raw = Probe(C_Bank.FetchDepositedMoney)
    local cached, at = VaultSCAN.GetWarbandWealth()
    print("|cffffd100VaultSCAN bank diagnostic|r (read-only)")
    print("CanViewBank=" .. canView .. "  CanUseBank=" .. canUse)
    print("Raw balance (copper)=" .. raw .. "  Cached (copper)=" .. tostring(cached))
    print("Verified today=" .. tostring(VaultSCAN.IsWarbandWealthVerified())
        .. "  Last saved scan=" .. (type(at) == "number" and date("%Y-%m-%d %H:%M", at) or "never"))
    print("Last attempt=" .. tostring(lastBankAttempt or "none")
        .. "  Last success=" .. tostring(lastBankSuccess or "none"))
    local history = VaultSCANDB and VaultSCANDB.wealthHistory
    local snapshot = type(history) == "table" and history[date("%Y-%m-%d")] or nil
    local status = type(snapshot) == "table" and (snapshot.status or "verified") or "none"
    print("Today's snapshot=" .. status)
end

events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
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
        if VaultSCAN.UpdateDailyWealthSnapshot then VaultSCAN.UpdateDailyWealthSnapshot() end
        C_Timer.After(2, RequestPlayedTime)
        StartWarbandMonitor()
        print("|cffffd100VaultSCAN v1.0.1 DEV:|r Ready. Passive bank verification active.")
    elseif event == "TIME_PLAYED_MSG" then
        local totalSeconds = ...
        VaultSCAN.SavePlayedTime(totalSeconds)
        if VaultSCAN.UpdateDailyWealthSnapshot then VaultSCAN.UpdateDailyWealthSnapshot() end
        if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- The bank API can become available after loading screens / zoning.
        C_Timer.After(8, PollBankIfNeeded)
    elseif event == "ACCOUNT_MONEY" then
        -- Prefer the event over waiting for the next 90-second timer tick.
        AttemptBankVerification("account-money event")
        if VaultSCAN.UpdateDailyWealthSnapshot then VaultSCAN.UpdateDailyWealthSnapshot() end
    elseif event == "BANKFRAME_OPENED" then
        -- Bank visibility may initialize asynchronously. Try twice; only
        -- mark the bank unavailable if both checks fail.
        C_Timer.After(0.5, function()
            if AttemptBankVerification("bank opened") then return end
            C_Timer.After(1.5, function()
                if not AttemptBankVerification("bank initialization retry") then
                    VaultSCAN.MarkWarbandUnavailable()
                    if VaultSCAN.RefreshUI then VaultSCAN.RefreshUI() end
                end
            end)
        end)
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
        if VaultSCAN.UpdateDailyWealthSnapshot then VaultSCAN.UpdateDailyWealthSnapshot() end
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

SLASH_VSBANKDEBUG1 = "/vsbankdebug"
SlashCmdList.VSBANKDEBUG = DebugBankAvailability
