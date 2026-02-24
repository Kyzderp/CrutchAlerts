local Crutch = CrutchAlerts
Crutch.AsylumSanctorium = {
    llothisId = nil,
    felmsId = nil,
}
local AS = Crutch.AsylumSanctorium
local C = Crutch.Constants

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
-- Mini event detection
---------------------------------------------------------------------
-- Olms to minis (they have same hp)
local MINI_HPS = {
    [26129964] = 2181284, -- Normal
    [89263744] = 9314480, -- Vet
}

local FELMS_NAME = GetString(CRUTCH_BHB_SAINT_FELMS_THE_BOLD)

--[[
95466 -- Unraveling Energies
99990 -- Dormant - takes 45s to fade
58246 -- Speedboost - seems to only be for llothis
]]
-- Felms name detection
local function OnMiniDetectionCombat(_, _, _, _, _, _, sourceName, _, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (sourceName == FELMS_NAME and sourceUnitId ~= 0) then
        AS.felmsId = sourceUnitId
    elseif (targetName == FELMS_NAME and targetUnitId ~= 0) then
        AS.felmsId = targetUnitId
    else
        -- Crutch.dbgSpam(string.format("not felms event %s %d - %s %d", sourceName, sourceUnitId, targetName, targetUnitId))
        return
    end

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASFelmsDetection", EVENT_COMBAT_EVENT)
    Crutch.dbgOther(string.format("detected Felms %d from %s %d - %s %d - %s (%d)", AS.felmsId, sourceName, sourceUnitId, targetName, targetUnitId, GetAbilityName(abilityId), abilityId))
    
    AS.OnFelmsDetectedBHB()
    AS.OnFelmsDetectedPanel()
end

-- TODO: detection by effect

-- Speedboost for detecting Llothis
local function OnSpeedboost(_, _, _, _, _, _, sourceName, _, targetName, _, _, _, _, _, sourceUnitId, targetUnitId, abilityId)
    AS.llothisId = targetUnitId

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASSpeedboost", EVENT_COMBAT_EVENT)
    Crutch.dbgOther(string.format("detected Llothis %d from %s %d - %s %d - %s (%d)", AS.llothisId, sourceName, sourceUnitId, targetName, targetUnitId, GetAbilityName(abilityId), abilityId))
    
    AS.OnLlothisDetectedBHB()
    AS.OnLlothisDetectedPanel()
end

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnDormant(_, changeType, _, _, _, _, _, _, _, _, _, _, _, _, unitId)
    if (unitId == AS.llothisId) then
        AS.OnLlothisDormantBHB(changeType)
        AS.OnLlothisDormantPanel(changeType)
    elseif (unitId == AS.felmsId) then
        AS.OnFelmsDormantBHB(changeType)
        AS.OnFelmsDormantPanel(changeType)
    end
end

local function RegisterMiniDetection()
    -- Llothis detection only needs Speedboost
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASSpeedboost", EVENT_COMBAT_EVENT, OnSpeedboost)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASSpeedboost", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 58246)

    -- Events for detecting Felms
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASFelmsDetection", EVENT_COMBAT_EVENT, OnMiniDetectionCombat)

    -- Dormant for resetting hp
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASMiniDormant", EVENT_EFFECT_CHANGED, OnDormant)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASMiniDormant", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 99990)

    AS.RegisterMinisBHB()
    AS.RegisterMiniPanel()
end

local function UnregisterMiniDetection()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASSpeedboost", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASFelmsDetection", EVENT_COMBAT_EVENT)

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASMiniDormant", EVENT_EFFECT_CHANGED)

    AS.llothisId = nil
    AS.felmsId = nil

    AS.UnregisterMinisBHB()
    AS.UnregisterMiniPanel()
end

local function MaybeRegisterMiniDetection()
    -- Check if it's Olms
    local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (MINI_HPS[powerMax]) then
        RegisterMiniDetection()
    else
        UnregisterMiniDetection()
    end
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterAsylumSanctorium()
    -- Defiling Dye Blast
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASDefiledBlast", EVENT_COMBAT_EVENT, OnCone)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASDefiledBlast", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASDefiledBlast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 95545)

    Crutch.RegisterBossChangedListener("CrutchAsylum", MaybeRegisterMiniDetection)
    MaybeRegisterMiniDetection()

    Crutch.RegisterExitedGroupCombatListener("ExitedCombatASMinis", function()
        UnregisterMiniDetection()
        MaybeRegisterMiniDetection()
    end)

    AS.RegisterMiniPanel()

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Asylum Sanctorium")
end

function Crutch.UnregisterAsylumSanctorium()
    -- Defiling Dye Blast
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASDefiledBlast", EVENT_COMBAT_EVENT)

    Crutch.UnregisterBossChangedListener("CrutchAsylum")
    UnregisterMiniDetection()

    Crutch.UnregisterExitedGroupCombatListener("ExitedCombatASMinis")

    AS.UnregisterMiniPanel()

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Asylum Sanctorium")
end
