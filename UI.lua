
--[[
    VaultSCAN
    File: UI.lua
    Version: 0.1.0

    Purpose:
    Creates and manages the VaultSCAN character dashboard.

    Features:
    - Movable Blizzard-style window.
    - Multi-character table.
    - Class-colored names and item levels.
    - Saved gold balances.
    - Combined wealth across all saved characters.
    - Automatic UI refresh.
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

mainFrame:SetSize(360, 240)
mainFrame:SetPoint("CENTER")
mainFrame.TitleText:SetText("VaultSCAN")

-- Allow the player to move the window.
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
-- TABLE CONFIGURATION
-- ============================================================

local ROW_HEIGHT = 24
local FIRST_ROW_OFFSET = -85

-- Reuse character rows instead of recreating them.
local characterRows = {}


-- ============================================================
-- TABLE HEADERS
-- ============================================================

local nameHeader = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

nameHeader:SetPoint(
    "TOPLEFT",
    mainFrame,
    "TOPLEFT",
    20,
    -55
)

nameHeader:SetText("Character")


local goldHeader = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

goldHeader:SetPoint(
    "TOPRIGHT",
    mainFrame,
    "TOPRIGHT",
    -85,
    -55
)

goldHeader:SetText("Gold")


local itemLevelHeader = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

itemLevelHeader:SetPoint(
    "TOPRIGHT",
    mainFrame,
    "TOPRIGHT",
    -20,
    -55
)

itemLevelHeader:SetText("iLvl")


-- ============================================================
-- TOTAL WEALTH DISPLAY
-- ============================================================

-- Create a divider beneath the character list.
local totalDivider = mainFrame:CreateTexture(
    nil,
    "ARTWORK"
)

totalDivider:SetColorTexture(0.45, 0.40, 0.30, 0.8)
totalDivider:SetHeight(1)

-- The divider's vertical position is set during RefreshUI().
totalDivider:SetPoint(
    "LEFT",
    mainFrame,
    "LEFT",
    20,
    0
)

totalDivider:SetPoint(
    "RIGHT",
    mainFrame,
    "RIGHT",
    -20,
    0
)


-- Create the Total Wealth label.
local totalLabel = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

totalLabel:SetText("Total Wealth")


-- Create the total gold value.
local totalGoldLabel = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

totalGoldLabel:SetJustifyH("RIGHT")


-- ============================================================
-- CLASS COLOR HELPER
-- ============================================================

local function GetClassColorCode(classFile)

    local classColor = classFile
        and RAID_CLASS_COLORS[classFile]

    if classColor and classColor.colorStr then
        return classColor.colorStr
    end

    return "ffffffff"

end


-- ============================================================
-- CREATE CHARACTER ROW
-- ============================================================

local function CreateCharacterRow(index)

    local row = {}

    local yOffset = FIRST_ROW_OFFSET
        - ((index - 1) * ROW_HEIGHT)


    -- Character name column.
    row.name = mainFrame:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    row.name:SetPoint(
        "TOPLEFT",
        mainFrame,
        "TOPLEFT",
        20,
        yOffset
    )

    row.name:SetWidth(160)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)


    -- Gold balance column.
    row.gold = mainFrame:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    row.gold:SetPoint(
        "TOPRIGHT",
        mainFrame,
        "TOPRIGHT",
        -85,
        yOffset
    )

    row.gold:SetWidth(90)
    row.gold:SetJustifyH("RIGHT")
    row.gold:SetWordWrap(false)


    -- Item level column.
    row.itemLevel = mainFrame:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    row.itemLevel:SetPoint(
        "TOPRIGHT",
        mainFrame,
        "TOPRIGHT",
        -20,
        yOffset
    )

    row.itemLevel:SetWidth(50)
    row.itemLevel:SetJustifyH("RIGHT")
    row.itemLevel:SetWordWrap(false)


    characterRows[index] = row

    return row

end


-- ============================================================
-- REFRESH DASHBOARD
-- ============================================================

function VaultSCAN.RefreshUI()

    -- Retrieve all saved characters from Database.lua.
    local characters = VaultSCAN.GetAllCharacters()

    -- Accumulate wealth in copper to preserve precision.
    local totalCopper = 0


    -- Hide existing rows before repopulating.
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
            "|c"
            .. colorCode
            .. character.name
            .. "|r"
        )


        -- Add this character's wealth to the total.
        totalCopper = totalCopper + character.copper

        -- Convert copper into whole gold.
        local characterGold = math.floor(
            character.copper / 10000
        )

        -- Display gold in white.
        row.gold:SetText(
            "|cffffffff"
            .. BreakUpLargeNumbers(characterGold)
            .. "|r"
        )


        -- Equipped item level in class color.
        if type(character.itemLevel) == "number" then

            local roundedItemLevel = math.floor(
                character.itemLevel + 0.5
            )

            row.itemLevel:SetText(
                "|c"
                .. colorCode
                .. tostring(roundedItemLevel)
                .. "|r"
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
    -- TOTAL WEALTH CALCULATION
    -- ========================================================

    -- Convert the combined copper balance into whole gold.
    local totalGold = math.floor(totalCopper / 10000)

    -- Display the total in white.
    totalGoldLabel:SetText(
        "|cffffffff"
        .. BreakUpLargeNumbers(totalGold)
        .. "g|r"
    )


    -- ========================================================
    -- POSITION TOTAL WEALTH SECTION
    -- ========================================================

    -- Place the divider below the final character row.
    local dividerOffset = FIRST_ROW_OFFSET
        - (#characters * ROW_HEIGHT)
        + 4

    totalDivider:ClearAllPoints()

    totalDivider:SetPoint(
        "TOPLEFT",
        mainFrame,
        "TOPLEFT",
        20,
        dividerOffset
    )

    totalDivider:SetPoint(
        "TOPRIGHT",
        mainFrame,
        "TOPRIGHT",
        -20,
        dividerOffset
    )


    -- Position Total Wealth beneath the divider.
    totalLabel:ClearAllPoints()

    totalLabel:SetPoint(
        "TOPLEFT",
        totalDivider,
        "BOTTOMLEFT",
        0,
        -12
    )


    -- Right-align the total balance.
    totalGoldLabel:ClearAllPoints()

    totalGoldLabel:SetPoint(
        "TOPRIGHT",
        totalDivider,
        "BOTTOMRIGHT",
        0,
        -12
    )


    -- ========================================================
    -- WINDOW HEIGHT
    -- ========================================================

    -- Expand the window when additional characters are saved.
    -- Scrolling will be introduced in a later milestone.
    local requiredHeight = 145
        + (#characters * ROW_HEIGHT)

    mainFrame:SetHeight(
        math.max(240, requiredHeight)
    )

end


-- ============================================================
-- INITIAL WINDOW VISIBILITY
-- ============================================================

mainFrame:Hide()


-- ============================================================
-- WINDOW TOGGLE
-- ============================================================

function VaultSCAN.ToggleWindow()

    if mainFrame:IsShown() then

        mainFrame:Hide()

    else

        VaultSCAN.RefreshUI()
        mainFrame:Show()

    end

end
