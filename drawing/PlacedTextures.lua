local Crutch = CrutchAlerts
local Draw = Crutch.Drawing
local C = Crutch.Constants

---------------------------------------------------------------------
-- Marker icons placed in the world, for positioning, e.g. Lokk HM.
-- These are also used by icons/WorldIcons.lua, migrating from OSI.
-- They use the drawing.placedPositioning settings.
--
-- texture: texture path
-- x, y, z: raw world position of the bottom of the icon (y offset is automatically added)
-- size: 100 creates an icon with diameter of 1 meter
-- color: {r, g, b, a} (max value 1), default white (uncolored). Leave off the alpha to use user-specified opacity
--
-- @returns key: you must use this key to remove the icon later
---------------------------------------------------------------------
local function CreatePlacedPositionMarker(texture, x, y, z, size, color)
    size = size or 100

    color = color or C.WHITE
    local r, g, b, a = unpack(color)
    if (not a) then
        a = Crutch.savedOptions.drawing.placedPositioning.opacity
    end

    local faceCamera = not Crutch.savedOptions.drawing.placedPositioning.flat
    local orientation
    if (faceCamera) then
        y = y + size / 2
    else
        orientation = C.FLAT_ORIENTATION
        y = y + 5 -- To hopefully not sink in the ground, if depth buffers are off
    end

    return Draw.CreateWorldTexture(
        texture,
        x,
        y,
        z,
        size / 100,
        size / 100,
        {r, g, b, a},
        Crutch.savedOptions.drawing.placedPositioning.useDepthBuffers,
        faceCamera,
        orientation)
end
Draw.CreatePlacedPositionMarker = CreatePlacedPositionMarker

-- Convenience method
local function RemovePlacedPositionMarker(key)
    Draw.RemoveWorldTexture(key)
end
Draw.RemovePlacedPositionMarker = RemovePlacedPositionMarker


---------------------------------------------------------------------
-- Icons placed in the world that face the player, e.g. IA Brewmaster
-- potions.
-- They use the drawing.placedIcon settings.
--
-- texture: texture path
-- x, y, z: raw world position
-- size: 100 creates an icon with diameter of 1 meter
-- color: {r, g, b, a} (max value 1), default white (uncolored). Leave off the alpha to use user-specified opacity
-- updateFunc: a function that gets called every update tick, can be used to update position, etc. See Drawing.lua:CreateWorldTexture for the params provided
--
-- @returns key - you must use this key to remove the icon later
---------------------------------------------------------------------
local function CreatePlacedIcon(texture, x, y, z, size, color, updateFunc)
    size = size or 100

    color = color or C.WHITE
    local r, g, b, a = unpack(color)
    if (not a) then
        a = Crutch.savedOptions.drawing.placedIcon.opacity
    end

    return Draw.CreateWorldTexture(
        texture,
        x,
        y,
        z,
        size / 100,
        size / 100,
        color,
        Crutch.savedOptions.drawing.placedIcon.useDepthBuffers,
        true,
        nil,
        updateFunc)
end
Draw.CreatePlacedIcon = CreatePlacedIcon

-- Convenience method
local function RemovePlacedIcon(key)
    Draw.RemoveWorldTexture(key)
end
Draw.RemovePlacedIcon = RemovePlacedIcon


---------------------------------------------------------------------
-- Placed textures, no built-in usage yet, but see Drawing.lua:TestPoop() for example usage.
-- They use the drawing.placedOriented settings.
--
-- x, y, z: default to player position
-- size: diameter in meters, default 1
-- color: {r, g, b, a} (max value 1), default white. Leave off the alpha to use user-specified opacity
-- orientation: 3 orientation vectors(?) or 3 degrees of freedom, defaults to being flat on the ground. Either {{fX, fY, fZ}, {rX, rY, rZ}, {uX, uY, uZ}} or {pitch, yaw, roll}. {pitch, yaw, roll} is preferred for slightly less math
-- updateFunc: a function that gets called every update tick, can be used to update position, etc. See Drawing.lua:CreateWorldTexture for the params provided
--
-- @returns key: you must use this key to remove the texture later
---------------------------------------------------------------------
local function CreateOrientedTexture(texture, x, y, z, size, color, orientation, updateFunc)
    local _
    if (not x) then
        _, x, y, z = GetUnitRawWorldPosition("player")
    end

    size = size or 1

    color = color or C.WHITE
    local r, g, b, a = unpack(color)
    if (not a) then
        a = Crutch.savedOptions.drawing.placedOriented.opacity
    end

    -- TODO: don't use vectors here
    orientation = orientation or {
        {0, 1, 0},
        {1, 0, 0},
        {0, 0, 1},
    }

    return Draw.CreateWorldTexture(
        texture,
        x,
        y,
        z,
        size,
        size,
        {r, g, b, a},
        Crutch.savedOptions.drawing.placedOriented.useDepthBuffers,
        false,
        orientation,
        updateFunc)
end
Draw.CreateOrientedTexture = CreateOrientedTexture

-- Convenience method
local function RemoveOrientedTexture(key)
    Draw.RemoveWorldTexture(key)
end
Draw.RemoveOrientedTexture = RemoveOrientedTexture


---------------------------------------------------------------------
-- Ground circles, e.g. triplets Shock Field. Just for convenient use
-- of CreateOrientedTexture.
-- They use the drawing.placedOriented settings.
--
-- x, y, z: default to player position
-- radius: radius in meters, default 3
-- color: {r, g, b, a} (max value 1), default red. Leave off the alpha to use user-specified opacity
-- orientation: 3 orientation vectors(?) or 3 degrees of freedom, defaults to being flat on the ground. Either {{fX, fY, fZ}, {rX, rY, rZ}, {uX, uY, uZ}} or {pitch, yaw, roll}. {pitch, yaw, roll} is preferred for slightly less math
-- updateFunc: a function that gets called every update tick, can be used to update position, etc. See Drawing.lua:CreateWorldTexture for the params provided
--
-- @returns key: you must use this key to remove the circle later
---------------------------------------------------------------------
local function CreateGroundCircle(x, y, z, radius, color, orientation, updateFunc)
    radius = radius or 3
    local size = radius * 2

    color = color or C.RED

    return CreateOrientedTexture(
        "CrutchAlerts/assets/floor/circle.dds",
        x,
        y,
        z,
        size,
        color,
        orientation,
        updateFunc)
end
Draw.CreateGroundCircle = CreateGroundCircle

-- Convenience method
local function RemoveGroundCircle(key)
    Draw.RemoveWorldTexture(key)
end
Draw.RemoveGroundCircle = RemoveGroundCircle


---------------------------------------------------------------------
-- Line
---------------------------------------------------------------------
-- Returns, midpointX, midpointY, midpointZ, pitch, yaw, textureHeight
local function CalculateValues(x1, y1, z1, x2, y2, z2)
    -- Midpoint
    local oX = (x1 + x2) / 2
    local oY = (y1 + y2) / 2
    local oZ = (z1 + z2) / 2

    -- Roll doesn't change; pitch is the elevation change; yaw is the "flat" rotation in the XZ plane
    local xzDistance = math.sqrt((x2 - x1)^2 + (z2 - z1)^2)
    local pitch = math.pi / 2 - math.atan2(y2 - y1, xzDistance)
    local yaw = math.pi / 2 - math.atan2(z2 - z1, x2 - x1)

    -- Height
    local distance = math.sqrt(Crutch.GetSquaredDistance(x1, y1, z1, x2, y2, z2))

    return oX, oY, oZ, pitch, yaw, distance / 100
end

---------------------------------------------------------------------
-- A rectangle on the ground from point 1 to point 2
-- This uses the drawing.placedOriented settings.
--
-- x1, y1, z1: coordinates of point 1
-- x2, y2, z2: coordinates of point 2
-- width: thickness of the line in meters, default 1
-- color: {r, g, b, a} (max value 1), default white. Leave off the alpha to use user-specified opacity
-- useDepthBuffers: whether to use depth buffers. Defaults to user setting for placedOriented
-- updateFunc: a function that gets called every update tick, can be used to update color, etc. See Drawing.lua:CreateWorldTexture for the params provided
-- getPointsFunc: a function with no params that gets called every update tick. Return x1, y1, z1, x2, y2, z2 to have a line that moves dynamically
--
-- @returns key: you must use this key to remove the line later
---------------------------------------------------------------------
local function CreateLine(x1, y1, z1, x2, y2, z2, width, color, useDepthBuffers, updateFunc, getPointsFunc)
    color = color or C.WHITE
    local r, g, b, a = unpack(color)
    if (not a) then
        a = Crutch.savedOptions.drawing.placedOriented.opacity
    end

    if (useDepthBuffers == nil) then
        useDepthBuffers = Crutch.savedOptions.drawing.placedOriented.useDepthBuffers
    end

    local oX, oY, oZ, pitch, yaw, height = CalculateValues(x1, y1, z1, x2, y2, z2)

    -- Wrapper for updateFunc that also uses getPointsFunc to set things
    local function UpdateFunctionWrapper(icon)
        if (updateFunc) then
            updateFunc(icon)
        end

        if (getPointsFunc) then
            local x1, y1, z1, x2, y2, z2 = getPointsFunc()

            local oX, oY, oZ, pitch, yaw, height = CalculateValues(x1, y1, z1, x2, y2, z2)

            icon:SetPosition(oX, oY, oZ)
            icon:SetOrientation(pitch, yaw, 0)

            -- TODO: setDimensionsFunc?
            width = width or icon.control:Get3DLocalDimensions()
            icon.control:Set3DLocalDimensions(width, height)
        end
    end

    return Draw.CreateWorldTexture(
        "CrutchAlerts/assets/floor/square.dds",
        oX,
        oY,
        oZ,
        width or 1,
        height,
        {r, g, b, a},
        useDepthBuffers,
        false,
        {pitch, yaw, 0},
        UpdateFunctionWrapper)
end
Draw.CreateLine = CreateLine

-- Convenience method
local function RemoveLine(key)
    Draw.RemoveWorldTexture(key)
end
Draw.RemoveLine = RemoveLine

--[[
/script _, x1, y1, z1 = GetUnitRawWorldPosition("player")
/script _, x2, y2, z2 = GetUnitRawWorldPosition("player") local key = CrutchAlerts.Drawing.CreateLine(x1, y1, z1, x2, y2, z2, nil, nil, nil, nil, function()
local _, x2, y2, z2 = GetUnitRawWorldPosition("player")
return x1, y1, z1, x2, y2, z2
end)
]]
