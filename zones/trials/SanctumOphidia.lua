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

    Crutch.RegisterForCombatEvent("MagBomb", OnMagBombFaded, ACTION_RESULT_EFFECT_FADED, 56782, nil, COMBAT_UNIT_TYPE_PLAYER)
end

function Crutch.UnregisterSanctumOphidia()
    Crutch.UnregisterForCombatEvent("MagBomb")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Sanctum Ophidia")
end
