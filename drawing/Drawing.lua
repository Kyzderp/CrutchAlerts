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
--     control - the actual texture control, usage TBD...
--     setPositionFunc - function(x, y, z)
--     setColorFunc - function(r, g, b, a)
--     setOrientationFunc - function(forward, right, up). should not be called for icons that face camera
---------------------------------------------------------------------
local function CreateWorldTexture(texture, x, y, z, width, height, color, useDepthBuffer, faceCamera, forwardRightUp, updateFunc)
    local control, key = Create3DControl(texture, x, y, z, width, height, color, useDepthBuffer, forwardRightUp)
    Draw.activeIcons[key] = {
        control = control,
        faceCamera = faceCamera,
        x = x,
        y = y,
        z = z,
        color = {r = color[1], g = color[2], b = color[3], a = color[4]},
        forwardRightUp = forwardRightUp and {forward = forwardRightUp[1], right = forwardRightUp[2], up = forwardRightUp[3]} or {},
        updateFunc = updateFunc,
    }
    Draw.MaybeStartPolling()

    CrutchAlerts.dbgSpam("Created texture |t100%:100%:" .. texture .. "|t key " .. tostring(key))
    return key
end
Draw.CreateWorldTexture = CreateWorldTexture

local function RemoveWorldTexture(key)
    if (not Draw.activeIcons[key]) then
        CrutchAlerts.dbgOther("|cFF0000Icon \"" .. tostring(key) .. "\" does not exist")
        return
    end
    CrutchAlerts.dbgSpam("Removing texture " .. tostring(key))

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
]]

-- Example usage of some PlacedTextures APIs
local keys = {}
local function TestPoop(radius)
    -- Calling function should keep track of keys that are returned,
    -- so that the textures can be removed later
    for _, key in ipairs(keys) do
        RemoveWorldTexture(key)
    end
    keys = {}

    local _, x, y, z = GetUnitRawWorldPosition("player")
    radius = radius or 3

    -- Places circle at player's feet
    local function CircleFunc(_, setPositionFunc, setColorFunc, setOrientationFunc)
        -- Make circle follow the player
        local _, x, y, z = GetUnitRawWorldPosition("player")
        setPositionFunc(x, y, z)

        -- Make color change every update
        local time = GetGameTimeMilliseconds() % 2000 / 2000
        setColorFunc(Crutch.ConvertHSLToRGB(time, 1, 0.5))
    end
    table.insert(keys, Draw.CreateGroundCircle(x, y, z, radius, nil, nil, CircleFunc))

    -- Places poops orbiting the player
    local numPoops = 20
    local cycleTime = 3000
    for i = 1, numPoops do
        local function PoopFunc(_, setPositionFunc, setColorFunc, setOrientationFunc)
            local _, x, y, z = GetUnitRawWorldPosition("player")
            local time = (GetGameTimeMilliseconds() + i / numPoops * cycleTime) % cycleTime / cycleTime

            -- Make ring of poops follow the player, but orbiting at a distance
            local angle = time * 2 * math.pi
            local poopX = x + radius * 100 * math.cos(angle)
            local poopZ = z + radius * 100 * math.sin(angle)
            setPositionFunc(poopX, y + 150, poopZ)

            -- Make color change every update
            setColorFunc(Crutch.ConvertHSLToRGB(time, 1, 0.5))

            -- Make orientation change every update. This faces them towards player
            local forward = {x - poopX, 0, z - poopZ}
            local right = {z - poopZ, 0, poopX - x}
            local up = {0, 1, 0}
            setOrientationFunc(forward, right, up)
        end

        table.insert(keys, Draw.CreateOrientedTexture("CrutchAlerts/assets/poop.dds", x, y, z, 0.3, nil, nil, PoopFunc))
    end
end
Draw.TestPoop = TestPoop
--[[
/script CrutchAlerts.Drawing.TestPoop()
]]


---------------------------------------------------------------------
-- Init 3D render space and stuff idk
---------------------------------------------------------------------
function Draw.Initialize()
    CrutchAlertsDrawingCamera:Create3DRenderSpace()
    controlPool = ZO_ControlPool:New("CrutchAlertsDrawingTexture", CrutchAlertsDrawing)
    Draw.InitializeAttachedIcons()
end
