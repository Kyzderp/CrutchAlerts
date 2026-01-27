local Crutch = CrutchAlerts
local C = Crutch.Constants


---------------------------------------------------------------------
--[[
Parch Bomb (256478)
Parch Bomb (256480)
Parch Bomb (256483)
Skittering Bomb (256383)
Skittering Bomb (256386)
Skittering Bomb (256388)
Sorrow Bomb (256574)
Sorrow Bomb (256576)
Sorrow Bomb (256579)
]]
---------------------------------------------------------------------
local AFFINITY_UNIQUE_NAME = "CrutchAlertsOOAffinity"

local AFFINITIES = {
    [256682] = { -- Eclipse
        texture = "/esoui/art/buttons/gamepad/ps5/nav_ps5_square.dds",
        color = C.PURPLE,
    },
    [256680] = { -- Cobwebs
        texture = "/esoui/art/buttons/gamepad/ps5/nav_ps5_triangle.dds",
        color = C.RED,
    },
    [256681] = { -- Drylands
        texture = "/esoui/art/buttons/gamepad/ps5/nav_ps5_circle.dds",
        color = C.ORANGE,
    },
}

local function OnAffinity(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, _, abilityId)
    if (changeType == EFFECT_RESULT_GAINED) then
        local affinity = AFFINITIES[abilityId]
        Crutch.SetAttachedIconForUnit(unitTag, AFFINITY_UNIQUE_NAME, C.PRIORITY.MECHANIC_1_PRIORITY, affinity.texture, nil, affinity.color)
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.RemoveAttachedIconForUnit(unitTag, AFFINITY_UNIQUE_NAME)
    end
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterOpulentOrdeal()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Opulent Ordeal")

    Crutch.RegisterExitedGroupCombatListener("CrutchOpulentOrdealExitedCombat", function()
        Crutch.RemoveAllAttachedIcons(AFFINITY_UNIQUE_NAME)
    end)

    if (Crutch.savedOptions.opulentordeal.showAffinityIcons) then
        for id, _ in pairs(AFFINITIES) do
            EVENT_MANAGER:RegisterForEvent("CrutchAlertsOOAffinity" .. id, EVENT_EFFECT_CHANGED, OnAffinity)
            EVENT_MANAGER:AddFilterForEvent("CrutchAlertsOOAffinity" .. id, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
            EVENT_MANAGER:AddFilterForEvent("CrutchAlertsOOAffinity" .. id, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, id)
        end
    end
end

function Crutch.UnregisterOpulentOrdeal()
    for id, _ in pairs(AFFINITIES) do
        EVENT_MANAGER:UnregisterForEvent("CrutchAlertsOOAffinity" .. id, EVENT_EFFECT_CHANGED)
    end

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Opulent Ordeal")
end
