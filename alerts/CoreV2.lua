local Crutch = CrutchAlerts
local C = Crutch.Constants


---------------------------------------------------------------------
--[[
use control pool
option to move up instead of remain in same spot
support effects + interrupting
key using abilityid + source unit id?
]]
---------------------------------------------------------------------
-- Structs
---------------------------------------------------------------------
--[[
{
    [?] = {
        endTime = 12345,
        interrupted = false,
        abilityId = 13243,
        sourceUnitId = 12314,
        targetUnitId = 132124,
        key = 1,
    }
}
]]
local alerts = {}

local displaySlots = {} -- {[1] = nil, [2] = ?}


---------------------------------------------------------------------
-- Update
---------------------------------------------------------------------
local controlPool

local function UpdateDisplay()
end

local function UpdateAllAnchors()
end

local function CreateAlertControl()
    local control, key = controlPool:AcquireObject()
    -- TODO: anchor
    return control, key
end


---------------------------------------------------------------------
-- Mostly model
---------------------------------------------------------------------
local function Poll()
end

local function RemoveAlert()
end

-- preventOverwrite might be used by Roaring Flare and Bahsei portal, but could probably just specify that from format?
local function DisplayAlertCommon(key, abilityId, textLabel, timer, sourceUnitId, sourceName, sourceType, targetUnitId, targetName, targetType, result, preventOverwrite)
    -- Check for special format
    local customTime, customColor, hideTimer, alertType, resultFilter, dingInIA, customText = Crutch.GetFormatInfo(abilityId)
    if (customText) then
        textLabel = customText
    end
    if (Crutch.savedOptions.general.showSpeshul and Crutch.savedOptions.memes.alertNames) then
        textLabel = Crutch.DecorateNotificationText(textLabel)
    end

    -- Result filter
    if (resultFilter == 1 and result ~= ACTION_RESULT_BEGIN) then
        return
    end
    if (resultFilter == 2 and result ~= ACTION_RESULT_EFFECT_GAINED) then
        return
    end
    if (resultFilter == 3 and result ~= ACTION_RESULT_EFFECT_GAINED_DURATION) then
        return
    end

    -- Custom timer
    if (customTime ~= 0) then
        timer = customTime
    end
    if (type(timer) ~= "number") then
        timer = 1000
        Crutch.dbgOther("|cFF0000Warning: timer is not number, setting to 1000|r")
    end

    local sourceIdAndName = zo_strformat("<<1>> <<2>>", sourceUnitId, sourceName)
    local targetIdAndName = zo_strformat("<<1>> <<2>>", targetUnitId, targetName)


    -- Normally, we overwrite existing casts of the same ability, if the source is the same. But source
    -- can sometimes be unknown (0), or it's multiple projectiles, etc. If preventOverwrite is specified,
    -- do nothing. If "always display" is specified, make a new alert line.
    local existing
    for key, data in pairs(alerts) do
        if (data.sourceUnitId == sourceUnitId and data.abilityId == abilityId) then
            existing = key
            break
        end
    end
    if (preventOverwrite and existing) then return end
    if (alertType == 2 and existing) then return end -- preventOverwrite
    if (alertType == 3 and existing) then
        key = key .. "I"
    end

    local data = alerts[key]
    if (not data) then
        alerts[key] = {}
        data = alerts[key]
    end

    -- Set or update the stuff
    data.abilityId = abilityId
    data.sourceUnitId = sourceUnitId
    data.targetUnitId = targetUnitId
    data.endTime = GetGameTimeMilliseconds() + timer

    if (not data.control) then
        local control, controlKey = CreateAlertControl()
        data.control = control
        data.controlKey = controlKey
    end

    -- UI things that are only set once
    data.control:SetText()

    -- TODO: vvv

    -- Set the time and make some strings
    local lineControl = CrutchAlertsContainer:GetNamedChild("Line" .. tostring(index))
    freeControls[index] = {source = sourceUnitId, expireTime = GetGameTimeMilliseconds() + timer, abilityId = abilityId, target = targetUnitId}
    AddToDisplaying(sourceUnitId, abilityId, preventOverwrite, targetUnitId, index)

    local resultString = ""
    if (result) then
        resultString = " " .. (resultStrings[result] or tostring(result))
    end

    local sourceTypeString = ""
    if (sourceType) then
        sourceTypeString = " " .. (unitTypeStrings[sourceType] or tostring(sourceType))
    end

    local targetTypeString = ""
    if (targetType) then
        targetTypeString = " " .. (unitTypeStrings[targetType] or tostring(targetType))
    end

    -- Keyboard vs gamepad fonts
    local styles = Crutch.GetStyles()
    local scale = GetScale()
    local alertFont = styles.GetAlertFont(scale * 8 / 9)
    local smallFont = styles.GetAlertFont(scale * 7 / 18)


    -- Set the items
    lineControl:SetHeight(scale)
    local labelControl = lineControl:GetNamedChild("Label")
    labelControl:SetFont(alertFont)
    labelControl:SetDimensions(1200, scale)
    labelControl:SetText(customColor and zo_strformat("|c<<1>><<2>>|r", customColor, textLabel) or zo_strformat("<<1>>", textLabel))
    labelControl:SetWidth(labelControl:GetTextWidth())

    if (hideTimer == 1) then
        lineControl:GetNamedChild("Timer"):SetHidden(true)
    else
        local timerLabel = lineControl:GetNamedChild("Timer")
        timerLabel:SetHidden(false)
        timerLabel:SetFont(alertFont)
        timerLabel:SetText(string.format("%.1f", timer / 1000))
        timerLabel:SetDimensions(200, scale)
        timerLabel:SetWidth(timerLabel:GetTextWidth())
        timerLabel:SetAnchor(LEFT, labelControl, RIGHT, scale * 5 / 18)
        timerLabel:SetColor(unpack(GetTimerColor(timer)))
    end

    local iconControl = lineControl:GetNamedChild("Icon")
    iconControl:SetTexture(GetAbilityIcon(abilityId))
    iconControl:SetDimensions(scale, scale)
    iconControl:SetAnchor(RIGHT, labelControl, LEFT, - scale * 2 / 9, 3)

    lineControl:GetNamedChild("Id"):SetFont(smallFont)
    if (Crutch.savedOptions.debugLine) then
        lineControl:GetNamedChild("Id"):SetText(string.format("%d (%d) [%s%s] [%s%s]%s", abilityId, timer, sourceIdAndName, sourceTypeString, targetIdAndName, targetTypeString, resultString))
    else
        lineControl:GetNamedChild("Id"):SetText("")
    end

    lineControl:SetHidden(false)

    -- Play a ding sound only in IA for Uppercut and Power Bash
    if (dingInIA == 1
        and Crutch.savedOptions.endlessArchive.dingUppercut
        and GetZoneId(GetUnitZoneIndex("player")) == 1436) then
        PlaySound(SOUNDS.DUEL_START)
    end

    -- Play a ding sound only in IA for other dangerous attacks
    if (dingInIA == 2
        and Crutch.savedOptions.endlessArchive.dingDangerous
        and GetZoneId(GetUnitZoneIndex("player")) == 1436) then
        PlaySound(SOUNDS.DUEL_START)
    end

    -- Start polling if it's not already going
    if (not isPolling) then
        EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "Poll", 100, UpdateDisplay)
        isPolling = true
    end

    alerts[key] = {
        abilityId = abilityId,

    }
end

-- ["e" .. unitTag .. abilityId] -- effects
local function DisplayEffectAlert()
    local key = zo_strformat("e_<<1>>_<<2>>", unitTag, abilityId)
end

-- ["c" .. abilityId] -- channels (only need self)
local function DisplayChannelAlert()
    local key = zo_strformat("c_<<1>>", abilityId)
end

-- ["g" .. source .. ability .. target] -- general alert. most likely to need interrupting based on source unit id. there shouldn't be many in total tho, so iterating is probably ok
local function DisplayGeneralAlert(abilityId, textLabel, timer, sourceUnitId, sourceName, sourceType, targetUnitId, targetName, targetType, result, preventOverwrite)
    local key = zo_strformat("g_<<1>>_<<2>>_<<3>>", sourceUnitId, abilityId, targetUnitId)
    -- TODO: return a key?
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Crutch.InitializeCore()
    controlPool = ZO_ControlPool:New("CrutchAlerts_Line_Template", CrutchAlertsContainer)
end
