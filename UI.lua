
--[[
    VaultSCAN
    File: UI.lua
    Version: 0.1.0

    Displays a scrollable multi-character wealth dashboard.
]]

local addonName, VaultSCAN = ...


-- ============================================================
-- MAIN WINDOW
-- ============================================================

local mainFrame = CreateFrame(
    "Frame",
    "VaultSCANMainFrame",
    UIParent,
    "BasicFrameTemplateWithInset"
)

mainFrame:SetSize(400, 320)
mainFrame:SetPoint("CENTER")
mainFrame.TitleText:SetText("VaultSCAN")

mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")

mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)


-- ============================================================
-- LAYOUT CONFIGURATION
-- ============================================================

local ROW_HEIGHT = 26
local ROW_BOTTOM_PADDING = 12

local NAME_LEFT = 0
local GOLD_RIGHT = -85
local ILVL_RIGHT = -25

local characterRows = {}


-- ============================================================
-- SCROLL FRAME
-- ============================================================

local scrollFrame = CreateFrame(
    "ScrollFrame",
    "VaultSCANScrollFrame",
    mainFrame,
    "UIPanelScrollFrameTemplate"
)

scrollFrame:SetPoint(
    "TOPLEFT",
    mainFrame,
    "TOPLEFT",
    20,
    -80
)

scrollFrame:SetPoint(
    "BOTTOMRIGHT",
    mainFrame,
    "BOTTOMRIGHT",
    -45,
    70
)

-- The scroll child contains all character rows.
local scrollChild = CreateFrame(
    "Frame",
    nil,
    scrollFrame
)

-- Match the scroll child's width to the visible scroll area.
scrollChild:SetWidth(scrollFrame:GetWidth())
scrollChild:SetHeight(1)

scrollFrame:SetScrollChild(scrollChild)


-- ============================================================
-- TABLE HEADERS
-- ============================================================

-- Header positions use the same horizontal column offsets
-- as the character rows.

local nameHeader = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

nameHeader:SetPoint(
    "BOTTOMLEFT",
    scrollFrame,
    "TOPLEFT",
    NAME_LEFT,
    10
)

nameHeader:SetText("Character")


local goldHeader = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

goldHeader:SetPoint(
    "BOTTOMRIGHT",
    scrollFrame,
    "TOPRIGHT",
    GOLD_RIGHT,
    10
)

goldHeader:SetText("Gold")


local itemLevelHeader = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

itemLevelHeader:SetPoint(
    "BOTTOMRIGHT",
    scrollFrame,
    "TOPRIGHT",
    ILVL_RIGHT,
    10
)

itemLevelHeader:SetText("iLvl")


-- ============================================================
-- TOTAL WEALTH SECTION
-- ============================================================

local totalDivider = mainFrame:CreateTexture(
    nil,
    "ARTWORK"
)

totalDivider:SetColorTexture(0.45, 0.40, 0.30, 0.8)
totalDivider:SetHeight(1)

totalDivider:SetPoint(
    "BOTTOMLEFT",
    mainFrame,
    "BOTTOMLEFT",
    20,
    55
)

totalDivider:SetPoint(
    "BOTTOMRIGHT",
    mainFrame,
    "BOTTOMRIGHT",
    -20,
    55
)


local totalLabel = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

totalLabel:SetPoint(
    "TOPLEFT",
    totalDivider,
    "BOTTOMLEFT",
    0,
    -12
)

totalLabel:SetText("Total Wealth")


local totalGoldLabel = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

totalGoldLabel:SetPoint(
    "TOPRIGHT",
    totalDivider,
    "BOTTOMRIGHT",
    0,
    -12
)


-- ============================================================
-- CLASS COLOR HELPER
-- ============================================================

local function GetClassColorCode(classFile)

    local classColor = classFile
        and RAID_CLASS_COLORS[classFile]

    return classColor
        and classColor.colorStr
        or "ffffffff"

end


-- ============================================================
-- CREATE CHARACTER ROW
-- ============================================================

local function CreateCharacterRow(index)

    local row = {}

    local yOffset = -((index - 1) * ROW_HEIGHT)


    -- Character name.
    row.name = scrollChild:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    row.name:SetPoint(
        "TOPLEFT",
        scrollChild,
        "TOPLEFT",
        NAME_LEFT,
        yOffset
    )

    row.name:SetWidth(150)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)


    -- Gold balance.
    row.gold = scrollChild:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    row.gold:SetPoint(
        "TOPRIGHT",
        scrollChild,
        "TOPRIGHT",
        GOLD_RIGHT,
        yOffset
    )

    row.gold:SetWidth(95)
    row.gold:SetJustifyH("RIGHT")
    row.gold:SetWordWrap(false)


    -- Equipped item level.
    row.itemLevel = scrollChild:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    row.itemLevel:SetPoint(
        "TOPRIGHT",
        scrollChild,
        "TOPRIGHT",
        ILVL_RIGHT,
        yOffset
    )

    row.itemLevel:SetWidth(45)
    row.itemLevel:SetJustifyH("RIGHT")
    row.itemLevel:SetWordWrap(false)


    characterRows[index] = row

    return row

end


-- ============================================================
-- REFRESH DASHBOARD
-- ============================================================

function VaultSCAN.RefreshUI()

    local characters = VaultSCAN.GetAllCharacters()
    local totalCopper = 0

    -- Hide rows from the previous refresh.
    for _, row in ipairs(characterRows) do
        row.name:Hide()
        row.gold:Hide()
        row.itemLevel:Hide()
    end


    -- ========================================================
    -- POPULATE CHARACTER ROWS
    -- ========================================================

    for index, character in ipairs(characters) do

        local row = characterRows[index]

        if not row then
            row = CreateCharacterRow(index)
        end

        local colorCode = GetClassColorCode(character.class)


        -- Character name in class color.
        row.name:SetText(
            "|c" .. colorCode
            .. character.name .. "|r"
        )


        -- Gold balance.
        totalCopper = totalCopper + character.copper

        local characterGold = math.floor(
            character.copper / 10000
        )

        row.gold:SetText(
            "|cffffffff"
            .. BreakUpLargeNumbers(characterGold)
            .. "|r"
        )


        -- Equipped item level.
        if type(character.itemLevel) == "number" then

            local itemLevel = math.floor(
                character.itemLevel + 0.5
            )

            row.itemLevel:SetText(
                "|c" .. colorCode
                .. tostring(itemLevel) .. "|r"
            )

        else

            row.itemLevel:SetText(
                "|cffffffff—|r"
            )

        end


        row.name:Show()
        row.gold:Show()
        row.itemLevel:Show()

    end


    -- ========================================================
    -- SCROLL CONTENT SIZE
    -- ========================================================

    local contentHeight = (#characters * ROW_HEIGHT)
        + ROW_BOTTOM_PADDING

    scrollChild:SetHeight(
        math.max(1, contentHeight)
    )

    -- Prevent scrolling beyond the available content.
    local maxScroll = math.max(
        0,
        scrollChild:GetHeight() - scrollFrame:GetHeight()
    )

    if scrollFrame:GetVerticalScroll() > maxScroll then
        scrollFrame:SetVerticalScroll(maxScroll)
    end


    -- ========================================================
    -- TOTAL WEALTH
    -- ========================================================

    local totalGold = math.floor(totalCopper / 10000)

    totalGoldLabel:SetText(
        "|cffffffff"
        .. BreakUpLargeNumbers(totalGold)
        .. "g|r"
    )

end


-- ============================================================
-- WINDOW VISIBILITY
-- ============================================================

mainFrame:Hide()

function VaultSCAN.ToggleWindow()

    if mainFrame:IsShown() then

        mainFrame:Hide()

    else

        VaultSCAN.RefreshUI()
        mainFrame:Show()

    end

end
