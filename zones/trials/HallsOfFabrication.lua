CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
local spooderPulled = false

---------------------------------------------------------------------
-- EVENT_PLAYER_COMBAT_STATE (number eventCode, boolean inCombat)
local function HandleCombatState(_, inCombat)
    if (not inCombat) then
        -- Reset one-time vars
        spooderPulled = false
    end
end


---------------------------------------------------------------------
local function HandleOverheadRail()
    if (spooderPulled) then
        return
    end

    spooderPulled = true
    Crutch.DisplayDamageable(23.2)
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterHallsOfFabrication()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Halls of Fabrication")

    -- Spooder damageable
    if (Crutch.savedOptions.general.showDamageable) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DamageableCombatState", EVENT_PLAYER_COMBAT_STATE, HandleCombatState)
        EVENT_MANAGER:RegisterForEvent(Crutch.name.."Spooder", EVENT_COMBAT_EVENT, HandleOverheadRail)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name.."Spooder", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 94805)
    end

    if (not Crutch.WorldIconsEnabled()) then
        Crutch.msg("You must install OdySupportIcons 1.6.3+ to display in-world icons")
    else
        -- Triplets icon
        if (Crutch.savedOptions.hallsoffabrication.showTripletsIcon) then
            Crutch.EnableIcon("TripletsSafe")
        end

        -- AG icons
        if (Crutch.savedOptions.hallsoffabrication.showAGIcons) then
            Crutch.EnableIcon("AGN")
            Crutch.EnableIcon("AGNE")
            Crutch.EnableIcon("AGE")
            Crutch.EnableIcon("AGSE")
            Crutch.EnableIcon("AGS")
            Crutch.EnableIcon("AGSW")
            Crutch.EnableIcon("AGW")
            Crutch.EnableIcon("AGNW")
        end
    end
end

function Crutch.UnregisterHallsOfFabrication()
    -- Spooder damageable
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DamageableCombatState", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name.."Spooder", EVENT_COMBAT_EVENT)

    -- Triplets icon
    Crutch.DisableIcon("TripletsSafe")

    -- AG icons
    Crutch.DisableIcon("AGN")
    Crutch.DisableIcon("AGNE")
    Crutch.DisableIcon("AGE")
    Crutch.DisableIcon("AGSE")
    Crutch.DisableIcon("AGS")
    Crutch.DisableIcon("AGSW")
    Crutch.DisableIcon("AGW")
    Crutch.DisableIcon("AGNW")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Halls of Fabrication")
end
