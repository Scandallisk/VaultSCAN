local addonName, VaultSCAN = ...
local DEFAULT_ANGLE = 135
local BUTTON_RADIUS = 100
local DRAG_THRESHOLD = 5
local angle = DEFAULT_ANGLE
local startX, startY = 0, 0
local dragging = false

local button = CreateFrame("Button", "VaultSCANMinimapButton", Minimap)
button:SetSize(32, 32)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(Minimap:GetFrameLevel() + 5)
button:EnableMouse(true)

local function Position()
    local radians = math.rad(angle)
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(radians) * BUTTON_RADIUS, math.sin(radians) * BUTTON_RADIUS)
end

local function Save()
    VaultSCANDB = VaultSCANDB or {}
    VaultSCANDB.minimap = VaultSCANDB.minimap or {}
    VaultSCANDB.minimap.angle = angle
end

local function Load()
    if type(VaultSCANDB) == "table" and type(VaultSCANDB.minimap) == "table"
        and type(VaultSCANDB.minimap.angle) == "number" then
        angle = VaultSCANDB.minimap.angle
    end
    Position()
end

local border = button:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(54, 54)
border:SetPoint("TOPLEFT")

local icon = button:CreateTexture(nil, "ARTWORK")
icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
icon:SetSize(20, 20)
icon:SetPoint("CENTER")

local glow = button:CreateTexture(nil, "OVERLAY")
glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
glow:SetBlendMode("ADD")
glow:SetVertexColor(1, 0.82, 0.25, 0.6)
glow:SetSize(42, 42)
glow:SetPoint("CENTER")
glow:Hide()

local function DragPosition()
    local cursorX, cursorY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    cursorX, cursorY = cursorX / scale, cursorY / scale
    local centerX, centerY = Minimap:GetCenter()
    if not centerX or not centerY then return end
    angle = math.deg(math.atan2(cursorY - centerY, cursorX - centerX))
    Position()
end

button:SetScript("OnMouseDown", function(self, mouseButton)
    if mouseButton ~= "LeftButton" then return end
    startX, startY = GetCursorPosition()
    dragging = false
    self:SetScript("OnUpdate", function()
        local x, y = GetCursorPosition()
        local dx, dy = x - startX, y - startY
        if not dragging and dx * dx + dy * dy >= DRAG_THRESHOLD * DRAG_THRESHOLD then
            dragging = true
            GameTooltip:Hide()
        end
        if dragging then DragPosition() end
    end)
end)

button:SetScript("OnMouseUp", function(self, mouseButton)
    if mouseButton ~= "LeftButton" then return end
    self:SetScript("OnUpdate", nil)
    if dragging then Save() else VaultSCAN.ToggleWindow() end
    dragging = false
end)

button:SetScript("OnEnter", function(self)
    glow:Show()
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("VaultSCAN", 1, 0.82, 0)
    GameTooltip:AddLine("Left-click to open your wealth dashboard.", 1, 1, 1)
    GameTooltip:AddLine("Left-click and drag to move this button.", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)
button:SetScript("OnLeave", function() glow:Hide(); GameTooltip:Hide() end)

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", Load)
Position()
