CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterHallsOfFabrication()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Halls of Fabrication")

    if (not Crutch.WorldIconsEnabled()) then
        Crutch.msg("You must install OdySupportIcons 1.6.3+ to display in-world icons")
    else
        -- Triplets icon
        if (Crutch.savedOptions.hallsoffabrication.showTripletsIcon) then
            Crutch.EnableIcon("TripletsSafe")
        end
    end
end

function Crutch.UnregisterHallsOfFabrication()
    -- Triplets icon
    Crutch.DisableIcon("TripletsSafe")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Halls of Fabrication")
end
