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
        controlKey = 1,
    }
}
]]
local alerts = {}

local displaySlots = {} -- {[1] = nil, [2] = ?}


---------------------------------------------------------------------
-- Util

-- Milliseconds
local function GetTimerColor(timer)
    if (timer > 2000) then
        return {255, 238, 0}
    elseif (timer > 1000) then
        return {255, 140, 0}
    else
        return {255, 0, 0}
    end
end

-- Scale is the size of the icon, default 36
-- Default font size was 32
local function GetScale()
    return Crutch.savedOptions.general.alertScale
end


---------------------------------------------------------------------
-- Update
---------------------------------------------------------------------
local isPolling = false
local controlPool

local function UpdateAllAnchors()
end

local function UpdateDisplay()
    local numActive = 0
    for key, data in pairs(alerts) do
        local timer = data.endTime - GetGameTimeMilliseconds()
        if (timer < 0) then
            control:SetHidden(true)
            controlPool:ReleaseObject(data.controlKey)
            alerts[key] = nil
            UpdateAllAnchors()
        else
            numActive = numActive + 1
            local timerLabel = data.control:GetNamedChild("Timer")
            if (not timerLabel:IsHidden()) then
                timerLabel:SetText(string.format("%.1f", timer / 1000))
                timerLabel:SetColor(unpack(GetTimerColor(timer)))
            end
        end
    end

    -- Stop polling
    if (numActive == 0) then
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "PollV2")
        isPolling = false
    end
end

local function CreateAlertControl()
    local control, key = controlPool:AcquireObject()
    -- TODO: anchor
    return control, key
end

local function Poll()
end


---------------------------------------------------------------------
-- Mostly model
---------------------------------------------------------------------
local function SetInitialUI(control, customColor, alertType, resultFilter, dingInIA, customText, sourceUnitId, sourceName, sourceType, targetUnitId, targetName, targetType, result, abilityId, timer, hideTimer)
    -- Keyboard vs gamepad fonts
    local styles = Crutch.GetStyles()
    local scale = GetScale()
    local alertFont = styles.GetAlertFont(scale * 8 / 9)
    local smallFont = styles.GetAlertFont(scale * 7 / 18)

    control:SetHeight(scale)

    -- Main label text
    local labelControl = control:GetNamedChild("Label")
    labelControl:SetFont(alertFont)
    labelControl:SetDimensions(1200, scale)
    labelControl:SetText(customColor and zo_strformat("|c<<1>><<2>>|r", customColor, textLabel) or zo_strformat("<<1>>", textLabel))
    labelControl:SetWidth(labelControl:GetTextWidth())

    -- Debug text
    local debugControl = control:GetNamedChild("Id")
    debugControl:SetFont(smallFont)
    if (Crutch.savedOptions.debugLine) then
        local sourceIdAndName = zo_strformat("<<1>> <<2>>", sourceUnitId, sourceName)
        local targetIdAndName = zo_strformat("<<1>> <<2>>", targetUnitId, targetName)

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

        debugControl:SetText(zo_strformat("<<1>> (<<2>>) [<<3>><<4>>] [<<5>><<6>>]<<7>>", abilityId, timer, sourceIdAndName, sourceTypeString, targetIdAndName, targetTypeString, resultString)))
    else
        debugControl:SetText("")
    end

    -- Timer
    local timerControl = control:GetNamedChild("Timer")
    timerControl:SetHidden(hideTimer == 1)
    if (hideTimer ~= 1) then
        timerControl:SetFont(alertFont)
        timerControl:SetHeight(scale)
        timerControl:SetAnchor(LEFT, labelControl, RIGHT, scale * 5 / 18)
    end

    -- Icon
    local iconControl = control:GetNamedChild("Icon")
    iconControl:SetTexture(GetAbilityIcon(abilityId))
    iconControl:SetDimensions(scale, scale)
    iconControl:SetAnchor(RIGHT, labelControl, LEFT, - scale * 2 / 9, 3)

    control:SetHidden(false)
end

local function PlaySoundIfApplicable(dingInIA)
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

    -----------------------------------
    -- UI things that are only set once
    SetInitialUI(data.control, customColor, alertType, resultFilter, dingInIA, customText, sourceUnitId, sourceName, sourceType, targetUnitId, targetName, targetType, result, abilityId, timer, hideTimer)

    -- Dings in IA
    PlaySoundIfApplicable(dingInIA)

    UpdateDisplay()

    -- Start polling if it's not already going
    if (not isPolling) then
        EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "PollV2", 100, UpdateDisplay)
        isPolling = true
    end
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

local function InterruptAlert()
    -- TODO
end

local function RemoveAlert(showStopped)
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Crutch.InitializeCore()
    controlPool = ZO_ControlPool:New("CrutchAlerts_Line_Template", CrutchAlertsContainer)
end
