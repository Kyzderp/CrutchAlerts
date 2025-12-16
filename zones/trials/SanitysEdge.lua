local Crutch = CrutchAlerts
local C = Crutch.Constants

--[[
HM: 2, 4, 5, 6, 8
Vet: 1, 3, 5, 7
Norm: 4, 5, 6

gryphon all
1{x = 170065, z = 237908}
2{x = 172102, z = 238078}
3{x = 172289, z = 240133}
4{x = 172116, z = 242169}
5{x = 170051, z = 242334}
6{x = 168007, z = 242182}
7{x = 167843, z = 240125}
8{x = 168020, z = 238086}

lion all
1{x = 179984, y = 40350, z = 237903}
2{x = 182032, y = 40350, z = 238069}
3{x = 182228, y = 40350, z = 240155}
4{x = 182042, y = 40350, z = 242188}
5{x = 179982, y = 40350, z = 242334}
6{x = 177970, y = 40350, z = 242203}
7{x = 177792, y = 40351, z = 240115}
8{x = 177955, y = 40350, z = 238088}

wamasu all
1{x = 189900, y = 40350, z = 237900}
2{x = 191961, y = 40350, z = 238086}
3{x = 192115, y = 40350, z = 240117}
4{x = 191969, y = 40350, z = 242178}
5{x = 189909, y = 40350, z = 242334}
6{x = 187824, y = 40350, z = 242171}
7{x = 187671, y = 40350, z = 240128}
8{x = 187852, y = 40350, z = 238106}
]]
local function DisableChimeraIcons()
    Crutch.DisableIconGroup("SEChimeraVetGryphon")
    Crutch.DisableIconGroup("SEChimeraVetLion")
    Crutch.DisableIconGroup("SEChimeraVetWamasu")
    Crutch.DisableIconGroup("SEChimeraHMGryphon")
    Crutch.DisableIconGroup("SEChimeraHMLion")
    Crutch.DisableIconGroup("SEChimeraHMWamasu")
end

local mantleIds = {
    [183640] = "Gryphon",
    [184983] = "Lion",
    [184984] = "Wamasu",
}

-- Do this as a check rather than listening for events, because
-- it needs to be checked after player activation (or else the
-- icons will just get disabled after going into portal)
local function CheckMantle()
    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        local portal = mantleIds[abilityId]
        if (portal) then
            local iconGroupString = "SEChimera"
            local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)

            -- boss1 is Chimera
            if (powerMax == 93144792) then
                iconGroupString = iconGroupString .. "HM"
            elseif (powerMax == 46572396) then
                iconGroupString = iconGroupString .. "Vet"
            else
                iconGroupString = iconGroupString .. "Norm"
            end

            Crutch.EnableIconGroup(iconGroupString .. portal)
        end
    end
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterSanitysEdge()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Sanity's Edge")

    -- Ansuul icon
    if (Crutch.savedOptions.sanitysedge.showAnsuulIcon) then
        Crutch.EnableIcon("AnsuulCenter")
    end

    if (Crutch.savedOptions.sanitysedge.showChimeraIcons) then
        CheckMantle()
    end
end

function Crutch.UnregisterSanitysEdge()
    -- Ansuul icon
    Crutch.DisableIcon("AnsuulCenter")

    -- Chimera oracle icons
    DisableChimeraIcons()

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "SEGryphonPortal", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "SELionPortal", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "SEWamasuPortal", EVENT_EFFECT_CHANGED)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Sanity's Edge")
end
