local Crutch = CrutchAlerts

local fatecarverIds = {
    [185805] = true, -- Fatecarver (cost mag)
    [193331] = true, -- Fatecarver (cost stam)
    [183122] = true, -- Exhausting Fatecarver (cost mag)
    [193397] = true, -- Exhausting Fatecarver (cost stam)
    [186366] = true, -- Pragmatic Fatecarver (cost mag)
    [193398] = true, -- Pragmatic Fatecarver (cost stam)
    [183537] = true, -- Remedy Cascade (cost mag)
    [198309] = true, -- Remedy Cascade (cost stam)
    [186193] = true, -- Cascading Fortune (cost mag)
    [198330] = true, -- Cascading Fortune (cost stam)
    [186200] = true, -- Curative Surge (cost mag)
    [198537] = true, -- Curative Surge (cost stam)
}

local jbeamIds = {
    [63029] = true, -- Radiant Destruction
    [63044] = true, -- Radiant Glory
    [63046] = true, -- Radiant Oppression
}

-- TODO: these are just copied over from events.lua, lame
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

local function OnFatecarver(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)

    if (hitValue <= 75) then return end

    -- Remove the timer if fatecarver gets interrupted
    if (result == ACTION_RESULT_EFFECT_FADED) then
        Crutch.dbgSpam("fatecarver faded")
        Crutch.Interrupted(targetUnitId, true)
        return
    end

    -- Start debug
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

    Crutch.dbgSpam(string.format("A %s(%d): %s(%d) in %d on %s (%d). %s.%s %s",
        sourceName,
        sourceUnitId,
        GetAbilityName(abilityId),
        abilityId,
        hitValue,
        targetName,
        targetUnitId,
        sourceString,
        targetString,
        resultString))
    -- End debug

    if (result == ACTION_RESULT_BEGIN) then
        Crutch.DisplayNotification(abilityId, GetAbilityName(abilityId), hitValue, sourceUnitId, sourceName, sourceType, targetUnitId, targetName, targetType, result)
    end
end

--* EVENT_EFFECT_CHANGED (*[EffectResult|#EffectResult]* _changeType_, *integer* _effectSlot_, *string* _effectName_, *string* _unitTag_, *number* _beginTime_, *number* _endTime_, *integer* _stackCount_, *string* _iconName_, *string* _deprecatedBuffType_, *[BuffEffectType|#BuffEffectType]* _effectType_, *[AbilityType|#AbilityType]* _abilityType_, *[StatusEffectType|#StatusEffectType]* _statusEffectType_, *string* _unitName_, *integer* _unitId_, *integer* _abilityId_, *[CombatUnitType|#CombatUnitType]* _sourceType_)

local function OnBeamFaded(_, changeType, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId, sourceType)
    if (changeType ~= EFFECT_RESULT_FADED) then return end
    if (sourceType ~= COMBAT_UNIT_TYPE_PLAYER) then return end

    -- Remove the timer if beam gets interrupted
    Crutch.dbgSpam("beam faded")
    Crutch.InterruptAbility(abilityId)
end


---------------------------------------------------------------------
-- Init
function Crutch.RegisterFatecarver()
    -- Eventually I should explore only registering these if Fatecarver is even slotted
    -- Also healy beam though
    if (not Crutch.savedOptions.general.beginHideArcanist) then
        Crutch.dbgOther("Registering Fatecarver/Remedy Cascade")
        for abilityId, _ in pairs(fatecarverIds) do
            local eventName = Crutch.name .. "FC" .. tostring(abilityId)

            EVENT_MANAGER:RegisterForEvent(eventName .. "Begin", EVENT_COMBAT_EVENT, OnFatecarver)
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)

            EVENT_MANAGER:RegisterForEvent(eventName .. "Faded", EVENT_COMBAT_EVENT, OnFatecarver)
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Faded", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- interrupted self only
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Faded", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Faded", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
        end
    end

    -- Jbeam
    if (Crutch.savedOptions.general.showJBeam) then
        Crutch.dbgOther("Registering Radiant Destruction")
        for abilityId, _ in pairs(jbeamIds) do
            local eventName = Crutch.name .. "JB" .. tostring(abilityId)

            EVENT_MANAGER:RegisterForEvent(eventName .. "Begin", EVENT_COMBAT_EVENT, OnFatecarver)
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- self only
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)

            EVENT_MANAGER:RegisterForEvent(eventName .. "Faded", EVENT_EFFECT_CHANGED, OnBeamFaded)
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Faded", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
        end
    end
end

-- For use from settings when toggling
function Crutch.UnregisterFatecarver()
    Crutch.dbgOther("Unregistering Fatecarver/Remedy Cascade")
    for abilityId, _ in pairs(fatecarverIds) do
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "FC" .. tostring(abilityId) .. "Begin", EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "FC" .. tostring(abilityId) .. "Faded", EVENT_COMBAT_EVENT)
    end
    for abilityId, _ in pairs(jbeamIds) do
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "JB" .. tostring(abilityId) .. "Begin", EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "JB" .. tostring(abilityId) .. "Faded", EVENT_EFFECT_CHANGED)
    end
end
