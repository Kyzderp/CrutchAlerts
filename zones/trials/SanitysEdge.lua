CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterSanitysEdge()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Sanity's Edge")

    if (not Crutch.WorldIconsEnabled()) then
        Crutch.ComplainOSI()
    else
        -- Ansuul icon
        if (Crutch.savedOptions.sanitysedge.showAnsuulIcon) then
            Crutch.EnableIcon("AnsuulCenter")
        end
    end
end

function Crutch.UnregisterSanitysEdge()
    -- Ansuul icon
    Crutch.DisableIcon("AnsuulCenter")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Sanity's Edge")
end
