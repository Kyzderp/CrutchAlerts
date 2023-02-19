CrutchAlerts = CrutchAlerts or {}
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
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterAsylumSanctorium()
    -- Defiling Dye Blast
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASDefiledBlast", EVENT_COMBAT_EVENT, OnCone)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASDefiledBlast", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASDefiledBlast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 95545)

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Asylum Sanctorium")
end

function Crutch.UnregisterAsylumSanctorium()
    -- Defiling Dye Blast
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASDefiledBlast", EVENT_COMBAT_EVENT)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Asylum Sanctorium")
end
