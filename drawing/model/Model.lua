local Crutch = CrutchAlerts
Crutch.Drawing.Model = {}
local M = Crutch.Drawing.Model


---------------------------------------------------------------------
local function AreDepthBuffersSupported()
    if (IsConsoleUI()) then return false end
    return GetCVar("SUB_SAMPLING") == SUB_SAMPLING_MODE_NORMAL
end


---------------------------------------------------------------------
-- generic?
---------------------------------------------------------------------
local genericTexturePool, genericLabelPool
local first
local rectControls = {} -- {[key] = {control = control, targetY = 123}}
local labelControls = {} -- ''
local graves = {} -- {["group3"] = {rects = {key,}, labels = {}}}
local animations = {} -- {["group3"] = targetTime}

local ANIMATION_DURATION = 1000
local ANIMATION_Y = 170
local ANIMATION_X_PERIOD = 100
local ANIMATION_X = 1.5

local function UpdateAnimations()
    for unitTag, targetTime in pairs(animations) do
        local timeUntilEnd = targetTime - GetGameTimeMilliseconds()
        if (timeUntilEnd < 0) then
            -- animation reached end, remove animation but do 1 last update to the end target
            animations[unitTag] = nil
            if (ZO_IsTableEmpty(animations)) then
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
    if (ZO_IsTableEmpty(animations)) then
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "GraveUpdate")
    else
        EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "GraveUpdate", 20, UpdateAnimations)
    end
end

local function CreateRectRenderSpace(x, y, z, pitch, yaw, roll, width, height, color, texture)
    if (not genericTexturePool) then
        genericTexturePool = ZO_ControlPool:New("CrutchAlertsModelTexture", CrutchAlertsDrawing)
        -- TODO: reset function?
    end

    local control, key = genericTexturePool:AcquireObject()
    rectControls[key] = {control = control, targetX = x, targetY = y, targetZ = z}

    control:SetHidden(false)
    control:Create3DRenderSpace()
    control:SetColor(unpack(color))
    control:SetTexture(texture or "CrutchAlerts/assets/floor/square.dds")

    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y - ANIMATION_Y, z))

    control:Set3DLocalDimensions(width, height)
    control:Set3DRenderSpaceUsesDepthBuffer(true)

    -- pitch, yaw, roll
    control:Set3DRenderSpaceOrientation(pitch, yaw, roll)

    -- TODO
    control:SetDesaturation(1)

    return control, key
end

local function CreateLabelRenderSpace(x, y, z, pitch, yaw, roll, width, height, color, text, fontSize)
    if (not genericLabelPool) then
        genericLabelPool = ZO_ControlPool:New("CrutchAlertsModelLabel", CrutchAlertsDrawing)
        -- TODO: reset function?
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

    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y - ANIMATION_Y, z))
    control:Set3DRenderSpaceUsesDepthBuffer(true)

    -- pitch, yaw, roll
    control:Set3DRenderSpaceOrientation(pitch, yaw, roll)

    return control, key
end

local function CalculateValues(x1, y1, z1, x2, y2, z2, x3, y3, z3)
    -- Midpoint
    local oX = (x1 + x2) / 2
    local oY = (y1 + y2) / 2
    local oZ = (z1 + z2) / 2

    local height = math.sqrt((x3 - x2)^2 + (y3 - y2)^2 + (z3 - z2)^2)
    local width = math.sqrt((x3 - x1)^2 + (y3 - y1)^2 + (z3 - z1)^2)
    local pitch = math.atan2(z3 - z2, y3 - y2)
    local yaw = math.atan2(z3 - z1, x3 - x1)
    local roll = -math.atan2(x3 - x2, y3 - y2)

    return oX, oY, oZ, pitch, yaw, roll, width, height
end

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

local elements = {
    -- top left, bottom right, top right
    -- {coords = {.3, 1.4, -.1, -.3, .8, -.1, -.3, 1.4, -.1}, color = {.9, .9, .9, .5}, texture = "esoui/art/trials/vitalitydepletion.dds"},
    -- {coords = {0, 0, 0, 0, 0, 0, 0, 0, 0}, color = {.9, .9, .9, 1}, texture = "CrutchAlerts/assets/floor/square.dds"},

    -- frontback
    {coords = {-.6, 1.8, .3, .6, 0, .3, .6, 1.8, .3}, color = {.5, .5, .5, 1}, texture = "esoui/art/worldmap/worldmap_map_background_512tile.dds"},
    {coords = {-.6, 1.8,  0, .6, 0,  0, .6, 1.8,  0}, color = {.5, .5, .5, 1}, texture = "esoui/art/worldmap/worldmap_map_background_512tile.dds"},

    {coords = {-.6, 1.5, .31, .6, 1.4, .31, .6, 1.5, .31}, color = {.1, .1, .1, 1}, text = "<<1>>"},
    {coords = {-.6, 1.3, .31, .6, 1.2, .31, .6, 1.3, .31}, color = {.1, .1, .1, 1}, text = "<<2>>"},

    {coords = {-.6,   1, .31, .6,  .9, .31, .6,   1, .31}, color = {.1, .1, .1, 1}, text = "<<3>>", fontSize = 14},
    {coords = {-.6,  .9, .31, .6,  .8, .31, .6,  .9, .31}, color = {.1, .1, .1, 1}, text = "-", fontSize = 14},
    {coords = {-.6, .77, .31, .6, .67, .31, .6, .77, .31}, color = {.1, .1, .1, 1}, text = "<<4>>", fontSize = 14},

    -- sides
    {coords = {-.6, 1.8,  0, -.6,   0, .3, -.6, 1.8, .3}, color = {.4, .4, .4, 1}, texture = "esoui/art/worldmap/worldmap_map_background_512tile.dds"},
    {coords = {-.6, 1.8,  0,  .6, 1.8, .3,  .6, 1.8,  0}, color = {.45, .45, .45, 1}, texture = "esoui/art/worldmap/worldmap_map_background_512tile.dds"},
    {coords = { .6, 1.8, .3,  .6,   0,  0,  .6, 1.8,  0}, color = {.4, .4, .4, 1}, texture = "esoui/art/worldmap/worldmap_map_background_512tile.dds"},
}

local scale = 100
local function CreateControlFromElement(element, unitTag, x, y, z, intro, name, birth, death, uiScale)
    local oX, oY, oZ, pitch, yaw, roll, width, height = CalculateValues(unpack(element.coords))
    if (element.texture) then
        local control, key = CreateRectRenderSpace(x + oX * scale, y + oY * scale, z + oZ * scale, pitch, yaw, roll, width, height, element.color, element.texture)
        table.insert(graves[unitTag].rects, key)
    elseif (element.text) then
        local scaledFontSize = math.floor((element.fontSize or 17) / uiScale)

        -- Create it normally first
        local text = zo_strformat(element.text, intro, name, birth, death)
        local control, key = CreateLabelRenderSpace(x + oX * scale, y + oY * scale, z + oZ * scale, pitch, yaw, roll, width, height, element.color, text, scaledFontSize)
        table.insert(graves[unitTag].labels, key)

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
            element.coords[1] - offset,
            element.coords[2],
            element.coords[3],
            element.coords[4] - offset,
            element.coords[5],
            element.coords[6],
            element.coords[7] - offset,
            element.coords[8],
            element.coords[9]
            )
        local newX = x + sX * scale
        local newY = y + sY * scale
        local newZ = z + sZ * scale
        labelControls[key].targetX = newX
        labelControls[key].targetY = newY
        labelControls[key].targetZ = newZ
        control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(newX, newY - ANIMATION_Y, newZ))
        Crutch.dbgSpam("^^^ " .. control:GetName() .. " ^^^")
    end
end

local function Grave(unitTag, intro, name, birth, death)
    unitTag = unitTag or "player"
    local _, x, y, z = GetUnitRawWorldPosition(unitTag)
    y = y - 20
    intro = intro or "Here lies"
    name = name or "Kyzeragon"
    birth = birth or "Unknown"
    death = death or FormatDate(GetTimeStamp())

    RemoveGrave(unitTag)

    graves[unitTag] = {rects = {}, labels = {}}

    local uiScale = GetUIGlobalScale()

    for _, element in ipairs(elements) do
        CreateControlFromElement(element, unitTag, x, y, z, intro, name, birth, death, uiScale)
    end

    animations[unitTag] = GetGameTimeMilliseconds() + ANIMATION_DURATION
    PollIfNeeded()
end
M.Grave = Grave
--[[
/script CrutchAlerts.Drawing.Model.Grave()
/script CrutchAlerts.Drawing.Model.Grave("player", "Forever in our hearts", "efiye", "May 12, 3203")
/script CrutchAlerts.Drawing.Model.Grave("player", "Rest in Peace", "TheClawlessConqueror", "May 12, 320312345113")
]]

local intros = {
    "Here lies",
    "In loving memory of",
    "R.I.P.",
    "Rest in Peace",
    "Rest in Pieces",
    "Never forgotten",
    "Gone too soon",
}


---------------------------------------------------------------------
-- Events
---------------------------------------------------------------------
local function OnDeathStateChanged(_, unitTag, isDead)
    -- To exclude companions and possibly pets too
    if (unitTag ~= "player" and not string.find(unitTag, "^group%d+$")) then return end

    -- Let player be handled by "player"
    if (unitTag ~= "player" and AreUnitsEqual("player", unitTag)) then return end

    if (isDead) then
        if (Crutch.Drawing.ShouldUnitBeShown(unitTag)) then
            Grave(
                unitTag,
                intros[math.random(#intros)],
                string.gsub(GetUnitDisplayName(unitTag), "@", ""),
                unitTag == "player" and FormatDate(GetAchievementTimestamp(17))
                )
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
