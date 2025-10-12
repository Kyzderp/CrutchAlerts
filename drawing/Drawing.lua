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

-- Just a workaround for now; textures fade in when they are loaded for the first time,
-- but that doesn't look good when used for curse countdown, so load them in before
-- they need to be used.
local function LoadTextures(textures)
    local control, key = controlPool:AcquireObject()
    control:SetHidden(true)
    for _, texture in ipairs(textures) do
        control:SetTexture(texture)
    end
    controlPool:ReleaseObject(key)
end
Draw.LoadTextures = LoadTextures

-- Pitch, yaw, roll
local function IsDOF(value)
    return type(value) == "number"
end

---------------------------------------------------------------------
-- The core 3D code, at its simplest... or close to it
---------------------------------------------------------------------
local function Create3DControl(texture, x, y, z, width, height, color, useDepthBuffer, orientation)
    local control, key = AcquireTexture()
    control:SetTexture(texture)
    control:SetColor(unpack(color))
    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y, z))
    control:Set3DLocalDimensions(width, height)
    control:Set3DRenderSpaceUsesDepthBuffer(useDepthBuffer)

    if (orientation) then
        if (IsDOF(orientation[1])) then
            -- pitch, yaw, roll
            control:Set3DRenderSpaceOrientation(unpack(orientation))
        else
            -- forward, right, up
            control:Set3DRenderSpaceForward(unpack(orientation[1]))
            control:Set3DRenderSpaceRight(unpack(orientation[2]))
            control:Set3DRenderSpaceUp(unpack(orientation[3]))
        end
    end
    return control, key
end

---------------------------------------------------------------------
-- Icon callbacks on update
---------------------------------------------------------------------
-- Callback to set position, keeping old if nil
local function SetPosition(icon, x, y, z)
    if (icon.x ~= x or icon.z ~= z or icon.y ~= y) then
        icon.x = x or icon.x
        icon.y = y or icon.y
        icon.z = z or icon.z
        icon.control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(icon.x, icon.y, icon.z))
    end
end

-- Callback to set color, keeping old if nil
local function SetColor(icon, r, g, b, a)
    -- Not sure if doing this is actually more efficient
    local changed = false
    if (r and icon.color.r ~= r) then
        icon.color.r = r
        changed = true
    end
    if (g and icon.color.g ~= g) then
        icon.color.g = g
        changed = true
    end
    if (b and icon.color.b ~= b) then
        icon.color.b = b
        changed = true
    end
    if (a and icon.color.a ~= a) then
        icon.color.a = a
        changed = true
    end
    if (changed) then
        icon.control:SetColor(icon.color.r, icon.color.g, icon.color.b, icon.color.a)
    end
end

-- Callback to set orientation, keeping old if nil
-- Either ({fX, fY, fZ}, {rX, rY, rZ}, {uX, uY, uZ}) or (pitch, yaw, roll)
local function SetOrientation(icon, first, second, third)
    local value = first or second or third
    local isDOF = IsDOF(value)
    if (isDOF == IsDOF(icon.orientation)) then
        first = first or icon.orientation.first
        second = second or icon.orientation.second
        third = third or icon.orientation.third
    else
        -- New orientation type is different from old
        if (not first and not second and not third) then
            return -- It's fine if it's all nil, but why is it being called...?
        end

        if (not first or not second or not third) then
            CrutchAlerts.msg("|cFF0000Caller attempted to set different orientation axis system but not all values are specified!")
            return
        end
    end

    -- TODO: fix all this garbo
    if (isDOF) then
        -- Pitch, Yaw, Roll
        if (icon.orientation.first ~= first or icon.orientation.second ~= second or icon.orientation.third ~= third) then
            icon.orientation.first = first
            icon.orientation.second = second
            icon.orientation.third = third
            icon.control:Set3DRenderSpaceOrientation(first, second, third)
        end
    else
        -- Forward, Right, Up
        icon.orientation.first = first
        icon.control:Set3DRenderSpaceForward(unpack(first))
        icon.orientation.second = second
        icon.control:Set3DRenderSpaceRight(unpack(second))
        icon.orientation.third = third
        icon.control:Set3DRenderSpaceUp(unpack(third))
    end
end

-- Callback to set texture, keeping old if nil
local function SetTexture(icon, path)
    if (path and icon.texture ~= path) then
        icon.texture = path
        icon.control:SetTexture(path)
    end
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
-- @param updateFunc - function called in Update.lua with param icon.
-- The icon can then be updated using calls like:
--     icon:SetPosition(x, y, z)
--     icon:SetColor(r, g, b, a)
--     icon:SetOrientation(forward, right, up) or icon:SetOrientation(pitch, yaw, roll). Should not be called for icons that face camera
--     icon:SetTexture(path)
-- Since this is called many times a second, the caller should take
-- care to make it performant, e.g. do not create tables or functions
-- on every call.
---------------------------------------------------------------------
local function CreateWorldTexture(texture, x, y, z, width, height, color, useDepthBuffer, faceCamera, orientation, updateFunc)
    local control, key
    control, key = Create3DControl(texture, x, y, z, width, height, color, useDepthBuffer, orientation)
    Draw.activeIcons[key] = {
        isSpace = false, -- TODO
        control = control,
        faceCamera = faceCamera,
        x = x,
        y = y,
        z = z,
        color = {r = color[1], g = color[2], b = color[3], a = color[4]},
        orientation = orientation and {first = orientation[1], second = orientation[2], third = orientation[3]} or {},
        texture = texture,
        updateFunc = updateFunc,

        -- Callback functions
        SetPosition = SetPosition,
        SetColor = SetColor,
        SetOrientation = SetOrientation,
        SetTexture = SetTexture,
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
    local function CircleFunc(icon)
        -- Make circle follow the player
        local _, x, y, z = GetUnitRawWorldPosition("player")
        icon:SetPosition(x, y + 5, z) -- Small y bump because of clipping with depth buffers on

        -- Make color change every update
        local time = GetGameTimeMilliseconds() % 2000 / 2000
        icon:SetColor(Crutch.ConvertHSLToRGB(time, 1, 0.5))
    end
    table.insert(keys, Draw.CreateGroundCircle(x, y, z, radius, nil, nil, CircleFunc))

    -- Places poops orbiting the player
    local numPoops = 20
    local cycleTime = 3000
    for i = 1, numPoops do
        local forward = {}
        local right = {}
        local up = {}
        local function PoopFunc(icon)
            local _, x, y, z = GetUnitRawWorldPosition("player")
            local time = (GetGameTimeMilliseconds() + i / numPoops * cycleTime) % cycleTime / cycleTime

            -- Make ring of poops follow the player, but orbiting at a distance
            local angle = time * 2 * math.pi
            local poopX = x + radius * 100 * math.cos(angle)
            local poopZ = z + radius * 100 * math.sin(angle)
            icon:SetPosition(poopX, y + 150, poopZ)

            -- Make color change every update
            icon:SetColor(Crutch.ConvertHSLToRGB(time, 1, 0.5))

            -- Make orientation change every update. This faces them towards player
            forward[1] = x - poopX
            forward[2] = 0
            forward[3] = z - poopZ
            right[1] = z - poopZ
            right[2] = 0
            right[3] = poopX - x
            up[1] = 0
            up[2] = 1
            up[3] = 0
            icon:SetOrientation(forward, right, up)

            -- Alternatively, set pitch, yaw, roll
            -- icon:SetOrientation(0, 0, angle)
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
