CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
local amuletSmashed = false

---------------------------------------------------------------------
local function OnCombatStateChanged(_, inCombat)
    -- Reset
    if (not inCombat) then
        amuletSmashed = false
    end
end

-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnRoaringFlareGained(_, result, _, _, _, _, sourceName, sourceType, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (not amuletSmashed) then return end

    -- Actual display
    targetName = Crutch.groupMembers[targetUnitId]
    if (targetName) then
        targetName = zo_strformat("<<1>>", targetName)
    else
        targetName = "UNKNOWN"
    end

    if (abilityId == 103531) then
        local label = string.format("|cff0000|t100%:100%:Esoui/Art/Buttons/large_leftarrow_up.dds:inheritcolor|t |cff7700%s |caaaaaaLEFT|r", targetName)
        Crutch.DisplayNotification(abilityId, label, hitValue, sourceUnitId, sourceName, sourceType, result)
        -- /script CrutchAlerts.DisplayNotification(103531, "|cff0000|t100%:100%:Esoui/Art/Buttons/large_leftarrow_up.dds:inheritcolor|t |cff7700@Kyzeragon |caaaaaaLEFT|r", 1, 0, 0, 0, 0)
    elseif (abilityId == 110431) then
        local label = string.format("|cff7700%s |caaaaaaRIGHT |cff0000|t100%:100%:Esoui/Art/Buttons/large_rightarrow_up.dds:inheritcolor|t|r", targetName)
        Crutch.DisplayNotification(abilityId, label, hitValue, sourceUnitId, sourceName, sourceType, result)
        -- /script CrutchAlerts.DisplayNotification(110431, "|cff7700@Kyzeragon |caaaaaaRIGHT |cff0000|t100%:100%:Esoui/Art/Buttons/large_rightarrow_up.dds:inheritcolor|t|r", 1, 0, 0, 0, 0)
    else
        d("|cFF0000SHOULD NOT BE POSSIBLE")
    end
end

local function OnAmuletSmashed()
    amuletSmashed = true
end

---------------------------------------------------------------------
-- Register/Unregister
function Crutch.RegisterCloudrest()
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CT]|r Registered Cloudrest") end
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CloudrestCombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    -- Register break amulet
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CloudrestBreakAmulet", EVENT_COMBAT_EVENT, OnAmuletSmashed)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestBreakAmulet", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestBreakAmulet", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 106023) -- Breaking the amulet (takes 4 seconds)

    -- Register the Roaring Flares
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT, OnRoaringFlareGained)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) -- from enemy
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 103531) -- Flare 1 throughout the fight

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT, OnRoaringFlareGained)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) -- from enemy
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 110431) -- Flare 2 in execute
end

function Crutch.UnregisterCloudrest()
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CT]|r Unregistered Cloudrest") end
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "CloudrestCombatState", EVENT_PLAYER_COMBAT_STATE)
end
