local Crutch = CrutchAlerts
local C = Crutch.Constants

--[[
gryphon room HM

[20:03:38] [Kyzderp's Derps] zoneId=1427 {x = 172091, y = 40350, z = 238068}
[20:03:44] [Kyzderp's Derps] zoneId=1427 {x = 172123, y = 40350, z = 242163}
[20:03:48] [Kyzderp's Derps] zoneId=1427 {x = 170049, y = 40350, z = 242334}
[20:03:51] [Kyzderp's Derps] zoneId=1427 {x = 168007, y = 40350, z = 242182}
[20:03:57] [Kyzderp's Derps] zoneId=1427 {x = 168000, y = 40350, z = 238103}

wamasu room nonHM

[03:20:16] [Kyzderp's Derps] zoneId=1427 {x = 192112, y = 40350, z = 240132}
[03:20:21] [Kyzderp's Derps] zoneId=1427 {x = 189867, y = 40350, z = 242334}
[03:20:24] [Kyzderp's Derps] zoneId=1427 {x = 187670, y = 40350, z = 240136}
[03:20:28] [Kyzderp's Derps] zoneId=1427 {x = 189892, y = 40350, z = 237901}
]]


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterSanitysEdge()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Sanity's Edge")

    -- Ansuul icon
    if (Crutch.savedOptions.sanitysedge.showAnsuulIcon) then
        Crutch.EnableIcon("AnsuulCenter")
    end

    -- TODO: enable depending on difficulty
    if (Crutch.savedOptions.experimental) then
        Crutch.EnableIconGroup("SEChimeraVet")
        Crutch.EnableIconGroup("SEChimeraHM")
    end
end

function Crutch.UnregisterSanitysEdge()
    -- Ansuul icon
    Crutch.DisableIcon("AnsuulCenter")

    -- Chimera oracle icons
    Crutch.DisableIconGroup("SEChimeraVet")
    Crutch.DisableIconGroup("SEChimeraHM")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Sanity's Edge")
end
