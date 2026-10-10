
--[[
    VaultSCAN
    File: Minimap.lua
    Version: 0.1.0

    Creates the minimap button for opening VaultSCAN.
]]

local addonName, VaultSCAN = ...


-- ============================================================
-- MINIMAP BUTTON
-- ============================================================

local minimapButton = CreateFrame(
    "Button",
    "VaultSCANMinimapButton",
    Minimap
)

minimapButton:SetSize(32, 32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(Minimap:GetFrameLevel() + 5)


-- ============================================================
-- BUTTON POSITION
-- ============================================================

-- Position the button near 11 o'clock, just outside the minimap.
local angle = math.rad(135)
local radius = 100

local function UpdateButtonPosition()

    minimapButton:ClearAllPoints()

    minimapButton:SetPoint(
        "CENTER",
        Minimap,
        "CENTER",
        math.cos(angle) * radius,
        math.sin(angle) * radius
    )

end

UpdateButtonPosition()


-- ============================================================
-- BUTTON APPEARANCE
-- ============================================================

local border = minimapButton:CreateTexture(
    nil,
    "OVERLAY"
)

border:SetTexture(
    "Interface\\Minimap\\MiniMap-TrackingBorder"
)

border:SetSize(54, 54)
border:SetPoint("TOPLEFT")


local icon = minimapButton:CreateTexture(
    nil,
    "BACKGROUND"
)

icon:SetTexture(
    "Interface\\Icons\\INV_Misc_Coin_01"
)

icon:SetSize(20, 20)
icon:SetPoint("CENTER")


local highlight = minimapButton:CreateTexture(
    nil,
    "HIGHLIGHT"
)

highlight:SetTexture(
    "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
)

highlight:SetSize(32, 32)
highlight:SetPoint("CENTER")


-- ============================================================
-- BUTTON INTERACTION
-- ============================================================

minimapButton:RegisterForClicks("LeftButtonUp")

minimapButton:SetScript("OnClick", function(self, button)

    if button == "LeftButton" then
        VaultSCAN.ToggleWindow()
    end

end)


-- ============================================================
-- TOOLTIP
-- ============================================================

minimapButton:SetScript("OnEnter", function(self)

    GameTooltip:SetOwner(self, "ANCHOR_LEFT")

    GameTooltip:AddLine("VaultSCAN", 1, 0.82, 0)

    GameTooltip:AddLine(
        "Left-click to open your wealth dashboard.",
        1, 1, 1
    )

    GameTooltip:Show()

end)

minimapButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)
