local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
-- (_, changeType, _, _, unitTag, beginTime, endTime, stackCount, _, _, _, _, _, _, unitId, abilityId)
function Crutch.RegisterForEffectChanged(suffix, callback, abilityId, unitTagPrefix)
    local name = Crutch.name .. suffix
    EVENT_MANAGER:RegisterForEvent(name, EVENT_EFFECT_CHANGED, callback)
    if (abilityId) then
        EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
    end
    if (unitTagPrefix) then
        EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, unitTagPrefix)
    end
end

function Crutch.UnregisterForEffectChanged(suffix)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. suffix, EVENT_EFFECT_CHANGED)
end


---------------------------------------------------------------------
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
-- (_, result, _, _, _, _, _, _, _, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
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
