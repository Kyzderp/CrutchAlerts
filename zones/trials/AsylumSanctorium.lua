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

-- Could put these all in a more generic struct
local FELMS_NAME = GetString(CRUTCH_BHB_SAINT_FELMS_THE_BOLD)
local llothisId, felmsId
local llothisHp, felmsHp
local regenning = {["2"] = false, ["3"] = false} -- 2: llothis, 3: felms

-- TODO: stop using these strings
local function GetRegenningHp(indexString)
    local elapsed = GetGameTimeSeconds() - regenning[indexString]
    return miniMaxHp * elapsed / 45
end

local function SpoofLlothis()
    local _, olmsMaxHp = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    miniMaxHp = MINI_HPS[olmsMaxHp]
    llothisHp = miniMaxHp

    Crutch.SpoofBoss("boss2", "Saint Llothis the Pious", function()
        if (not regenning["2"]) then
            return llothisHp, miniMaxHp, miniMaxHp
        end
        return GetRegenningHp("2"), miniMaxHp, miniMaxHp
    end,
    {15/255, 113/255, 0, 0.73},
    {5/255, 20/255, 0, 0.66})
end

local function SpoofFelms()
    local _, olmsMaxHp = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    miniMaxHp = MINI_HPS[olmsMaxHp]
    felmsHp = miniMaxHp

    Crutch.SpoofBoss("boss3", "Saint Felms the Bold", function()
        if (not regenning["3"]) then
            return felmsHp, miniMaxHp, miniMaxHp
        end
        return GetRegenningHp("3"), miniMaxHp, miniMaxHp
    end,
    {120/255, 15/255, 0, 0.73},
    {30/255, 5/255, 0, 0.66})
end

local function UnspoofMinis()
    Crutch.UnspoofBoss("boss2")
    Crutch.UnspoofBoss("boss3")
end

--[[
95466 -- Unraveling Energies
99990 -- Dormant - takes 45s to fade
58246 -- Speedboost - seems to only be for llothis
]]
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnMiniDetectionCombat(_, _, _, _, _, _, sourceName, _, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (sourceName == FELMS_NAME and sourceUnitId ~= 0) then
        felmsId = sourceUnitId
    elseif (targetName == FELMS_NAME and targetUnitId ~= 0) then
        felmsId = targetUnitId
    else
        -- Crutch.dbgSpam(string.format("not felms event %s %d - %s %d", sourceName, sourceUnitId, targetName, targetUnitId))
        return
    end

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASFelmsDetection", EVENT_COMBAT_EVENT)
    Crutch.dbgOther(string.format("detected Felms %d from %s %d - %s %d - %s (%d)", felmsId, sourceName, sourceUnitId, targetName, targetUnitId, GetAbilityName(abilityId), abilityId))
    SpoofFelms()
end

local function OnSpeedboost(_, _, _, _, _, _, sourceName, _, targetName, _, _, _, _, _, sourceUnitId, targetUnitId, abilityId)
    llothisId = targetUnitId

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASSpeedboost", EVENT_COMBAT_EVENT)
    Crutch.dbgOther(string.format("detected Llothis %d from %s %d - %s %d - %s (%d)", llothisId, sourceName, sourceUnitId, targetName, targetUnitId, GetAbilityName(abilityId), abilityId))
    SpoofLlothis()
end

-- TODO: first hit might get missed due to being the first event?
local function OnMiniDamage(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (targetUnitId == llothisId) then
        -- Crutch.dbgSpam(string.format("damage to llothis %d by %s (%d)", hitValue, GetAbilityName(abilityId), abilityId))
        llothisHp = llothisHp - hitValue
        Crutch.UpdateSpoofedBossHealth("boss2", llothisHp, miniMaxHp)
    elseif (targetUnitId == felmsId) then
        felmsHp = felmsHp - hitValue
        Crutch.UpdateSpoofedBossHealth("boss3", felmsHp, miniMaxHp)
    end
end

local function RegenWhileDormant(indexString)
    regenning[indexString] = GetGameTimeSeconds()
    Crutch.SetBarColors(indexString,
        {92/255, 92/255, 92/255, 0.73},
        {28/255, 28/255, 28/255, 0.66})

    -- ZO_StatusBar_SmoothTransition(self, value, max, forceInit, onStopCallback, customApproachAmountMs)
    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "ASRegen" .. indexString, 1000, function()
        Crutch.UpdateSpoofedBossHealth("boss" .. indexString, GetRegenningHp(indexString), miniMaxHp)
    end)
end

local function StopRegenning(indexString)
    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "ASRegen" .. indexString)
    regenning[indexString] = false
    -- TODO: uggo
    if (indexString == "2") then
        Crutch.SetBarColors(indexString,
            {15/255, 113/255, 0, 0.73},
            {5/255, 20/255, 0, 0.66})
    elseif (indexString == "3") then
        Crutch.SetBarColors(indexString,
            {120/255, 15/255, 0, 0.73},
            {30/255, 5/255, 0, 0.66})
    end
end

-- Listen for Dormant to reset hp
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnDormant(_, changeType, _, _, _, _, _, _, _, _, _, _, _, _, unitId)
    if (unitId == llothisId) then
        if (changeType == EFFECT_RESULT_GAINED) then
            Crutch.dbgOther("Llothis now dormant")
            RegenWhileDormant("2")
        elseif (changeType == EFFECT_RESULT_FADED) then
            Crutch.dbgOther("Llothis no longer dormant")
            StopRegenning("2")
            llothisHp = miniMaxHp
            Crutch.UpdateSpoofedBossHealth("boss2", llothisHp, miniMaxHp)
        end
        return
    end

    if (unitId == felmsId) then
        if (changeType == EFFECT_RESULT_GAINED) then
            Crutch.dbgOther("Felms now dormant")
            RegenWhileDormant("3")
        elseif (changeType == EFFECT_RESULT_FADED) then
            Crutch.dbgOther("Felms no longer dormant")
            StopRegenning("3")
            felmsHp = miniMaxHp
            Crutch.UpdateSpoofedBossHealth("boss3", felmsHp, miniMaxHp)
        end
    end
end

local damageTypes = {
    [ACTION_RESULT_DAMAGE] = "dmg",
    [ACTION_RESULT_CRITICAL_DAMAGE] = "dmg*",
    [ACTION_RESULT_DOT_TICK] = "tick",
    [ACTION_RESULT_DOT_TICK_CRITICAL] = "tick*",
}
local function RegisterMinis()
    if (not Crutch.savedOptions.asylumsanctorium.showMinisHp) then return end

    -- Llothis detection only needs Speedboost
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASSpeedboost", EVENT_COMBAT_EVENT, OnSpeedboost)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASSpeedboost", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 58246)

    -- Events for detecting Felms
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASFelmsDetection", EVENT_COMBAT_EVENT, OnMiniDetectionCombat)

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
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASSpeedboost", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASFelmsDetection", EVENT_COMBAT_EVENT)

    for actionResult, str in pairs(damageTypes) do
        local eventName = Crutch.name .. "ASMinis" .. tostring(actionResult)
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
    end

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASMiniDormant", EVENT_EFFECT_CHANGED)

    UnspoofMinis()

    llothisId = nil
    felmsId = nil
end

local function MaybeRegisterMinis()
    -- Check if it's Olms
    local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (MINI_HPS[powerMax]) then
        RegisterMinis()
    else
        UnregisterMinis()
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

    Crutch.RegisterBossChangedListener("CrutchAsylum", MaybeRegisterMinis)
    MaybeRegisterMinis()

    Crutch.RegisterExitedGroupCombatListener("ExitedCombatASMinis", function()
        UnregisterMinis()
        MaybeRegisterMinis()
    end)

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Asylum Sanctorium")
end

function Crutch.UnregisterAsylumSanctorium()
    -- Defiling Dye Blast
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASDefiledBlast", EVENT_COMBAT_EVENT)

    Crutch.UnregisterBossChangedListener("CrutchAsylum")
    UnregisterMinis()

    Crutch.UnregisterExitedGroupCombatListener("ExitedCombatASMinis")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Asylum Sanctorium")
end
