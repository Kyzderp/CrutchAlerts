local Crutch = CrutchAlerts
local C = Crutch.Constants

-- TODO: chaurus totem dodge

---------------------------------------------------------------------
-- Trash
---------------------------------------------------------------------
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnExplodingSpearBegin(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    local unitTag = Crutch.groupIdToTag[targetUnitId]
    if (unitTag) then
        zo_callLater(function()
            local _, x, y, z = GetUnitRawWorldPosition(unitTag)
            local iconKey = Crutch.Drawing.CreatePlacedIcon("/esoui/art/icons/death_recap_fire_ranged_arrow.dds", x, y + 30, z, 60)
            local circleKey = Crutch.Drawing.CreateGroundCircle(x, y + 5, z, 4, {1, 0.5, 0}) -- Circle is more obvious if it's not accurate, but oh well...

            zo_callLater(function()
                Crutch.Drawing.RemovePlacedIcon(iconKey)
                Crutch.Drawing.RemoveGroundCircle(circleKey)
            end, 4000)
        end, 500)
    end
end

---------------------------------------------------------------------
-- Falgravn
---------------------------------------------------------------------
local prisoned = {}
local PRISON_UNIQUE_NAME = "CrutchAlertsKAPrison"

-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnPrisonBegin(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, targetUnitId)
    if (hitValue ~= 1500) then return end
    local unitTag = Crutch.groupIdToTag[targetUnitId]
    if (unitTag) then
        Crutch.SetAttachedIconForUnit(unitTag, PRISON_UNIQUE_NAME, C.PRIORITY.MECHANIC_1_PRIORITY, "/esoui/art/icons/death_recap_oblivion.dds")
        zo_callLater(function()
            if (not prisoned[unitTag]) then
                -- Remove the icon if not prisoned, this can happen if the bitter knight dies during the cast
                Crutch.RemoveAttachedIconForUnit(unitTag, PRISON_UNIQUE_NAME)
            end
        end, 2000)
    end
end

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnPrisonEffect(_, changeType, _, _, unitTag)
    -- seems to be 1.5s for the cast, then 8s for the prison?
    if (changeType == EFFECT_RESULT_GAINED) then
        prisoned[unitTag] = true
        Crutch.SetAttachedIconForUnit(unitTag, PRISON_UNIQUE_NAME, C.PRIORITY.MECHANIC_1_PRIORITY, "/esoui/art/icons/death_recap_oblivion.dds")
    elseif (changeType == EFFECT_RESULT_FADED) then
        prisoned[unitTag] = nil
        Crutch.RemoveAttachedIconForUnit(unitTag, PRISON_UNIQUE_NAME)
    end
end

---------------------------------------------------------------------
-- Falgravn Icons
---------------------------------------------------------------------
local falgravnEnabled = false

local function EnableFalgravnIcons()
    if (Crutch.savedOptions.kynesaegis.showFalgravnIcons) then
        falgravnEnabled = true
        Crutch.EnableIcon("Falgravn2ndFloor1")
        Crutch.EnableIcon("Falgravn2ndFloor2")
        Crutch.EnableIcon("Falgravn2ndFloor3")
        Crutch.EnableIcon("Falgravn2ndFloor4")
        Crutch.EnableIcon("Falgravn2ndFloorH1")
        Crutch.EnableIcon("Falgravn2ndFloorH2")
    end
end

local function DisableFalgravnIcons()
    falgravnEnabled = false
    Crutch.DisableIcon("Falgravn2ndFloor1")
    Crutch.DisableIcon("Falgravn2ndFloor2")
    Crutch.DisableIcon("Falgravn2ndFloor3")
    Crutch.DisableIcon("Falgravn2ndFloor4")
    Crutch.DisableIcon("Falgravn2ndFloorH1")
    Crutch.DisableIcon("Falgravn2ndFloorH2")
end

-- Enable Falgravn icons if the boss is present
local function TryEnablingFalgravnIcons()
    local _, powerMax, _ = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (powerMax == 248386064 -- Hardmode
        or powerMax == 124193032 -- Veteran
        or powerMax == 18177368) then -- Normal
        if (not falgravnEnabled) then
            EnableFalgravnIcons()
        end
    else
        if (falgravnEnabled) then
            DisableFalgravnIcons()
        end
    end
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
local function GetUnitNameIfExists(unitTag)
    if (DoesUnitExist(unitTag)) then
        return GetUnitName(unitTag)
    end
end

function Crutch.RegisterKynesAegis()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Kyne's Aegis")

    -- Prison icon
    if (Crutch.savedOptions.kynesaegis.showPrisonIcon) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "PrisonEffect", EVENT_EFFECT_CHANGED, OnPrisonEffect)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "PrisonEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 132473)
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "PrisonCast", EVENT_COMBAT_EVENT, OnPrisonBegin)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "PrisonCast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 132468)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "PrisonCast", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    end

    --Spear
    if (Crutch.savedOptions.kynesaegis.showSpearIcon) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ExplodingSpear", EVENT_COMBAT_EVENT, OnExplodingSpearBegin)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ExplodingSpear", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ExplodingSpear", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 133936)
    end

    -- Falgravn icons
    if (Crutch.savedOptions.kynesaegis.showFalgravnIcons) then
        TryEnablingFalgravnIcons()

        -- Show icons on Falgravn
        Crutch.RegisterBossChangedListener("CrutchKynesAegis", TryEnablingFalgravnIcons)
    end
end

function Crutch.UnregisterKynesAegis()
    -- Spear
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ExplodingSpear", EVENT_COMBAT_EVENT)

    -- Prison icon
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "PrisonEffect", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "PrisonCast", EVENT_COMBAT_EVENT)

    -- Falgravn icons
    Crutch.UnregisterBossChangedListener("CrutchKynesAegis")
    DisableFalgravnIcons()

    -- Clean up in case of PTE; unit tags may change
    Crutch.RemoveAllAttachedIcons(PRISON_UNIQUE_NAME)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Kyne's Aegis")
end
