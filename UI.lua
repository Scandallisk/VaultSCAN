local addonName, VaultSCAN = ...

local ROW_HEIGHT = 26
local ROW_BOTTOM_PADDING = 12
local COLUMN_GAP = 18
local COLUMN_ORDER = { "name", "level", "gold", "itemLevel", "played", "lastPlayed", "faction", "realm" }
local COLUMNS = {
    name = { title = "Character", width = 166, align = "LEFT" },
    level = { title = "Level", width = 72, align = "RIGHT" },
    gold = { title = "Gold", width = 90, align = "RIGHT" },
    itemLevel = { title = "iLvl", width = 55, align = "RIGHT" },
    played = { title = "Played", width = 85, align = "RIGHT" },
    lastPlayed = { title = "Last Played", width = 115, align = "LEFT" },
    faction = { title = "Faction", width = 90, align = "LEFT" },
    realm = { title = "Realm", width = 130, align = "LEFT" },
}
local REALM_COLOR = "ffffffff" -- White (#FFFFFF)
local ALLIANCE_COLOR = "ff398bff"
local HORDE_COLOR = "ffe05252"
local UNKNOWN_FACTION_COLOR = "ffaaaaaa"
-- v0.6.1 muted accent colors.
local LAST_PLAYED_COLOR = "ffffffff" -- White (#FFFFFF)
local FOOTER_LABEL_COLOR = { 1, 1, 1 } -- White (#FFFFFF)
local GOLD_VALUE_COLOR = "ffd6c6a4" -- Champagne Gold (#D6C6A4)

local rows, headers = {}, {}
local positions, widths = {}, {}
local sortColumn, sortAscending = "itemLevel", false

-- Skip the cosmetic READ emote when the player uses the Warband Bank spell shortcut.
local suppressReadOnHide = false
local mainFrame = CreateFrame("Frame", "VaultSCANMainFrame", UIParent, "BasicFrameTemplateWithInset")
mainFrame:SetSize(1100, 430)
mainFrame:SetPoint("CENTER")
-- Cover the stock top decoration with an independent, correctly layered header.
-- Do not resize Blizzard's nine-slice textures: they are not a scalable title bar.
mainFrame.TitleBg:Hide()
mainFrame.TitleText:Hide()

-- Blizzard's inset is a separate child frame with its own textured artwork.
-- Hiding only Inset.Bg leaves other dark textures visible above our canvas.
-- Hide the complete decorative inset, then draw an opaque charcoal surface
-- above the template's background artwork and below the UI's child frames.
if mainFrame.Inset then mainFrame.Inset:Hide() end
if mainFrame.Bg then mainFrame.Bg:Hide() end
local darkBackground = mainFrame:CreateTexture(nil, "ARTWORK", nil, 1)
darkBackground:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -4) -- Extend 4px left to cover exposed frame edge
darkBackground:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -4, 4)
darkBackground:SetColorTexture(16 / 255, 16 / 255, 18 / 255, 1)

local titleBar = CreateFrame("Frame", nil, mainFrame)
titleBar:SetFrameLevel(mainFrame:GetFrameLevel() + 10)
titleBar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", -2, 3)
titleBar:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 2, 3)
titleBar:SetHeight(48)

local titleBarBg = titleBar:CreateTexture(nil, "BACKGROUND")
titleBarBg:SetAllPoints()
titleBarBg:SetColorTexture(0, 0, 0, 1) -- Pure black (#000000)

local function HeaderRule(point)
    local line = titleBar:CreateTexture(nil, "BORDER")
    line:SetHeight(1)
    line:SetPoint(point .. "LEFT", titleBar, point .. "LEFT", 0, 0)
    line:SetPoint(point .. "RIGHT", titleBar, point .. "RIGHT", 0, 0)
    line:SetColorTexture(0.45, 0.45, 0.45, 0.85)
end
HeaderRule("TOP")
HeaderRule("BOTTOM")

local titleLabel = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleLabel:SetPoint("LEFT", titleBar, "LEFT", 54, 0)
titleLabel:SetJustifyH("LEFT")
titleLabel:SetText("VaultSCAN")
titleLabel:SetTextColor(1, 1, 1, 1)

-- Keep Blizzard's functioning close button, but place it above the header layer.
mainFrame.CloseButton:SetParent(titleBar)
mainFrame.CloseButton:SetFrameLevel(titleBar:GetFrameLevel() + 2)
mainFrame.CloseButton:ClearAllPoints()
mainFrame.CloseButton:SetSize(36, 36)
mainFrame.CloseButton:SetPoint("RIGHT", titleBar, "RIGHT", -7, 0)
-- The template close handler hides the button's parent (now titleBar).
-- Always close the full addon window instead.
mainFrame.CloseButton:SetScript("OnClick", function()
    mainFrame:Hide()
end)

-- A circular, 20%-smaller coin, vertically centered within the title bar.
-- The slightly larger masked gold disc creates a clean circular border.
local titleCoin = CreateFrame("Button", nil, titleBar)
titleCoin:SetSize(38.4, 38.4)
titleCoin:SetFrameLevel(titleBar:GetFrameLevel() + 3)
titleCoin:SetPoint("LEFT", titleBar, "LEFT", 8, 0)

local coinBorder = titleCoin:CreateTexture(nil, "ARTWORK")
coinBorder:SetAllPoints()
coinBorder:SetColorTexture(0.88, 0.67, 0.24, 1)
local borderMask = titleCoin:CreateMaskTexture()
borderMask:SetAllPoints(coinBorder)
borderMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
coinBorder:AddMaskTexture(borderMask)

local titleCoinTexture = titleCoin:CreateTexture(nil, "OVERLAY")
titleCoinTexture:SetPoint("TOPLEFT", titleCoin, "TOPLEFT", 2, -2)
titleCoinTexture:SetPoint("BOTTOMRIGHT", titleCoin, "BOTTOMRIGHT", -2, 2)
titleCoinTexture:SetTexture("Interface\\Icons\\spell_progenitor_orb2")
local titleCoinMask = titleCoin:CreateMaskTexture()
titleCoinMask:SetAllPoints(titleCoinTexture)
titleCoinMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
titleCoinTexture:AddMaskTexture(titleCoinMask)
titleCoin:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
    GameTooltip:AddLine("VaultSCAN", 1, 0.82, 0)
    GameTooltip:AddLine("Author: SCAN", 1, 1, 1)
    GameTooltip:AddLine("Version 1.0.1 DEV", 0.75, 0.75, 0.75)
    GameTooltip:Show()
end)
titleCoin:SetScript("OnLeave", function() GameTooltip:Hide() end)
mainFrame:SetMovable(true)
mainFrame:SetResizable(true)
mainFrame:SetResizeBounds(1050, 400)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
mainFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

local scrollFrame = CreateFrame("ScrollFrame", "VaultSCANScrollFrame", mainFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 20, -110)
scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -45, 142)
local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(1, 1)
scrollFrame:SetScrollChild(scrollChild)

local function FormatPlayed(seconds)
    if type(seconds) ~= "number" then return "—" end
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    if days > 0 then return string.format("%dd %dh", days, hours) end
    if hours > 0 then return string.format("%dh %dm", hours, minutes) end
    return string.format("%dm", minutes)
end

local function UpdateColumnLayout()
    local available = math.max(1, scrollFrame:GetWidth() - 10)
    local base = 0
    for _, column in ipairs(COLUMN_ORDER) do base = base + COLUMNS[column].width end
    local extra = math.max(0, available - base - COLUMN_GAP * (#COLUMN_ORDER - 1))
    local x = 0
    for _, column in ipairs(COLUMN_ORDER) do
        positions[column] = x
        widths[column] = COLUMNS[column].width + extra * (COLUMNS[column].width / base)
        x = x + widths[column] + COLUMN_GAP
    end
    scrollChild:SetWidth(math.max(1, x - COLUMN_GAP))
    for _, column in ipairs(COLUMN_ORDER) do
        local header = headers[column]
        if header then
            header:ClearAllPoints()
            local headerX = positions[column]
            if column == "name" then headerX = headerX + 40
            elseif column == "level" then headerX = 180 end
            header:SetPoint("BOTTOMLEFT", scrollFrame, "TOPLEFT", headerX, 16)
            header:SetWidth(widths[column])
        end
    end
    for index, row in ipairs(rows) do
        for _, column in ipairs(COLUMN_ORDER) do
            local field = row[column]
            field:ClearAllPoints()
            local fieldX = positions[column] + (column == "name" and 40 or 0)
            if column == "level" then fieldX = 180 end
            field:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", fieldX, -(index - 1) * ROW_HEIGHT)
            field:SetWidth(widths[column] - (column == "name" and 40 or 0))
        end
        row.icon:ClearAllPoints()
        row.icon:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", positions.name + 19, -(index - 1) * ROW_HEIGHT + 3)
        row.historyButton:ClearAllPoints()
        row.historyButton:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", positions.itemLevel, -(index - 1) * ROW_HEIGHT)
        row.historyButton:SetSize(widths.itemLevel, ROW_HEIGHT - 2)
        row.delete:ClearAllPoints()
        row.delete:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", positions.name, -(index - 1) * ROW_HEIGHT + 3)
    end
end

local function UpdateHeaderLabels()
    for _, column in ipairs(COLUMN_ORDER) do
        local header = headers[column]
        header.label:SetText(COLUMNS[column].title)
        if column == sortColumn then
            header.arrow:Show()
            if sortAscending then header.arrow:SetTexCoord(0, 1, 1, 0)
            else header.arrow:SetTexCoord(0, 1, 0, 1) end
        else
            header.arrow:Hide()
        end
    end
end

local function SortCharacters(characters)
    table.sort(characters, function(a, b)
        local valueA, valueB
        if sortColumn == "level" then
            valueA = type(a.level) == "number" and a.level or -1
            valueB = type(b.level) == "number" and b.level or -1
        elseif sortColumn == "gold" then
            valueA, valueB = a.copper or 0, b.copper or 0
        elseif sortColumn == "itemLevel" then
            valueA = type(a.itemLevel) == "number" and a.itemLevel or -1
            valueB = type(b.itemLevel) == "number" and b.itemLevel or -1
        elseif sortColumn == "lastPlayed" then
            valueA = type(a.lastPlayed) == "number" and a.lastPlayed or -1
            valueB = type(b.lastPlayed) == "number" and b.lastPlayed or -1
        elseif sortColumn == "played" then
            valueA = type(a.playedSeconds) == "number" and a.playedSeconds or -1
            valueB = type(b.playedSeconds) == "number" and b.playedSeconds or -1
        else
            valueA = string.lower(a[sortColumn] or "")
            valueB = string.lower(b[sortColumn] or "")
        end
        if valueA ~= valueB then
            if sortAscending then return valueA < valueB end
            return valueA > valueB
        end
        if a.realm ~= b.realm then return a.realm < b.realm end
        return a.name < b.name
    end)
end

local function SetSortColumn(column)
    if sortColumn == column then
        sortAscending = not sortAscending
    else
        sortColumn = column
        sortAscending = column == "name" or column == "realm" or column == "faction"
    end
    UpdateHeaderLabels()
    VaultSCAN.RefreshUI()
end

for _, column in ipairs(COLUMN_ORDER) do
    local button = CreateFrame("Button", nil, mainFrame)
    button:SetHeight(24)
    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    label:SetPoint("LEFT", button, "LEFT", 0, 0)
    label:SetPoint("RIGHT", button, "RIGHT", 0, 0)
    label:SetJustifyH("LEFT")
    label:SetTextColor(1, 1, 1, 1)
    label:SetWordWrap(false)
    local arrow = button:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture("Interface\\Buttons\\UI-SortArrow")
    arrow:SetVertexColor(1, 1, 1, 1)
    arrow:SetSize(12, 12)
    arrow:SetPoint("LEFT", button, "LEFT")
    button.label, button.arrow = label, arrow
    headers[column] = button
    local selected = column
    button:SetScript("OnClick", function() SetSortColumn(selected) end)
end
UpdateHeaderLabels()

-- Fixed header rule, outside the scrolling content.
local columnDivider = mainFrame:CreateTexture(nil, "ARTWORK", nil, 2) -- Above charcoal background (sublevel 1)
columnDivider:SetColorTexture(0, 0, 0, 1) -- Black #000000
columnDivider:SetHeight(1)
columnDivider:SetPoint("BOTTOMLEFT", scrollFrame, "TOPLEFT", 0, 8)
columnDivider:SetPoint("BOTTOMRIGHT", scrollFrame, "TOPRIGHT", 0, 8)

local FOOTER_STATS_WIDTH = 300 -- Width of the left footer stats area

local divider = mainFrame:CreateTexture(nil, "ARTWORK", nil, 2)
divider:SetColorTexture(0, 0, 0, 1) -- Black #000000
divider:SetHeight(1)
divider:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 20, 126)
divider:SetWidth(FOOTER_STATS_WIDTH)

local footerLabels = {}
local footerValues = {}
local footerStatus = {}
local footerFields = {
    { key = "character", title = "Character Gold", icon = "Interface\\Icons\\inv_ore_gold_nugget" },
    { key = "warband", title = "Warband Gold", icon = "Interface\\Icons\\inv_ore_gold_01" },
    { key = "total", title = "Total Wealth", icon = "Interface\\Icons\\inv_misc_coin_02" },
    { key = "played", title = "Total Played Time", icon = "Interface\\Icons\\spell_holy_borrowedtime" },
}
for i, field in ipairs(footerFields) do
    local offset = (i <= 2) and (-8 - (i - 1) * 25) or (-66 - (i - 3) * 25)
    local icon = mainFrame:CreateTexture(nil, "OVERLAY")
    icon:SetSize(16, 16)
    icon:SetTexture(field.icon)
    icon:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, offset + 2)

    local label = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 24, offset)
    label:SetText(field.title)
    label:SetTextColor(unpack(FOOTER_LABEL_COLOR))

    local value = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    value:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 180, offset)
    value:SetJustifyH("LEFT")
    value:SetTextColor(214 / 255, 198 / 255, 164 / 255, 1)
    footerLabels[field.key], footerValues[field.key] = label, value
    if field.key == "warband" or field.key == "total" then
        local status = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        status:SetPoint("LEFT", value, "RIGHT", 5, 0)
        status:SetTextColor(0.67, 0.67, 0.67, 1)
        status:Hide()
        footerStatus[field.key] = status
    end
end

-- A second fixed rule groups Character/Warband Gold above the totals.
-- Anchor it to the existing footer divider so it follows frame resizing.
local wealthDivider = mainFrame:CreateTexture(nil, "ARTWORK", nil, 2) -- Above charcoal background (sublevel 1)
wealthDivider:SetColorTexture(0, 0, 0, 1) -- Black #000000
wealthDivider:SetHeight(1)
wealthDivider:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, -57)
wealthDivider:SetPoint("TOPRIGHT", divider, "BOTTOMRIGHT", 0, -57)

-- Account Wealth Trend: account-wide daily snapshots in the existing right footer.
-- Existing snapshots are read without modifying SavedVariables or changing collection rules.
local trendPanel = CreateFrame("Frame", nil, mainFrame)
trendPanel:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 365, -6)
trendPanel:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -32, 15)

local trendTitle = trendPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
trendTitle:SetPoint("TOPLEFT", trendPanel, "TOPLEFT", 0, 0)
trendTitle:SetText("ACCOUNT WEALTH TREND")
trendTitle:SetTextColor(1, 1, 1)

-- Optional Warband Bank Distance Inhibitor shortcut, beside the graph title.
-- Spell 460905 is the summon effect; 465226 is the quest reward/dummy spell.
-- InsecureActionButtonTemplate supports player-triggered actions out of combat
-- without making the full resizable dashboard a protected frame.
local BANK_PORTAL_SPELL = 460905
local BANK_PORTAL_REWARD = 465226 -- alternate quest-granted spell entry
local BANK_PORTAL_ICON = "Interface\\Icons\\inv_cosmicvoid_orb"

local function PlayerKnowsBankPortal()
    -- The quest reward (465226) is a dummy effect; it cannot summon the bank.
    -- Detect the actual summon spell to avoid showing an unusable button as ready.
    if C_SpellBook and type(C_SpellBook.IsSpellKnown) == "function" then
        local ok, known = pcall(C_SpellBook.IsSpellKnown, BANK_PORTAL_SPELL)
        if ok and known == true then return true end
    end
    if type(IsPlayerSpell) == "function" then
        local ok, known = pcall(IsPlayerSpell, BANK_PORTAL_SPELL)
        if ok and known == true then return true end
    end
    return false
end

local function PortalCooldownRemaining()
    if not (C_Spell and type(C_Spell.GetSpellCooldown) == "function") then return nil end
    local ok, info = pcall(C_Spell.GetSpellCooldown, BANK_PORTAL_SPELL)
    if not ok or type(info) ~= "table" or type(info.startTime) ~= "number"
        or type(info.duration) ~= "number" then return nil end
    return math.max(0, (info.startTime + info.duration) - GetTime())
end

local function PortalIsUsable()
    if C_Spell and type(C_Spell.IsSpellUsable) == "function" then
        local ok, usable = pcall(C_Spell.IsSpellUsable, BANK_PORTAL_SPELL)
        if ok and usable == false then return false end
    end
    return true
end

local portalButton = CreateFrame("Button", "VaultSCANBankPortalButton", trendPanel, "InsecureActionButtonTemplate")
portalButton:SetSize(20, 20)
portalButton:SetPoint("LEFT", trendTitle, "RIGHT", 10, 0)
portalButton:RegisterForClicks("AnyUp", "AnyDown")
portalButton:SetAttribute("useOnKeyDown", false)
local portalSpellName = "Warband Bank Distance Inhibitor"
if C_Spell and type(C_Spell.GetSpellInfo) == "function" then
    local ok, info = pcall(C_Spell.GetSpellInfo, BANK_PORTAL_SPELL)
    if ok and type(info) == "table" then
        portalSpellName = info.name or portalSpellName
        BANK_PORTAL_ICON = info.iconID or BANK_PORTAL_ICON
    end
end
-- Canonical secure-button attributes: pass the actual casting spell ID.
-- Unlike the quest reward 465226, 460905 summons the bank portal.
portalButton:SetAttribute("spell", BANK_PORTAL_SPELL)
portalButton:SetAttribute("type", nil) -- enabled after checking the learned summon spell
local portalTexture = portalButton:CreateTexture(nil, "ARTWORK")
portalTexture:SetAllPoints()
portalTexture:SetTexture(BANK_PORTAL_ICON)
local portalBorder = portalButton:CreateTexture(nil, "OVERLAY")
portalBorder:SetPoint("TOPLEFT", portalButton, "TOPLEFT", -1, 1)
portalBorder:SetPoint("BOTTOMRIGHT", portalButton, "BOTTOMRIGHT", 1, -1)
portalBorder:SetTexture("Interface\\Buttons\\UI-Quickslot2")

local function UpdatePortalButton()
    local known = PlayerKnowsBankPortal()
    if not InCombatLockdown() then
        portalButton:SetAttribute("type", known and "spell" or nil)
    end
    local ready = known and not InCombatLockdown() and PortalIsUsable()
    local remaining = ready and PortalCooldownRemaining() or nil
    if remaining and remaining > 0 then ready = false end
    portalTexture:SetVertexColor(ready and 1 or 0.55, ready and 1 or 0.55, ready and 1 or 0.55)
end

portalButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddLine("Warband Bank Distance Inhibitor", 1, 0.82, 0)
    if not PlayerKnowsBankPortal() then
        GameTooltip:AddLine("Unavailable: this account has not unlocked the Warband Bank portal spell.", 1, 0.75, 0.45, true)
    elseif InCombatLockdown() then
        GameTooltip:AddLine("Cannot summon your Warband Bank during combat.", 1, 0.75, 0.45, true)
    else
        local remaining = PortalCooldownRemaining()
        if remaining and remaining > 0 then
            GameTooltip:AddLine(string.format("On cooldown: about %d minutes remaining.", math.ceil(remaining / 60)), 1, 0.75, 0.45, true)
        elseif not PortalIsUsable() then
            GameTooltip:AddLine("This ability cannot be used at your current location.", 1, 0.75, 0.45, true)
        else
            GameTooltip:AddLine("Click to summon your Warband Bank portal.", 1, 1, 1, true)
            GameTooltip:AddLine("VaultSCAN closes so you can see the cast and interact with the bank.", 0.8, 0.8, 0.8, true)
        end
    end
    GameTooltip:AddLine("Optional: your history continues even without a verified bank visit.", 0.7, 0.7, 0.7, true)
    GameTooltip:Show()
end)
portalButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- A quiet, inline prompt beside the portal spell. Keep the long explanation
-- behind the gold information icon, not in the wealth graph's general tooltip.
local portalPrompt = trendPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
portalPrompt:SetPoint("LEFT", portalButton, "RIGHT", 7, 0)
portalPrompt:SetJustifyH("LEFT")
portalPrompt:SetWordWrap(false)
portalPrompt:SetText("Open your Warband Bank to update your snapshot")
portalPrompt:SetTextColor(0.77, 0.77, 0.77, 1)

local bankInfoButton = CreateFrame("Button", nil, trendPanel)
bankInfoButton:SetSize(16, 16)
bankInfoButton:SetPoint("LEFT", portalPrompt, "RIGHT", 6, 0)
bankInfoButton:SetFrameLevel(trendPanel:GetFrameLevel() + 2)

-- Draw a small gold circular information icon without changing theme assets.
local infoDisc = bankInfoButton:CreateTexture(nil, "ARTWORK")
infoDisc:SetAllPoints()
infoDisc:SetColorTexture(214 / 255, 198 / 255, 164 / 255, 1)
local infoMask = bankInfoButton:CreateMaskTexture()
infoMask:SetAllPoints(infoDisc)
infoMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
infoDisc:AddMaskTexture(infoMask)
local infoGlyph = bankInfoButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
infoGlyph:SetPoint("CENTER", bankInfoButton, "CENTER", 0, 0)
infoGlyph:SetText("i")
infoGlyph:SetTextColor(0.06, 0.06, 0.07, 1)

bankInfoButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddLine("Warband Bank Verification", 1, 0.82, 0)
    GameTooltip:AddLine("Limitation - Warcraft does not permit Warband Bank data to be verified automatically.", 1, 0.8, 0.5, true)
    GameTooltip:AddLine("When the bank is not viewable, VaultSCAN uses the last verified Warband balance and labels the snapshot as estimated.", 0.85, 0.85, 0.85, true)
    GameTooltip:AddLine("Use the adjacent shortcut to summon your Warband Bank if you've unlocked the ability. Open the bank to verify today's snapshot.", 0.8, 0.8, 0.8, true)
    GameTooltip:AddLine("You can keep playing without visiting a bank.", 0.7, 0.7, 0.7, true)
    GameTooltip:Show()
end)
bankInfoButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
-- Never close the dashboard merely because a click occurred. A button click
-- can fail silently due to a protected-action restriction, cooldown, etc.
-- Keep the dashboard up until WoW confirms that the summon cast actually began.
local portalCastPending = false
local portalCastToken = 0
local lastPortalEvent = "none"
portalButton:HookScript("PreClick", function(self, button, down)
    -- The secure template uses useOnKeyDown=false; respond to the release only.
    if button ~= "LeftButton" or down then return end
    local remaining = PortalCooldownRemaining()
    if not (PlayerKnowsBankPortal() and not InCombatLockdown()
        and (remaining == nil or remaining <= 0) and PortalIsUsable()) then
        portalCastPending = false
        return
    end
    portalCastPending = true
    portalCastToken = portalCastToken + 1
    local token = portalCastToken
    -- Allow for event delivery; if no cast starts, keep the dashboard open.
    C_Timer.After(2, function()
        if portalCastPending and portalCastToken == token then
            portalCastPending = false
            print("|cffffd100VaultSCAN:|r The Warband Bank spell did not start. "
                .. "Try |cffffffff/cast Warband Bank Distance Inhibitor|r "
                .. "to verify the spell works normally. Use /vsportaldebug for details.")
            UpdatePortalButton()
        end
    end)
end)
local portalCastEvents = CreateFrame("Frame")
portalCastEvents:RegisterEvent("UNIT_SPELLCAST_START")
portalCastEvents:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
portalCastEvents:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
portalCastEvents:SetScript("OnEvent", function(_, event, unit, _, spellID)
    if unit ~= "player" or (spellID ~= BANK_PORTAL_SPELL and spellID ~= BANK_PORTAL_REWARD) then return end
    lastPortalEvent = event
    if not portalCastPending then return end
    portalCastPending = false
    GameTooltip:Hide()
    if mainFrame:IsShown() then
        -- The emote played on opening can linger; never trigger another one here.
        suppressReadOnHide = true
        mainFrame:Hide()
    end
    UpdatePortalButton()
end)
SLASH_VSPORTALDEBUG1 = "/vsportaldebug"
SlashCmdList.VSPORTALDEBUG = function()
    local learnedSummon = PlayerKnowsBankPortal()
    local learnedReward = false
    if C_SpellBook and type(C_SpellBook.IsSpellKnown) == "function" then
        local ok, result = pcall(C_SpellBook.IsSpellKnown, BANK_PORTAL_REWARD)
        learnedReward = ok and result == true
    end
    local remaining = PortalCooldownRemaining()
    print("|cffffd100VaultSCAN portal diagnostic:|r")
    print("Summon spell (460905) learned=" .. tostring(learnedSummon)
        .. " | Quest reward (465226) learned=" .. tostring(learnedReward))
    print("Button type=" .. tostring(portalButton:GetAttribute("type"))
        .. " | spell=" .. tostring(portalButton:GetAttribute("spell"))
        .. " | usable=" .. tostring(PortalIsUsable()))
    print("Cooldown=" .. tostring(remaining) .. " | pending=" .. tostring(portalCastPending)
        .. " | last cast event=" .. lastPortalEvent)
end
local portalEvents = CreateFrame("Frame")
portalEvents:RegisterEvent("SPELLS_CHANGED")
portalEvents:RegisterEvent("SPELL_UPDATE_COOLDOWN")
portalEvents:RegisterEvent("PLAYER_LOGIN")
portalEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
portalEvents:RegisterEvent("PLAYER_REGEN_DISABLED")
portalEvents:SetScript("OnEvent", UpdatePortalButton)
mainFrame:HookScript("OnShow", UpdatePortalButton)
UpdatePortalButton()

local trendChange = trendPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
trendChange:SetPoint("TOPRIGHT", trendPanel, "TOPRIGHT", 0, 0)
trendChange:SetWidth(260)
trendChange:SetJustifyH("RIGHT")

local trendCaption = trendPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
trendCaption:SetPoint("BOTTOMLEFT", trendPanel, "BOTTOMLEFT", 0, 0)
trendCaption:SetTextColor(0.65, 0.65, 0.65)

local trendStart = trendPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
trendStart:SetPoint("BOTTOMLEFT", trendPanel, "BOTTOMLEFT", 0, 15)
trendStart:SetTextColor(0.82, 0.82, 0.82)

local trendCurrent = trendPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
trendCurrent:SetPoint("BOTTOMRIGHT", trendPanel, "BOTTOMRIGHT", 0, 15)
trendCurrent:SetJustifyH("RIGHT")
trendCurrent:SetTextColor(0.82, 0.82, 0.82)

local trendGraph = CreateFrame("Frame", nil, trendPanel)
trendGraph:SetPoint("TOPLEFT", trendPanel, "TOPLEFT", 6, -24)
trendGraph:SetPoint("BOTTOMRIGHT", trendPanel, "BOTTOMRIGHT", -6, 33)

local GOLD_R, GOLD_G, GOLD_B = 214 / 255, 198 / 255, 164 / 255
local graphLines, graphDots = {}, {}
local function MakeLine()
    local line = trendGraph:CreateTexture(nil, "ARTWORK")
    graphLines[#graphLines + 1] = line
    return line
end

local function DrawTrendLine(line, x1, y1, x2, y2, r, g, b)
    local dx, dy = x2 - x1, y2 - y1
    local length = math.sqrt(dx * dx + dy * dy)
    if length < 0.01 then line:Hide(); return end
    line:ClearAllPoints()
    line:SetPoint("CENTER", trendGraph, "BOTTOMLEFT", (x1 + x2) / 2, (y1 + y2) / 2)
    line:SetSize(length, 2)
    line:SetColorTexture(r, g, b, 1)
    line:SetRotation(math.atan2(dy, dx))
    line:Show()
end

local function FormatWealth(copper)
    return BreakUpLargeNumbers(math.floor(copper / 10000 + 0.5)) .. "g"
end

local function MakeDot()
    local dot = CreateFrame("Button", nil, trendGraph)
    dot:SetSize(14, 14)
    dot:EnableMouse(true)
    local point = dot:CreateTexture(nil, "OVERLAY")
    point:SetSize(5, 5)
    point:SetPoint("CENTER")
    point:SetColorTexture(GOLD_R, GOLD_G, GOLD_B, 1)
    dot.point = point
    local hollow = dot:CreateTexture(nil, "OVERLAY")
    hollow:SetSize(3, 3)
    hollow:SetPoint("CENTER")
    hollow:SetColorTexture(16 / 255, 16 / 255, 18 / 255, 1)
    hollow:Hide()
    dot.hollow = hollow
    dot:SetScript("OnEnter", function(self)
        local item = self.snapshot
        if not item then return end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(date("%b %d, %Y", item.at), 1, 0.82, 0)
        GameTooltip:AddDoubleLine("Recorded wealth", FormatWealth(item.copper), 1, 1, 1, 1, 1, 1)
        local estimated = item.status == "estimated"
        GameTooltip:AddDoubleLine("Snapshot status", estimated and "Estimated" or "Verified", 1, 1, 1,
            estimated and 0.8 or 0.65, estimated and 0.8 or 0.9, estimated and 0.8 or 0.65)
        if estimated then
            GameTooltip:AddLine("This observation uses the last verified bank balance and saved character gold.", 0.7, 0.7, 0.7, true)
        end
        if self.previous then
            local change = item.copper - self.previous.copper
            local delta = math.floor(math.abs(change) / 10000 + 0.5)
            local prefix = change > 0 and "+" or change < 0 and "-" or ""
            GameTooltip:AddDoubleLine("Since previous snapshot", prefix .. BreakUpLargeNumbers(delta) .. "g", 0.75, 0.75, 0.75, 1, 1, 1)
        end
        local validation = trendPanel.wealthValidation
        if validation and validation.snapshot and validation.snapshot.at == item.at then
            if validation.liveCopper then
                GameTooltip:AddDoubleLine("Verified live wealth", FormatWealth(validation.liveCopper), 0.8, 0.8, 0.8, 1, 1, 1)
                if validation.deltaCopper ~= 0 then
                    GameTooltip:AddLine("Live wealth can differ from the first snapshot recorded today.", 0.7, 0.7, 0.7, true)
                end
            elseif not validation.verified then
                GameTooltip:AddLine("No bank verification this session; estimates use the last confirmed bank balance.", 1, 0.75, 0.45, true)
            end
        end
        GameTooltip:AddLine("Offline characters use their last saved balances.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
        self.point:SetSize(8, 8)
    end)
    dot:SetScript("OnLeave", function(self)
        self.point:SetSize(5, 5)
        GameTooltip:Hide()
    end)
    graphDots[#graphDots + 1] = dot
    return dot
end

local function RenderWealthTrend()
    for _, line in ipairs(graphLines) do line:Hide() end
    for _, dot in ipairs(graphDots) do dot:Hide() end
    local history = VaultSCAN.GetWealthHistory and VaultSCAN.GetWealthHistory(30) or {}
    local count = #history
    trendStart:SetText("")
    trendCurrent:SetText("")
    if count == 0 then
        trendChange:SetTextColor(GOLD_R, GOLD_G, GOLD_B)
        trendChange:SetText("Collecting wealth history...")
        trendCaption:SetText("No snapshots recorded yet")
        return
    end
    if count == 1 then
        trendChange:SetTextColor(GOLD_R, GOLD_G, GOLD_B)
        trendChange:SetText("Waiting for next daily snapshot")
        trendCaption:SetText("1 day tracked" .. (history[1].status == "estimated" and " | Estimated" or " | Verified"))
        trendStart:SetText("Recorded: " .. FormatWealth(history[1].copper))
        return
    end

    local first, last = history[1], history[count]
    local diffCopper = last.copper - first.copper
    local diffGold = math.floor(math.abs(diffCopper) / 10000 + 0.5)
    local r, g, b = GOLD_R, GOLD_G, GOLD_B
    if diffCopper > 0 then r, g, b = 0.56, 0.83, 0.63
    elseif diffCopper < 0 then r, g, b = 0.92, 0.50, 0.50 end
    trendChange:SetTextColor(r, g, b)
    local prefix = diffCopper > 0 and "+" or diffCopper < 0 and "-" or ""
    local percentage = first.copper > 0 and (math.abs(diffCopper) / first.copper * 100) or nil
    local suffix = percentage and string.format(" (%.1f%%)", percentage) or ""
    local includesEstimate = first.status == "estimated" or last.status == "estimated"
    trendChange:SetText(prefix .. BreakUpLargeNumbers(diffGold) .. "g" .. suffix
        .. (includesEstimate and " (est.)" or ""))
    trendStart:SetText("Start: " .. FormatWealth(first.copper))
    trendCurrent:SetText("Last snapshot: " .. FormatWealth(last.copper)
        .. (last.status == "estimated" and " (estimated)" or ""))

    -- Calendar span between the recorded snapshots; never imply unrecorded days have data.
    local elapsedDays = math.max(1, math.floor((last.at - first.at) / 86400 + 0.5) + 1)
    trendCaption:SetText(string.format("%d days covered | %d snapshots", elapsedDays, count))

    local minCopper, maxCopper = first.copper, first.copper
    for _, entry in ipairs(history) do
        minCopper = math.min(minCopper, entry.copper)
        maxCopper = math.max(maxCopper, entry.copper)
    end
    local w, h = trendGraph:GetWidth(), trendGraph:GetHeight()
    if w <= 1 or h <= 1 then return end
    local pad = 5
    local span = maxCopper - minCopper
    local tspan = math.max(1, last.at - first.at)
    local points = {}
    for i, entry in ipairs(history) do
        points[i] = {
            x = pad + (entry.at - first.at) / tspan * math.max(1, w - pad * 2),
            y = span == 0 and h / 2 or pad + (entry.copper - minCopper) / span * math.max(1, h - pad * 2),
        }
    end
    -- Use time-proportional x coordinates, preserving gaps for days without snapshots.
    for i = 2, count do
        local line = graphLines[i - 1] or MakeLine()
        DrawTrendLine(line, points[i - 1].x, points[i - 1].y, points[i].x, points[i].y, r, g, b)
    end
    for i = 1, count do
        local dot = graphDots[i] or MakeDot()
        dot:ClearAllPoints()
        dot:SetPoint("CENTER", trendGraph, "BOTTOMLEFT", points[i].x, points[i].y)
        dot.point:SetColorTexture(r, g, b, 1)
        -- Hollow markers indicate estimates; filled markers are verified.
        dot.hollow:SetShown(history[i].status == "estimated")
        dot.snapshot = history[i]
        dot.previous = history[i - 1]
        dot:Show()
    end
end
trendGraph:SetScript("OnSizeChanged", RenderWealthTrend)
trendPanel:EnableMouse(true)
trendPanel:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddLine("Account Wealth Trend", 1, 0.82, 0)
    GameTooltip:AddLine("Daily snapshots are recorded automatically using the latest available balances.", 1, 1, 1, true)
    GameTooltip:AddLine("Filled markers = verified. Hollow markers = estimated.", 0.75, 0.75, 0.75, true)
    local state = trendPanel.wealthValidation
    if state and state.snapshot then
        GameTooltip:AddDoubleLine("Latest saved snapshot", date("%b %d, %Y %I:%M %p", state.snapshot.at), 1, 1, 1, 0.82, 0.82, 0.82)
        GameTooltip:AddDoubleLine("Snapshot status", state.snapshotStatus == "estimated" and "Estimated" or "Verified", 1, 1, 1, 0.82, 0.82, 0.82)
    end
    if state and state.liveCopper then
        GameTooltip:AddDoubleLine("Verified live wealth", FormatWealth(state.liveCopper), 1, 1, 1, 1, 1, 1)
        if state.deltaCopper and state.deltaCopper ~= 0 then
            local absGold = math.floor(math.abs(state.deltaCopper) / 10000 + 0.5)
            local sign = state.deltaCopper > 0 and "+" or "-"
            GameTooltip:AddDoubleLine("Since today's snapshot", sign .. BreakUpLargeNumbers(absGold) .. "g", 0.75, 0.75, 0.75, 1, 1, 1)
            GameTooltip:AddLine("The graph stores the first verified balance each day; live totals may change afterward.", 0.7, 0.7, 0.7, true)
        end
    end
    GameTooltip:AddLine("Hover over a graph point for its date and value.", 0.75, 0.75, 0.75, true)
    GameTooltip:Show()
end)
trendPanel:SetScript("OnLeave", function() GameTooltip:Hide() end)

local resize = CreateFrame("Button", nil, mainFrame)
resize:SetSize(20, 20)
resize:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -5, 5)
resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resize:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resize:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
resize:SetScript("OnMouseDown", function(_, button)
    if button == "LeftButton" then mainFrame:StartSizing("BOTTOMRIGHT") end
end)
resize:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then mainFrame:StopMovingOrSizing() end
end)

StaticPopupDialogs["VAULTSCAN_DELETE_CHARACTER"] = {
    text = "Remove %s from VaultSCAN? This deletes only the saved tracking data, not the WoW character.",
    button1 = YES,
    button2 = NO,
    OnAccept = function(_, data)
        if data then VaultSCAN.DeleteCharacter(data.realm, data.name) end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function ClassColor(class)
    local color = class and RAID_CLASS_COLORS[class]
    return color and color.colorStr or "ffffffff"
end

local function FactionColor(faction)
    if faction == "Alliance" then return ALLIANCE_COLOR end
    if faction == "Horde" then return HORDE_COLOR end
    return UNKNOWN_FACTION_COLOR
end

local function CreateRow(index)
    local row = {}
    for _, column in ipairs(COLUMN_ORDER) do
        local field = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        field:SetJustifyH("LEFT")
        field:SetWordWrap(false)
        field:SetTextColor(1, 1, 1, 1)

        -- Increase character name font size only.
        if column == "name" then
            local font, _, flags = field:GetFont()
            field:SetFont(font, 14, flags)
        end

        row[column] = field
    end
    local delete = CreateFrame("Button", nil, scrollChild)
    delete:SetSize(15, 15)
    local label = delete:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetAllPoints()
    label:SetText("|cffff5555×|r")
    delete:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Remove character from VaultSCAN")
        GameTooltip:Show()
    end)
    delete:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.delete = delete
    local classIcon = scrollChild:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(16, 16)
    classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
    row.icon = classIcon
    local historyButton = CreateFrame("Button", nil, scrollChild)
    row.historyButton = historyButton
    rows[index] = row
    UpdateColumnLayout()
    return row
end

function VaultSCAN.RefreshUI()
    local characters = VaultSCAN.GetAllCharacters()
    SortCharacters(characters)
    local totalCopper, totalSeconds, knownPlayed = 0, 0, 0
    for _, row in ipairs(rows) do
        for _, column in ipairs(COLUMN_ORDER) do row[column]:Hide() end
        row.delete:Hide()
        row.icon:Hide()
        row.historyButton:Hide()
    end
    for index, character in ipairs(characters) do
        local row = rows[index] or CreateRow(index)
        local classColor = ClassColor(character.class)
        row.name:SetText("|c" .. classColor .. character.name .. "|r")
        local coords = character.class and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[character.class]
        if coords then
            row.icon:SetTexCoord(unpack(coords))
            row.icon:Show()
        else
            row.icon:Hide()
        end
        row.level:SetText(type(character.level) == "number"
            and ("|cffffffff" .. tostring(character.level) .. "|r") or "—")
        row.gold:SetText("|c" .. GOLD_VALUE_COLOR .. BreakUpLargeNumbers(math.floor(character.copper / 10000)) .. "|r")
        if type(character.itemLevel) == "number" then
            row.itemLevel:SetText("|cffffffff" .. math.floor(character.itemLevel + 0.5) .. "|r")
        else
            row.itemLevel:SetText("—")
        end
        row.played:SetText("|cffffffff" .. FormatPlayed(character.playedSeconds) .. "|r")
        local lastPlayedText = type(character.lastPlayed) == "number"
            and date("%b %d, %Y", character.lastPlayed) or "—"
        row.lastPlayed:SetText("|c" .. LAST_PLAYED_COLOR .. lastPlayedText .. "|r")
        local history = character.history
        row.historyButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(character.name .. " — Weekly iLvl", 1, 0.82, 0)
            local entries = {}
            if type(history) == "table" then
                for _, entry in pairs(history) do
                    if type(entry) == "table" and type(entry.at) == "number"
                        and type(entry.itemLevel) == "number" then
                        entries[#entries + 1] = entry
                    end
                end
            end
            table.sort(entries, function(a, b) return a.at > b.at end)
            if #entries == 0 then
                GameTooltip:AddLine("No weekly snapshots yet.", 0.8, 0.8, 0.8)
            else
                for i = 1, math.min(12, #entries) do
                    local entry = entries[i]
                    GameTooltip:AddDoubleLine(date("%b %d, %Y", entry.at),
                        string.format("%.1f", entry.itemLevel), 1, 1, 1, 1, 0.82, 0)
                end
                if #entries > 12 then
                    GameTooltip:AddLine("Showing the latest 12 of " .. #entries .. " weeks", 0.7, 0.7, 0.7)
                end
            end
            GameTooltip:Show()
        end)
        row.historyButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row.faction:SetText("|c" .. FactionColor(character.faction) .. (character.faction or "Unknown") .. "|r")
        row.realm:SetText("|c" .. REALM_COLOR .. character.realm .. "|r")
        totalCopper = totalCopper + character.copper
        if type(character.playedSeconds) == "number" then
            totalSeconds = totalSeconds + character.playedSeconds
            knownPlayed = knownPlayed + 1
        end
        local realm, name = character.realm, character.name
        row.delete:SetScript("OnClick", function()
            StaticPopup_Show("VAULTSCAN_DELETE_CHARACTER", name .. " - " .. realm, nil, { realm = realm, name = name })
        end)
        for _, column in ipairs(COLUMN_ORDER) do row[column]:Show() end
        row.delete:Show()
        row.historyButton:Show()
    end
    scrollChild:SetHeight(math.max(1, #characters * ROW_HEIGHT + ROW_BOTTOM_PADDING))
    local maxScroll = math.max(0, scrollChild:GetHeight() - scrollFrame:GetHeight())
    if scrollFrame:GetVerticalScroll() > maxScroll then scrollFrame:SetVerticalScroll(maxScroll) end
    local bankCopper = VaultSCAN.GetWarbandWealth()
    local function Gold(copper)
        return "|c" .. GOLD_VALUE_COLOR .. BreakUpLargeNumbers(math.floor(copper / 10000)) .. "g|r"
    end
    footerValues.character:SetText(Gold(totalCopper))
    local bankVerified = VaultSCAN.IsWarbandWealthVerified and VaultSCAN.IsWarbandWealthVerified()
    footerStatus.warband:Hide()
    footerStatus.total:Hide()
    if bankCopper == nil then
        footerValues.warband:SetText("|c" .. GOLD_VALUE_COLOR .. "Not scanned|r")
        footerValues.total:SetText("|cffffffffPending bank scan|r")
    else
        -- Display cached status in a smaller, separate font string, leaving
        -- the gold amounts unchanged and preventing status text from affecting totals.
        footerValues.warband:SetText(Gold(bankCopper))
        footerValues.total:SetText("|cffffffff"
            .. BreakUpLargeNumbers(math.floor((totalCopper + bankCopper) / 10000)) .. "g|r")
        if not bankVerified then
            footerStatus.warband:SetText("(last verified)")
            footerStatus.total:SetText("(estimated)")
            footerStatus.warband:Show()
            footerStatus.total:Show()
        end
    end
    local playedText = FormatPlayed(totalSeconds)
    if knownPlayed < #characters then playedText = playedText .. " (" .. knownPlayed .. "/" .. #characters .. " tracked)" end
    footerValues.played:SetText("|cffffffff" .. playedText .. "|r")
    -- Record one daily observation; cached bank values are marked estimated.
    -- If bank verification succeeds later, upgrade today's estimate in place.
    if VaultSCAN.RecordWealthSnapshot then VaultSCAN.RecordWealthSnapshot(totalCopper) end
    -- Refresh verification/snapshot state after the optional daily recording.
    -- Never label a saved balance as verified solely because a snapshot exists.
    trendPanel.wealthValidation = VaultSCAN.ValidateWealthState
        and VaultSCAN.ValidateWealthState(totalCopper) or nil
    RenderWealthTrend()
end

scrollFrame:SetScript("OnSizeChanged", UpdateColumnLayout)
UpdateColumnLayout()
mainFrame:Hide()
-- Register after the initial hide so loading the addon does not trigger an emote.
mainFrame:HookScript("OnHide", function()
    if suppressReadOnHide then
        suppressReadOnHide = false
        return
    end
    DoEmote("READ")
end)
function VaultSCAN.ToggleWindow()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        UpdateColumnLayout()
        VaultSCAN.RefreshUI()
        mainFrame:Show()
        if VaultSCAN.RequestPlayedTime then VaultSCAN.RequestPlayedTime() end
    end
end
