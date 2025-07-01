CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

local resultStrings = {
    [ACTION_RESULT_BEGIN] = "BEGIN",
    [ACTION_RESULT_EFFECT_GAINED] = "GAIN",
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = "DUR",
    [ACTION_RESULT_EFFECT_FADED] = "FADED",
    [ACTION_RESULT_DAMAGE] = "DAMAGE",
}

local sourceStrings = {
    [COMBAT_UNIT_TYPE_GROUP] = "G",
    [COMBAT_UNIT_TYPE_NONE] = "N",
    [COMBAT_UNIT_TYPE_OTHER] = "O",
    [COMBAT_UNIT_TYPE_PLAYER] = "P",
    [COMBAT_UNIT_TYPE_PLAYER_COMPANION] = "C",
    [COMBAT_UNIT_TYPE_PLAYER_PET] = "PET",
    [COMBAT_UNIT_TYPE_TARGET_DUMMY] = "D",
}

local effectResults = {
    [EFFECT_RESULT_FADED] = "FADED",
    [EFFECT_RESULT_FULL_REFRESH] = "FULL_REFRESH",
    [EFFECT_RESULT_GAINED] = "GAINED",
    [EFFECT_RESULT_TRANSFER] = "TRANSFER",
    [EFFECT_RESULT_UPDATED] = "UPDATED",
}

Crutch.currentAttacks = {}
Crutch.playerGroupTag = "player"

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

local function UnregisterEvent(event, abilityId, eventName)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. eventName .. tostring(abilityId), event)
end

-- With caps!
local function FormatAbilityName(abilityId)
    return zo_strformat("<<C:1>>", GetAbilityName(abilityId))
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

local function SpamDebug(result, sourceName, sourceType, targetName, targetType, hitValue, sourceUnitId, targetUnitId, abilityId, prefix)
    -- Spammy debug
    if (Crutch.savedOptions.debugChatSpam
        and not Crutch.noSpamZone[Crutch.zoneId]) then
        local resultString = ""
        if (result) then
            resultString = (resultStrings[result] or tostring(result))
        end

        local sourceString = ""
        if (sourceType) then
            sourceString = (sourceStrings[sourceType] or tostring(sourceType))
        end
        local targetString = ""
        if (targetType) then
            targetString = (sourceStrings[targetType] or tostring(targetType))
        elseif (targetType == nil) then
            targetString = "nil"
        end

        Crutch.dbgSpam(string.format("%s %s(%d): %s(%d) in %d on %s (%d). %s.%s %s",
            prefix,
            sourceName,
            sourceUnitId,
            FormatAbilityName(abilityId),
            abilityId,
            hitValue,
            targetName,
            targetUnitId,
            sourceString,
            targetString,
            resultString))
    end
end
Crutch.SpamEventDebug = SpamDebug


---------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED caching
---------------------------------------------------------------------
local function CacheUnitTag(_, _, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId)
    if (GetUnitDisplayName(unitTag) == GetUnitDisplayName("player")) then
        Crutch.playerGroupTag = unitTag
    end

    local oldId = Crutch.groupTagToId[unitTag]
    if (oldId ~= nil and oldId ~= unitId) then
        Crutch.groupIdToTag[oldId] = nil
    end
    Crutch.groupIdToTag[unitId] = unitTag
    Crutch.groupTagToId[unitTag] = unitId
end

function Crutch.RegisterEffectChanged()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Effect", EVENT_EFFECT_CHANGED, CacheUnitTag)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

    -- Also cache player, player pets, currently for IA elixirs. Could be the same for companions too
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "EffectPet", EVENT_EFFECT_CHANGED, CacheUnitTag)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "EffectPet", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "EffectCompanion", EVENT_EFFECT_CHANGED, CacheUnitTag)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "EffectCompanion", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "companion")
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
    SpamDebug(result, sourceName, sourceType, targetName, targetType, hitValue, sourceUnitId, targetUnitId, abilityId, "A")

    -- Several immediate light attacks are 75ms
    if (hitValue <= 75) then return end

    -- Specific abilities should ignore hitValues that are below certain thresholds
    if (Crutch.filter[abilityId] and not Crutch.filter[abilityId](hitValue, "player")) then
        Crutch.dbgSpam(string.format("Skipping %s (%d) because of filter",
            abilityName,
            abilityId))
        return
    end

    -- Cap some really long values
    if (hitValue >= Crutch.savedOptions.general.hitValueAboveThreshold) then
        Crutch.dbgOther(string.format("Capping hitValue for %s(%d) at %d from %d",
            abilityName,
            abilityId,
            Crutch.savedOptions.general.hitValueAboveThreshold,
            hitValue))
        hitValue = Crutch.savedOptions.general.hitValueAboveThreshold
    end

    -- Ignore abilities that are in the "others" because they will be displayed from there
    if (Crutch.savedOptions.general.showOthers and Crutch.others[abilityId]) then return end

    -- Setting for not showing casts on self (things like Recall and others not already blacklisted)
    if (Crutch.savedOptions.general.beginHideSelf and result == ACTION_RESULT_BEGIN and sourceType == COMBAT_UNIT_TYPE_PLAYER) then return end

    -- Actual display
    Crutch.DisplayNotification(abilityId, FormatAbilityName(abilityId), hitValue, sourceUnitId, sourceName, sourceType, result)
end

function Crutch.RegisterBegin()
    if (Crutch.registered.begin) then return end
    Crutch.dbgOther("Registered Begin")

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT, OnCombatEventAll)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Self
    -- if (Crutch.savedOptions.general.beginHideSelf) then EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) end -- from enemy THIS IS BUGGY??
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN) -- Begin, usually

    Crutch.registered.begin = true
end

function Crutch.UnregisterBegin()
    if (not Crutch.registered.begin) then return end
    Crutch.dbgOther("Unregistered Begin")

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Begin", EVENT_COMBAT_EVENT)

    Crutch.registered.begin = false
end

function Crutch.RegisterGained()
    if (Crutch.registered.gained) then return end
    Crutch.dbgOther("Registered Gained")

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT, OnCombatEventAll)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Self
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) -- from enemy
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)

    -- EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT, function(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
    --     if (targetType == COMBAT_UNIT_TYPE_PLAYER) then
    --         if (Crutch.gainedDuration[abilityId]) then
    --             OnCombatEventAll(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
    --         else
    --         end
    --     end
    -- end)
    -- I don't understand why adding this filter is seemingly preventing all? events that appear to match the filter from being received.
    -- So I think this event has never worked. For now, I'm working around it by manually filtering the unit type above and with specific
    -- ability IDs only.
    -- EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Self
    -- EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) -- from enemy
    -- EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)

    RegisterData(Crutch.gainedDuration, "Duration", ACTION_RESULT_EFFECT_GAINED_DURATION, nil, function(result, isError, abilityName, sourceName, sourceType, targetName, targetType, hitValue, sourceUnitId, targetUnitId, abilityId, timer)
        if (targetType == COMBAT_UNIT_TYPE_PLAYER) then
            OnCombatEventAll(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
        end
    end)

    if (Crutch.savedOptions.debugChatSpam) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GainedDurationDebug", EVENT_COMBAT_EVENT, function(_, result, _, _, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
            if (targetType == COMBAT_UNIT_TYPE_PLAYER) then
                SpamDebug(result, sourceName, sourceType, targetName, targetType, hitValue, sourceUnitId, targetUnitId, abilityId, "|c55FFFF[dur]|r")
            end
        end)
        -- EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GainedDurationDebug", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Self
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GainedDurationDebug", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) -- from enemy
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "GainedDurationDebug", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
    end

    Crutch.registered.gained = true
end

function Crutch.UnregisterGained()
    if (not Crutch.registered.gained) then return end
    Crutch.dbgOther("Unregistered Gained")

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Gained", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "GainedDuration", EVENT_COMBAT_EVENT)

    Crutch.registered.gained = false
end


---------------------------------------------------------------------
-- Interrupted
local interruptedResults = {
    [ACTION_RESULT_FEARED] = "FEARED",
    [ACTION_RESULT_STUNNED] = "STUNNED",
    [ACTION_RESULT_INTERRUPT] = "INTERRUPT",
    [ACTION_RESULT_DIED] = "DIED",
    [ACTION_RESULT_DIED_XP] = "DIED_XP",
    -- TODO: effect ended
}

local function OnInterrupted(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
    -- Spammy debug
    if (Crutch.savedOptions.debugChatSpam
        and (abilityId == 103531 or abilityId == 110431) -- Roaring Flare
        ) then
        local resultString = ""
        if (result) then
            resultString = (interruptedResults[result] or tostring(result))
        end

        local sourceString = ""
        if (sourceType) then
            sourceString = (sourceStrings[sourceType] or tostring(sourceType))
        end
        Crutch.dbgSpam(string.format("Interrupted %s(%d): %s(%d) on %s (%d) HitValue %d %s %s",
            sourceName,
            sourceUnitId,
            FormatAbilityName(abilityId),
            abilityId,
            targetName,
            targetUnitId,
            hitValue,
            sourceString,
            resultString))
    end

    Crutch.Interrupted(targetUnitId)
end

function Crutch.RegisterInterrupts()
    if (Crutch.registered.interrupts) then return end
    Crutch.dbgOther("Registered Interrupts")

    for result, name in pairs(interruptedResults) do
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. name, EVENT_COMBAT_EVENT, OnInterrupted)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. name, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) -- interrupted enemies only
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result)
    end

    -- Interrupt Seeking Spheres (Tho'at Shard) -- TODO: stop putting code everywhere ffs
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "SeekingSpheresFaded", EVENT_COMBAT_EVENT, function() Crutch.InterruptAbility(192517) end) -- TODO: this probably removes all of them
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "SeekingSpheresFaded", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "SeekingSpheresFaded", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 192517)

    Crutch.registered.interrupts = true
end

function Crutch.UnregisterInterrupts()
    if (not Crutch.registered.interrupts) then return end
    Crutch.dbgOther("Unregistered Interrupts")

    for result, name in pairs(interruptedResults) do
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. name, EVENT_COMBAT_EVENT)
    end

    Crutch.registered.interrupts = false
end


---------------------------------------------------------------------
-- Crutch.test (unknown timers)

local function OnCombatEventTest(result, isError, abilityName, sourceName, sourceType, targetName, targetType, hitValue, sourceUnitId, targetUnitId, abilityId, timer)
    -- Spammy debug
    if (not Crutch.savedOptions.debugChatSpam) then return end

    local resultString = ""
    if (result) then
        resultString = (resultStrings[result] or tostring(result))
    end

    local sourceString = ""
    if (sourceType) then
        sourceString = (sourceStrings[sourceType] or tostring(sourceType))
    end

    local targetString = ""
    if (targetType) then
        targetString = (sourceStrings[targetType] or tostring(targetType))
    end

    Crutch.dbgSpam(string.format("|cFF8888Test %s(%d): %s(%d) in %d on %s (%d). %s.%s %s|r",
        sourceName,
        sourceUnitId,
        FormatAbilityName(abilityId),
        abilityId,
        hitValue,
        targetName,
        targetUnitId,
        sourceString,
        targetString,
        resultString))

    if (result == ACTION_RESULT_BEGIN) then
        Crutch.currentAttacks[sourceUnitId] = GetGameTimeMilliseconds()
        Crutch.dbgSpam(string.format("|cFFFF88%s (%d) starting from %d|r", abilityName, abilityId, sourceUnitId))
    elseif (result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DODGED) then
        local beginTime = Crutch.currentAttacks[sourceUnitId]
        if (beginTime) then
            Crutch.dbgSpam(string.format("|cFFFF88%d %s from %d took %d|r", result, abilityName, sourceUnitId, (GetGameTimeMilliseconds() - beginTime)))
        end
    end
end

local function SpamDebugEffect(changeType, unitTag, stackCount, unitName, unitId, abilityId, sourceType)
    -- Spammy debug
    if (not Crutch.savedOptions.debugChatSpam) then return end

    local resultString = ""
    if (changeType) then
        resultString = effectResults[changeType] or tostring(changeType)
    end

    local sourceString = ""
    if (sourceType) then
        sourceString = (sourceStrings[sourceType] or tostring(sourceType))
    end
    Crutch.dbgSpam(string.format("|cFF8888TestEffect %s(%s)(%d): %s(%d) x%d %s %s|r",
        unitName or "",
        (unitTag ~= nil) and GetUnitDisplayName(unitTag) or "",
        unitId,
        FormatAbilityName(abilityId),
        abilityId,
        stackCount,
        sourceString,
        resultString))
end
Crutch.SpamDebugEffect = SpamDebugEffect

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnEffectChangedTest(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, unitName, unitId, abilityId, sourceType)
    SpamDebugEffect(changeType, unitTag, stackCount, unitName, unitId, abilityId, sourceType)
end

function Crutch.RegisterTest()
    if (Crutch.registered.test) then return end
    Crutch.dbgOther("Registered Test")

    RegisterData(Crutch.testing, "Test", nil, nil, OnCombatEventTest)

    for abilityId, _ in pairs(Crutch.testing) do
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TestEffect" .. tostring(abilityId), EVENT_EFFECT_CHANGED, OnEffectChangedTest)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TestEffect" .. tostring(abilityId), EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
    end

    Crutch.registered.test = true
end

function Crutch.UnregisterTest()
    if (not Crutch.registered.test) then return end

    UnregisterData(Crutch.testing, "Test")

    for abilityId, _ in pairs(Crutch.testing) do
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TestEffect" .. tostring(abilityId), EVENT_EFFECT_CHANGED)
    end

    Crutch.dbgOther("Unregistered Test")
    Crutch.registered.test = false
end


---------------------------------------------------------------------
-- Test ability stacks

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnStackChanged(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, unitName, unitId, abilityId)
    local stacks = changeType == EFFECT_RESULT_FADED and 0 or stackCount
    Crutch.dbgSpam(string.format("|ca182ff%s(%s)(%d) has %d stacks of %s(%d)|r",
        unitName,
        unitTag,
        unitId,
        stacks,
        FormatAbilityName(abilityId),
        abilityId))
end

-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnStackCombat(_, result, _, _, _, _, _, _, targetName, _, stackCount, _, _, _, _, targetUnitId, abilityId)
    if (result ~= ACTION_RESULT_EFFECT_GAINED and result ~= ACTION_RESULT_EFFECT_FADED) then
        return
    end
    local stacks = result == ACTION_RESULT_EFFECT_FADED and 0 or stackCount
    Crutch.dbgSpam(string.format("|ca182ff%s(%d) has %d stacks of %s(%d)|r",
        targetName,
        targetUnitId,
        stacks,
        FormatAbilityName(abilityId),
        abilityId))
end

function Crutch.RegisterStacks()
    for abilityId in pairs(Crutch.stacks) do
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Stacks" .. abilityId, EVENT_EFFECT_CHANGED, OnStackChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Stacks" .. abilityId, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "StacksCombat" .. abilityId, EVENT_COMBAT_EVENT, OnStackCombat)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "StacksCombat" .. abilityId, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "StacksCombat" .. abilityId, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    end
end


---------------------------------------------------------------------
-- Crutch.others (on anyone)
---------------------------------------------------------------------

local function OnCombatEventOthers(result, isError, abilityName, sourceName, sourceType, targetName, targetType, hitValue, sourceUnitId, targetUnitId, abilityId, timer)
    -- Actual display
    targetName = GetUnitDisplayName(Crutch.groupIdToTag[targetUnitId])
    if (targetName) then
        targetName = " |cAAAAAAon " .. zo_strformat("<<1>>", targetName) .. "|r"
    else
        targetName = ""
    end

    -- Spammy debug
    if (Crutch.savedOptions.debugChatSpam
        and abilityId ~= 114578 -- BRP Portal Spawn
        and abilityId ~= 72057 -- MA Portal Spawn
        and not Crutch.noSpamZone[Crutch.zoneId]
        ) then
        local resultString = ""
        if (result) then
            resultString = (resultStrings[result] or tostring(result))
        end

        local sourceString = ""
        if (sourceType) then
            sourceString = (sourceStrings[sourceType] or tostring(sourceType))
        end
        Crutch.dbgSpam(string.format("O %s(%d): %s(%d) in %d on %s (%d). %s %s",
            sourceName,
            sourceUnitId,
            FormatAbilityName(abilityId),
            abilityId,
            hitValue,
            targetName,
            targetUnitId,
            sourceString,
            resultString))
    end

    -- Specific abilities should ignore hitValues that are below certain thresholds
    if (Crutch.filter[abilityId] and not Crutch.filter[abilityId](hitValue, Crutch.groupIdToTag[targetUnitId])) then
        Crutch.dbgSpam(string.format("Skipping %s (%d) because of filter",
            abilityName,
            abilityId))
        return
    end

    Crutch.DisplayNotification(abilityId, FormatAbilityName(abilityId) .. targetName, hitValue, sourceUnitId, sourceName, sourceType, result)
end

function Crutch.RegisterOthers()
    if (Crutch.registered.others) then return end
    Crutch.dbgOther("Registered Others")

    RegisterData(Crutch.others, "OthersBegin", ACTION_RESULT_BEGIN, nil, OnCombatEventOthers)
    RegisterData(Crutch.others, "OthersGained", ACTION_RESULT_EFFECT_GAINED, nil, OnCombatEventOthers)
    RegisterData(Crutch.others, "OthersGainedDuration", ACTION_RESULT_EFFECT_GAINED_DURATION, nil, OnCombatEventOthers)

    Crutch.registered.others = true
end

function Crutch.UnregisterOthers()
    if (not Crutch.registered.others) then return end
    Crutch.dbgOther("Unregistered Others")

    UnregisterData(Crutch.others, "OthersBegin")
    UnregisterData(Crutch.others, "OthersGained")
    UnregisterData(Crutch.others, "OthersGainedDuration")

    Crutch.registered.others = false
end

---------------------------------------------------------------------
--[[
/script CrutchAlerts.Test()
]]
function Crutch.Test()
    OnCombatEventOthers(ACTION_RESULT_EFFECT_GAINED, false, "Crush", "", COMBAT_UNIT_TYPE_NONE, "", COMBAT_UNIT_TYPE_NONE, 1, 0, 0, 120890)
    OnCombatEventOthers(ACTION_RESULT_BEGIN, false, "Crush", "", COMBAT_UNIT_TYPE_NONE, "", COMBAT_UNIT_TYPE_NONE, 2000, 0, 0, 120890)
    OnCombatEventOthers(ACTION_RESULT_EFFECT_GAINED_DURATION, false, "Crush", "", COMBAT_UNIT_TYPE_NONE, "", COMBAT_UNIT_TYPE_NONE, 2000, 0, 0, 120890)

    OnCombatEventOthers(ACTION_RESULT_EFFECT_GAINED, false, "Crush", "", COMBAT_UNIT_TYPE_NONE, "", COMBAT_UNIT_TYPE_NONE, 1, 0, 0, 120890)
    OnCombatEventOthers(ACTION_RESULT_BEGIN, false, "Crush", "", COMBAT_UNIT_TYPE_NONE, "", COMBAT_UNIT_TYPE_NONE, 2000, 0, 0, 120890)
    OnCombatEventOthers(ACTION_RESULT_EFFECT_GAINED_DURATION, false, "Crush", "", COMBAT_UNIT_TYPE_NONE, "", COMBAT_UNIT_TYPE_NONE, 2000, 0, 0, 120890)

    OnCombatEventOthers(ACTION_RESULT_BEGIN, false, "Focus Fire", "", COMBAT_UNIT_TYPE_NONE, "", COMBAT_UNIT_TYPE_NONE, 1333, 0, 0, 121722)

    -- Bahsei portal
    OnCombatEventOthers(ACTION_RESULT_BEGIN, false, "asdf", "", COMBAT_UNIT_TYPE_NONE, "", COMBAT_UNIT_TYPE_NONE, 1333, 0, 0, 153517)
    OnCombatEventOthers(ACTION_RESULT_BEGIN, false, "asdf", "", COMBAT_UNIT_TYPE_NONE, "", COMBAT_UNIT_TYPE_NONE, 1333, 0, 0, 153518)
end

---------------------------------------------------------------------
function Crutch.RegisterUnitId(unitId)
    function HandleTest(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
        if (sourceUnitId ~= unitId and targetUnitId ~= unitId) then
            return
        end

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
            Crutch.dbgSpam(string.format("|cFF8888Test %s(%d): %s(%d) in %d on %s (%d). %s %s|r",
                sourceName,
                sourceUnitId,
                FormatAbilityName(abilityId),
                abilityId,
                hitValue,
                targetName,
                targetUnitId,
                sourceString,
                resultString))
        end
    end
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "RezStopped", EVENT_COMBAT_EVENT, HandleTest)
end
