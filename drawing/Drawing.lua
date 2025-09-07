CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.Drawing = CrutchAlerts.Drawing or {}
local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

---------------------------------------------------------------------
-- wow, using a pool for the first time instead of making my own janky version
local controlPool
Draw.activeIcons = {} -- {[key] = {control = control, faceCamera = true, x = x, y = y, z = z, updateFunc = function() end}}
-- /script d(CrutchAlerts.Drawing.activeIcons)

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
-- forwardRightUp = {{fX}}
local function Create3DControl(texture, x, y, z, width, height, color, useDepthBuffer, forwardRightUp)
    local control, key = AcquireTexture()
    control:SetTexture(texture)
    control:SetColor(unpack(color))
    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y, z))
    control:Set3DLocalDimensions(width, height)
    control:Set3DRenderSpaceUsesDepthBuffer(useDepthBuffer)

    if (forwardRightUp) then
        control:Set3DRenderSpaceForward(unpack(forwardRightUp[1]))
        control:Set3DRenderSpaceRight(unpack(forwardRightUp[2]))
        control:Set3DRenderSpaceUp(unpack(forwardRightUp[3]))
    end
    return control, key
end

---------------------------------------------------------------------
-- Creating and removing textures
--
-- It is NOT recommended to use these functions directly! This is the
-- common entry point for several different "types" of textures.
--
-- See AttachedIcons.lua for a framework for showing icons above
-- group members' heads, with prioritization.
-- See PlacedTextures.lua for functions for placing marker icons in
-- the world, as well as "oriented" textures, e.g. circles on the
-- ground.
--
-- Those other functions are recommended because they respect the
-- user's settings for use of depth buffers for different types, as
-- well as other settings for group member icons, which are set in
-- CrutchAlerts settings.
--
-- @param updateFunc - function with params: control, setPositionFunc
--     control - the actual texture control, can be used to change color
--     setPositionFunc - function(x, y, z), called every update tick
---------------------------------------------------------------------
local function CreateWorldTexture(texture, x, y, z, width, height, color, useDepthBuffer, faceCamera, forwardRightUp, updateFunc)
    local control, key = Create3DControl(texture, x, y, z, width, height, color, useDepthBuffer, forwardRightUp)
    Draw.activeIcons[key] = {
        control = control,
        faceCamera = faceCamera,
        x = x,
        y = y,
        z = z,
        updateFunc = updateFunc,
    }
    Draw.MaybeStartPolling()

    CrutchAlerts.dbgSpam("Created icon |t100%:100%:" .. texture .. "|t key " .. tostring(key))
    return key
end
Draw.CreateWorldTexture = CreateWorldTexture

local function RemoveWorldTexture(key)
    if (not Draw.activeIcons[key]) then
        CrutchAlerts.dbgOther("|cFF0000Icon \"" .. tostring(key) .. "\" does not exist")
        return
    end
    CrutchAlerts.dbgSpam("Removing icon " .. tostring(key))

    local icon = Draw.activeIcons[key]
    icon.control:Destroy3DRenderSpace()
    icon.control:SetHidden(true)
    controlPool:ReleaseObject(key)
    Draw.activeIcons[key] = nil
    Draw.MaybeStopPolling()
end
Draw.RemoveWorldTexture = RemoveWorldTexture


---------------------------------------------------------------------
-- Testing for now
---------------------------------------------------------------------
local function TestJet(size)
    local start = 90000
    local forwardRightUp = {
        {0, 0, 1},
        {-1, 0, 0},
        {0, 1, 0},
    }
    local width = size or 20
    local height = width / 600 * 128
    local key = CreateWorldTexture("CrutchAlerts/assets/jet.dds", 98000, 44000, 101500, width, height, {1, 1, 1, 1}, true, false, forwardRightUp, function(control, setPositionFunc)
        start = start + 15
        setPositionFunc(start, 44000, 106000)
    end)

    zo_callLater(function() RemoveWorldTexture(key) end, 30000)
end
Draw.TestJet = TestJet
-- /script CrutchAlerts.Drawing.TestJet()
-- /script d("|t100%:100%:CrutchAlerts/assets/jet.dds|t")
-- /script d("|t100%:100%:CrutchAlerts/assets/directional/N.dds|t")

local lastKey
local function TestCircle(radius, x, y, z)
    if (lastKey) then
        RemoveWorldTexture(lastKey)
    end
    lastKey = Draw.CreateGroundCircle(x, y, z, radius)
end
Draw.TestCircle = TestCircle
--[[
/script CrutchAlerts.Drawing.TestCircle()
/script CrutchAlerts.Drawing.TestCircle(nil, nil, nil, nil)
/script
Set3DRenderSpaceToCurrentCamera("CrutchAlertsDrawingCamera")
d(CrutchAlertsDrawingCamera:Get3DRenderSpaceForward())
d(CrutchAlertsDrawingCamera:Get3DRenderSpaceRight())
d(CrutchAlertsDrawingCamera:Get3DRenderSpaceUp())
]]


---------------------------------------------------------------------
-- Init 3D render space and stuff idk
---------------------------------------------------------------------
function Draw.Initialize()
    CrutchAlertsDrawingCamera:Create3DRenderSpace()
    controlPool = ZO_ControlPool:New("CrutchAlertsDrawingTexture", CrutchAlertsDrawing)
    Draw.InitializeAttachedIcons()
end
