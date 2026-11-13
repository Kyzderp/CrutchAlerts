local Crutch = CrutchAlerts
Crutch.Drawing.Model = {}
local M = Crutch.Drawing.Model
local C = Crutch.Constants


---------------------------------------------------------------------
-- FSR and DLSS must be off so that subsampling can be high
local function AreDepthBuffersSupported()
    if (IsConsoleUI()) then return false end
    return GetCVar("FSR_MODE") == tostring(FSR_MODE_OFF)
        and GetCVar("ANTIALIASING_TYPE") ~= tostring(ANTIALIASING_TYPE_DLSS)
        and GetCVar("SUB_SAMPLING") == tostring(SUB_SAMPLING_MODE_NORMAL)
end
M.AreDepthBuffersSupported = AreDepthBuffersSupported


---------------------------------------------------------------------
-- Common
---------------------------------------------------------------------
local genericTexturePool, genericLabelPool
local rectControls = {} -- {[key] = {control = control, targetY = 123}}
local labelControls = {} -- ''

local function CreateRectRenderSpace(x, y, z, pitch, yaw, roll, width, height, color, desaturation, texture, animationOffset)
    if (not genericTexturePool) then
        local function ResetControl(control)
            control:SetHidden(true)
            control:SetAlpha(1)
        end
        genericTexturePool = ZO_ControlPool:New("CrutchAlertsModelTexture", CrutchAlertsDrawing)
        genericTexturePool:SetCustomResetBehavior(ResetControl)
    end

    local control, key = genericTexturePool:AcquireObject()
    rectControls[key] = {control = control, targetX = x, targetY = y, targetZ = z}

    control:SetHidden(false)
    control:Create3DRenderSpace()
    control:SetColor(unpack(color))
    control:SetTexture(texture or "CrutchAlerts/assets/floor/square.dds")

    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y - animationOffset, z))

    control:Set3DLocalDimensions(width, height)
    control:Set3DRenderSpaceUsesDepthBuffer(true)

    -- pitch, yaw, roll
    control:Set3DRenderSpaceOrientation(pitch, yaw, roll)

    control:SetDesaturation(desaturation)

    return control, key
end

local function CreateLabelRenderSpace(x, y, z, pitch, yaw, roll, width, height, color, text, fontSize, animationOffset)
    if (not genericLabelPool) then
        genericLabelPool = ZO_ControlPool:New("CrutchAlertsModelLabel", CrutchAlertsDrawing)
    end

    local control, key = genericLabelPool:AcquireObject()
    labelControls[key] = {control = control, targetX = x, targetY = y, targetZ = z}

    control:SetHidden(false)
    control:Create3DRenderSpace()
    control:SetColor(unpack(color))

    fontSize = fontSize or 20
    control:SetFont("$(STONE_TABLET_FONT)|" .. fontSize)
    control:SetText(text)
    control:SetColor(.1, .1, .1, 1)
    Crutch.dbgSpam(text .. " - $(STONE_TABLET_FONT)|" .. fontSize)

    control:SetScale(0.01)

    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y - animationOffset, z))
    control:Set3DRenderSpaceUsesDepthBuffer(true)

    -- pitch, yaw, roll
    control:Set3DRenderSpaceOrientation(pitch, yaw, roll)

    return control, key
end

local function CalculateValues(x1, y1, z1, x2, y2, z2, x3, y3, z3, theta)
    -- Midpoint
    local oX = (x1 + x2) / 2
    local oY = (y1 + y2) / 2
    local oZ = (z1 + z2) / 2

    theta = math.pi * 2 - theta
    local roX = oX * math.cos(theta) - oZ * math.sin(theta)
    local roZ = oZ * math.cos(theta) + oX * math.sin(theta)

    local height = math.sqrt((x3 - x2)^2 + (y3 - y2)^2 + (z3 - z2)^2)
    local width = math.sqrt((x3 - x1)^2 + (y3 - y1)^2 + (z3 - z1)^2)
    local pitch = math.atan2(z3 - z2, y3 - y2)
    local yaw = math.atan2(z3 - z1, x3 - x1) - theta
    local roll = -math.atan2(x3 - x2, y3 - y2)

    return roX, oY, roZ, pitch, yaw, roll, width, height
end

local scale = 100
local function CreateControlFromElement(rect, rectTable, labelTable, x, y, z, uiScale, theta, animationOffset, coordsCallback, textParams, controlParams)
    animationOffset = animationOffset or 0
    local oX, oY, oZ, pitch, yaw, roll, width, height = CalculateValues(
        rect.coords[1] * (controlParams and controlParams.xScale or 1),
        rect.coords[2] * (controlParams and controlParams.yScale or 1),
        rect.coords[3] * (controlParams and controlParams.zScale or 1),
        rect.coords[4] * (controlParams and controlParams.xScale or 1),
        rect.coords[5] * (controlParams and controlParams.yScale or 1),
        rect.coords[6] * (controlParams and controlParams.zScale or 1),
        rect.coords[7] * (controlParams and controlParams.xScale or 1),
        rect.coords[8] * (controlParams and controlParams.yScale or 1),
        rect.coords[9] * (controlParams and controlParams.zScale or 1),
        theta
        )
    if (rect.text) then
        local scaledFontSize = math.floor((rect.fontSize or 17) / uiScale)

        -- Create it normally first
        local text = zo_strformat(rect.text, textParams[1], textParams[2], textParams[3], textParams[4])
        local control, key = CreateLabelRenderSpace(x + oX * scale, y + oY * scale, z + oZ * scale, pitch, yaw, roll, width, height, rect.color, text, scaledFontSize, animationOffset)
        table.insert(labelTable, key)

        -- Adjust font size
        local textWidth = control:GetTextWidth()
        -- uiscale 1: width of 1.2 is 120 in textwidth; TheClawlessConqueror is 110 at font size 8
        -- uiscale .752: width of 1.2 is ~150 in textwidth; TheClawlessConqueror is 147 at font size 10

        local allowedTextWidth = 115 / uiScale

        -- /script CrutchAlertsDrawingCrutchAlertsModelLabel2:SetFont("$(STONE_TABLET_FONT)|10") d(CrutchAlertsDrawingCrutchAlertsModelLabel2:GetTextWidth())
        if (textWidth > allowedTextWidth) then
            Crutch.dbgSpam(string.format("adjusting font size for \"%s\" because textWidth %f and width %f", text, textWidth, width))
            local newFontSize = scaledFontSize

            while (textWidth > allowedTextWidth and newFontSize > 0) do
                newFontSize = newFontSize - 1
                control:SetFont("$(STONE_TABLET_FONT)|" .. newFontSize)
                textWidth = control:GetTextWidth()
                Crutch.dbgSpam("trying newFontSize " .. newFontSize .. " = " .. textWidth)
            end

            Crutch.dbgSpam("newFontSize: " .. newFontSize)
            control:SetFont("$(STONE_TABLET_FONT)|" .. newFontSize)
            textWidth = control:GetTextWidth()
            Crutch.dbgSpam("new textWidth: " .. textWidth)
        else
            Crutch.dbgSpam(string.format("NOT adjusting font size for \"%s\" because textWidth %f and width %f", text, textWidth, width))
        end

        -- Adjust location to re-center it
        local offset = textWidth / 100 / 2 * uiScale
        -- TODO: not just x
        local sX, sY, sZ = CalculateValues(
            rect.coords[1] - offset,
            rect.coords[2],
            rect.coords[3],
            rect.coords[4] - offset,
            rect.coords[5],
            rect.coords[6],
            rect.coords[7] - offset,
            rect.coords[8],
            rect.coords[9],
            theta
            )
        local newX = x + sX * scale
        local newY = y + sY * scale
        local newZ = z + sZ * scale
        labelControls[key].targetX = newX
        labelControls[key].targetY = newY
        labelControls[key].targetZ = newZ
        control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(newX, newY - animationOffset, newZ))
        Crutch.dbgSpam("^^^ " .. control:GetName() .. " ^^^")
    else
        local control, key = CreateRectRenderSpace(
            x + oX * scale,
            y + oY * scale,
            z + oZ * scale,
            pitch, yaw, roll,
            width, height,
            controlParams and controlParams.color or rect.color,
            rect.desaturation or 0,
            rect.texture,
            animationOffset)
        table.insert(rectTable, key)

        if (coordsCallback) then
            coordsCallback(x + oX * scale, y + oY * scale, z + oZ * scale, control)
        end
    end
end


---------------------------------------------------------------------
-- Grave animation
---------------------------------------------------------------------
local graves = {} -- {["group3"] = {rects = {key,}, labels = {}}}
local graveAnimations = {} -- {["group3"] = targetTime}

local ANIMATION_DURATION = 1000
local ANIMATION_Y = 170
local ANIMATION_X_PERIOD = 100
local ANIMATION_X = 1.5

local function UpdateGraveAnimations()
    for unitTag, targetTime in pairs(graveAnimations) do
        local timeUntilEnd = targetTime - GetGameTimeMilliseconds()
        if (timeUntilEnd < 0) then
            -- animation reached end, remove animation but do 1 last update to the end target
            graveAnimations[unitTag] = nil
            if (ZO_IsTableEmpty(graveAnimations)) then
                Crutch.dbgSpam("end animation " .. unitTag)
                EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "GraveUpdate")
            end

            timeUntilEnd = 0
        end

        local progress = 1 - timeUntilEnd / ANIMATION_DURATION
        local yOffset = (1 - ZO_EaseOutCubic(progress)) * ANIMATION_Y
        local xOffset = math.sin((ANIMATION_DURATION - timeUntilEnd) / ANIMATION_X_PERIOD * math.pi * 2) * ANIMATION_X
        -- Crutch.dbgSpam(xOffset)

        local keys = graves[unitTag]
        if (not keys) then return end

        for _, key in ipairs(keys.rects) do
            local controlData = rectControls[key]
            controlData.control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(
                controlData.targetX + xOffset, controlData.targetY - yOffset, controlData.targetZ))
        end
        for _, key in ipairs(keys.labels) do
            local controlData = labelControls[key]
            controlData.control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(
                controlData.targetX + xOffset, controlData.targetY - yOffset, controlData.targetZ))
        end
    end
end

local function PollIfNeeded()
    if (ZO_IsTableEmpty(graveAnimations)) then
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "GraveUpdate")
    else
        EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "GraveUpdate", 20, UpdateGraveAnimations)
    end
end


---------------------------------------------------------------------
-- Grave
---------------------------------------------------------------------
local graveRects = {
    -- top left, bottom right, top right
    -- {coords = {.3, 1.4, -.1, -.3, .8, -.1, -.3, 1.4, -.1}, color = {.9, .9, .9, .5}, texture = "esoui/art/trials/vitalitydepletion.dds"},
    -- {coords = {0, 0, 0, 0, 0, 0, 0, 0, 0}, color = {.9, .9, .9, 1}, texture = "CrutchAlerts/assets/floor/square.dds"},

    -- frontback
    {coords = {-.6, 1.8, .3, .6, 0, .3, .6, 1.8, .3}, color = {.5, .5, .5, 1}, desaturation = 1, texture = "esoui/art/worldmap/worldmap_map_background_512tile.dds"},
    {coords = {-.6, 1.8,  0, .6, 0,  0, .6, 1.8,  0}, color = {.5, .5, .5, 1}, desaturation = 1, texture = "esoui/art/worldmap/worldmap_map_background_512tile.dds"},

    {coords = {-.6, 1.5, .31, .6, 1.4, .31, .6, 1.5, .31}, color = {.1, .1, .1, 1}, text = "<<1>>"},
    {coords = {-.6, 1.3, .31, .6, 1.2, .31, .6, 1.3, .31}, color = {.1, .1, .1, 1}, text = "<<2>>"},

    {coords = {-.6,   1, .31, .6,  .9, .31, .6,   1, .31}, color = {.1, .1, .1, 1}, text = "<<3>>", fontSize = 14},
    {coords = {-.6,  .9, .31, .6,  .8, .31, .6,  .9, .31}, color = {.1, .1, .1, 1}, text = "-", fontSize = 14},
    {coords = {-.6, .77, .31, .6, .67, .31, .6, .77, .31}, color = {.1, .1, .1, 1}, text = "<<4>>", fontSize = 14},

    -- sides
    {coords = {-.6, 1.8,  0, -.6,   0, .3, -.6, 1.8, .3}, color = {.4, .4, .4, 1}, desaturation = 1, texture = "esoui/art/worldmap/worldmap_map_background_512tile.dds"},
    {coords = {-.6, 1.8,  0,  .6, 1.8, .3,  .6, 1.8,  0}, color = {.45, .45, .45, 1}, desaturation = 1, texture = "esoui/art/worldmap/worldmap_map_background_512tile.dds"},
    {coords = { .6, 1.8, .3,  .6,   0,  0,  .6, 1.8,  0}, color = {.4, .4, .4, 1}, desaturation = 1, texture = "esoui/art/worldmap/worldmap_map_background_512tile.dds"},
}

local intros = {
    "Here lies",
    "In loving memory of",
    "R.I.P.",
    "Rest in Peace",
    "Rest in Pieces",
    "Never forgotten",
    "Gone too soon",
}

local function FormatDate(timestamp)
    local MONTHS = {
        [1] = "Jan",
        [2] = "Feb",
        [3] = "Mar",
        [4] = "Apr",
        [5] = "May",
        [6] = "Jun",
        [7] = "Jul",
        [8] = "Aug",
        [9] = "Sep",
        [10] = "Oct",
        [11] = "Nov",
        [12] = "Dec",
    }
    local year, month, day = GetDateElementsFromTimestamp(timestamp)
    return zo_strformat("<<1>> <<2>>, <<3>>", MONTHS[month], day, year)
end

local function RemoveGrave(unitTag)
    local data = graves[unitTag]
    if (not data) then return end

    for _, key in ipairs(data.rects) do
        genericTexturePool:ReleaseObject(key)
        rectControls[key] = nil
    end
    for _, key in ipairs(data.labels) do
        genericLabelPool:ReleaseObject(key)
        labelControls[key] = nil
    end
    graves[unitTag] = nil
end
M.RemoveGrave = RemoveGrave
-- M.RemoveGrave = function(unitTag) Crutch.dbgOther(zo_strformat("|cFFAA00Removing <<1>> grave due to suppression", GetUnitDisplayName(unitTag))) RemoveGrave() end

local function RemoveAllGraves()
    for unitTag, _ in pairs(graves) do
        RemoveGrave(unitTag)
    end
end

local function Grave(unitTag, intro, name, birth, death, theta)
    unitTag = unitTag or "player"
    local _, x, y, z = GetUnitRawWorldPosition(unitTag)
    y = y - 20
    intro = intro or "Here lies"
    name = name or "Kyzeragon"
    birth = birth or "Unknown"
    death = death or FormatDate(GetTimeStamp())
    theta = theta or 0

    RemoveGrave(unitTag)

    graves[unitTag] = {rects = {}, labels = {}}

    local uiScale = GetUIGlobalScale()

    local textParams = {intro, name, birth, death}

    for _, rect in ipairs(graveRects) do
        CreateControlFromElement(rect, graves[unitTag].rects, graves[unitTag].labels, x, y, z, uiScale, theta, ANIMATION_Y, nil, textParams)
    end

    graveAnimations[unitTag] = GetGameTimeMilliseconds() + ANIMATION_DURATION
    PollIfNeeded()
end
M.Grave = Grave
--[[
/script CrutchAlerts.Drawing.Model.Grave()
/script CrutchAlerts.Drawing.Model.Grave("player", "Forever in our hearts", "efiye", "May 12, 3203", nil, math.pi/2)
/script CrutchAlerts.Drawing.Model.Grave("player", "Rest in Peace", "TheClawlessConqueror", "May 12, 320312345113")
]]


---------------------------------------------------------------------
-- Present
---------------------------------------------------------------------
local presentControls = {}
local presentAnimations = {} -- {[name] = {x = 123, y = 123, z = 123, w = 2, h = 3, d = 1, theta = pi}}
--[[
{
    [name] = {
        height = 2,
        theta = 1,
        {oX, oY, oZ},
    }
}
]]

local function RemovePresent(name)
    local data = presentControls[name]
    if (not data) then return end

    for _, key in ipairs(data.rects) do
        genericTexturePool:ReleaseObject(key)
        rectControls[key] = nil
    end
    for _, key in ipairs(data.labels) do
        genericLabelPool:ReleaseObject(key)
        labelControls[key] = nil
    end
    presentControls[name] = nil

    if (presentAnimations[name].poopKey) then
        Crutch.Drawing.RemoveWorldTexture(presentAnimations[name].poopKey)
        Crutch.Drawing.RemoveWorldTexture(presentAnimations[name].glowKey)
    end
    presentAnimations[name] = nil
end
M.RemovePresent = RemovePresent

local function UpdatePresentAnimation(name, progress)
    name = name or "Test1"
    local presentAnimation = presentAnimations[name]

    local sideProgress = zo_clamp(progress * 2, 0, 1)
    local angle = sideProgress * math.pi / 2

    local topProgress = ZO_EaseInQuadratic(progress)
    local topAngle = topProgress * math.pi * 2
    local topY = topProgress * presentAnimation.height * 100
    local topAlpha = 1 - ZO_EaseOutCubic(topProgress)


    -- Calculate new center. height / 2 is the radius, must rotate in the direction of yaw
    -- 1 south means rotation point is d / 2

    for i, present in pairs(presentAnimation) do -- TODO
        -- local present = presentAnimation[i]
        if (type(i) == "number") then
            local control = present.control

            if (present.angleMultiplier) then
                -- Sides
                local horiz = math.sin(angle * present.angleMultiplier) * presentAnimation.height * 100 / 2
                local y = math.cos(angle * present.angleMultiplier) * presentAnimation.height * 100 / 2

                -- rotation
                local _, yaw, roll = control:Get3DRenderSpaceOrientation()
                control:Set3DRenderSpaceOrientation(angle * present.angleMultiplier, yaw, roll)

                -- offset due to rotating around bottom
                local x = math.sin(present.theta) * horiz
                local z = math.cos(present.theta) * horiz
                -- d("horiz x y z", horiz, x, y, z)

                local newX = present.oX + x
                local newY = present.oY + y
                local newZ = present.oZ + z
                -- d(zo_strformat("update: <<1>> <<2>> <<3>>", newX, newY, newZ))
                control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(newX, newY, newZ))
            elseif (present.top) then
                -- Top
                local pitch, _, roll = control:Get3DRenderSpaceOrientation()
                control:Set3DRenderSpaceOrientation(pitch, present.theta + topAngle)
                control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(present.oX, present.oY + topY, present.oZ))
                control:SetAlpha(topAlpha)
            end
        end
    end
end
M.UpdatePresentAnimation = UpdatePresentAnimation
-- /script CrutchAlerts.Drawing.Model.UpdatePresentAnimation(nil, 0.5)

local function PlayPresentAnimation(name)
    Crutch.dbgOther("Opening " .. name)

    local present = presentAnimations[name]
    if (present.animating) then return end
    present.animating = true

    local startTime = GetGameTimeMilliseconds()
    local function poopFunc(icon)
        local poopgress = zo_clamp((GetGameTimeMilliseconds() - startTime) / 1500, 0, 1)
        icon.control:Set3DLocalDimensions(ZO_EaseInCubic(poopgress), ZO_EaseInQuadratic(poopgress))
    end

    present.poopKey = Crutch.Drawing.CreateWorldTexture(
        "CrutchAlerts/assets/poop.dds",
        present.x,
        present.y + 50,
        present.z,
        0,
        0,
        C.WHITE,
        true,
        true,
        nil,
        poopFunc)

    local function glowFunc(icon)
        local glowProgress = zo_clamp((GetGameTimeMilliseconds() - startTime) / 2000, 0, 1)
        local size = ZO_EaseInOutQuadratic(glowProgress) * 6
        icon.control:Set3DLocalDimensions(size, size)
        icon:SetOrientation(-math.pi/2, (GetGameTimeMilliseconds() % 4000) / 4000 * math.pi * 2, 0)
    end
    present.glowKey = Crutch.Drawing.CreateWorldTexture(
        "/esoui/art/champion/champion_star_burst.dds",
        present.x,
        present.y + 3,
        present.z,
        0,
        0,
        C.WHITE,
        true,
        false,
        C.FLAT_ORIENTATION,
        glowFunc)

    local progress = 0
    EVENT_MANAGER:RegisterForUpdate("CrutchAlertsPresent" .. name, 25, function()
        if (progress > 1) then
            EVENT_MANAGER:UnregisterForUpdate("CrutchAlertsPresent" .. name)
            return
        end
        progress = progress + 0.025
        UpdatePresentAnimation(name, progress)
    end)

    zo_callLater(function() RemovePresent(name) end, 10000)
end
M.PlayPresentAnimation = PlayPresentAnimation

local presentRects = {
    -- top left, bottom right, top right
    {coords = {-.5, 1,  .5,  .5, 0,  .5,  .5, 1,  .5}, color = {-.05, 0, 0, "base"}, angle = 1, thetaOffset = 0}, -- south
    {coords = {-.5, 1, -.5,  .5, 0, -.5,  .5, 1, -.5}, color = {-.05, 0, 0, "base"}, angle = -1, thetaOffset = 0}, -- north
    {coords = {-.5, 1, -.5, -.5, 0,  .5, -.5, 1,  .5}, color = {   0, 0, 0, "base"}, angle = -1, thetaOffset = math.pi/2}, -- west
    {coords = { .5, 1,  .5,  .5, 0, -.5,  .5, 1, -.5}, color = {   0, 0, 0, "base"}, angle = -1, thetaOffset = math.pi*1.5}, -- east
    {coords = {-.5, 1, -.5,  .5, 1,  .5,  .5, 1, -.5}, color = { -.1, 0, 0, "base"}, top = true}, -- top
    {coords = {-.5, 0, -.5,  .5, 0,  .5,  .5, 0, -.5}, color = { -.1, 0, 0, "base"}}, -- bottom

    {coords = { -.2, 1.02,  .52,   .2, -.02,  .52,   .2, 1.02,  .52}, color = {-.05, -.05, 0, "ribbon"}, angle = 1, thetaOffset = 0}, -- frontback
    {coords = { -.2, 1.02, -.52,   .2, -.02, -.52,   .2, 1.02, -.52}, color = {-.05, -.05, 0, "ribbon"}, angle = -1, thetaOffset = 0},
    {coords = {-.52, 1.02,  -.2, -.52, -.02,   .2, -.52, 1.02,   .2}, color = {   0,    0, 0, "ribbon"}, angle = -1, thetaOffset = math.pi/2},
    {coords = { .52, 1.02,   .2,  .52, -.02,  -.2,  .52, 1.02,  -.2}, color = {   0,    0, 0, "ribbon"}, angle = -1, thetaOffset = math.pi*1.5},
    {coords = { -.2, 1.02, -.52,   .2, 1.02,  .52,   .2, 1.02, -.52}, color = { -.1,  -.1, 0, "ribbon"}, top = true}, -- top
    {coords = {-.52, 1.02,  -.2,  .52, 1.02,   .2,  .52, 1.02,  -.2}, color = { -.1,  -.1, 0, "ribbon"}, top = true}, -- top
    -- {coords = {-.5, 0, -.5,  .5, 0,  .5,  .5, 0, -.5}, color = {.05, .7, .15, 1}}, -- bottom
}

local presentColors = {
    -- reds
    {
        {.75, .2, .15},
        {.6, .1, 0},
        {.4, .1, 0},
    },
    -- greens
    {
        {.15, .75, .15},
        {.1, .5, .1},
        {.1, .4, .1},
        {.2, .3, .1},
    },
    -- whites
    {
        {.9, .9, .9},
        {.9, .9, .8},
    },
}
local function SelectColor(taken)
    local index = taken
    while (index == taken) do -- not ideal but easy, good enough for now
        index = math.random(1, 3)
    end

    local colors = presentColors[index]
    return colors[math.random(1, #colors)], index
end

local function Present(name, x, y, z, width, height, depth, boxColor, ribbonColor, theta)
    name = name or "Test1"
    theta = theta or math.random() * math.pi * .5
    width = width or math.random() * .5 + .5
    height = height or math.random() * .5 + .5
    depth = depth or math.random() * .5 + .5
    if (not x) then
        local _
        _, x, y, z = GetUnitRawWorldPosition("player")
    end
    y = y + 5 -- assume y coord given is right on the floor

    -- select random color
    local taken
    if (not boxColor) then
        boxColor, taken = SelectColor()
    end
    ribbonColor = ribbonColor or SelectColor(taken)

    RemovePresent(name)

    presentControls[name] = {rects = {}, labels = {}}
    presentAnimations[name] = {
        height = height,
        x = x,
        y = y,
        z = z,
    }

    local controlParams = {
        xScale = width,
        yScale = height,
        zScale = depth,
        color = {1, 1, 1, 1},
    }

    for i, rect in ipairs(presentRects) do
        local coordsFunc
        if (rect.thetaOffset) then
            coordsFunc = function(x, y, z, control)
                -- d(zo_strformat("initial: <<1>> <<2>> <<3>> <<4>>", x, y - height * 100 / 2, z, theta + rect.thetaOffset))
                presentAnimations[name][i] = {
                    control = control,
                    oX = x,
                    oY = y - (rect.coords[2] - rect.coords[5]) * height * 100 / 2,
                    oZ = z,
                    theta = theta + rect.thetaOffset,
                    angleMultiplier = rect.angle,
                }
            end
        elseif (rect.top) then
            coordsFunc = function(x, y, z, control)
                presentAnimations[name][i] = {oX = x, oY = y, oZ = z, theta = theta, top = true, control = control}
            end
        end

        local baseColor = rect.color[4] == "base" and boxColor or ribbonColor
        controlParams.color[1] = baseColor[1] + rect.color[1]
        controlParams.color[2] = baseColor[2] + rect.color[2]
        controlParams.color[3] = baseColor[3] + rect.color[3]

        CreateControlFromElement(rect, presentControls[name].rects, presentControls[name].labels, x, y, z, GetUIGlobalScale(), theta, 0, coordsFunc, nil, controlParams)
    end
end
M.Present = Present
--[[
/script CrutchAlerts.Drawing.Model.Present()
/script CrutchAlerts.Drawing.Model.UpdatePresentAnimation(nil, 0.5)
/script CrutchAlerts.Drawing.Model.Present() zo_callLater(function() CrutchAlerts.Drawing.Model.PlayPresentAnimation("Test1") end, 2000)
/script CrutchAlerts.Drawing.Model.PlayPresentAnimation("Test1")
]]


---------------------------------------------------------------------
-- Events
---------------------------------------------------------------------
local messaged
local function OnDeathStateChanged(_, unitTag, isDead)
    -- To exclude companions and possibly pets too
    if (unitTag ~= "player" and not string.find(unitTag, "^group%d+$")) then return end

    -- Let player be handled by "player"
    if (unitTag ~= "player" and AreUnitsEqual("player", unitTag)) then return end

    if (isDead) then
        if (Crutch.Drawing.ShouldUnitBeShown(unitTag)) then
            local theta = GetPlayerCameraHeading()
            -- local theta = math.random() * math.pi * 2
            -- Grave facing player character?
            if (not AreUnitsEqual(unitTag, "player")) then
                local _, x1, _, z1 = GetUnitRawWorldPosition(unitTag)
                local _, x2, _, z2 = GetUnitRawWorldPosition("player")
                theta = math.atan2(x2 - x1, z2 - z1)
            end
            Grave(
                unitTag,
                intros[math.random(#intros)],
                string.gsub(GetUnitDisplayName(unitTag), "@", ""),
                unitTag == "player" and FormatDate(GetAchievementTimestamp(17)),
                nil,
                theta
                )

            if (not messaged and Crutch.GetSpeshulDate() == 1031) then
                messaged = true
                Crutch.msg("Happy spoopy season! If you don't want to see graves, you can turn it off in CrutchAlerts > Miscellaneous > Enable \"fun\" stuff")
            end
        end
    else
        RemoveGrave(unitTag)
    end
end

-- If someone leaves, clear all graves... cba figuring out new tags
local function RefreshUnitTags(reason)
    if (reason == "Left" or reason == "Update") then
        Crutch.dbgOther("Removing all graves because " .. reason)
        RemoveAllGraves()
    end
end

local function RefreshUnitTagsTimeout(reason)
    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "GraveRefreshTimeout", 200, function()
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "GraveRefreshTimeout")
        RefreshUnitTags(reason)
    end)
end


---------------------------------------------------------------------
-- Enable if it was deliberately turned on; if involuntary, only allow with depth buffers
local function AreGravesEnabled()
    if (not Crutch.savedOptions.general.showSpeshul) then return false end
    if (Crutch.savedOptions.experimental or Crutch.savedOptions.memes.graves) then return true end
    return Crutch.GetSpeshulDate() == 1031 and AreDepthBuffersSupported()
end
M.AreGravesEnabled = AreGravesEnabled


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function M.InitializeGrave()
    Crutch.UnregisterUnitTagListener("CrutchAlertsGraveUnitTags")
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "GraveGroupDeathState", EVENT_UNIT_DEATH_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "GravePlayerDeathState", EVENT_UNIT_DEATH_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "GravePlayerActivated", EVENT_PLAYER_ACTIVATED)

    RemoveAllGraves()

    if (not AreGravesEnabled()) then return end

    Crutch.RegisterUnitTagListener("CrutchAlertsGraveUnitTags", RefreshUnitTagsTimeout)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GraveGroupDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GraveGroupDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GravePlayerDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GravePlayerDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    -- Clean up on port
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GravePlayerActivated", EVENT_PLAYER_ACTIVATED, RemoveAllGraves)
end