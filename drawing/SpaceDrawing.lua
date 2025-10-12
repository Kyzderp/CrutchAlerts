local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

---------------------------------------------------------------------
local controlPool

local function AcquireControl()
    local control, key = controlPool:AcquireObject()

    control:SetHidden(false)
    control:SetTransformNormalizedOriginPoint(0.5, 0.5)

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
    control:SetScale(0.01)

    local textureControl = control:GetNamedChild("Texture")
    textureControl:SetTexture(texture)
    textureControl:SetColor(unpack(color))

    -- TODO: width, height

    -- if (orientation) then
    --     if (IsDOF(orientation[1])) then
    --         -- pitch, yaw, roll
    --         control:SetTransformRotation(unpack(orientation))
    --     else
    --         -- forward, right, up
    --         control:Set3DRenderSpaceForward(unpack(orientation[1]))
    --         control:Set3DRenderSpaceRight(unpack(orientation[2]))
    --         control:Set3DRenderSpaceUp(unpack(orientation[3]))
    --     end
    -- end
    return control, key
end
Draw.CreateSpaceControl = CreateSpaceControl


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
]]

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Draw.InitializeSpace()
    controlPool = ZO_ControlPool:New("CrutchAlertsSpaceControl", CrutchAlertsSpace)

    -- TODO: fragment?
end
