CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

local resultStrings = {
    [ACTION_RESULT_BEGIN] = "BEGIN",
    [ACTION_RESULT_EFFECT_GAINED] = "GAINED",
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = "DURATION",
    [ACTION_RESULT_EFFECT_FADED] = "FADED",
    [ACTION_RESULT_DAMAGE] = "DAMAGE",
}

local sourceStrings = {
    [COMBAT_UNIT_TYPE_NONE] = "NONE",
    [COMBAT_UNIT_TYPE_PLAYER] = "PLAYER",
    [COMBAT_UNIT_TYPE_PLAYER_PET] = "PET",
    [COMBAT_UNIT_TYPE_GROUP] = "GROUP",
    [COMBAT_UNIT_TYPE_TARGET_DUMMY] = "DUMMY",
    [COMBAT_UNIT_TYPE_OTHER] = "OTHER",
}

Crutch.currentAttacks = {}

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
            local displayName = GetUnitDisplayName(unitTag) or zo_strformat("<<1>>", unitName)
            Crutch.groupMembers[unitId] = displayName
            if (not string.sub(displayName, 1, 1) == "@" and Crutch.savedOptions.debugOther) then
                d(string.format("|c88FFFF[CO]|r Received non-@ for %s from %s, result %s", unitTag, GetAbilityName(abilityId), displayName))
            end
        end)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end


---------------------------------------------------------------------
-- Outside calling
---------------------------------------------------------------------

---------------------------------------------------------------------
-- ALL ACTION_RESULT_BEGIN/GAINED/GAINED_DURATION

-- MAIN FUNCTION where all ACTION_RESULT_BEGIN/GAINED/GAINED_DURATION will pass through
local function OnCombatEventAll(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
    -- Seems to be really spammy aura things that also trigger on other people
    if (sourceUnitId == 0 and
        (result == ACTION_RESULT_EFFECT_GAINED
            or result == ACTION_RESULT_EFFECT_GAINED_DURATION)) then
        return
    end

    -- Ignore abilities that are blacklisted
    if (Crutch.blacklist[abilityId]) then return end

    -- Spammy debug
    if (Crutch.savedOptions.debugChatSpam) then
        local resultString = ""
        if (result) then
            resultString = (resultStrings[result] or tostring(result))
        end

        local sourceString = ""
        if (sourceType) then
            sourceString = (sourceStrings[sourceType] or tostring(sourceType))
        end
        d(string.format("All %s(%d): %s(%d) in %dms on %s(%d). Type %s Result %s",
            sourceName,
            sourceUnitId,
            GetAbilityName(abilityId),
            abilityId,
            hitValue,
            targetName,
            targetUnitId,
            sourceString,
            resultString))
    end

    -- Several immediate light attacks are 75ms
    if (hitValue <= 75) then return end

    -- Ignore abilities that are in the "others" because they will be displayed from there
    if (Crutch.others[abilityId]) then return end

    -- Actual display
    Crutch.DisplayNotification(abilityId, GetAbilityName(abilityId), hitValue, sourceUnitId, sourceName, sourceType, result)
end

function Crutch.RegisterBegin()
    if (Crutch.registered.begin) then return end
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CO]|r Registered Begin") end

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT, OnCombatEventAll)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Self
    if (Crutch.savedOptions.general.beginHideSelf) then EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) end -- from enemy
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN) -- Begin, usually

    Crutch.registered.begin = true
end

function Crutch.UnregisterBegin()
    if (not Crutch.registered.begin) then return end
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CO]|r Unregistered Begin") end

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT)

    Crutch.registered.begin = false
end

function Crutch.RegisterGained()
    if (Crutch.registered.gained) then return end
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CO]|r Registered Gained") end

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT, OnCombatEventAll)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Self
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) -- from enemy
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT, OnCombatEventAll)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Self
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) -- from enemy
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)

    Crutch.registered.gained = true
end

function Crutch.UnregisterGained()
    if (not Crutch.registered.gained) then return end
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CO]|r Unregistered Gained") end

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT)

    Crutch.registered.gained = false
end


---------------------------------------------------------------------
-- Interrupted
local InterruptedResults = {
    [ACTION_RESULT_FEARED] = "FEARED",
    [ACTION_RESULT_STUNNED] = "STUNNED",
    [ACTION_RESULT_INTERRUPT] = "INTERRUPT",
    [ACTION_RESULT_DIED] = "DIED",
    [ACTION_RESULT_DIED_XP] = "DIED_XP",
    -- TODO: effect ended
}

local function OnInterrupted(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
    -- Spammy debug
    -- if (Crutch.savedOptions.debugChatSpam) then
    --     local resultString = ""
    --     if (result) then
    --         resultString = (InterruptedResults[result] or tostring(result))
    --     end

    --     local sourceString = ""
    --     if (sourceType) then
    --         sourceString = (sourceStrings[sourceType] or tostring(sourceType))
    --     end
    --     d(string.format("Interrupted %s(%d): %s(%d) on %s(%d) HitValue %d Type %s Result %s",
    --         sourceName,
    --         sourceUnitId,
    --         GetAbilityName(abilityId),
    --         abilityId,
    --         targetName,
    --         targetUnitId,
    --         hitValue,
    --         sourceString,
    --         resultString))
    -- end

    Crutch.Interrupted(targetUnitId)
end

function Crutch.RegisterInterrupts()
    if (Crutch.registered.interrupts) then return end
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CO]|r Registered Interrupts") end

    for result, name in pairs(InterruptedResults) do
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. name, EVENT_COMBAT_EVENT, OnInterrupted)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. name, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) -- interrupted enemies only
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result)
    end

    Crutch.registered.interrupts = true
end

function Crutch.UnregisterInterrupts()
    if (not Crutch.registered.interrupts) then return end
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CO]|r Unregistered Interrupts") end

    for result, name in pairs(InterruptedResults) do
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. name, EVENT_COMBAT_EVENT)
    end

    Crutch.registered.interrupts = false
end


---------------------------------------------------------------------
-- Crutch.test (unknown timers)

local function OnCombatEventTest(result, isError, abilityName, sourceName, sourceType, targetName, targetType, hitValue, sourceUnitId, targetUnitId, abilityId, timer)
    -- Spammy debug
    if (Crutch.savedOptions.debugChatSpam) then
        local resultString = ""
        if (result) then
            resultString = (resultStrings[result] or tostring(result))
        end

        local sourceString = ""
        if (sourceType) then
            sourceString = (sourceStrings[sourceType] or tostring(sourceType))
        end
        d(string.format("|cFF8888Test %s(%d): %s(%d) in %dms on %s(%d). Type %s Result %s|r",
            sourceName,
            sourceUnitId,
            GetAbilityName(abilityId),
            abilityId,
            hitValue,
            targetName,
            targetUnitId,
            sourceString,
            resultString))
    end

    if (result == ACTION_RESULT_BEGIN) then
        Crutch.currentAttacks[sourceUnitId] = GetGameTimeMilliseconds()
        d(string.format("|cFFFF88%s (%d) starting from %d|r", abilityName, abilityId, sourceUnitId))
    elseif (result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DODGED) then
        local beginTime = Crutch.currentAttacks[sourceUnitId]
        if (beginTime) then
            d(string.format("|cFFFF88%d %s from %d took %d|r", result, abilityName, sourceUnitId, (GetGameTimeMilliseconds() - beginTime)))
        end
    end
end

function Crutch.RegisterTest()
    if (Crutch.registered.test) then return end
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CO]|r Registered Test") end

    RegisterData(Crutch.testing, "Test", nil, nil, OnCombatEventTest)

    Crutch.registered.test = true
end

function Crutch.UnregisterTest()
    if (not Crutch.registered.test) then return end
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CO]|r Unregistered Test") end

    UnregisterData(Crutch.testing, "Test")

    Crutch.registered.test = false
end


---------------------------------------------------------------------
-- Crutch.others (on group or others)

local function OnCombatEventOthers(result, isError, abilityName, sourceName, sourceType, targetName, targetType, hitValue, sourceUnitId, targetUnitId, abilityId, timer)
    -- Actual display
    targetName = Crutch.groupMembers[targetUnitId]
    if (targetName) then
        targetName = " |cAAAAAAon " .. zo_strformat("<<1>>", targetName) .. "|r"
    else
        targetName = ""
    end

    -- Spammy debug
    if (Crutch.savedOptions.debugChatSpam
        and abilityId ~= 114578 -- BRP Portal Spawn
        and abilityId ~= 72057 -- MA Portal Spawn
        ) then
        local resultString = ""
        if (result) then
            resultString = (resultStrings[result] or tostring(result))
        end

        local sourceString = ""
        if (sourceType) then
            sourceString = (sourceStrings[sourceType] or tostring(sourceType))
        end
        d(string.format("Others %s(%d): %s(%d) in %dms on %s(%d). Type %s Result %s",
            sourceName,
            sourceUnitId,
            GetAbilityName(abilityId),
            abilityId,
            hitValue,
            targetName,
            targetUnitId,
            sourceString,
            resultString))
    end

    Crutch.DisplayNotification(abilityId, GetAbilityName(abilityId) .. targetName, hitValue, sourceUnitId, sourceName, sourceType, result)
end

function Crutch.RegisterOthers()
    if (Crutch.registered.others) then return end
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CO]|r Registered Others") end

    RegisterData(Crutch.others, "OthersBegin", ACTION_RESULT_BEGIN, nil, OnCombatEventOthers)
    RegisterData(Crutch.others, "OthersGained", ACTION_RESULT_EFFECT_GAINED, nil, OnCombatEventOthers)
    RegisterData(Crutch.others, "OthersGainedDuration", ACTION_RESULT_EFFECT_GAINED_DURATION, nil, OnCombatEventOthers)

    Crutch.registered.others = true
end

function Crutch.UnregisterOthers()
    if (not Crutch.registered.others) then return end
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CO]|r Unregistered Others") end

    UnregisterData(Crutch.others, "OthersBegin")
    UnregisterData(Crutch.others, "OthersGained")
    UnregisterData(Crutch.others, "OthersGainedDuration")

    Crutch.registered.others = false
end

