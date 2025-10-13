local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

---------------------------------------------------------------------
Draw.activeIcons = {} -- {[key] = {control = control, faceCamera = true, x = x, y = y, z = z, updateFunc = function() end}}
-- /script d(CrutchAlerts.Drawing.activeIcons)

-- Pitch, yaw, roll
local function IsDOF(value)
    return type(value) == "number"
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
        if (icon.isSpace) then
            local oX, oY, oZ = GuiRender3DPositionToWorldPosition(0, 0, 0) -- TODO: maybe move this out
            local tX = (x - oX) / 100
            local tY = y / 100
            local tZ = (z - oZ) / 100
            icon.control:SetTransformOffset(tX, tY, tZ)
        else
            icon.control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(icon.x, icon.y, icon.z))
        end
    end
end
Draw.SetPosition = SetPosition

-- Callback to set color, keeping old if nil
local function SetColor(icon, r, g, b, a, childControlName)
    local control
    if (icon.isSpace) then
        control = icon.control:GetNamedChild(childControlName or "Texture")
    else
        control = icon.control
    end

    local oldR, oldG, oldB, oldA = control:GetColor()
    r = r or oldR
    g = g or oldG
    b = b or oldB

    control:SetColor(r, g, b, a)
end
Draw.SetColor = SetColor

-- Util
local function ConvertToPitchYawRollIfNeeded(first, second, third)
    if (IsDOF(first or second or third)) then
        return first, second, third
    end

    local fX, fY, fZ = unpack(first)
    local rX, rY, rZ = unpack(second)

    local pitch = zo_atan2(fY, zo_sqrt(fX * fX + fZ * fZ))
    local yaw = zo_atan2(fX, fZ) - math.pi
    local roll = zo_atan2(rY, zo_sqrt(rX * rX + rZ * rZ))

    -- Crutch.dbgOther(string.format("Converted to %f %f %f", pitch, yaw, roll))
    return pitch, yaw, roll
end
Draw.ConvertToPitchYawRollIfNeeded = ConvertToPitchYawRollIfNeeded

-- Callback to set orientation, keeping old if nil
-- Either ({fX, fY, fZ}, {rX, rY, rZ}, {uX, uY, uZ}) or (pitch, yaw, roll)
-- (pitch, yaw, roll) is preferred for slightly less math
local function SetOrientation(icon, first, second, third)
    if (not first and not second and not third) then
        return -- It's fine if it's all nil, but why is it being called...?
    end

    -- If using forward right up, all values must be specified
    local isDOF = IsDOF(first or second or third)
    if (not isDOF) then
        if (not first or not second or not third) then
            CrutchAlerts.msg("|cFF0000Caller attempted to use {forward, right, up} system but not all values are specified!")
            return
        end
    end

    local pitch, yaw, roll = ConvertToPitchYawRollIfNeeded(first, second, third)
    pitch = pitch or icon.orientation.pitch
    yaw = yaw or icon.orientation.yaw
    roll = roll or icon.orientation.roll

    if (pitch ~= icon.orientation.pitch or
        yaw ~= icon.orientation.yaw or
        roll ~= icon.orientation.roll) then
        icon.orientation.pitch = pitch
        icon.orientation.yaw = yaw
        icon.orientation.roll = roll
        if (icon.isSpace) then
            icon.control:SetTransformRotation(pitch, yaw, roll)
        else
            icon.control:Set3DRenderSpaceOrientation(pitch, yaw, roll)
        end
    end
end
Draw.SetOrientation = SetOrientation

-- Callback to set texture, keeping old if nil
local function SetTexture(icon, path)
    if (path and icon.texture ~= path) then
        icon.texture = path
        if (icon.isSpace) then
            icon.control:GetNamedChild("Texture"):SetTexture(path)
        else
            icon.control:SetTexture(path)
        end
    end
end
Draw.SetTexture = SetTexture


---------------------------------------------------------------------
-- Common for both Space and RenderSpace
---------------------------------------------------------------------
local function CreateControlCommon(isSpace, control, key, texture, x, y, z,  faceCamera, pitch, yaw, roll, updateFunc, setPositionFunc, setOrientationFunc, setColorFunc, setTextureFunc, setTextFunc, setFontColorFunc)
    Draw.activeIcons[key] = {
        isSpace = isSpace,
        control = control,
        faceCamera = faceCamera,
        x = x,
        y = y,
        z = z,
        orientation = {pitch = pitch, yaw = yaw, roll = roll},
        texture = texture,
        updateFunc = updateFunc,

        -- Callback functions
        SetPosition = setPositionFunc,
        SetOrientation = setOrientationFunc,
        SetColor = setColorFunc,
        SetTexture = setTextureFunc, -- All RenderSpace; Space textures
        SetText = setTextFunc, -- Space labels
        SetFontColor = setFontColorFunc, -- Space labels
    }
    Draw.MaybeStartPolling()

    local controlDebugString = ""
    if (texture) then
        controlDebugString = string.format("texture |t100%%:100%%:%s|t", texture)
    elseif (setTextFunc) then
        controlDebugString = "text label"
    end

    CrutchAlerts.dbgSpam(string.format("Created %s key %s %s {%d, %d, %d} %s",
        controlDebugString,
        key,
        isSpace and "Space" or "RenderSpace",
        x,
        y,
        z,
        control:GetName()))
end
Draw.CreateControlCommon = CreateControlCommon


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
--     icon:SetOrientation(forward, right, up) or icon:SetOrientation(pitch, yaw, roll). (pitch, yaw, roll) is preferred for slightly less math. Should not be called for icons that face camera
--     icon:SetTexture(path)
-- Since this is called many times a second, the caller should take
-- care to make it performant, e.g. do not create tables or functions
-- on every call.
---------------------------------------------------------------------
local useSpace = true
local function CreateWorldTexture(texture, x, y, z, width, height, color, useDepthBuffer, faceCamera, orientation, updateFunc)
    orientation = orientation or {0, 0, 0}
    local pitch, yaw, roll = ConvertToPitchYawRollIfNeeded(unpack(orientation))

    local isSpace = useSpace and not useDepthBuffer and width == height -- Space framework is only squares for now
    local control, key
    if (isSpace) then
        control, key = Draw.CreateSpaceTexture(texture, x, y, z, width, height, color, {pitch, yaw, roll})
    else
        control, key = Draw.CreateRenderSpaceTexture(texture, x, y, z, width, height, color, useDepthBuffer, {pitch, yaw, roll})
    end

    CreateControlCommon(
        isSpace,
        control,
        key,
        texture,
        x, y, z,
        faceCamera,
        pitch, yaw, roll,
        updateFunc,
        SetPosition,
        SetOrientation,
        SetColor,
        SetTexture)

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

    if (icon.isSpace) then
        Draw.ReleaseSpaceControl(key)
    else
        Draw.ReleaseRenderSpaceTexture(key)
    end

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

local function TestOrientation()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    -- local forward = {0, -1, 0}
    -- local right = {-1, 0, .4}
    -- local up = {.4, 0, 1}

    Set3DRenderSpaceToCurrentCamera("CrutchAlertsDrawingCamera")
    local fX, fY, fZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceForward()
    local rX, rY, rZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceRight()
    local uX, uY, uZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceUp()

    local forward = {fX, fY, fZ}
    local right = {rX, rY, rZ}
    local up = {uX, uY, uZ}

    CrutchAlerts.Drawing.CreateWorldTexture("CrutchAlerts/assets/shape/diamond_orange_4.dds", x, y, z, 1, 1, {0, 1, 0, 0.5}, false, false, {forward, right, up})

    zo_callLater(function()
        _, x, y, z = GetUnitRawWorldPosition("player")
        local pitch, yaw, roll = CrutchAlerts.Drawing.ConvertToPitchYawRollIfNeeded(forward, right, up)
        CrutchAlerts.Drawing.CreateWorldTexture("CrutchAlerts/assets/shape/diamond_orange_4.dds", x, y, z, 1, 1, {0, 0, 1, 0.5}, false, false, {pitch, yaw, roll})
    end, 1000)
end
Draw.TestOrientation = TestOrientation
--[[
/script CrutchAlerts.Drawing.TestOrientation()
]]
