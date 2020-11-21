CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Data

-- Currently unused controls for notifications: {[1] = {source = sourceUnitId, expireTime = 1235345, interrupted = true}}
local freeControls = {}

-- Currently displaying source to index {[sourceUnitId] = index}
local displaying = {}

-- Poll every 100ms when one is active
local isPolling = false

-- Debug purposes? {[sourceunitId] = beginTime}
local currentAttacks = {}

local fontSize = 32

-- Cache group members by using status effects, so we know the unit IDs
Crutch.groupMembers = {}

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
                displaying[data.source] = nil
            else
                numActive = numActive + 1
                if (not data.interrupted) then
                    lineControl:GetNamedChild("Timer"):SetText(string.format("%.1f", millisRemaining / 1000))
                    lineControl:GetNamedChild("Timer"):SetColor(unpack(GetTimerColor(millisRemaining)))
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

function Crutch.DisplayNotification(abilityId, textLabel, timer, sourceUnitId, sourceName, sourceType, result)
    if (type(timer) ~="number") then
        timer = 1000
        d("Warning: timer is not number, setting to 1000")
    end

    sourceName = zo_strformat("<<1>>", sourceName)

    local index = 0
    -- Maybe fixes the spam for Throw Dagger?
    if (displaying[sourceUnitId]) then
        if (Crutch.savedOptions.debugChatSpam) then
            d(string.format("|cFF8888[CS]|r Overwriting %s from %s because it's already being displayed", GetAbilityName(abilityId), sourceName))
        end
        index = displaying[sourceUnitId]
        return
    else
        index = FindOrCreateControl()
    end

    local lineControl = CrutchAlertsContainer:GetNamedChild("Line" .. tostring(index))
    freeControls[index] = {source = sourceUnitId, expireTime = GetGameTimeMilliseconds() + timer}
    displaying[sourceUnitId] = index

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
    labelControl:SetWidth(600)
    labelControl:SetText(textLabel)
    labelControl:SetWidth(labelControl:GetTextWidth())

    lineControl:GetNamedChild("Timer"):SetText(string.format("%.1f", timer / 1000))
    lineControl:GetNamedChild("Timer"):SetWidth(fontSize * 4)
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
    local index = displaying[targetUnitId]
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
end
