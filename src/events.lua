CrutchNotifications = CrutchNotifications or {}
local Crutch = CrutchNotifications


---------------------------------------------------------------------
-- Utility

local function RegisterEvent(event, result, unitFilter, abilityId, eventHandler, eventName)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. eventName .. tostring(abilityId), event, eventHandler)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. eventName .. tostring(abilityId), event, REGISTER_FILTER_ABILITY_ID, abilityId) -- Ability

    -- Add filter for the target type if requested
    if (unitFilter) then
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. eventName .. tostring(abilityId), event, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, unitFilter)
    end

    -- Add filter for the result if requested
    if (result) then
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. eventName .. tostring(abilityId), event, REGISTER_FILTER_COMBAT_RESULT, result) -- Begin, usually
    end
end

local function UnregisterEvent(event, abilityId)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. eventName .. tostring(abilityId), event)
end


---------------------------------------------------------------------
-- Common

-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function RegisterData(data, eventName, resultFilter, unitFilter, eventHandler)
    for id, time in pairs(data) do
        local wrapper = function(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
            eventHandler(result, isError, abilityName, sourceName, sourceType, targetName, targetType, hitValue, sourceUnitId, targetUnitId, abilityId, time)
        end
        RegisterEvent(EVENT_COMBAT_EVENT, resultFilter, unitFilter, id, wrapper, eventName)
    end
end

local function UnregisterData(data, eventName)
    for id, time in pairs(data) do
        UnregisterEvent(EVENT_COMBAT_EVENT, id, eventName)
    end
end


---------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED caching
---------------------------------------------------------------------

function Crutch.RegisterEffectChanged()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Effect", EVENT_EFFECT_CHANGED,
        function(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, unitName, unitId, abilityId, sourceType)
            Crutch.groupMembers[unitId] = GetUnitDisplayName(unitTag) or zo_strformat("<<1>>", unitName)
        end)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end


---------------------------------------------------------------------
-- Outside calling
---------------------------------------------------------------------

---------------------------------------------------------------------
-- ALL ACTION_RESULT_BEGIN

-- MAIN FUNCTION where all ACTION_RESULT_BEGIN will pass through
local function OnCombatEventBegin(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
    -- Several immediate light attacks are 75ms
    if (hitValue <= 75) then return end

    -- Ignore abilities that are blacklisted
    if (Crutch.blacklist[abilityId]) then return end

    -- Ignore abilities that are in the "others" because they will be displayed from there
    if (Crutch.others[abilityId]) then return end

    -- Actual display
    Crutch.DisplayNotification(abilityId, GetAbilityName(abilityId), hitValue, sourceUnitId, sourceName, sourceType, result)
end

function Crutch.RegisterBegin()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT, OnCombatEventBegin)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Self
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN) -- Begin, usually

    -- EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT, OnCombatEventBegin)
    -- EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Self
    -- EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)

    -- EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT, OnCombatEventBegin)
    -- EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Self
    -- EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
end

function Crutch.UnregisterBegin()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT)
    -- EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT)
    -- EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT)
end


---------------------------------------------------------------------
-- Interrupted
local InterruptedResults = {
    [ACTION_RESULT_FEARED] = "FEARED",
    [ACTION_RESULT_STUNNED] = "STUNNED",
    [ACTION_RESULT_INTERRUPT] = "INTERRUPT",
    [ACTION_RESULT_DIED] = "DIED",
    [ACTION_RESULT_DIED_XP] = "DIED_XP",
}

local function OnInterrupted(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
    Crutch.Interrupted(targetUnitId)
end

function Crutch.RegisterInterrupts()
    for result, name in pairs(InterruptedResults) do
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. name, EVENT_COMBAT_EVENT, OnInterrupted)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result)
    end
end


---------------------------------------------------------------------
-- Crutch.test (unknown timers)

local function OnCombatEventTest(result, isError, abilityName, sourceName, sourceType, targetName, targetType, hitValue, sourceUnitId, targetUnitId, abilityId, timer)
    if (result == ACTION_RESULT_BEGIN) then

        -- Autodetect
        if (timer == true) then
            timer = hitValue
        elseif (timer == false) then
            timer = hitValue
            currentAttacks[sourceUnitId] = GetGameTimeMilliseconds()
        end

        d(string.format("%s (%d) starting", abilityName, abilityId))
    elseif (result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DODGED) then
        local beginTime = currentAttacks[sourceUnitId]
        if (beginTime) then
            d(string.format("%d %s took %d", result, abilityName, (GetGameTimeMilliseconds() - beginTime)))
        end
    end
end

function Crutch.RegisterTest()
    RegisterData(Crutch.testing, "Test", nil, COMBAT_UNIT_TYPE_PLAYER, OnCombatEventTest)
end

function Crutch.UnregisterTest()
    UnregisterData(Crutch.testing, "Test")
end


---------------------------------------------------------------------
-- Crutch.others (on group or others)

local function OnCombatEventOthers(result, isError, abilityName, sourceName, sourceType, targetName, targetType, hitValue, sourceUnitId, targetUnitId, abilityId, timer)
    -- Actual display
    if (not targetName or targetName == "") then
        targetName = Crutch.groupMembers[targetUnitId]
    end
    if (targetName) then
        targetName = " |cAAAAAAon " .. zo_strformat("<<1>>", targetName) .. "|r"
    else
        targetName = ""
    end
    Crutch.DisplayNotification(abilityId, GetAbilityName(abilityId) .. targetName, hitValue, sourceUnitId, sourceName, sourceType, result)
    -- d(string.format("%s(%d) on %s(%d) for %d", abilityName, abilityId, targetName, targetUnitId, hitValue))
end

function Crutch.RegisterOthers()
    RegisterData(Crutch.others, "OthersBegin", ACTION_RESULT_BEGIN, nil, OnCombatEventOthers)
    RegisterData(Crutch.others, "OthersGained", ACTION_RESULT_EFFECT_GAINED, nil, OnCombatEventOthers)
    RegisterData(Crutch.others, "OthersGainedDuration", ACTION_RESULT_EFFECT_GAINED_DURATION, nil, OnCombatEventOthers)
end

function Crutch.UnregisterOthers()
    UnregisterData(Crutch.others, "OthersBegin")
    UnregisterData(Crutch.others, "OthersGained")
    UnregisterData(Crutch.others, "OthersGainedDuration")
end

