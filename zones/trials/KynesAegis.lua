CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

-- TODO: chaurus totem dodge

---------------------------------------------------------------------
-- Trash
---------------------------------------------------------------------
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnExplodingSpearBegin(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    local unitTag = Crutch.groupIdToTag[targetUnitId]
    -- Persist icon for 5 seconds
    if (unitTag) then
        zo_callLater(function()
            local _, x, y, z = GetUnitRawWorldPosition(unitTag)
            local spear1 = OSI.CreatePositionIcon(x, y, z, "/esoui/art/icons/death_recap_fire_ranged_arrow.dds", 100)
            zo_callLater(function() OSI.DiscardPositionIcon(spear1) end, 5000)
        end, 500)
    end
end

---------------------------------------------------------------------
-- Falgravn
---------------------------------------------------------------------
local prisoned = {}

-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnPrisonBegin(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, targetUnitId)
    if (hitValue ~= 1500) then return end
    local unitTag = Crutch.groupIdToTag[targetUnitId]
    if (unitTag) then
        OSI.SetMechanicIconForUnit(GetUnitDisplayName(unitTag), "/esoui/art/icons/death_recap_oblivion.dds")
        zo_callLater(function()
            if (not prisoned[unitTag]) then
                -- Remove the icon if not prisoned, this can happen if the bitter knight dies during the cast
                OSI.RemoveMechanicIconForUnit(GetUnitDisplayName(unitTag))
            end
        end, 2000)
    end
end

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnPrisonEffect(_, changeType, _, _, unitTag)
    -- seems to be 1.5s for the cast, then 8s for the prison?
    if (changeType == EFFECT_RESULT_GAINED) then
        prisoned[unitTag] = true
        OSI.SetMechanicIconForUnit(GetUnitDisplayName(unitTag), "/esoui/art/icons/death_recap_oblivion.dds")
    elseif (changeType == EFFECT_RESULT_FADED) then
        prisoned[unitTag] = nil
        OSI.RemoveMechanicIconForUnit(GetUnitDisplayName(unitTag))
    end
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterKynesAegis()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Kyne's Aegis")

    if (not Crutch.WorldIconsEnabled()) then
        Crutch.msg("You must install OdySupportIcons 1.6.3+ to display in-world icons")
    else
        --Spear
        if (Crutch.savedOptions.kynesaegis.showSpearIcon) then
            EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ExplodingSpear", EVENT_COMBAT_EVENT, OnExplodingSpearBegin)
            EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ExplodingSpear", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_BEGIN)
            EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ExplodingSpear", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 133936)
        end

        -- Prison icon
        if (Crutch.savedOptions.kynesaegis.showPrisonIcon) then
            EVENT_MANAGER:RegisterForEvent(Crutch.name .. "PrisonEffect", EVENT_EFFECT_CHANGED, OnPrisonEffect)
            EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "PrisonEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 132473)
            EVENT_MANAGER:RegisterForEvent(Crutch.name .. "PrisonCast", EVENT_COMBAT_EVENT, OnPrisonBegin)
            EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "PrisonCast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 132468)
            EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "PrisonCast", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_BEGIN)
        end

        -- Falgravn icons
        if (Crutch.savedOptions.kynesaegis.showFalgravnIcons) then
            Crutch.EnableIcon("Falgravn2ndFloor1")
            Crutch.EnableIcon("Falgravn2ndFloor2")
            Crutch.EnableIcon("Falgravn2ndFloor3")
            Crutch.EnableIcon("Falgravn2ndFloor4")
            Crutch.EnableIcon("Falgravn2ndFloorH1")
            Crutch.EnableIcon("Falgravn2ndFloorH2")
        end
    end
end

function Crutch.UnregisterKynesAegis()
    -- Spear
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ExplodingSpear", EVENT_COMBAT_EVENT)

    -- Prison icon
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "PrisonEffect", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "PrisonCast", EVENT_COMBAT_EVENT)

    -- Falgravn icons
    Crutch.DisableIcon("Falgravn2ndFloor1")
    Crutch.DisableIcon("Falgravn2ndFloor2")
    Crutch.DisableIcon("Falgravn2ndFloor3")
    Crutch.DisableIcon("Falgravn2ndFloor4")
    Crutch.DisableIcon("Falgravn2ndFloorH1")
    Crutch.DisableIcon("Falgravn2ndFloorH2")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Kyne's Aegis")
end
