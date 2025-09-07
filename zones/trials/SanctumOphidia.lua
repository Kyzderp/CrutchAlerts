local Crutch = CrutchAlerts

---------------------------------------------------------------------
local function OnMagBombFaded(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId, _)
    Crutch.dbgSpam("magicka bomb faded")
    Crutch.InterruptAbility(abilityId)
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterSanctumOphidia()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Sanctum Ophidia")

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "MagBomb", EVENT_COMBAT_EVENT, OnMagBombFaded)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "MagBomb", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 56782)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "MagBomb", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- self only
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "MagBomb", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
end

function Crutch.UnregisterSanctumOphidia()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "MagBomb", EVENT_COMBAT_EVENT)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Sanctum Ophidia")
end
