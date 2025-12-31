local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Data

-- Currently unused controls for notifications: {[1] = {source = sourceUnitId, expireTime = 1235345, interrupted = true, abilityId = 12345, target = targetUnitId}}
local freeControls = {}

---------------------------------------------------------------------
-- Currently displaying info to index. Used to interrupt/remove existing notifications
-- We cannot rely only on sourceUnitId, because it can be 0 for attacks targeting
-- other players, or possibly other unknown.
--[[
{
    [sourceUnitId] = {
        [abilityId] = {
            multiTargets = false,
            targets = { -- if multiTargets
                [targetUnitId] = index,
            },
            index = 1, -- if not multiTargets
        },
    },
}
]]
local displaying = {}

local function RemoveFromDisplaying(sourceUnitId, abilityId, targetUnitId)
    if (displaying[sourceUnitId]) then
        if (displaying[sourceUnitId][abilityId]) then
            if (displaying[sourceUnitId][abilityId].multiTargets) then
                -- Only remove the specific target
                displaying[sourceUnitId][abilityId].targets[targetUnitId] = nil
                if (ZO_IsTableEmpty(displaying[sourceUnitId][abilityId].targets)) then
                    displaying[sourceUnitId][abilityId] = nil
                end
            else
                -- If preventOverwrite, it only displays once anyway, so no targets needed
                displaying[sourceUnitId][abilityId] = nil
            end
        end
        if (ZO_IsTableEmpty(displaying[sourceUnitId])) then
            displaying[sourceUnitId] = nil
        end
    end
end

local function AddToDisplaying(sourceUnitId, abilityId, preventOverwrite, targetUnitId, index)
    if (not displaying[sourceUnitId]) then
        displaying[sourceUnitId] = {}
    end

    if (not displaying[sourceUnitId][abilityId]) then
        displaying[sourceUnitId][abilityId] = {multiTargets = preventOverwrite}
        if (displaying[sourceUnitId][abilityId].multiTargets) then
            displaying[sourceUnitId][abilityId].targets = {}
        end
    end

    if (displaying[sourceUnitId][abilityId].multiTargets) then
        displaying[sourceUnitId][abilityId].targets[targetUnitId] = index
    else
        displaying[sourceUnitId][abilityId].index = index
    end
end

---------------------------------------------------------------------
-- Poll every 100ms when one is active
local isPolling = false

local fontSize = 32 -- This isn't really font size, just line size

-- Cache group members by using status effects, so we know the unit IDs
Crutch.groupIdToTag = {}
Crutch.groupTagToId = {}

local resultStrings = {
    [ACTION_RESULT_BEGIN] = "begin",
    [ACTION_RESULT_EFFECT_GAINED] = "gained",
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = "duration",
}

local unitTypeStrings = {
    [COMBAT_UNIT_TYPE_NONE] = "none",
    [COMBAT_UNIT_TYPE_PLAYER] = "player",
    [COMBAT_UNIT_TYPE_PLAYER_PET] = "pet",
    [COMBAT_UNIT_TYPE_GROUP] = "group",
    [COMBAT_UNIT_TYPE_TARGET_DUMMY] = "dummy",
    [COMBAT_UNIT_TYPE_OTHER] = "other",
}


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
-- Display

local function UpdateDisplay()
    local currTime = GetGameTimeMilliseconds()
    local numActive = 0
    for i, data in pairs(freeControls) do
        if (data and data.expireTime) then
            local lineControl = CrutchAlertsContainer:GetNamedChild("Line" .. tostring(i))
            local millisRemaining = (data.expireTime - currTime)
            if (millisRemaining < 0) then
                -- Hide because timer is over
                lineControl:SetHidden(true)
                freeControls[i] = false
                RemoveFromDisplaying(data.source, data.abilityId, data.target)
            else
                numActive = numActive + 1
                if (not data.interrupted and lineControl:GetNamedChild("Timer") ~= "") then
                    -- Update the timer
                    lineControl:GetNamedChild("Timer"):SetText(string.format("%.1f", millisRemaining / 1000))
                    lineControl:GetNamedChild("Timer"):SetColor(unpack(GetTimerColor(millisRemaining)))

                    -- Also display prominent alert if applicable
                    if (Crutch.savedOptions.general.showProminent) then
                        local prominentThreshold = 1000
                        if (Crutch.prominent[data.abilityId] and Crutch.prominent[data.abilityId].preMillis) then
                            prominentThreshold = Crutch.prominent[data.abilityId].preMillis
                        end
                        if (millisRemaining <= prominentThreshold and Crutch.prominent[data.abilityId]) then
                            if (not Crutch.prominentDisplaying[data.abilityId]) then
                                Crutch.DisplayProminent(data.abilityId)
                            end
                        end
                    end
                end
            end
        end
    end

    -- Stop polling
    if (numActive == 0) then
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "Poll")
        isPolling = false
    end
end

local function FindOrCreateControl()
    for i, data in pairs(freeControls) do
        if (data == false) then
            return i
        end
    end

    -- Else, make a new control
    local index = #freeControls + 1
    local lineControl = CreateControlFromVirtual(
        "$(parent)Line" .. tostring(index),     -- name
        CrutchAlertsContainer,           -- parent
        "CrutchAlerts_Line_Template",    -- template
        "")                                     -- suffix
    if (index == 1) then
        lineControl:SetAnchor(CENTER, CrutchAlertsContainer, CENTER, 0, 0)
    else
        local prevControl = CrutchAlertsContainer:GetNamedChild("Line" .. tostring(index - 1))
        lineControl:SetAnchor(TOP, prevControl, BOTTOM, 0, GetScale() * 4 / 9)
    end

    return index
end


---------------------------------------------------------------------
-- Outside calling

function Crutch.DisplayNotification(abilityId, textLabel, timer, sourceUnitId, sourceName, sourceType, targetUnitId, targetName, targetType, result, preventOverwrite)
    -- Check for special format
    local customTime, customColor, hideTimer, alertType, resultFilter, dingInIA, customText = Crutch.GetFormatInfo(abilityId)
    if (customText) then
        textLabel = customText
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


    local index = 0
    -- Overwrite existing cast of the same ability
    if (displaying[sourceUnitId] and displaying[sourceUnitId][abilityId]) then
        -- Don't overwrite for type == 2
        if ((not preventOverwrite and alertType == 2) or displaying[sourceUnitId][abilityId].multiTargets) then
            return
        end

        -- Do not overwrite for alert type 3 and instead display a second possibly duplicate alert
        if (alertType == 3) then
            index = FindOrCreateControl()
        else
            -- Overwrite the currently displaying if it's single mode
            if (abilityId ~= 114578 -- BRP Portal Spawn
                and abilityId ~= 72057 -- MA Portal Spawn
                ) then
                Crutch.dbgSpam(string.format("|cFF8888[CS]|r Overwriting %s from %s because it's already being displayed", GetAbilityName(abilityId), sourceIdAndName))
            end
            index = displaying[sourceUnitId][abilityId].index
        end
    else
        index = FindOrCreateControl()
    end

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
end

local function AdjustControlsOnInterrupt(unitId, abilityId, targetUnitId, suppressStopped)
    if (Crutch.uninterruptible[abilityId]) then -- Some abilities show up as immediately interrupted, don't do that
        return
    end

    local data = displaying[unitId][abilityId]
    local index
    if (targetUnitId and data.targets) then
        index = data.targets[targetUnitId]
    else
        index = data.index
    end
    local expiredTimer = "0" -- A possible string for duration remaining that was cancelled
    if (index and not freeControls[index].interrupted) then -- Don't add it again if it's already interrupted
        freeControls[index].interrupted = true

        -- Only show "stopped" if we're not choosing to suppress it, and it hasn't already expired naturally
        -- i.e. if the current time is not yet within 100ms of the expire time
        if (suppressStopped) then
            -- Remove immediately
            freeControls[index].expireTime = GetGameTimeMilliseconds() - 1
            UpdateDisplay()
        elseif (GetGameTimeMilliseconds() < freeControls[index].expireTime - 100) then
            freeControls[index].expireTime = GetGameTimeMilliseconds() + 1000 -- Hide it after 1 second

            -- Set the text to "stopped"
            local lineControl = CrutchAlertsContainer:GetNamedChild("Line" .. tostring(index))
            local labelControl = lineControl:GetNamedChild("Label")
            local timerControl = lineControl:GetNamedChild("Timer")
            labelControl:SetWidth(800)
            labelControl:SetText(labelControl:GetText() .. " |cA8FFBD- stopped|r")
            labelControl:SetWidth(labelControl:GetTextWidth())
            expiredTimer = timerControl:GetText()
            timerControl:SetText("")
        end
    end

    -- Also cancel the prominent display if there is one--though this is unlikely, since most prominents have been moved to V2
    if (Crutch.prominentDisplaying[abilityId]) then
        local slot = Crutch.prominentDisplaying[abilityId]
        local control = GetControl("CrutchAlertsProminent" .. tostring(slot))
        control:SetHidden(true)
        Crutch.prominentDisplaying[abilityId] = nil
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "Prominent" .. tostring(slot))
    end

    return expiredTimer
end

-- To be called when an enemy is interrupted
function Crutch.Interrupted(sourceUnitId)
    if (not displaying[sourceUnitId]) then
        return
    end

    Crutch.dbgSpam("Attempting to interrupt sourceUnitId " .. tostring(sourceUnitId))
    local expiredTimer = "0"
    for abilityId, _ in pairs(displaying[sourceUnitId]) do
        expiredTimer = AdjustControlsOnInterrupt(sourceUnitId, abilityId, nil)
    end
    return expiredTimer
end

-- To be called when an ability by any enemy is interrupted
function Crutch.InterruptAbility(abilityId, suppressStopped)
    -- Check through all displaying alerts to find matching ability IDs
    local expiredTimer = "0"
    for unitId, unitData in pairs(displaying) do
        if (unitData[abilityId]) then
            expiredTimer = AdjustControlsOnInterrupt(unitId, abilityId, nil, suppressStopped)
        end
    end
    return expiredTimer
end

function Crutch.InterruptAbilityOnTarget(abilityId, targetUnitId, suppressStopped)
    Crutch.dbgSpam(string.format("Attempting to interrupt %s (%d) on %s (%d)", GetAbilityName(abilityId), abilityId, GetUnitDisplayName(Crutch.groupIdToTag[targetUnitId]), targetUnitId))
    -- Check through all display alerts to find matching ability IDs that have the target
    local expiredTimer = "0"
    for unitId, unitData in pairs(displaying) do
        if (unitData[abilityId] and unitData[abilityId].targets and unitData[abilityId].targets[targetUnitId]) then
            expiredTimer = AdjustControlsOnInterrupt(unitId, abilityId, targetUnitId, suppressStopped)
        end
    end
    return expiredTimer
end
