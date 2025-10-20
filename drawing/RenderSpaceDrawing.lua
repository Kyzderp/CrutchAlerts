local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

---------------------------------------------------------------------
-- wow, using a pool for the first time instead of making my own janky version
local controlPool

local function AcquireTexture()
    local control, key = controlPool:AcquireObject()

    control:SetHidden(false)
    control:Create3DRenderSpace()
    control:SetColor(1, 1, 1, 1)

    return control, key
end

-- Pitch, yaw, roll
local function IsDOF(value)
    return type(value) == "number"
end


---------------------------------------------------------------------
-- The core 3D code, at its simplest... or close to it
---------------------------------------------------------------------
local function CreateRenderSpaceTexture(texture, x, y, z, width, height, color, useDepthBuffer, orientation)
    local control, key = AcquireTexture()
    control:SetTexture(texture)
    control:SetColor(unpack(color))
    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y, z))
    control:Set3DLocalDimensions(width, height)
    control:Set3DRenderSpaceUsesDepthBuffer(useDepthBuffer)

    -- pitch, yaw, roll
    control:Set3DRenderSpaceOrientation(unpack(orientation))
    return control, key
end
Draw.CreateRenderSpaceTexture = CreateRenderSpaceTexture

local function ReleaseRenderSpaceTexture(key)
    local icon = Draw.activeIcons[key]

    icon.control:SetHidden(true)
    icon.control:Destroy3DRenderSpace()

    controlPool:ReleaseObject(key)
end
Draw.ReleaseRenderSpaceTexture = ReleaseRenderSpaceTexture


---------------------------------------------------------------------
-- Init 3D render space and stuff idk
---------------------------------------------------------------------
function Draw.InitializeRenderSpace()
    CrutchAlertsDrawingCamera:Create3DRenderSpace()
    controlPool = ZO_ControlPool:New("CrutchAlertsDrawingTexture", CrutchAlertsDrawing)
end
