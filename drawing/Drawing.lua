CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.Drawing = CrutchAlerts.Drawing or {}
local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

---------------------------------------------------------------------
-- wow, using a pool for the first time instead of making my own janky version
local controlPool
local activeIcons = {} -- {[key] = {control = control, faceCamera = true}}

local function AcquireTexture()
    local control, key = controlPool:AcquireObject()

    control:SetHidden(false)
    control:Create3DRenderSpace()
    control:SetColor(1, 1, 1, 1)

    return control, key
end

---------------------------------------------------------------------
-- The core 3D code, at its simplest... or close to it
---------------------------------------------------------------------
local function Create3DControl(texture, x, y, z, width, height, color, useDepthBuffer)
    local control, key = AcquireTexture()
    control:SetTexture(texture)
    control:SetColor(unpack(color))
    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y, z))
    control:Set3DLocalDimensions(width, height)
    control:Set3DRenderSpaceUsesDepthBuffer(useDepthBuffer)
    return control, key
end

---------------------------------------------------------------------
-- Creating and removing icons
---------------------------------------------------------------------
local function CreateWorldIcon(texture, x, y, z, width, height, color, useDepthBuffer, faceCamera)
    local control, key = Create3DControl(texture, x, y, z, width, height, color, useDepthBuffer)
    activeIcons[key] = {
        control = control,
        faceCamera = faceCamera,
    }

    CrutchAlerts.dbgSpam("Created icon |t100%:100%:" .. texture .. "|t key " .. tostring(key))
    return key
end

local function RemoveWorldIcon(key)
    if (not activeIcons[key]) then
        CrutchAlerts.dbgOther("|cFF0000Icon \"" .. tostring(key) .. "\" does not exist")
        return
    end
    CrutchAlerts.dbgSpam("Removing icon " .. tostring(key))

    local icon = activeIcons[key]
    icon.control:Destroy3DRenderSpace()
    icon.control:SetHidden(true)
    controlPool:ReleaseObject(key)
    activeIcons[key] = nil
end

---------------------------------------------------------------------
-- For calling from WorldIcons, migration from OSI
---------------------------------------------------------------------
local function EnableWorldIcon(texture, x, y, z, size, color)
    color = color or {1, 1, 1, 1}
    return CreateWorldIcon(texture, x, y, z, size / 150, size / 150, color, false, true)
end
Draw.EnableWorldIcon = EnableWorldIcon

local function DisableWorldIcon(key)
    RemoveWorldIcon(key)
end
Draw.DisableWorldIcon = DisableWorldIcon

---------------------------------------------------------------------
-- Testing for now
---------------------------------------------------------------------
local num = 1

local function TestBooger(faceCamera, color)
    color = color or {1, 1, 1, 1}

    local _, x, y, z = GetUnitWorldPosition("player")

    CreateWorldIcon("esoui/art/icons/targetdummy_voriplasm_01.dds", x, y + 50, z, 1, 1, color, true, faceCamera)
end
Draw.TestBooger = TestBooger
-- /script CrutchAlerts.Drawing.TestBooger(true)
-- /script CrutchAlerts.Drawing.TestBooger(false)

---------------------------------------------------------------------
-- Update
-- This is run continuously to update icons if needed
---------------------------------------------------------------------
-- TODO: only run this when there's stuff that needs it
local function DoUpdate()
    -- Get the camera matrix once per update; the same values are applied to each control
    local fX, fY, fZ
    local rX, rY, rZ
    local uX, uY, uZ

    for _, icon in pairs(activeIcons) do
        if (icon.faceCamera) then
            if (not fX) then
                Set3DRenderSpaceToCurrentCamera("CrutchAlertsDrawingCamera")
                fX, fY, fZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceForward()
                rX, rY, rZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceRight()
                uX, uY, uZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceUp()
            end

            icon.control:Set3DRenderSpaceForward(fX, fY, fZ)
            icon.control:Set3DRenderSpaceRight(rX, rY, rZ)
            icon.control:Set3DRenderSpaceUp(uX, uY, uZ)
        end
    end
end

---------------------------------------------------------------------
-- Init 3D render space and stuff idk
---------------------------------------------------------------------
function Draw.Initialize()
    CrutchAlertsDrawingCamera:Create3DRenderSpace()
    controlPool = ZO_ControlPool:New("CrutchAlertsDrawingTexture", CrutchAlertsDrawing)

    EVENT_MANAGER:RegisterForUpdate(CrutchAlerts.name .. "DrawingUpdate", 10, DoUpdate)
end
