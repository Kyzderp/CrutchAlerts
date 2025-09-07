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
local tripletsCircleKey
local function EnableTripletsCircle(x, y, z, radius)
    if (tripletsCircleKey) then
        Crutch.Drawing.RemoveGroundCircle(tripletsCircleKey)
    end

    x = x or 30155
    y = y or 52960
    z = z or 73255
    radius = radius or 3.1
    tripletsCircleKey = Crutch.Drawing.CreateGroundCircle(x, y, z, radius, {1, 0, 0})
end
Crutch.EnableTripletsCircle = EnableTripletsCircle
--/script CrutchAlerts.EnableTripletsCircle()
--/script CrutchAlerts.EnableTripletsCircle(30160, 52960, 73250)
--/script CrutchAlerts.EnableTripletsCircle(30155, 52960, 73255)


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

    -- Triplets icon
    if (Crutch.savedOptions.hallsoffabrication.showTripletsIcon) then
        -- Crutch.EnableIcon("TripletsSafe")
        EnableTripletsCircle()
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

function Crutch.UnregisterHallsOfFabrication()
    -- Spooder damageable
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DamageableCombatState", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name.."Spooder", EVENT_COMBAT_EVENT)

    -- Triplets icon
    Crutch.DisableIcon("TripletsSafe")
    Crutch.Drawing.RemoveGroundCircle(tripletsCircleKey)

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
