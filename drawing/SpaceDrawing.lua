local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

---------------------------------------------------------------------
local controlPool

local function AcquireControl()
    local control, key = controlPool:AcquireObject()

    control:SetHidden(false)
    control:SetScale(0.01)

    return control, key
end


---------------------------------------------------------------------
-- Core
---------------------------------------------------------------------
local function CreateSpaceControl(texture, x, y, z, width, height, color, orientation)
    local control, key = AcquireControl()

    -- Position is a bit different from RenderSpace
    local oX, oY, oZ = GuiRender3DPositionToWorldPosition(0, 0, 0)
    local tX = (x - oX) / 100
    local tY = y / 100
    local tZ = (z - oZ) / 100
    control:SetTransformOffset(tX, tY, tZ)

    local textureControl = control:GetNamedChild("Texture")
    textureControl:SetTexture(texture)
    textureControl:SetColor(unpack(color))

    -- TODO: different width and height
    control:SetTransformNormalizedOriginPoint(0.5, 0.5)
    control:SetTransformScale(width)

    -- pitch, yaw, roll
    control:SetTransformRotation(unpack(orientation))
    return control, key
end
Draw.CreateSpaceControl = CreateSpaceControl

local function ReleaseSpaceControl(key)
    local icon = Draw.activeIcons[key]

    icon.control:SetHidden(true)
    controlPool:ReleaseObject(key)
end
Draw.ReleaseSpaceControl = ReleaseSpaceControl


---------------------------------------------------------------------
-- Testing
---------------------------------------------------------------------
local function TestSpacePoop()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    CreateSpaceControl("CrutchAlerts/assets/poop.dds", x, y, z, 1, 1, {1, 1, 1}, {0, 0, 0})
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
