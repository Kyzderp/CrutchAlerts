CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Data

-- Currently unused controls for notifications: {[1] = {source = sourceUnitId, expireTime = 1235345, interrupted = true, abilityId = 12345}}
local freeControls = {}

-- Currently displaying source to index {[sourceUnitId] = {[abilityId] = {index = index, preventOverwrite = true},}}
local displaying = {}

-- Poll every 100ms when one is active
local isPolling = false

local fontSize = 32

-- Cache group members by using status effects, so we know the unit IDs
Crutch.groupIdToTag = {}
Crutch.groupTagToId = {}

local resultStrings = {
    [ACTION_RESULT_BEGIN] = "begin",
    [ACTION_RESULT_EFFECT_GAINED] = "gained",
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = "duration",
}

local sourceStrings = {
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

local function GetNumEntries(tab)
    local count = 0
    for k, v in pairs(tab) do
        if (v) then
            count = count + 1
        end
    end
    return count
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
                -- Hide
                lineControl:SetHidden(true)
                freeControls[i] = false
                if (displaying[data.source]) then
                    displaying[data.source][data.abilityId] = nil
                    if (GetNumEntries(displaying[data.source]) == 0) then
                        displaying[data.source] = nil
                    end
                end
            else
                numActive = numActive + 1
                if (not data.interrupted and lineControl:GetNamedChild("Timer") ~= "") then
                    -- Update the timer
                    lineControl:GetNamedChild("Timer"):SetText(string.format("%.1f", millisRemaining / 1000))
                    lineControl:GetNamedChild("Timer"):SetColor(unpack(GetTimerColor(millisRemaining)))

                    -- Also display prominent alert if applicable
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
    lineControl:SetAnchor(CENTER, CrutchAlertsContainer, CENTER, 0, (index - 1) * zo_floor(fontSize * 1.5))

    return index
end


---------------------------------------------------------------------
-- Outside calling

function Crutch.DisplayNotification(abilityId, textLabel, timer, sourceUnitId, sourceName, sourceType, result, preventOverwrite)
    -- Check for special format
    local customTime, customColor, hideTimer, alertType, resultFilter = Crutch.GetFormatInfo(abilityId)

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
        d("|cFF0000Warning: timer is not number, setting to 1000|r")
    end
    sourceName = zo_strformat("<<1>>", sourceName)

    local index = 0
    -- Overwrite existing cast of the same ability
    if (displaying[sourceUnitId] and displaying[sourceUnitId][abilityId]) then
        -- Don't overwrite for type == 2
        if ((not preventOverwrite and alertType == 2) or displaying[sourceUnitId][abilityId].preventOverwrite) then
            return
        end

        -- Do not overwrite for alert type 3 and instead display a second possibly duplicate alert
        if (alertType == 3) then
            index = FindOrCreateControl()
        else
            if (abilityId ~= 114578 -- BRP Portal Spawn
                and abilityId ~= 72057 -- MA Portal Spawn
                ) then
                Crutch.dbgSpam(string.format("|cFF8888[CS]|r Overwriting %s from %s because it's already being displayed", GetAbilityName(abilityId), sourceName))
            end
            index = displaying[sourceUnitId][abilityId].index
        end
    else
        index = FindOrCreateControl()
    end

    -- Set the time and make some strings
    local lineControl = CrutchAlertsContainer:GetNamedChild("Line" .. tostring(index))
    freeControls[index] = {source = sourceUnitId, expireTime = GetGameTimeMilliseconds() + timer, abilityId = abilityId}
    if (not displaying[sourceUnitId]) then
        displaying[sourceUnitId] = {}
    end
    displaying[sourceUnitId][abilityId] = {index = index, preventOverwrite = preventOverwrite}

    local resultString = ""
    if (result) then
        resultString = " " .. (resultStrings[result] or tostring(result))
    end

    local sourceString = ""
    if (sourceType) then
        sourceString = " " .. (sourceStrings[sourceType] or tostring(sourceType))
    end

    -- Set the items
    local labelControl = lineControl:GetNamedChild("Label")
    labelControl:SetWidth(1200)
    labelControl:SetText(customColor and zo_strformat("|c<<1>><<2>>|r", customColor, textLabel) or zo_strformat("<<1>>", textLabel))
    labelControl:SetWidth(labelControl:GetTextWidth())

    if (hideTimer == 1) then
        lineControl:GetNamedChild("Timer"):SetHidden(true)
    else
        lineControl:GetNamedChild("Timer"):SetHidden(false)
        lineControl:GetNamedChild("Timer"):SetText(string.format("%.1f", timer / 1000))
        lineControl:GetNamedChild("Timer"):SetWidth(fontSize * 4)
    end
    lineControl:GetNamedChild("Icon"):SetTexture(GetAbilityIcon(abilityId))
    if (Crutch.savedOptions.debugLine) then
        lineControl:GetNamedChild("Id"):SetText(string.format("%d (%d) [%s%s]%s", abilityId, timer, sourceName, sourceString, resultString))
    else
        lineControl:GetNamedChild("Id"):SetText("")
    end

    -- Reanchor
    lineControl:GetNamedChild("Icon"):SetAnchor(RIGHT, labelControl, LEFT, -8, 3)
    lineControl:GetNamedChild("Timer"):SetAnchor(LEFT, labelControl, RIGHT, 10)
    lineControl:GetNamedChild("Timer"):SetColor(unpack(GetTimerColor(timer)))

    lineControl:SetHidden(false)

    -- Start polling if it's not already going
    if (not isPolling) then
        EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "Poll", 100, UpdateDisplay)
        isPolling = true
    end
end

-- To be called when an enemy is interrupted
function Crutch.Interrupted(targetUnitId)
    if (not displaying[targetUnitId]) then
        return
    end

    for abilityId, data in pairs(displaying[targetUnitId]) do
        local index = data.index
        if (index and not freeControls[index].interrupted) then -- Don't add it again if it's already interrupted
            freeControls[index].interrupted = true
            freeControls[index].expireTime = GetGameTimeMilliseconds() + 1000 -- Hide it after 1 second

            -- Set the text to "stopped"
            local lineControl = CrutchAlertsContainer:GetNamedChild("Line" .. tostring(index))
            local labelControl = lineControl:GetNamedChild("Label")
            labelControl:SetWidth(800)
            labelControl:SetText(labelControl:GetText() .. " |cA8FFBD- stopped|r")
            labelControl:SetWidth(labelControl:GetTextWidth())
            lineControl:GetNamedChild("Timer"):SetText("")
        end

        if (Crutch.prominentDisplaying[abilityId]) then
            local slot = Crutch.prominentDisplaying[abilityId]
            local control = GetControl("CrutchAlertsProminent" .. tostring(slot))
            control:SetHidden(true)
            Crutch.prominentDisplaying[abilityId] = nil
            EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "Prominent" .. tostring(slot))
        end
    end
end
