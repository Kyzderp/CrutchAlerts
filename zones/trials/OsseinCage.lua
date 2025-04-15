CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts


---------------------------------------------------------------------
-- Stricken
---------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnStricken(_, changeType, _, _, unitTag, beginTime, endTime)
    local atName = GetUnitDisplayName(unitTag)
    local tagNumber = string.gsub(unitTag, "group", "")
    local tagId = tonumber(tagNumber)
    local fakeSourceUnitId = 8880100 + tagId -- TODO: really gotta rework the alerts and stop hacking around like this

    -- Gained
    if (changeType == EFFECT_RESULT_GAINED) then
        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(zo_strformat("<<1>> got Stricken", atName))
        end

        -- Event is not registered if NEVER, so the only other option is TANK
        if (Crutch.savedOptions.osseincage.showStricken == "ALWAYS" or GetSelectedLFGRole() == LFG_ROLE_TANK) then
            local label = zo_strformat("|ca361ff<<C:1>>: <<2>>|r", GetAbilityName(235594), atName)
            Crutch.DisplayNotification(235594, label, (endTime - beginTime) * 1000, fakeSourceUnitId, 0, 0, 0, false)
        end

    -- Faded
    elseif (changeType == EFFECT_RESULT_FADED) then
        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(zo_strformat("<<1>> is no longer Stricken", atName))
        end

        Crutch.Interrupted(fakeSourceUnitId)
    end
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterOsseinCage()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Ossein Cage")

    -- Stricken (tank swap)
    if (Crutch.savedOptions.osseincage.showStricken ~= "NEVER") then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Stricken", EVENT_EFFECT_CHANGED, OnStricken)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Stricken", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Stricken", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 235594)
    end
end

function Crutch.UnregisterOsseinCage()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Stricken", EVENT_EFFECT_CHANGED)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Ossein Cage")
end
