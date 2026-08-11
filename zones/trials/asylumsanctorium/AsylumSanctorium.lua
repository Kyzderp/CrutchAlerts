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
local function OnCone(_, _, _, _, _, _, _, _, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (hitValue ~= 2000) then
        -- Only the initial cast
        return
    end

    targetName = GetUnitDisplayName(Crutch.groupIdToTag[targetUnitId])
    if (not targetName) then return end

    if (targetName == GetUnitDisplayName("player")) then
        if (Crutch.savedOptions.asylumsanctorium.dingSelfCone) then
            PlaySound(SOUNDS.DUEL_START)
        end
    else
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
local function OnFelmsDetected()
    Crutch.UnregisterForCombatEvent("ASFelmsDetection")
    Crutch.UnregisterForEffectChanged("ASFelmsDetectionEffect")

    AS.OnFelmsDetectedBHB()
    AS.OnFelmsDetectedPanel()
end

local function OnMiniDetectionCombat(_, _, _, _, _, _, sourceName, _, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (sourceName == FELMS_NAME and sourceUnitId ~= 0) then
        AS.felmsId = sourceUnitId
    elseif (targetName == FELMS_NAME and targetUnitId ~= 0) then
        AS.felmsId = targetUnitId
    else
        -- Crutch.dbgSpam(string.format("not felms event %s %d - %s %d", sourceName, sourceUnitId, targetName, targetUnitId))
        return
    end

    Crutch.dbgSpam(string.format("detected Felms %d from %s %d - %s %d - %s (%d)", AS.felmsId, sourceName, sourceUnitId, targetName, targetUnitId, GetAbilityName(abilityId), abilityId))
    
    OnFelmsDetected()
end

local function OnMiniDetectionEffect(_, changeType, _, _, _, _, _, _, _, _, _, _, _, unitName, unitId, abilityId)
    if (unitName == FELMS_NAME and unitId ~= 0 and changeType == EFFECT_RESULT_GAINED) then
        AS.felmsId = unitId

        Crutch.dbgSpam(string.format("detected Felms using effect %d from %s %d - %s (%d)", AS.felmsId, unitName, unitId, GetAbilityName(abilityId), abilityId))

        OnFelmsDetected()
    end
end

-- Speedboost for detecting Llothis
local function OnSpeedboost(_, _, _, _, _, _, sourceName, _, targetName, _, _, _, _, _, sourceUnitId, targetUnitId, abilityId)
    AS.llothisId = targetUnitId

    Crutch.UnregisterForCombatEvent("ASSpeedboost")
    Crutch.dbgSpam(string.format("detected Llothis %d from %s %d - %s %d - %s (%d)", AS.llothisId, sourceName, sourceUnitId, targetName, targetUnitId, GetAbilityName(abilityId), abilityId))
    
    AS.OnLlothisDetectedBHB()
    AS.OnLlothisDetectedPanel()
end

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
    Crutch.RegisterForCombatEvent("ASSpeedboost", OnSpeedboost, nil, 58246)

    -- Events for detecting Felms
    Crutch.RegisterForCombatEvent("ASFelmsDetection", OnMiniDetectionCombat)
    Crutch.RegisterForEffectChanged("ASFelmsDetectionEffect", OnMiniDetectionEffect)

    -- Dormant for resetting hp
    Crutch.RegisterForEffectChanged("ASMiniDormant", OnDormant, 99990)

    AS.RegisterMinisBHB()
    AS.RegisterMiniPanel()
end

local function UnregisterMiniDetection()
    Crutch.UnregisterForCombatEvent("ASSpeedboost")
    Crutch.UnregisterForCombatEvent("ASFelmsDetection")
    Crutch.UnregisterForEffectChanged("ASFelmsDetectionEffect")

    Crutch.UnregisterForEffectChanged("ASMiniDormant")

    AS.llothisId = nil
    AS.felmsId = nil

    AS.UnregisterMinisBHB()
    AS.UnregisterMiniPanel()
end

local function MaybeRegisterMiniDetection()
    -- Check if it's Olms
    local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (MINI_HPS[powerMax] and not IsUnitDead("boss1")) then
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
    Crutch.RegisterForCombatEvent("ASDefiledBlast", OnCone, ACTION_RESULT_BEGIN, 95545)

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
    Crutch.UnregisterForCombatEvent("ASDefiledBlast")

    Crutch.UnregisterBossChangedListener("CrutchAsylum")
    UnregisterMiniDetection()

    Crutch.UnregisterExitedGroupCombatListener("ExitedCombatASMinis")

    AS.UnregisterMiniPanel()

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Asylum Sanctorium")
end
