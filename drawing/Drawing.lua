CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.Drawing = CrutchAlerts.Drawing or {}
local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

---------------------------------------------------------------------
-- wow, using a pool for the first time instead of making my own janky version
local controlPool -- TODO
local activeIcons = {} -- {[name] = {control = control, faceCamera = true, key = key}}

local function AcquireTexture()
    local control, key = controlPool:AcquireObject()

    -- TODO: reset stuff here once I start poking that
    control:SetHidden(false)

    return control, key
end

---------------------------------------------------------------------
-- The core 3D code, at its simplest... or close to it
---------------------------------------------------------------------
local function Create3DControl(name, texture, x, y, z, width, height, useDepthBuffer)
    -- local control = WINDOW_MANAGER:CreateControl("$(parent)" .. name, CrutchAlertsDrawing, CT_TEXTURE)
    local control, key = AcquireTexture()
    control:SetTexture(texture)
    control:Create3DRenderSpace()
    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y, z))
    control:Set3DLocalDimensions(width, height)
    control:Set3DRenderSpaceUsesDepthBuffer(useDepthBuffer)
    return control, key
end

---------------------------------------------------------------------
local function CreateWorldIcon(name, texture, x, y, z, width, height, useDepthBuffer, faceCamera)
    if (activeIcons[name]) then
        CrutchAlerts.dbgOther("|cFF0000Icon \"" .. name .. "\" already exists")
        return
    end

    CrutchAlerts.dbgSpam("Creating icon " .. name)
    local control, key = Create3DControl(name, texture, x, y, z, width, height, useDepthBuffer)
    activeIcons[name] = {
        control = control,
        faceCamera = faceCamera,
        key = key,
    }
end

local function RemoveWorldIcon(name)
    if (not activeIcons[name]) then
        CrutchAlerts.dbgOther("|cFF0000Icon \"" .. name .. "\" does not exist")
        return
    end

    CrutchAlerts.dbgSpam("Removing icon " .. name)
    local icon = activeIcons[name]
    icon.control:Destroy3DRenderSpace()
    icon.control:SetHidden(true)
    controlPool:ReleaseObject(icon.key)
    activeIcons[name] = nil
end

---------------------------------------------------------------------
-- For calling from WorldIcons, migration from OSI
---------------------------------------------------------------------
local function EnableWorldIcon(name, texture, x, y, z, size)
    CreateWorldIcon(name, texture, x, y, z, size / 150, size / 150, false, true)
end
Draw.EnableWorldIcon = EnableWorldIcon

local function DisableWorldIcon(name)
    RemoveWorldIcon(name)
end
Draw.DisableWorldIcon = DisableWorldIcon

---------------------------------------------------------------------
-- Testing for now
---------------------------------------------------------------------
local num = 1

local function TestBooger(faceCamera)
    local name = "Icon" .. tostring(num)
    num = num + 1

    local _, x, y, z = GetUnitWorldPosition("player")

    CreateWorldIcon(name, "esoui/art/icons/targetdummy_voriplasm_01.dds", x, y + 50, z, 1, 1, true, faceCamera)
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
    Set3DRenderSpaceToCurrentCamera("CrutchAlertsDrawingCamera")

    -- Get the camera matrix once per update; the same values are applied to each control
    local fX, fY, fZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceForward()
    local rX, rY, rZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceRight()
    local uX, uY, uZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceUp()

    for name, icon in pairs(activeIcons) do
        if (icon.faceCamera) then
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

SLASH_COMMANDS["/testcrutch"] = function() TestBooger() end
