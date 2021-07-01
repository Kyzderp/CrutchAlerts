CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
local function OnBoogerTimerFaded()
    if (GetSelectedLFGRole() == LFG_ROLE_TANK) then
        d("GET BOOGER")
        Crutch.DisplayProminent(888001)
    else
        d("skipping because not tank")
    end
end

---------------------------------------------------------------------
-- Register/Unregister
function Crutch.RegisterKynesAegis()
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CT]|r Registered Kyne's Aegis") end
    EVENT_MANAGER:RegisterForEvent(CrutchAlerts.name .. "BoogerTimerFade", EVENT_COMBAT_EVENT, OnBoogerTimerFaded)
    EVENT_MANAGER:AddFilterForEvent(CrutchAlerts.name .. "BoogerTimerFade", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
    EVENT_MANAGER:AddFilterForEvent(CrutchAlerts.name .. "BoogerTimerFade", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 136548)
end

function Crutch.UnregisterKynesAegis()
    EVENT_MANAGER:UnregisterForEvent(CrutchAlerts.name .. "BoogerTimerFade", EVENT_COMBAT_EVENT)
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CT]|r Unregistered Kyne's Aegis") end
end
