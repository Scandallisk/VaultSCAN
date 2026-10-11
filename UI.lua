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
-- v0.5.0 muted accent colors.
local LAST_PLAYED_COLOR = "ffffffff" -- White (#FFFFFF)
local FOOTER_LABEL_COLOR = { 1, 1, 1 } -- White (#FFFFFF)
local GOLD_VALUE_COLOR = "ffd6c6a4" -- Champagne Gold (#D6C6A4)

local rows, headers = {}, {}
local positions, widths = {}, {}
local sortColumn, sortAscending = "itemLevel", false

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
titleCoinTexture:SetTexture("Interface\\Icons\\Ability_iyyokuk_bomb_white")
local titleCoinMask = titleCoin:CreateMaskTexture()
titleCoinMask:SetAllPoints(titleCoinTexture)
titleCoinMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
titleCoinTexture:AddMaskTexture(titleCoinMask)
titleCoin:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
    GameTooltip:AddLine("VaultSCAN", 1, 0.82, 0)
    GameTooltip:AddLine("Author: SCAN", 1, 1, 1)
    GameTooltip:AddLine("Version 0.5.0", 0.75, 0.75, 0.75)
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
            header:SetPoint("BOTTOMLEFT", scrollFrame, "TOPLEFT", positions[column], 16)
            header:SetWidth(widths[column])
        end
    end
    for index, row in ipairs(rows) do
        for _, column in ipairs(COLUMN_ORDER) do
            local field = row[column]
            field:ClearAllPoints()
            field:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", positions[column] + (column == "name" and 40 or 0), -(index - 1) * ROW_HEIGHT)
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
    label:SetPoint("LEFT", button, "LEFT", 16, 0)
    label:SetPoint("RIGHT", button, "RIGHT", 0, 0)
    label:SetJustifyH(COLUMNS[column].align)
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

local divider = mainFrame:CreateTexture(nil, "ARTWORK", nil, 2) -- Above charcoal background (sublevel 1)
divider:SetColorTexture(0, 0, 0, 1) -- Black #000000
divider:SetHeight(1)
divider:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 20, 126)
divider:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -20, 126)

local footerLabels = {}
local footerValues = {}
local footerFields = {
    { key = "character", title = "Character Gold" },
    { key = "warband", title = "Warband Gold" },
    { key = "total", title = "Total Wealth" },
    { key = "played", title = "Total Played Time" },
}
for i, field in ipairs(footerFields) do
    -- Extra space between the individual gold balances and their total.
    local offset = (i <= 2) and (-8 - (i - 1) * 25) or (-66 - (i - 3) * 25)
    local label = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, offset)
    label:SetText(field.title)
    label:SetTextColor(unpack(FOOTER_LABEL_COLOR))
    local value = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    value:SetPoint("TOPRIGHT", divider, "BOTTOMRIGHT", 0, offset)
    value:SetTextColor(214 / 255, 198 / 255, 164 / 255, 1)
    footerLabels[field.key], footerValues[field.key] = label, value
end

-- A second fixed rule groups Character/Warband Gold above the totals.
-- Anchor it to the existing footer divider so it follows frame resizing.
local wealthDivider = mainFrame:CreateTexture(nil, "ARTWORK", nil, 2) -- Above charcoal background (sublevel 1)
wealthDivider:SetColorTexture(0, 0, 0, 1) -- Black #000000
wealthDivider:SetHeight(1)
wealthDivider:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, -57)
wealthDivider:SetPoint("TOPRIGHT", divider, "BOTTOMRIGHT", 0, -57)

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
        field:SetJustifyH(
            (column == "lastPlayed" or column == "faction") and "CENTER"
            or COLUMNS[column].align
        )
        field:SetWordWrap(false)
        field:SetTextColor(1, 1, 1, 1)
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
    footerValues.warband:SetText(bankCopper ~= nil and Gold(bankCopper) or "|c" .. GOLD_VALUE_COLOR .. "Not scanned|r")
    footerValues.total:SetText(bankCopper ~= nil and Gold(totalCopper + bankCopper)
        or "|c" .. GOLD_VALUE_COLOR .. "Pending bank scan|r")
    local playedText = FormatPlayed(totalSeconds)
    if knownPlayed < #characters then playedText = playedText .. " (" .. knownPlayed .. "/" .. #characters .. " tracked)" end
    footerValues.played:SetText("|c" .. GOLD_VALUE_COLOR .. playedText .. "|r")
end

scrollFrame:SetScript("OnSizeChanged", UpdateColumnLayout)
UpdateColumnLayout()
mainFrame:Hide()
-- Register after the initial hide so loading the addon does not trigger an emote.
mainFrame:HookScript("OnHide", function()
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
