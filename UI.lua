
--[[
    VaultSCAN
    File: UI.lua
    Version: 0.2.0

    Displays the resizable, sortable character dashboard.
]]

local addonName, VaultSCAN = ...


-- ============================================================
-- LAYOUT CONFIGURATION
-- ============================================================

local ROW_HEIGHT = 26
local ROW_BOTTOM_PADDING = 12
local COLUMN_GAP = 20

local COLUMN_ORDER = {
    "name",
    "gold",
    "itemLevel",
    "faction",
    "realm"
}

local COLUMNS = {
    name = {
        title = "Character",
        width = 145,
        align = "LEFT"
    },
    gold = {
        title = "Gold",
        width = 90,
        align = "RIGHT"
    },
    itemLevel = {
        title = "iLvl",
        width = 55,
        align = "RIGHT"
    },
    faction = {
        title = "Faction",
        width = 95,
        align = "LEFT"
    },
    realm = {
        title = "Realm",
        width = 140,
        align = "LEFT"
    }
}

local REALM_COLOR = "ffe8c878"
local ALLIANCE_COLOR = "ff398bff"
local HORDE_COLOR = "ffe05252"
local UNKNOWN_COLOR = "ffaaaaaa"

local characterRows = {}
local headers = {}

local sortColumn = "itemLevel"
local sortAscending = false


-- ============================================================
-- MAIN WINDOW
-- ============================================================

local mainFrame = CreateFrame(
    "Frame",
    "VaultSCANMainFrame",
    UIParent,
    "BasicFrameTemplateWithInset"
)

mainFrame:SetSize(700, 320)
mainFrame:SetPoint("CENTER")
mainFrame.TitleText:SetText("VaultSCAN")

mainFrame:SetMovable(true)
mainFrame:SetResizable(true)
mainFrame:SetResizeBounds(650, 320)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")

mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)


-- ============================================================
-- SCROLL FRAME
-- ============================================================

local scrollFrame = CreateFrame(
    "ScrollFrame",
    "VaultSCANScrollFrame",
    mainFrame,
    "UIPanelScrollFrameTemplate"
)

scrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 20, -80)
scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -45, 70)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetWidth(1)
scrollChild:SetHeight(1)

scrollFrame:SetScrollChild(scrollChild)


-- ============================================================
-- COLUMN LAYOUT
-- ============================================================

local columnPositions = {}
local columnWidths = {}

local function UpdateColumnLayout()

    local availableWidth = math.max(1, scrollFrame:GetWidth() - 10)

    local totalBaseWidth = 0

    for _, column in ipairs(COLUMN_ORDER) do
        totalBaseWidth = totalBaseWidth + COLUMNS[column].width
    end

    local totalGapWidth = COLUMN_GAP * (#COLUMN_ORDER - 1)
    local extraWidth = math.max(
        0,
        availableWidth - totalBaseWidth - totalGapWidth
    )

    local xOffset = 0

    for _, column in ipairs(COLUMN_ORDER) do

        local baseWidth = COLUMNS[column].width

        local width = baseWidth + (
            extraWidth * (baseWidth / totalBaseWidth)
        )

        columnPositions[column] = xOffset
        columnWidths[column] = width

        xOffset = xOffset + width + COLUMN_GAP

    end

    scrollChild:SetWidth(math.max(1, xOffset - COLUMN_GAP))

    -- Reposition headers.
    for _, column in ipairs(COLUMN_ORDER) do

        local header = headers[column]

        if header then

            header:ClearAllPoints()

            header:SetPoint(
                "BOTTOMLEFT",
                scrollFrame,
                "TOPLEFT",
                columnPositions[column],
                10
            )

            header:SetWidth(columnWidths[column])

        end

    end

    -- Reposition existing character rows.
    for index, row in ipairs(characterRows) do

        local yOffset = -((index - 1) * ROW_HEIGHT)

        for _, column in ipairs(COLUMN_ORDER) do

            local fontString = row[column]

            fontString:ClearAllPoints()

            fontString:SetPoint(
                "TOPLEFT",
                scrollChild,
                "TOPLEFT",
                columnPositions[column],
                yOffset
            )

            fontString:SetWidth(columnWidths[column])

        end

    end

end


-- ============================================================
-- TABLE HEADERS
-- ============================================================

local function UpdateHeaderLabels()

    for _, column in ipairs(COLUMN_ORDER) do

        local header = headers[column]

        header.label:SetText(COLUMNS[column].title)

        if column == sortColumn then

            header.arrow:Show()

            if sortAscending then
                header.arrow:SetTexCoord(0, 1, 1, 0)
            else
                header.arrow:SetTexCoord(0, 1, 0, 1)
            end

        else
            header.arrow:Hide()
        end

    end

end


-- ============================================================
-- SORTING
-- ============================================================

local function SortCharacters(characters)

    table.sort(characters, function(a, b)

        local valueA
        local valueB

        if sortColumn == "gold" then

            valueA = a.copper or 0
            valueB = b.copper or 0

        elseif sortColumn == "itemLevel" then

            valueA = type(a.itemLevel) == "number"
                and a.itemLevel or -1

            valueB = type(b.itemLevel) == "number"
                and b.itemLevel or -1

        else

            valueA = string.lower(a[sortColumn] or "")
            valueB = string.lower(b[sortColumn] or "")

        end

        if valueA ~= valueB then
            return sortAscending and valueA < valueB or valueA > valueB
        end

        if a.realm ~= b.realm then
            return a.realm < b.realm
        end

        return a.name < b.name

    end)

end

local function SetSortColumn(column)

    if sortColumn == column then
        sortAscending = not sortAscending
    else
        sortColumn = column
        sortAscending = (
            column == "name"
            or column == "realm"
            or column == "faction"
        )
    end

    UpdateHeaderLabels()
    VaultSCAN.RefreshUI()

end


-- ============================================================
-- CREATE TABLE HEADERS
-- ============================================================

for _, column in ipairs(COLUMN_ORDER) do

    local button = CreateFrame("Button", nil, mainFrame)
    button:SetHeight(24)

    local label = button:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalLarge"
    )

    label:SetPoint("LEFT", button, "LEFT", 16, 0)
    label:SetPoint("RIGHT", button, "RIGHT", 0, 0)
    label:SetJustifyH(COLUMNS[column].align)
    label:SetWordWrap(false)

    local arrow = button:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture("Interface\\Buttons\\UI-SortArrow")
    arrow:SetSize(12, 12)
    arrow:SetPoint("LEFT", button, "LEFT", 0, 0)

    button.label = label
    button.arrow = arrow
    headers[column] = button

    local selectedColumn = column

    button:SetScript("OnClick", function()
        SetSortColumn(selectedColumn)
    end)

end

UpdateHeaderLabels()


-- ============================================================
-- TOTAL WEALTH SECTION
-- ============================================================

local totalDivider = mainFrame:CreateTexture(nil, "ARTWORK")

totalDivider:SetColorTexture(0.45, 0.40, 0.30, 0.8)
totalDivider:SetHeight(1)
totalDivider:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 20, 55)
totalDivider:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -20, 55)

local totalLabel = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

totalLabel:SetPoint("TOPLEFT", totalDivider, "BOTTOMLEFT", 0, -12)
totalLabel:SetText("Total Wealth")

local totalGoldLabel = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

totalGoldLabel:SetPoint("TOPRIGHT", totalDivider, "BOTTOMRIGHT", 0, -12)


-- ============================================================
-- RESIZE HANDLE
-- ============================================================

local resizeHandle = CreateFrame("Button", nil, mainFrame)

resizeHandle:SetSize(20, 20)
resizeHandle:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -5, 5)

resizeHandle:SetNormalTexture(
    "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up"
)

resizeHandle:SetHighlightTexture(
    "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight"
)

resizeHandle:SetPushedTexture(
    "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down"
)

resizeHandle:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        mainFrame:StartSizing("BOTTOMRIGHT")
    end
end)

resizeHandle:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        mainFrame:StopMovingOrSizing()
    end
end)


-- ============================================================
-- COLOR HELPERS
-- ============================================================

local function GetClassColorCode(classFile)
    local color = classFile and RAID_CLASS_COLORS[classFile]
    return color and color.colorStr or "ffffffff"
end

local function GetFactionColorCode(faction)

    if faction == "Alliance" then
        return ALLIANCE_COLOR
    elseif faction == "Horde" then
        return HORDE_COLOR
    end

    return UNKNOWN_COLOR

end


-- ============================================================
-- CHARACTER ROWS
-- ============================================================

local function CreateCharacterRow(index)

    local row = {}
    local yOffset = -((index - 1) * ROW_HEIGHT)

    for _, column in ipairs(COLUMN_ORDER) do

        local fontString = scrollChild:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

        fontString:SetPoint(
            "TOPLEFT",
            scrollChild,
            "TOPLEFT",
            columnPositions[column] or 0,
            yOffset
        )

        fontString:SetWidth(columnWidths[column] or 100)
        fontString:SetJustifyH(COLUMNS[column].align)
        fontString:SetWordWrap(false)

        row[column] = fontString

    end

    characterRows[index] = row
    return row

end


-- ============================================================
-- REFRESH DASHBOARD
-- ============================================================

function VaultSCAN.RefreshUI()

    local characters = VaultSCAN.GetAllCharacters()
    local totalCopper = 0

    SortCharacters(characters)

    for _, row in ipairs(characterRows) do
        for _, column in ipairs(COLUMN_ORDER) do
            row[column]:Hide()
        end
    end

    for index, character in ipairs(characters) do

        local row = characterRows[index]

        if not row then
            row = CreateCharacterRow(index)
        end

        local classColor = GetClassColorCode(character.class)
        local factionColor = GetFactionColorCode(character.faction)

        row.name:SetText(
            "|c" .. classColor .. character.name .. "|r"
        )

        totalCopper = totalCopper + character.copper

        local characterGold = math.floor(character.copper / 10000)

        row.gold:SetText(
            "|cffffffff"
            .. BreakUpLargeNumbers(characterGold)
            .. "|r"
        )

        if type(character.itemLevel) == "number" then

            local itemLevel = math.floor(character.itemLevel + 0.5)

            row.itemLevel:SetText(
                "|c" .. classColor .. tostring(itemLevel) .. "|r"
            )

        else
            row.itemLevel:SetText("|cffffffff—|r")
        end

        row.faction:SetText(
            "|c" .. factionColor
            .. (character.faction or "Unknown") .. "|r"
        )

        row.realm:SetText(
            "|c" .. REALM_COLOR .. character.realm .. "|r"
        )

        for _, column in ipairs(COLUMN_ORDER) do
            row[column]:Show()
        end

    end

    local contentHeight = (#characters * ROW_HEIGHT)
        + ROW_BOTTOM_PADDING

    scrollChild:SetHeight(math.max(1, contentHeight))

    local maxScroll = math.max(
        0,
        scrollChild:GetHeight() - scrollFrame:GetHeight()
    )

    if scrollFrame:GetVerticalScroll() > maxScroll then
        scrollFrame:SetVerticalScroll(maxScroll)
    end

    local totalGold = math.floor(totalCopper / 10000)

    totalGoldLabel:SetText(
        "|cffffffff"
        .. BreakUpLargeNumbers(totalGold)
        .. "g|r"
    )

end


-- ============================================================
-- RESIZE UPDATES
-- ============================================================

scrollFrame:SetScript("OnSizeChanged", function()
    UpdateColumnLayout()
end)

UpdateColumnLayout()


-- ============================================================
-- WINDOW VISIBILITY
-- ============================================================

mainFrame:Hide()

function VaultSCAN.ToggleWindow()

    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        UpdateColumnLayout()
        VaultSCAN.RefreshUI()
        mainFrame:Show()
    end

end
