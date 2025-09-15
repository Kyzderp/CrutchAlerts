local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Llothis
---------------------------------------------------------------------
-- Alert is already displayed by data.lua, this is just for dinging
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnCone(_, _, _, _, _, _, _, _, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (hitValue ~= 2000) then
        -- Only the initial cast
        return
    end

    targetName = GetUnitDisplayName(Crutch.groupIdToTag[targetUnitId])
    if (not targetName) then return end

    if (targetName == GetUnitDisplayName("player")) then
        Crutch.dbgOther(string.format("Cone self %s", targetName))
        if (Crutch.savedOptions.asylumsanctorium.dingSelfCone) then
            PlaySound(SOUNDS.DUEL_START)
        end
    else
        Crutch.dbgOther(string.format("Cone other %s", targetName))
        if (Crutch.savedOptions.asylumsanctorium.dingOthersCone) then
            PlaySound(SOUNDS.DUEL_START)
        end
    end
end


---------------------------------------------------------------------
-- Mini health bars?
---------------------------------------------------------------------
-- Olms to minis (they have same hp)
local MINI_HPS = {
    [26129964] = 2181284, -- Normal
    [89263744] = 9314480, -- Vet
}

local miniMaxHp

local LLOTHIS_NAME = "Saint Llothis the Pious^M"
local llothisId, felmsId
local llothisHp

local function SpoofLlothis()
    local _, olmsMaxHp = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    miniMaxHp = MINI_HPS[olmsMaxHp]
    llothisHp = miniMaxHp

    Crutch.SpoofBoss("boss2", "Saint Llothis the Pious", function()
        return llothisHp, miniMaxHp, miniMaxHp
    end,
    {25/255, 123/255, 0, 0.73},
    {5/255, 20/255, 0, 0.66})
end

local function UnspoofLlothis()
    Crutch.UnspoofBoss("boss2")
end

--[[
95466 -- Unraveling Energies
99990 -- Dormant - takes 45s to fade
58246 -- Speedboost - seems to only be for llothis
]]
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnMiniDetectionCombat(_, _, _, _, _, _, sourceName, _, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (abilityId == 58246) then -- Speedboost
        llothisId = targetUnitId
    elseif (sourceName == LLOTHIS_NAME and sourceUnitId ~= 0) then
        llothisId = sourceUnitId
    elseif (targetName == LLOTHIS_NAME and targetUnitId ~= 0) then
        llothisId = targetUnitId
    else
        -- Crutch.dbgSpam(string.format("not llothis event %s %d - %s %d", sourceName, sourceUnitId, targetName, targetUnitId))
        return
    end

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASMiniDetection", EVENT_COMBAT_EVENT)
    Crutch.dbgOther(string.format("detected Llothis %d from %s %d - %s %d - %s (%d)", llothisId, sourceName, sourceUnitId, targetName, targetUnitId, GetAbilityName(abilityId), abilityId))
    SpoofLlothis()
end

-- TODO: first hit might get missed due to being the first event?
local function OnMiniDamage(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (targetUnitId ~= llothisId) then return end

    Crutch.dbgSpam(string.format("damage to llothis %d by %s (%d)", hitValue, GetAbilityName(abilityId), abilityId))

    llothisHp = llothisHp - hitValue

    Crutch.UpdateSpoofedBossHealth("boss2", llothisHp, miniMaxHp)
end

-- Listen for Dormant to reset hp
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnDormant(_, changeType, _, _, _, _, _, _, _, _, _, _, _, _, unitId)
    if (unitId ~= llothisId) then return end

    if (changeType == EFFECT_RESULT_GAINED) then
        Crutch.dbgOther("Llothis now dormant")
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.dbgOther("Llothis no longer dormant")
        llothisHp = miniMaxHp
        Crutch.UpdateSpoofedBossHealth("boss2", llothisHp, miniMaxHp)
    end
end

local damageTypes = {
    [ACTION_RESULT_DAMAGE] = "dmg",
    [ACTION_RESULT_CRITICAL_DAMAGE] = "dmg*",
    [ACTION_RESULT_DOT_TICK] = "tick",
    [ACTION_RESULT_DOT_TICK_CRITICAL] = "tick*",
}
local function RegisterMinis()
    -- Events for detecting the mini
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASMiniDetection", EVENT_COMBAT_EVENT, OnMiniDetectionCombat)

    -- Damage events for hp changes
    for actionResult, str in pairs(damageTypes) do
        local eventName = Crutch.name .. "ASMinis" .. tostring(actionResult)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, OnMiniDamage)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, actionResult)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
    end

    -- Dormant for resetting hp
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASMiniDormant", EVENT_EFFECT_CHANGED, OnDormant)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASMiniDormant", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 99990)
end

local function UnregisterMinis()
    UnspoofLlothis()

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASMiniDetection", EVENT_COMBAT_EVENT)

    for actionResult, str in pairs(damageTypes) do
        local eventName = Crutch.name .. "ASMinis" .. tostring(actionResult)
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
    end

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASMiniDormant", EVENT_EFFECT_CHANGED)
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterAsylumSanctorium()
    -- Defiling Dye Blast
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASDefiledBlast", EVENT_COMBAT_EVENT, OnCone)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASDefiledBlast", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASDefiledBlast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 95545)

    RegisterMinis()

    Crutch.RegisterExitedGroupCombatListener("ExitedCombatASMinis", function()
        UnspoofLlothis()
    end)

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Asylum Sanctorium")
end

function Crutch.UnregisterAsylumSanctorium()
    -- Defiling Dye Blast
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASDefiledBlast", EVENT_COMBAT_EVENT)

    UnregisterMinis()

    Crutch.UnregisterExitedGroupCombatListener("ExitedCombatASMinis")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Asylum Sanctorium")
end
