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
local graves = {} -- {["group3"] = {rects = {key,}, labels = {}}}

local function CreateRectRenderSpace(x, y, z, pitch, yaw, roll, width, height, color, texture)
    if (not genericTexturePool) then
        genericTexturePool = ZO_ControlPool:New("CrutchAlertsModelTexture", CrutchAlertsDrawing)
        -- TODO: reset function?
    end

    local control, key = genericTexturePool:AcquireObject()

    control:SetHidden(false)
    control:Create3DRenderSpace()
    control:SetColor(unpack(color))
    control:SetTexture(texture or "CrutchAlerts/assets/floor/square.dds")

    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y, z))

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

    control:SetHidden(false)
    control:Create3DRenderSpace()
    control:SetColor(unpack(color))

    fontSize = fontSize or 20
    control:SetFont("$(STONE_TABLET_FONT)|" .. fontSize)
    control:SetText(text)
    control:SetColor(.1, .1, .1, 1)
    Crutch.dbgSpam(text .. " - $(STONE_TABLET_FONT)|" .. fontSize)

    control:SetScale(0.01)

    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y, z))
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
    end
    for _, key in ipairs(data.labels) do
        genericLabelPool:ReleaseObject(key)
    end
    graves[unitTag] = nil
end
M.RemoveGrave = RemoveGrave

local elements = {
    -- top left, bottom right, top right
    {coords = {0, 0, 0, 0, 0, 0, 0, 0, 0}, color = {.9, .9, .9, 1}, texture = "CrutchAlerts/assets/floor/square.dds"},

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

local function Grave(unitTag, intro, name, birth, death)
    unitTag = unitTag or "player"
    local _, x, y, z = GetUnitRawWorldPosition(unitTag)
    y = y - 20
    intro = intro or "Here lies"
    name = name or "TheClawlessConqueror"
    birth = birth or "Unknown"
    death = death or FormatDate(GetTimeStamp())

    RemoveGrave(unitTag)

    graves[unitTag] = {rects = {}, labels = {}}

    local uiScale = GetUIGlobalScale()

    local scale = 100
    local num = 1
    for _, element in ipairs(elements) do
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
            local offset = textWidth / 100 / 2 * uiScale -- .75 arbitrary to get the centering offset right
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
            control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x + sX * scale, y + sY * scale, z + sZ * scale))
            Crutch.dbgSpam("^^^ " .. control:GetName() .. " ^^^")
        else
            return
        end
    end
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

local function OnDeathStateChanged(_, unitTag, isDead)
    -- To exclude companions and possibly pets too
    if (unitTag ~= "player" and not string.find(unitTag, "^group%d+$")) then return end

    -- Let player be handled by "player"
    if (unitTag ~= "player" and AreUnitsEqual("player", unitTag)) then return end

    if (isDead) then
        Grave(
            unitTag,
            intros[math.random(#intros)],
            string.gsub(GetUnitDisplayName(unitTag), "@", ""),
            unitTag == "player" and FormatDate(GetAchievementTimestamp(17))
            )
    else
        RemoveGrave(unitTag)
    end
end

-- Enable if it was deliberately turned on; if involuntary, only allow with depth buffers
local function AreGravesEnabled()
    if (not Crutch.savedOptions.general.showSpeshul) then return false end
    if (Crutch.savedOptions.experimental or Crutch.savedOptions.memes.graves) then return true end
    return Crutch.GetSpeshulDate() == 1031 and AreDepthBuffersSupported()
end
M.AreGravesEnabled = AreGravesEnabled

function M.InitializeGrave()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "GraveGroupDeathState", EVENT_UNIT_DEATH_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "GravePlayerDeathState", EVENT_UNIT_DEATH_STATE_CHANGED)

    if (not AreGravesEnabled()) then return end

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GraveGroupDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GraveGroupDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GravePlayerDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GravePlayerDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
end
