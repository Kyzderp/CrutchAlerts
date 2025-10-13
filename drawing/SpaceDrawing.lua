local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

---------------------------------------------------------------------
local controlPool

local function AcquireControl()
    local control, key = controlPool:AcquireObject()

    control:SetHidden(false)
    control:SetScale(0.01)

    -- To not clash with RenderSpace keys when put in Draw.activeIcons together
    local spaceKey = "Space" .. key
    return control, spaceKey
end


---------------------------------------------------------------------
-- Core
---------------------------------------------------------------------
local function CreateSpaceControlCommon(x, y, z, orientation)
    local control, key = AcquireControl()
    control:SetTransformNormalizedOriginPoint(0.5, 0.5)

    -- Position is a bit different from RenderSpace
    local oX, oY, oZ = GuiRender3DPositionToWorldPosition(0, 0, 0)
    local tX = (x - oX) / 100
    local tY = y / 100
    local tZ = (z - oZ) / 100
    control:SetTransformOffset(tX, tY, tZ)

    -- pitch, yaw, roll
    control:SetTransformRotation(unpack(orientation))
    return control, key
end

local function ReleaseSpaceControl(key)
    local icon = Draw.activeIcons[key]

    icon.control:SetHidden(true)
    icon.control:GetNamedChild("Texture"):SetHidden(true)
    icon.control:GetNamedChild("Label"):SetHidden(true)

    local realKey = string.sub(key, 6)
    controlPool:ReleaseObject(realKey)
end
Draw.ReleaseSpaceControl = ReleaseSpaceControl


---------------------------------------------------------------------
-- Texture, similar to RenderSpace
-- DO NOT CALL THIS DIRECTLY. See Draw.CreateWorldTexture
---------------------------------------------------------------------
local function CreateSpaceTexture(texture, x, y, z, width, height, color, orientation)
    local control, key = CreateSpaceControlCommon(x, y, z, orientation)

    local textureControl = control:GetNamedChild("Texture")
    textureControl:SetHidden(false)
    textureControl:SetTexture(texture)
    textureControl:SetColor(unpack(color))

    -- TODO: width and height?
    control:SetTransformScale(width)

    return control, key
end
Draw.CreateSpaceTexture = CreateSpaceTexture


---------------------------------------------------------------------
-- Text label
---------------------------------------------------------------------
local function CreateSpaceLabel(text, x, y, z, size, color, orientation)
    local control, key = CreateSpaceControlCommon(x, y, z, orientation)

    local labelControl = control:GetNamedChild("Label")
    labelControl:SetHidden(false)
    labelControl:SetFont(Crutch.GetStyles().GetMarkerFont(size))
    labelControl:SetColor(unpack(color))
    labelControl:SetText(text)
    labelControl:SetDimensions(2000, 2000)
    labelControl:SetDimensions(labelControl:GetTextWidth(), labelControl:GetTextHeight())

    -- TODO?
    control:SetTransformScale(1)

    return control, key
end
Draw.CreateSpaceLabel = CreateSpaceLabel
--[[
/script local _, x, y, z = GetUnitRawWorldPosition("player") CrutchAlerts.Drawing.CreateSpaceLabel("asdfasdfs fdsfs", x, y, z, 120, {1, 1, 1, 1}, {0, 0, 0})
]]


---------------------------------------------------------------------
-- Testing
---------------------------------------------------------------------
local function TestSpacePoop()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    CreateSpaceTexture("CrutchAlerts/assets/poop.dds", x, y, z, 1, 1, {1, 1, 1}, {0, 0, 0})
end
Draw.TestSpacePoop = TestSpacePoop
--[[
/script CrutchAlerts.Drawing.TestSpacePoop()
/tb CrutchAlertsSpaceCrutchAlertsSpaceControl1
]]

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Draw.InitializeSpace()
    controlPool = ZO_ControlPool:New("CrutchAlertsSpaceControl", CrutchAlertsSpace)

    -- TODO: fragment?
end
