local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

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

    color = color or {1, 1, 1}
    local r, g, b, a = unpack(color)
    if (not a) then
        a = Crutch.savedOptions.drawing.placedPositioning.opacity
    end

    local faceCamera = not Crutch.savedOptions.drawing.placedPositioning.flat
    local forwardRightUp
    if (faceCamera) then
        y = y + size / 2
    else
        forwardRightUp = {
            {0, -1, 0},
            {1, 0, 0},
            {0, 0, -1},
        }
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
        forwardRightUp)
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

    color = color or {1, 1, 1}
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
-- orientation: 3 orientation vectors(?) or 3 degrees of freedom, defaults to being flat on the ground. Either {{fX, fY, fZ}, {rX, rY, rZ}, {uX, uY, uZ}} or {pitch, yaw, roll}
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

    color = color or {1, 1, 1}
    local r, g, b, a = unpack(color)
    if (not a) then
        a = Crutch.savedOptions.drawing.placedOriented.opacity
    end

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
-- orientation: 3 orientation vectors(?) or 3 degrees of freedom, defaults to being flat on the ground. Either {{fX, fY, fZ}, {rX, rY, rZ}, {uX, uY, uZ}} or {pitch, yaw, roll}
-- updateFunc: a function that gets called every update tick, can be used to update position, etc. See Drawing.lua:CreateWorldTexture for the params provided
--
-- @returns key: you must use this key to remove the circle later
---------------------------------------------------------------------
local function CreateGroundCircle(x, y, z, radius, color, orientation, updateFunc)
    radius = radius or 3
    local size = radius * 2

    color = color or {1, 0, 0}

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

