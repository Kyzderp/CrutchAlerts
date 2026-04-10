local Crutch = CrutchAlerts

---------------------------------------------------------------------
function Crutch.RegisterForEffectChanged(suffix, callback, abilityId, unitTagPrefix)
    local name = Crutch.name .. suffix
    EVENT_MANAGER:RegisterForEvent(name, EVENT_EFFECT_CHANGED, callback)
    EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
    EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, unitTagPrefix)
end

function Crutch.UnregisterForEffectChanged(suffix)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. suffix, EVENT_EFFECT_CHANGED)
end
