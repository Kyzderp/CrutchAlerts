local Crutch = CrutchAlerts
local Draw = Crutch.Drawing
local C = Crutch.Constants

--[[
CrutchAlerts.savedOptions.drawing.attached.individualIcons = {
    ["@Kyzeragon"] = {
        type = C.CIRCLE, -- C.DIAMOND, C.CHEVRON, C.THINCHEVRON
        size = 1,
        custom = nil,
        color = {1, 0.3, 0.4},
        text = "blah",
        textSize = 50,
    },
    ["@Kyzeragone"] = {
        type = C.LCI,
        size = 1,
        custom = nil, -- nil for self name, otherwise @ name to use someone else's...?
        color = {1, 1, 1},
        text = "blah",
        textSize = 50,
    },
    ["@TheClawlessConqueror"] = {
        type = C.PATH,
        size = 1,
        custom = "esoui/art/icons/targetdummy_voriplasm_01.dds",
        color = {1, 1, 1},
        text = "blah",
        textSize = 50,
    },
}
]]

---------------------------------------------------------------------
-- Actual texture to show
---------------------------------------------------------------------
local function GetIconTexture(name, iconData)
    if (iconData.type == C.CIRCLE) then
        return "CrutchAlerts/assets/shape/circle.dds"
    elseif (iconData.type == C.DIAMOND) then
        return "CrutchAlerts/assets/shape/diamond.dds"
    elseif (iconData.type == C.CHEVRON) then
        return "CrutchAlerts/assets/shape/chevron.dds"
    elseif (iconData.type == C.CHEVRON_THIN) then
        return "CrutchAlerts/assets/shape/chevronthin.dds"
    elseif (iconData.type == C.LCI) then
        if (LibCustomIcons) then
            return LibCustomIcons.GetStatic(name)
        end
        return nil
    elseif (iconData.type == C.CUSTOM) then
        return iconData.custom
    end
    return nil
end


---------------------------------------------------------------------
-- Individual icons internal
---------------------------------------------------------------------
local INDIVIDUAL_ICONS_NAME = "CrutchAlertsIndividualIcon"
local INDIVIDUAL_ICONS_PRIORITY = 108

-- Because this would create a lot of tables otherwise
local spaceOptionsTablePool = {} -- {@name = table}

-- To be called from group refresh, clears all
local function DestroyIndividualIcons()
    Crutch.RemoveAllAttachedIcons(INDIVIDUAL_ICONS_NAME)
end
Draw.DestroyIndividualIcons = DestroyIndividualIcons

-- To be called from group refresh
local function MaybeSetIndividualIcon(unitTag)
    local name = GetUnitDisplayName(unitTag)
    local iconData = Crutch.savedOptions.drawing.attached.individualIcons[name]
    if (iconData) then
        -- TODO: mention it's case sensitive
        local spaceOptions = spaceOptionsTablePool[name] or {}
        spaceOptionsTablePool[name] = spaceOptions
        ZO_ClearTable(spaceOptions)

        local texture, left, right, top, bottom = GetIconTexture(name, iconData)
        if (texture) then
            spaceOptions.texture = {
                path = texture,
                size = iconData.size,
                color = iconData.color,

                -- Texture coords
                left = left,
                right = right,
                top = top,
                bottom = bottom,
            }
        end

        if (iconData.text) then
            spaceOptions.label = {
                text = iconData.text,
                size = iconData.textSize,
                color = iconData.textColor,
            }
        end

        -- SetIconForUnit(unitTag, uniqueName, priority, texture, size, color, yOffset, persistOutsideCombat, callback, spaceOptions)
        Crutch.SetAttachedIconForUnit(unitTag,
            INDIVIDUAL_ICONS_NAME,
            C.PRIORITY.INDIVIDUAL_ICONS,
            nil,
            100,
            nil,
            true,
            nil,
            spaceOptions)
    end
end
Draw.MaybeSetIndividualIcon = MaybeSetIndividualIcon


---------------------------------------------------------------------
-- Adding individual icons API, persisted
---------------------------------------------------------------------
local function AddIndividualIcon(atName, type, custom, size, color, text, textSize, textColor)
    Crutch.dbgSpam("Adding individual icon for " .. atName)
    local data = Crutch.savedOptions.drawing.attached.individualIcons[atName]
    if (not data) then
        data = {
            color = {1, 1, 1, 1},
            textColor = {1, 1, 1, 1},
        }
    end

    data.type = type or C.CIRCLE
    data.custom = custom
    data.size = size or 1
    if (color) then data.color = color end

    data.text = text
    data.textSize = textSize or 50
    if (textColor) then data.textColor = textColor end

    Crutch.savedOptions.drawing.attached.individualIcons[atName] = data
end
Crutch.AddIndividualIcon = AddIndividualIcon
-- /script CrutchAlerts.AddIndividualIcon("@Kyzeragon", CrutchAlerts.Constants.CUSTOM, "esoui/art/icons/targetdummy_voriplasm_01.dds", nil, nil, "blob", 50, nil) CrutchAlerts.Drawing.RefreshGroup()

local function RemoveIndividualIcon(atName)
    Crutch.savedOptions.drawing.attached.individualIcons[atName] = nil
end
Crutch.RemoveIndividualIcon = RemoveIndividualIcon
