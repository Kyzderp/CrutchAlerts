CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Trash
---------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnDarknessInflicted()
    Crutch.DisplayProminent(888007)
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
local whichOrphic = true
function Crutch.RegisterLucentCitadel()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Lucent Citadel")

    if (not Crutch.WorldIconsEnabled()) then
        Crutch.msg("You must install OdySupportIcons 1.6.3+ to display in-world icons")
    else
        -- Orphic Shattered Shard icons for mirrors
        if (Crutch.savedOptions.lucentcitadel.showOrphicIcons) then
            if (whichOrphic) then
            Crutch.EnableIcon("Orphic1")
            Crutch.EnableIcon("Orphic2")
            Crutch.EnableIcon("Orphic3")
            Crutch.EnableIcon("Orphic4")
            Crutch.EnableIcon("Orphic5")
            Crutch.EnableIcon("Orphic6")
            Crutch.EnableIcon("Orphic7")
            Crutch.EnableIcon("Orphic8")
            else
            Crutch.EnableIcon("Orphic1_2")
            Crutch.EnableIcon("Orphic2_2")
            Crutch.EnableIcon("Orphic3_2")
            Crutch.EnableIcon("Orphic4_2")
            Crutch.EnableIcon("Orphic5_2")
            Crutch.EnableIcon("Orphic6_2")
            Crutch.EnableIcon("Orphic7_2")
            Crutch.EnableIcon("Orphic8_2")
            end
        end
    end

    -- Darkness Inflicted
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DarknessInflicted", EVENT_EFFECT_CHANGED, OnDarknessInflicted)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DarknessInflicted", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DarknessInflicted", EVENT_EFFECT_CHANGED, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DarknessInflicted", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 214338)
end

function Crutch.UnregisterLucentCitadel()
    -- Orphic mirror icons
    Crutch.DisableIcon("Orphic1")
    Crutch.DisableIcon("Orphic2")
    Crutch.DisableIcon("Orphic3")
    Crutch.DisableIcon("Orphic4")
    Crutch.DisableIcon("Orphic5")
    Crutch.DisableIcon("Orphic6")
    Crutch.DisableIcon("Orphic7")
    Crutch.DisableIcon("Orphic8")

    Crutch.DisableIcon("Orphic1_2")
    Crutch.DisableIcon("Orphic2_2")
    Crutch.DisableIcon("Orphic3_2")
    Crutch.DisableIcon("Orphic4_2")
    Crutch.DisableIcon("Orphic5_2")
    Crutch.DisableIcon("Orphic6_2")
    Crutch.DisableIcon("Orphic7_2")
    Crutch.DisableIcon("Orphic8_2")

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DarknessInflicted", EVENT_EFFECT_CHANGED)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Lucent Citadel")
end

function Crutch.ToggleOrphic()
    whichOrphic = not whichOrphic
    Crutch.OnPlayerActivated()
end
-- /script CrutchAlerts.ToggleOrphic()
