local Crutch = CrutchAlerts
local AS = Crutch.AsylumSanctorium
local C = Crutch.Constants


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
    C.LLOTHIS_FG,
    C.LLOTHIS_BG)
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
    C.FELMS_FG,
    C.FELMS_BG)
end

local function UnspoofMinis()
    Crutch.UnspoofBoss("boss2")
    Crutch.UnspoofBoss("boss3")
end

-- TODO: first hit might get missed due to being the first event?
local function OnMiniDamage(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (targetUnitId == AS.llothisId) then
        -- Crutch.dbgSpam(string.format("damage to llothis %d by %s (%d)", hitValue, GetAbilityName(abilityId), abilityId))
        llothisHp = llothisHp - hitValue
        Crutch.UpdateSpoofedBossHealth("boss2", llothisHp, miniMaxHp)
    elseif (targetUnitId == AS.felmsId) then
        felmsHp = felmsHp - hitValue
        Crutch.UpdateSpoofedBossHealth("boss3", felmsHp, miniMaxHp)
    end
end

local function RegenWhileDormant(indexString)
    regenning[indexString] = GetGameTimeSeconds()
    Crutch.SetBarColors(indexString,
        C.DORMANT_FG,
        C.DORMANT_BG)

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
            C.LLOTHIS_FG,
            C.LLOTHIS_BG)
    elseif (indexString == "3") then
        Crutch.SetBarColors(indexString,
            C.FELMS_FG,
            C.FELMS_BG)
    end
end


---------------------------------------------------------------------
-- Register called from AsylumSanctoriumlua
---------------------------------------------------------------------
local damageTypes = {
    [ACTION_RESULT_DAMAGE] = "dmg",
    [ACTION_RESULT_CRITICAL_DAMAGE] = "dmg*",
    [ACTION_RESULT_DOT_TICK] = "tick",
    [ACTION_RESULT_DOT_TICK_CRITICAL] = "tick*",
}
function AS.RegisterMinisBHB()
    if (not Crutch.savedOptions.asylumsanctorium.showMinisHp) then return end

    -- Damage events for hp changes
    for actionResult, str in pairs(damageTypes) do
        local eventName = Crutch.name .. "ASMinis" .. tostring(actionResult)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, OnMiniDamage)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, actionResult)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
    end
end

function AS.UnregisterMinisBHB()
    for actionResult, str in pairs(damageTypes) do
        local eventName = Crutch.name .. "ASMinis" .. tostring(actionResult)
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
    end

    UnspoofMinis()
end


---------------------------------------------------------------------
-- "Events" called from AsylumSanctorium.lua
---------------------------------------------------------------------
function AS.OnLlothisDetectedBHB()
    SpoofLlothis()
end

function AS.OnLlothisDormantBHB(changeType)
    if (changeType == EFFECT_RESULT_GAINED) then
        Crutch.dbgOther("Llothis now dormant")
        RegenWhileDormant("2")
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.dbgOther("Llothis no longer dormant")
        StopRegenning("2")
        llothisHp = miniMaxHp
        Crutch.UpdateSpoofedBossHealth("boss2", llothisHp, miniMaxHp)
    end
end

function AS.OnFelmsDetectedBHB()
    SpoofFelms()
end

function AS.OnFelmsDormantBHB(changeType)
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
