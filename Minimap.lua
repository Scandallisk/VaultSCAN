
--[[
    VaultSCAN
    File: Minimap.lua
    Version: 0.2.0

    Handles the draggable minimap button.
]]

local addonName, VaultSCAN = ...


-- ============================================================
-- CONFIGURATION
-- ============================================================

local DEFAULT_ANGLE = 135
local BUTTON_RADIUS = 100
local DRAG_THRESHOLD = 5

local buttonAngle = DEFAULT_ANGLE
local dragStartX = 0
local dragStartY = 0
local isDragging = false


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

minimapButton:EnableMouse(true)


-- ============================================================
-- BUTTON POSITION
-- ============================================================

local function UpdateButtonPosition()

    local angleRadians = math.rad(buttonAngle)

    local x = math.cos(angleRadians) * BUTTON_RADIUS
    local y = math.sin(angleRadians) * BUTTON_RADIUS

    minimapButton:ClearAllPoints()

    minimapButton:SetPoint(
        "CENTER",
        Minimap,
        "CENTER",
        x,
        y
    )

end

local function SaveButtonPosition()

    VaultSCANDB = VaultSCANDB or {}
    VaultSCANDB.minimap = VaultSCANDB.minimap or {}

    VaultSCANDB.minimap.angle = buttonAngle

end

local function LoadButtonPosition()

    if type(VaultSCANDB) == "table"
        and type(VaultSCANDB.minimap) == "table"
        and type(VaultSCANDB.minimap.angle) == "number" then

        buttonAngle = VaultSCANDB.minimap.angle

    end

    UpdateButtonPosition()

end


-- ============================================================
-- BUTTON APPEARANCE
-- ============================================================

local border = minimapButton:CreateTexture(nil, "OVERLAY")

border:SetTexture(
    "Interface\\Minimap\\MiniMap-TrackingBorder"
)

border:SetSize(54, 54)
border:SetPoint("TOPLEFT")


local icon = minimapButton:CreateTexture(nil, "ARTWORK")

icon:SetTexture(
    "Interface\\Icons\\INV_Misc_Coin_01"
)

icon:SetSize(20, 20)
icon:SetPoint("CENTER")


-- Subtle gold glow displayed only while hovering.
local hoverGlow = minimapButton:CreateTexture(nil, "OVERLAY")

hoverGlow:SetTexture(
    "Interface\\Buttons\\UI-ActionButton-Border"
)

hoverGlow:SetBlendMode("ADD")
hoverGlow:SetVertexColor(1, 0.82, 0.25, 0.6)
hoverGlow:SetSize(42, 42)
hoverGlow:SetPoint("CENTER")
hoverGlow:Hide()


-- ============================================================
-- DRAGGING
-- ============================================================

local function UpdateDragPosition()

    local cursorX, cursorY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()

    cursorX = cursorX / scale
    cursorY = cursorY / scale

    local centerX, centerY = Minimap:GetCenter()

    if not centerX or not centerY then
        return
    end

    local deltaX = cursorX - centerX
    local deltaY = cursorY - centerY

    buttonAngle = math.deg(
        math.atan2(deltaY, deltaX)
    )

    UpdateButtonPosition()

end

minimapButton:SetScript("OnMouseDown", function(self, button)

    if button ~= "LeftButton" then
        return
    end

    dragStartX, dragStartY = GetCursorPosition()
    isDragging = false

    self:SetScript("OnUpdate", function()

        local cursorX, cursorY = GetCursorPosition()

        local deltaX = cursorX - dragStartX
        local deltaY = cursorY - dragStartY

        if not isDragging then

            local distanceSquared =
                (deltaX * deltaX) + (deltaY * deltaY)

            if distanceSquared >=
                (DRAG_THRESHOLD * DRAG_THRESHOLD) then

                isDragging = true

                GameTooltip:Hide()
            end

        end

        if isDragging then
            UpdateDragPosition()
        end

    end)

end)

minimapButton:SetScript("OnMouseUp", function(self, button)

    if button ~= "LeftButton" then
        return
    end

    self:SetScript("OnUpdate", nil)

    if isDragging then

        SaveButtonPosition()
        isDragging = false

    else

        VaultSCAN.ToggleWindow()

    end

end)


-- ============================================================
-- TOOLTIP AND HOVER
-- ============================================================

minimapButton:SetScript("OnEnter", function(self)

    hoverGlow:Show()

    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("VaultSCAN", 1, 0.82, 0)

    GameTooltip:AddLine(
        "Left-click to open your wealth dashboard.",
        1, 1, 1
    )

    GameTooltip:AddLine(
        "Left-click and drag to move this button.",
        0.7, 0.7, 0.7
    )

    GameTooltip:Show()

end)

minimapButton:SetScript("OnLeave", function(self)

    hoverGlow:Hide()
    GameTooltip:Hide()

end)


-- ============================================================
-- INITIALIZATION
-- ============================================================

local initFrame = CreateFrame("Frame")

initFrame:RegisterEvent("PLAYER_LOGIN")

initFrame:SetScript("OnEvent", function()
    LoadButtonPosition()
end)

UpdateButtonPosition()
