CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Trash
---------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnDarknessInflicted(_, changeType)
    if (changeType == EFFECT_RESULT_GAINED) then
        Crutch.DisplayProminent(888007)
    end
end


---------------------------------------------------------------------
-- Arcane Knot
---------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnArcaneKnot(_, changeType, _, _, unitTag, beginTime, endTime)
    local atName = GetUnitDisplayName(unitTag)
    local tagNumber = string.gsub(unitTag, "group", "")
    local tagId = tonumber(tagNumber)
    local fakeSourceUnitId = 8880070 + tagId

    -- Pick up
    if (changeType == EFFECT_RESULT_GAINED) then
        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(zo_strformat("<<1>> picked up the knot", atName))
        end

        local label = zo_strformat("|cff7700<<C:1>>: <<2>>|r", GetAbilityName(213477), atName)
        Crutch.DisplayNotification(213477, label, endTime - beginTime, fakeSourceUnitId, 0, 0, 0, false)

    -- Drop
    elseif (changeType == EFFECT_RESULT_FADED) then
        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(zo_strformat("<<1>> dropped the knot", atName))
        end

        Crutch.Interrupted(fakeSourceUnitId)
    end
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
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DarknessInflicted", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DarknessInflicted", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 214338)

    -- Arcane Knot
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ArcaneKnot", EVENT_EFFECT_CHANGED, OnArcaneKnot)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ArcaneKnot", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ArcaneKnot", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 213477)
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
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ArcaneKnot", EVENT_EFFECT_CHANGED)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Lucent Citadel")
end

function Crutch.ToggleOrphic()
    whichOrphic = not whichOrphic
    Crutch.OnPlayerActivated()
end
-- /script CrutchAlerts.ToggleOrphic()
