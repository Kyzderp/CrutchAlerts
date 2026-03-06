local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

local VISUALS = {
    [ATTRIBUTE_VISUAL_AUTOMATIC] = "AUTOMATIC",
    [ATTRIBUTE_VISUAL_DECREASED_MAX_POWER] = "DECREASED_MAX_POWER",
    [ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER] = "DECREASED_REGEN_POWER",
    [ATTRIBUTE_VISUAL_DECREASED_STAT] = "DECREASED_STAT",
    [ATTRIBUTE_VISUAL_FORCE_INCREASED_POWER_STAT_VISUAL] = "FORCE_INCREASED_POWER_STAT_VISUAL",
    [ATTRIBUTE_VISUAL_INCREASED_MAX_POWER] = "INCREASED_MAX_POWER",
    [ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER] = "INCREASED_REGEN_POWER",
    [ATTRIBUTE_VISUAL_INCREASED_STAT] = "INCREASED_STAT",
    [ATTRIBUTE_VISUAL_NONE] = "NONE",
    [ATTRIBUTE_VISUAL_NO_HEALING] = "NO_HEALING",
    [ATTRIBUTE_VISUAL_POSSESSION] = "POSSESSION",
    [ATTRIBUTE_VISUAL_POWER_SHIELDING] = "POWER_SHIELDING",
    [ATTRIBUTE_VISUAL_TRAUMA] = "TRAUMA",
    [ATTRIBUTE_VISUAL_UNWAVERING_POWER] = "UNWAVERING_POWER",
}

local STAT_TYPES = {
    [STAT_ARMOR_RATING] = "ARMOR_RATING",
    [STAT_ATTACK_POWER] = "ATTACK_POWER",
    [STAT_BLOCK] = "BLOCK",
    [STAT_CRITICAL_CHANCE] = "CRITICAL_CHANCE",
    [STAT_CRITICAL_RESISTANCE] = "CRITICAL_RESISTANCE",
    [STAT_CRITICAL_STRIKE] = "CRITICAL_STRIKE",
    [STAT_DAMAGE_RESIST_BLEED] = "DAMAGE_RESIST_BLEED",
    [STAT_DAMAGE_RESIST_COLD] = "DAMAGE_RESIST_COLD",
    [STAT_DAMAGE_RESIST_DISEASE] = "DAMAGE_RESIST_DISEASE",
    [STAT_DAMAGE_RESIST_DROWN] = "DAMAGE_RESIST_DROWN",
    [STAT_DAMAGE_RESIST_EARTH] = "DAMAGE_RESIST_EARTH",
    [STAT_DAMAGE_RESIST_FIRE] = "DAMAGE_RESIST_FIRE",
    [STAT_DAMAGE_RESIST_GENERIC] = "DAMAGE_RESIST_GENERIC",
    [STAT_DAMAGE_RESIST_MAGIC] = "DAMAGE_RESIST_MAGIC",
    [STAT_DAMAGE_RESIST_OBLIVION] = "DAMAGE_RESIST_OBLIVION",
    [STAT_DAMAGE_RESIST_PHYSICAL] = "DAMAGE_RESIST_PHYSICAL",
    [STAT_DAMAGE_RESIST_POISON] = "DAMAGE_RESIST_POISON",
    [STAT_DAMAGE_RESIST_SHOCK] = "DAMAGE_RESIST_SHOCK",
    [STAT_DAMAGE_RESIST_START] = "DAMAGE_RESIST_START",
    [STAT_DEPRECATED_0] = "DEPRECATED_0",
    [STAT_DEPRECATED_1] = "DEPRECATED_1",
    [STAT_DEPRECATED_2] = "DEPRECATED_2",
    [STAT_DEPRECATED_3] = "DEPRECATED_3",
    [STAT_DODGE] = "DODGE",
    [STAT_HEALING_DONE] = "HEALING_DONE",
    [STAT_HEALING_TAKEN] = "HEALING_TAKEN",
    [STAT_HEALTH_MAX] = "HEALTH_MAX",
    [STAT_HEALTH_REGEN_COMBAT] = "HEALTH_REGEN_COMBAT",
    [STAT_HEALTH_REGEN_IDLE] = "HEALTH_REGEN_IDLE",
    [STAT_MAGICKA_MAX] = "MAGICKA_MAX",
    [STAT_MAGICKA_REGEN_COMBAT] = "MAGICKA_REGEN_COMBAT",
    [STAT_MAGICKA_REGEN_IDLE] = "MAGICKA_REGEN_IDLE",
    [STAT_MISS] = "MISS",
    [STAT_MITIGATION] = "MITIGATION",
    [STAT_MOUNT_STAMINA_MAX] = "MOUNT_STAMINA_MAX",
    [STAT_MOUNT_STAMINA_REGEN_COMBAT] = "MOUNT_STAMINA_REGEN_COMBAT",
    [STAT_MOUNT_STAMINA_REGEN_MOVING] = "MOUNT_STAMINA_REGEN_MOVING",
    [STAT_NONE] = "NONE",
    [STAT_OFFENSIVE_PENETRATION] = "OFFENSIVE_PENETRATION",
    [STAT_PHYSICAL_PENETRATION] = "PHYSICAL_PENETRATION",
    [STAT_PHYSICAL_RESIST] = "PHYSICAL_RESIST",
    [STAT_POWER] = "POWER",
    [STAT_SPELL_CRITICAL] = "SPELL_CRITICAL",
    [STAT_SPELL_MITIGATION] = "SPELL_MITIGATION",
    [STAT_SPELL_PENETRATION] = "SPELL_PENETRATION",
    [STAT_SPELL_POWER] = "SPELL_POWER",
    [STAT_SPELL_RESIST] = "SPELL_RESIST",
    [STAT_STAMINA_MAX] = "STAMINA_MAX",
    [STAT_STAMINA_REGEN_COMBAT] = "STAMINA_REGEN_COMBAT",
    [STAT_STAMINA_REGEN_IDLE] = "STAMINA_REGEN_IDLE",
    [STAT_WEAPON_AND_SPELL_DAMAGE] = "WEAPON_AND_SPELL_DAMAGE",
}

local ATTRIBUTES = {
    [ATTRIBUTE_HEALTH] = "HEALTH",
    [ATTRIBUTE_MAGICKA] = "MAGICKA",
    [ATTRIBUTE_NONE] = "NONE",
    [ATTRIBUTE_STAMINA] = "STAMINA",
}

local POWER_TYPES = {
    [COMBAT_MECHANIC_FLAGS_DAEDRIC] = "DAEDRIC",
    [COMBAT_MECHANIC_FLAGS_HEALTH] = "HEALTH",
    [COMBAT_MECHANIC_FLAGS_MAGICKA] = "MAGICKA",
    [COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA] = "MOUNT_STAMINA",
    [COMBAT_MECHANIC_FLAGS_STAMINA] = "STAMINA",
    [COMBAT_MECHANIC_FLAGS_ULTIMATE] = "ULTIMATE",
    [COMBAT_MECHANIC_FLAGS_WEREWOLF] = "WEREWOLF",
}

--[[
h5. UnitAttributeVisual
* ATTRIBUTE_VISUAL_AUTOMATIC
* ATTRIBUTE_VISUAL_DECREASED_MAX_POWER
* ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER
* ATTRIBUTE_VISUAL_DECREASED_STAT
* ATTRIBUTE_VISUAL_FORCE_INCREASED_POWER_STAT_VISUAL
* ATTRIBUTE_VISUAL_INCREASED_MAX_POWER
* ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER
* ATTRIBUTE_VISUAL_INCREASED_STAT
* ATTRIBUTE_VISUAL_NONE
* ATTRIBUTE_VISUAL_NO_HEALING
* ATTRIBUTE_VISUAL_POSSESSION
* ATTRIBUTE_VISUAL_POWER_SHIELDING
* ATTRIBUTE_VISUAL_TRAUMA
* ATTRIBUTE_VISUAL_UNWAVERING_POWER


* GetAllUnitAttributeVisualizerEffectInfo(*string* _unitTag_)
** _Uses variable returns..._
** _Returns:_ *[UnitAttributeVisual|#UnitAttributeVisual]* _unitAttributeVisual_, *[DerivedStats|#DerivedStats]* _statType_, *[Attributes|#Attributes]* _attributeType_, *[CombatMechanicFlags|#CombatMechanicFlags]* _powerType_, *number* _value_, *number* _maxValue_

* GetUnitAttributeVisualizerEffectInfo(*string* _unitTag_, *[UnitAttributeVisual|#UnitAttributeVisual]* _unitAttributeVisual_, *[DerivedStats|#DerivedStats]* _statType_, *[Attributes|#Attributes]* _attributeType_, *[CombatMechanicFlags|#CombatMechanicFlags]* _powerType_)
** _Returns:_ *number:nilable* _value_, *number:nilable* _maxValue_, *integer:nilable* _sequenceId_


* EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED (*string* _unitTag_, *[UnitAttributeVisual|#UnitAttributeVisual]* _unitAttributeVisual_, *[DerivedStats|#DerivedStats]* _statType_, *[Attributes|#Attributes]* _attributeType_, *[CombatMechanicFlags|#CombatMechanicFlags]* _powerType_, *number* _value_, *number* _maxValue_, *integer* _sequenceId_)
* EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED (*string* _unitTag_, *[UnitAttributeVisual|#UnitAttributeVisual]* _unitAttributeVisual_, *[DerivedStats|#DerivedStats]* _statType_, *[Attributes|#Attributes]* _attributeType_, *[CombatMechanicFlags|#CombatMechanicFlags]* _powerType_, *number* _value_, *number* _maxValue_, *integer* _sequenceId_)
* EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED (*string* _unitTag_, *[UnitAttributeVisual|#UnitAttributeVisual]* _unitAttributeVisual_, *[DerivedStats|#DerivedStats]* _statType_, *[Attributes|#Attributes]* _attributeType_, *[CombatMechanicFlags|#CombatMechanicFlags]* _powerType_, *number* _oldValue_, *number* _newValue_, *number* _oldMaxValue_, *number* _newMaxValue_, *integer* _sequenceId_)
]]

local BARS = {
    [ATTRIBUTE_VISUAL_POWER_SHIELDING] = "Shield",
    [ATTRIBUTE_VISUAL_UNWAVERING_POWER] = "Invuln",
}

local function GetSubBar(unitTag, unitAttributeVisual)
    local index = tonumber(unitTag:sub(5, 5))
    local statusBar = CrutchAlertsBossHealthBarContainer:GetNamedChild("Bar" .. tostring(index))
    if (statusBar) then
        return statusBar:GetNamedChild(BARS[unitAttributeVisual])
    end
end

local function UpdateBar(unitTag, unitAttributeVisual, hide, value, maxValue)
    local subBar = GetSubBar(unitTag, unitAttributeVisual)
    if (not subBar) then
        Crutch.dbgOther(BARS[unitAttributeVisual] .. " bar doesn't exist for " .. unitTag .. "?!")
        return
    end

    subBar:SetHidden(hide)
    ZO_StatusBar_SmoothTransition(subBar, value, maxValue)
end

local function OnVisualAdded(_, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    if (unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING and unitAttributeVisual ~= ATTRIBUTE_VISUAL_UNWAVERING_POWER) then return end

    Crutch.dbgOther(zo_strformat("ADDED <<1>> - visual: <<2>>, statType: <<3>>, attributeType: <<4>>, powerType: <<5>>, value/max: <<6>> / <<7>>, sequenceId: <<8>>", unitTag, VISUALS[unitAttributeVisual], STAT_TYPES[statType], ATTRIBUTES[attributeType], POWER_TYPES[powerType], value, maxValue, sequenceId))

    UpdateBar(unitTag, unitAttributeVisual, false, value, maxValue)
end

local function OnVisualRemoved(_, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    if (unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING and unitAttributeVisual ~= ATTRIBUTE_VISUAL_UNWAVERING_POWER) then return end

    Crutch.dbgOther(zo_strformat("REMOVED <<1>> - visual: <<2>>, statType: <<3>>, attributeType: <<4>>, powerType: <<5>>, value/max: <<6>> / <<7>>, sequenceId: <<8>>", unitTag, VISUALS[unitAttributeVisual], STAT_TYPES[statType], ATTRIBUTES[attributeType], POWER_TYPES[powerType], value, maxValue, sequenceId))

    UpdateBar(unitTag, unitAttributeVisual, true, value, maxValue)
end

local function OnVisualUpdated(_, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
    if (unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING and unitAttributeVisual ~= ATTRIBUTE_VISUAL_UNWAVERING_POWER) then return end

    Crutch.dbgOther(zo_strformat("UPDATED <<1>> - visual: <<2>>, statType: <<3>>, attributeType: <<4>>, powerType: <<5>>, value/max: <<6>> / <<7>> -> <<8>> / <<9>>, sequenceId: <<10>>", unitTag, VISUALS[unitAttributeVisual], STAT_TYPES[statType], ATTRIBUTES[attributeType], POWER_TYPES[powerType], oldValue, newValue, oldMaxValue, newMaxValue, sequenceId))

    UpdateBar(unitTag, unitAttributeVisual, false, newValue, newMaxValue)
end

function BHB.RegisterVisualizers()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "BHBAttrVisualAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnVisualAdded)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BHBAttrVisualAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "BHBAttrVisualRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnVisualRemoved)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BHBAttrVisualRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "BHBAttrVisualUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnVisualUpdated)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BHBAttrVisualUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
end

function BHB.UnregisterVisualizers()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "BHBAttrVisualAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "BHBAttrVisualRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "BHBAttrVisualUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)
end