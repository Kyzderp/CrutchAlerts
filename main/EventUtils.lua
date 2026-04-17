local Crutch = CrutchAlerts

---------------------------------------------------------------------
function Crutch.RegisterForEffectChanged(suffix, callback, abilityId, unitTagPrefix)
    local name = Crutch.name .. suffix
    EVENT_MANAGER:RegisterForEvent(name, EVENT_EFFECT_CHANGED, callback)
    EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
    if (unitTagPrefix) then
        EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, unitTagPrefix)
    end
end

function Crutch.UnregisterForEffectChanged(suffix)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. suffix, EVENT_EFFECT_CHANGED)
end


---------------------------------------------------------------------
function Crutch.RegisterForCombatEvent(suffix, callback, result, abilityId, sourceType, targetType)
    local name = Crutch.name .. suffix
    EVENT_MANAGER:RegisterForEvent(name, EVENT_COMBAT_EVENT, callback)
    if (sourceType) then
        EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, sourceType)
    end
    if (targetType) then
        EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, targetType)
    end
    if (result) then
        EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result)
    end
    if (abilityId) then
        EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
    end
end

function Crutch.UnregisterForCombatEvent(suffix)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. suffix, EVENT_COMBAT_EVENT)
end
