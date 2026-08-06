local Crutch = CrutchAlerts
local C = Crutch.Constants

---------------------------------------------------------------------
local spooderPulled = false

---------------------------------------------------------------------
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
        tripletsCircleKey = nil
    end

    x = x or 30155
    y = y or 52960
    z = z or 73255
    radius = radius or 3.1
    tripletsCircleKey = Crutch.Drawing.CreateGroundCircle(x, y, z, radius, C.RED)
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
        Crutch.RegisterForCombatEvent("Spooder", HandleOverheadRail, nil, 94805)
    end

    -- Triplets icon
    if (Crutch.savedOptions.hallsoffabrication.showTripletsIcon) then
        EnableTripletsCircle()
    end

    -- AG icons
    -- TODO: make them only show on AG
    if (Crutch.savedOptions.hallsoffabrication.showAGIcons) then
        Crutch.EnableIconGroup("AGExecute")
    end
end

function Crutch.UnregisterHallsOfFabrication()
    -- Spooder damageable
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DamageableCombatState", EVENT_PLAYER_COMBAT_STATE)
    Crutch.UnregisterForCombatEvent("Spooder")

    -- Triplets icon
    if (tripletsCircleKey) then
        Crutch.Drawing.RemoveGroundCircle(tripletsCircleKey)
        tripletsCircleKey = nil
    end

    -- AG icons
    Crutch.DisableIconGroup("AGExecute")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Halls of Fabrication")
end
