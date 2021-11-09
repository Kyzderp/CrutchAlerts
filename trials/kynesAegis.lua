CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
local function OnBoogerTimerFaded()
    if (GetSelectedLFGRole() == LFG_ROLE_TANK) then
        Crutch.DisplayProminent(888001)
    end
end

---------------------------------------------------------------------
-- Register/Unregister
function Crutch.RegisterKynesAegis()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Kyne's Aegis")

    EVENT_MANAGER:RegisterForEvent(CrutchAlerts.name .. "BoogerTimerFade", EVENT_COMBAT_EVENT, OnBoogerTimerFaded)
    EVENT_MANAGER:AddFilterForEvent(CrutchAlerts.name .. "BoogerTimerFade", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
    EVENT_MANAGER:AddFilterForEvent(CrutchAlerts.name .. "BoogerTimerFade", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 136548)

    if (not Crutch.WorldIconsEnabled()) then
        Crutch.msg("You must install OdySupportIcons 1.6.3+ to display in-world icons")
    else
        Crutch.EnableIcon("Falgravn2ndFloor1")
        Crutch.EnableIcon("Falgravn2ndFloor2")
        Crutch.EnableIcon("Falgravn2ndFloor3")
        Crutch.EnableIcon("Falgravn2ndFloor4")
    end
end

function Crutch.UnregisterKynesAegis()
    EVENT_MANAGER:UnregisterForEvent(CrutchAlerts.name .. "BoogerTimerFade", EVENT_COMBAT_EVENT)

    Crutch.DisableIcon("Falgravn2ndFloor1")
    Crutch.DisableIcon("Falgravn2ndFloor2")
    Crutch.DisableIcon("Falgravn2ndFloor3")
    Crutch.DisableIcon("Falgravn2ndFloor4")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Kyne's Aegis")
end
