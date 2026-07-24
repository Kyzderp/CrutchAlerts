local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- The Blind
---------------------------------------------------------------------
local function OnBesiege()
    local currHealth, maxHealth = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (currHealth / maxHealth < 0.25) then
        Crutch.dbgSpam("Boss is under 25%, this is probably the 20% besiege")
        Crutch.DisplayDamageable(18.7)
    end
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterBedlamVeil()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Bedlam Veil")

    if (Crutch.savedOptions.general.showDamageable) then
        Crutch.RegisterForCombatEvent("Besiege", OnBesiege, ACTION_RESULT_EFFECT_GAINED, 213837)
    end
end

function Crutch.UnregisterBedlamVeil()
    Crutch.UnregisterForCombatEvent("Besiege")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Bedlam Veil")
end