
--[[
    VaultSCAN
    File: UI.lua
    Version: 0.1.0

    Purpose:
    Creates and manages the VaultSCAN graphical user interface.

    Responsibilities:
    - Create the main addon window.
    - Configure window appearance and positioning.
    - Handle window dragging.
    - Display character information and saved gold.
    - Control window visibility.
]]

-- Retrieve the addon name and shared namespace provided by WoW.
-- The VaultSCAN table allows functions to be shared between Lua files.
local addonName, VaultSCAN = ...


-- ============================================================
-- MAIN WINDOW INITIALIZATION
-- ============================================================

-- Create the main VaultSCAN window using Blizzard's UI framework.
--
-- Parameters:
-- "Frame"                     = Type of UI element.
-- "VaultSCANMainFrame"        = Unique global name for this frame.
-- UIParent                    = Parent UI element (WoW's main interface).
-- "BasicFrameTemplateWithInset" = Blizzard's built-in window template.
--
-- The template provides a background, title bar, and close button.
local mainFrame = CreateFrame(
    "Frame",
    "VaultSCANMainFrame",
    UIParent,
    "BasicFrameTemplateWithInset"
)

-- Define the window's width and height in UI coordinate units.
mainFrame:SetSize(360, 240)

-- Anchor the window to the center of the screen.
-- SetPoint() determines where a frame is positioned relative
-- to another UI element or anchor point.
mainFrame:SetPoint("CENTER")

-- Set the text displayed in the window's title bar.
-- TitleText is supplied by Blizzard's frame template.
mainFrame.TitleText:SetText("VaultSCAN")


-- ============================================================
-- WINDOW MOVEMENT
-- ============================================================

-- Allow the frame to be repositioned by the player.
mainFrame:SetMovable(true)

-- Enable mouse interaction with the frame.
mainFrame:EnableMouse(true)

-- Allow dragging with the left mouse button.
mainFrame:RegisterForDrag("LeftButton")

-- Register the callback executed when dragging begins.
--
-- "OnDragStart" is a WoW UI event script.
-- 'self' refers to the frame that triggered the callback.
mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

-- Register the callback executed when dragging ends.
-- This stops movement and keeps the frame at its new position.
mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)


-- ============================================================
-- CHARACTER NAME DISPLAY
-- ============================================================

-- Create a text element (FontString) attached to the main window.
--
-- Parameters:
-- nil              = No globally registered name is needed.
-- "OVERLAY"        = Draw the text on the overlay layer.
-- "GameFontNormal" = Use Blizzard's standard gold-colored font.
local characterLabel = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalLarge"
)

-- Position the character label inside the window.
--
-- TOPLEFT = Anchor the label's upper-left corner.
-- mainFrame = Position relative to the main window.
-- 20 = Horizontal offset from the left edge.
-- -65 = Vertical offset downward from the top edge.
characterLabel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 20, -65)

-- Retrieve the currently logged-in character's name
-- using the WoW API and display it in the window.

-- Gold field label with a white character name.
characterLabel:SetText(
    "|cffffd700Character:|r |cffffffff"
    .. (characterName or "Unknown")
    .. "|r"
)



-- ============================================================
-- CHARACTER GOLD DISPLAY
-- ============================================================

-- Create a second text element to display saved character gold.
local goldLabel = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)

-- Position the gold label relative to the character label.
--
-- The gold label's TOPLEFT corner is anchored to the
-- character label's BOTTOMLEFT corner.
--
-- 0   = No horizontal offset.
-- -12 = Place the gold label 12 units below the character label.
goldLabel:SetPoint("TOPLEFT", characterLabel, "BOTTOMLEFT", 0, -12)


-- ============================================================
-- UI DATA REFRESH
-- ============================================================

-- Refresh the character information displayed in the window.
--
-- This function reads the latest data from VaultSCANDB
-- instead of relying on values captured during UI creation.
--
-- Other modules can call:
-- VaultSCAN.RefreshUI()
function VaultSCAN.RefreshUI()

    -- Identify the currently logged-in character.
    local characterName = UnitName("player")
    local realmName = GetRealmName()

    -- Update the character name displayed in the UI.

    -- Gold field label with a white character name.
    characterLabel:SetText(
        "|cffffd700Character:|r |cffffffff"
        .. (characterName or "Unknown")
        .. "|r"
    )


    -- Retrieve the character's saved wealth record.
    -- The 'and' operators prevent indexing a missing table.
    local characterData = VaultSCANDB
        and VaultSCANDB[realmName]
        and VaultSCANDB[realmName][characterName]

    -- Update the gold label using the latest saved balance.
    if characterData and type(characterData.copper) == "number" then

        -- Convert copper into whole gold.
        local totalGold = math.floor(characterData.copper / 10000)

        -- Format the number with thousands separators.
        
        -- Gold field label with a white numeric balance.
        goldLabel:SetText(
            "|cffffd700Gold:|r |cffffffff"
            .. BreakUpLargeNumbers(totalGold)
            .. "|r"
        )

    else

        -- Display a fallback when no saved record exists.
        goldLabel:SetText("Gold: Not yet recorded")

    end
end


-- ============================================================
-- WINDOW VISIBILITY
-- ============================================================

-- Hide the window when the addon first loads.
-- The frame still exists in memory and can be shown later.
mainFrame:Hide()


-- ============================================================
-- WINDOW TOGGLE FUNCTION
-- ============================================================

-- Expose a reusable function through the shared addon namespace.
--
-- This function can be called from VaultSCAN.lua:
--
-- VaultSCAN.ToggleWindow()
--
-- It controls whether the main window is visible.
function VaultSCAN.ToggleWindow()


-- Toggle the VaultSCAN window.
function VaultSCAN.ToggleWindow()

    -- Check whether the window is currently visible.
    if mainFrame:IsShown() then

        -- Hide the window if it is currently displayed.
        mainFrame:Hide()

    else

        -- Refresh character information before opening.
        VaultSCAN.RefreshUI()

        -- Show the window with updated information.
        mainFrame:Show()

    end
end

end
