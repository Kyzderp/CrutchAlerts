CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.Drawing = CrutchAlerts.Drawing or {}
local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

---------------------------------------------------------------------
-- Marker icons placed in the world, for positioning, e.g. Lokk HM.
-- These are also used by icons/WorldIcons.lua, migrating from OSI.
-- They use the drawing.placedPositioning settings.
--
-- texture: texture path
-- x, y, z: raw world position
-- size: a sort of arbitrary number. 100~150 should look pretty "normal"
-- color: {r, g, b, a} (max value 1), default white (uncolored). Leave off the alpha to use user-specified opacity
--
-- @returns key: you must use this key to remove the icon later
---------------------------------------------------------------------
local function CreatePlacedPositionMarker(texture, x, y, z, size, color)
    size = size or 150

    color = color or {1, 1, 1}
    local r, g, b, a = unpack(color)
    if (not a) then
        a = Crutch.savedOptions.drawing.placedPositioning.opacity
    end

    return Draw.CreateWorldTexture(
        texture,
        x,
        y,
        z,
        size / 150,
        size / 150,
        {r, g, b, a},
        Crutch.savedOptions.drawing.placedPositioning.useDepthBuffers,
        true)
end
Draw.CreatePlacedPositionMarker = CreatePlacedPositionMarker

-- Convenience method
local function RemovePlacedPositionMarker(key)
    Draw.RemoveWorldTexture(key)
end
Draw.RemovePlacedPositionMarker = RemovePlacedPositionMarker


---------------------------------------------------------------------
-- Ground circles, e.g. triplets Shock Field.
-- They use the drawing.placedOriented settings.
--
-- x, y, z: default to player position
-- radius: radius in meters
-- color: {r, g, b, a} (max value 1), default red. Leave off the alpha to use user-specified opacity
-- forwardRightUp: orientation vectors(?), defaults to being flat on the ground
--
-- @returns key: you must use this key to remove the circle later
---------------------------------------------------------------------
local function CreateGroundCircle(x, y, z, radius, color, forwardRightUp)
    local _
    if (not x) then
        _, x, y, z = GetUnitRawWorldPosition("player")
    end

    radius = radius or 12
    local size = radius * 2

    color = color or {1, 0, 0}
    local r, g, b, a = unpack(color)
    if (not a) then
        a = Crutch.savedOptions.drawing.placedOriented.opacity
    end

    forwardRightUp = forwardRightUp or {
        {0, 1, 0},
        {1, 0, 0},
        {0, 0, 1},
    }

    return Draw.CreateWorldTexture(
        "CrutchAlerts/assets/floor/circle.dds",
        x,
        y,
        z,
        size,
        size,
        {r, g, b, a},
        Crutch.savedOptions.drawing.placedOriented.useDepthBuffers,
        false,
        forwardRightUp)
end
Draw.CreateGroundCircle = CreateGroundCircle

-- Convenience method
local function RemoveGroundCircle(key)
    Draw.RemoveWorldTexture(key)
end
Draw.RemoveGroundCircle = RemoveGroundCircle


---------------------------------------------------------------------
-- Icons placed in the world that face the player, e.g. IA Brewmaster
-- potions.
-- They use the drawing.placedIcon settings.
--
-- texture: texture path
-- x, y, z: raw world position
-- size: a sort of arbitrary number. 100~150 should look pretty "normal"
-- color: {r, g, b, a} (max value 1), default white (uncolored). Leave off the alpha to use user-specified opacity
--
-- @returns key - you must use this key to remove the icon later
---------------------------------------------------------------------
local function CreatePlacedIcon(texture, x, y, z, size, color)
    size = size or 150

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
        size / 150,
        size / 150,
        color,
        Crutch.savedOptions.drawing.placedIcon.useDepthBuffers,
        true)
end
Draw.CreatePlacedIcon = CreatePlacedIcon

-- Convenience method
local function RemovePlacedIcon(key)
    Draw.RemoveWorldTexture(key)
end
Draw.RemovePlacedIcon = RemovePlacedIcon
