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

3 second cast to summon + 4 mins for essence
Summon Arid Varlet Essence (256413)
Summon Knightshade Essence (256495)
Summon Web Eater Essence (256159)
Stunned (257929) Arid Varlet
Stunned (257928) Web Eater
Stunned (257930) Knightshade

damage taken (just to display as text)
Arid Varlet Essence (256447)
Knightshade Essence (256518)
Web Eater Essence (256088)
]]

---------------------------------------------------------------------
-- Panel
---------------------------------------------------------------------
local PANEL_ESSENCE_INDEX = 5

local BOSS_ESSENCES = { -- [summonId] = {}
    [256159] = {
        -- Web Eater
        stunnedId = 257928,
        displayId = 256088,
        color = "ff0000",
    },
    [256413] = {
        -- Arid Varlet
        stunnedId = 257929,
        displayId = 256447,
        color = "ff8000",
    },
    [256495] = {
        -- Knightshade
        stunnedId = 257930,
        displayId = 256518,
        color = "cc33ff",
    },
}

local function OnSummonEssence(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    local data = BOSS_ESSENCES[abilityId]
    Crutch.InfoPanel.CountDownDuration(PANEL_ESSENCE_INDEX, string.format("|c%s%s ", data.color, GetAbilityName(data.displayId)), 243000)
end

local function OnEssenceDone()
    Crutch.InfoPanel.StopCount(PANEL_ESSENCE_INDEX)
end

---------------------------------------------------------------------
-- Affinity icons
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
---------------------------------------------------------------------
local function CleanUp()
    Crutch.RemoveAllAttachedIcons(AFFINITY_UNIQUE_NAME)
    Crutch.InfoPanel.StopCount(PANEL_ESSENCE_INDEX)
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterOpulentOrdeal()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Opulent Ordeal")

    Crutch.RegisterExitedGroupCombatListener("CrutchOpulentOrdealExitedCombat", CleanUp)

    if (Crutch.savedOptions.opulentordeal.showAffinityIcons) then
        local idsToCallbacks = {}
        for id, _ in pairs(AFFINITIES) do
            Crutch.RegisterForEffectChanged("OOAffinity" .. id, OnAffinity, id, "group")

            -- Since we can have player activations during the trial, we also need to
            -- check buffs every time, in case any were missed while in loadscreen (probably).
            -- Only act on positive, because the unique name is shared.
            idsToCallbacks[id] = function(unitTag, hasBuff)
                if (hasBuff) then
                    OnAffinity(nil, EFFECT_RESULT_GAINED, nil, nil, unitTag, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, id)
                    Crutch.dbgSpam(GetUnitDisplayName(unitTag) .. " has " .. GetAbilityName(id))
                end
            end
        end

        Crutch.CheckGroupBuffs(idsToCallbacks, function(unitTag, hasAnyBuffs)
            -- Remove icon entirely if no buffs. Cannot do this as part of the individual
            -- callback because they share the same unique name.
            if (not hasAnyBuffs) then
                OnAffinity(nil, EFFECT_RESULT_FADED, nil, nil, unitTag)
                Crutch.dbgSpam(GetUnitDisplayName(unitTag) .. " does not have any affinities")
            end
        end)
    end

    for summonId, data in pairs(BOSS_ESSENCES) do
        Crutch.RegisterForCombatEvent("OOSummonEssence" .. summonId, OnSummonEssence, ACTION_RESULT_BEGIN, summonId)
        Crutch.RegisterForCombatEvent("OOBossStunned" .. data.stunnedId, OnEssenceDone, nil, data.stunnedId)
    end
end

function Crutch.UnregisterOpulentOrdeal(isSameZone)
    for id, _ in pairs(AFFINITIES) do
        Crutch.UnregisterForEffectChanged("OOAffinity" .. id)
    end

    for summonId, data in pairs(BOSS_ESSENCES) do
        Crutch.UnregisterForCombatEvent("OOSummonEssence" .. summonId)
        Crutch.UnregisterForCombatEvent("OOBossStunned" .. data.stunnedId)
    end

    -- Getting ported out of the side areas triggers player activated
    -- We don't actually want to clean up in that case
    if (not isSameZone) then
        CleanUp()
    end

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Opulent Ordeal")
end
