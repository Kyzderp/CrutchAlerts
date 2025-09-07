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
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Besiege", EVENT_COMBAT_EVENT, OnBesiege)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Besiege", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Besiege", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 213837)
    end
end

function Crutch.UnregisterBedlamVeil()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Besiege", EVENT_COMBAT_EVENT)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Bedlam Veil")
end