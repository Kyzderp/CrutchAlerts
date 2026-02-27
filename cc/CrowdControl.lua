local Crutch = CrutchAlerts


---------------------------------------------------------------------
local CHANGE_TYPES = {
    [EFFECT_RESULT_FADED] = "FADED",
    [EFFECT_RESULT_FULL_REFRESH] = "FULL_REFRESH",
    [EFFECT_RESULT_GAINED] = "GAINED",
    [EFFECT_RESULT_TRANSFER] = "TRANSFER",
    [EFFECT_RESULT_UPDATED] = "UPDATED",
}

local STATUS_EFFECT_TYPES = {
    [STATUS_EFFECT_TYPE_BLEED] = "BLEED",
    [STATUS_EFFECT_TYPE_BLIND] = "BLIND",
    [STATUS_EFFECT_TYPE_CHARM] = "CHARM",
    [STATUS_EFFECT_TYPE_DAZED] = "DAZED",
    [STATUS_EFFECT_TYPE_DISEASE] = "DISEASE",
    [STATUS_EFFECT_TYPE_ENVIRONMENT] = "ENVIRONMENT",
    [STATUS_EFFECT_TYPE_FEAR] = "FEAR",
    [STATUS_EFFECT_TYPE_LEVITATE] = "LEVITATE",
    [STATUS_EFFECT_TYPE_MAGIC] = "MAGIC",
    [STATUS_EFFECT_TYPE_MESMERIZE] = "MESMERIZE",
    [STATUS_EFFECT_TYPE_NEARSIGHT] = "NEARSIGHT",
    [STATUS_EFFECT_TYPE_NONE] = "NONE",
    [STATUS_EFFECT_TYPE_PACIFY] = "PACIFY",
    [STATUS_EFFECT_TYPE_POISON] = "POISON",
    [STATUS_EFFECT_TYPE_PUNCTURE] = "PUNCTURE",
    [STATUS_EFFECT_TYPE_ROOT] = "ROOT",
    [STATUS_EFFECT_TYPE_SILENCE] = "SILENCE",
    [STATUS_EFFECT_TYPE_SNARE] = "SNARE",
    [STATUS_EFFECT_TYPE_STUN] = "STUN",
    [STATUS_EFFECT_TYPE_TRAUMA] = "TRAUMA",
    [STATUS_EFFECT_TYPE_WEAKNESS] = "WEAKNESS",
    [STATUS_EFFECT_TYPE_WOUND] = "WOUND",
}

local CCTYPES = {
    [STATUS_EFFECT_TYPE_CHARM] = "CHARM",
    [STATUS_EFFECT_TYPE_DAZED] = "DAZED",
    [STATUS_EFFECT_TYPE_ENVIRONMENT] = "ENVIRONMENT",
    [STATUS_EFFECT_TYPE_FEAR] = "FEAR",
    [STATUS_EFFECT_TYPE_LEVITATE] = "LEVITATE",
    [STATUS_EFFECT_TYPE_MAGIC] = "MAGIC",
    [STATUS_EFFECT_TYPE_MESMERIZE] = "MESMERIZE",
    [STATUS_EFFECT_TYPE_NEARSIGHT] = "NEARSIGHT",
    [STATUS_EFFECT_TYPE_PACIFY] = "PACIFY",
    [STATUS_EFFECT_TYPE_PUNCTURE] = "PUNCTURE",
    [STATUS_EFFECT_TYPE_ROOT] = "ROOT",
    [STATUS_EFFECT_TYPE_SILENCE] = "SILENCE",
    [STATUS_EFFECT_TYPE_SNARE] = "SNARE",
    [STATUS_EFFECT_TYPE_STUN] = "STUN",
    [STATUS_EFFECT_TYPE_WEAKNESS] = "WEAKNESS",
    [STATUS_EFFECT_TYPE_WOUND] = "WOUND",
}

---------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED (*[EffectResult|#EffectResult]* _changeType_, *integer* _effectSlot_, *string* _effectName_, *string* _unitTag_, *number* _beginTime_, *number* _endTime_, *integer* _stackCount_, *string* _iconName_, *string* _deprecatedBuffType_, *[BuffEffectType|#BuffEffectType]* _effectType_, *[AbilityType|#AbilityType]* _abilityType_, *[StatusEffectType|#StatusEffectType]* _statusEffectType_, *string* _unitName_, *integer* _unitId_, *integer* _abilityId_, *[CombatUnitType|#CombatUnitType]* _sourceType_)
local function OnEffectChanged(_, changeType, _, _, _, beginTime, endTime, stackCount, _, _, _, _, statusEffectType, _, _, abilityId)
    local changeTypeString = CHANGE_TYPES[changeType]
    Crutch.dbgOther(string.format("effect %s |cff0000%s|r %f %d - %s (%d)", changeTypeString, statusEffectType and STATUS_EFFECT_TYPES[statusEffectType] or "???", endTime - beginTime, stackCount, GetAbilityName(abilityId), abilityId))
    if (changeType ~= EFFECT_RESULT_GAINED and changeType ~= EFFECT_RESULT_UPDATED) then return end -- TODO: remove also when faded

    local ccType = CCTYPES[statusEffectType]
    if (not ccType) then return end

    Crutch.dbgOther(string.format("cc %s |cff0000%s|r %f %d - %s (%d)", changeTypeString, ccType or "???", endTime - beginTime, stackCount, GetAbilityName(abilityId), abilityId))
end

local CC_RESULTS = {
    [ACTION_RESULT_CHARMED] = "CHARMED",
    [ACTION_RESULT_DISORIENTED] = "DISORIENTED",
    [ACTION_RESULT_INTERRUPT] = "INTERRUPT",
    [ACTION_RESULT_LEVITATED] = "LEVITATED",
    [ACTION_RESULT_SILENCED] = "SILENCED",

    -- verified
    [ACTION_RESULT_FEARED] = "FEARED",
    [ACTION_RESULT_KNOCKBACK] = "KNOCKBACK", -- TODO: probably not necessary. stampede is a knockback lol
    [ACTION_RESULT_ROOTED] = "ROOTED",
    -- [ACTION_RESULT_SNARED] = "SNARED",
    [ACTION_RESULT_STAGGERED] = "STAGGERED",
    [ACTION_RESULT_STUNNED] = "STUNNED",
}

local UNIT_TYPES = {
    [COMBAT_UNIT_TYPE_GROUP] = "GROUP",
    [COMBAT_UNIT_TYPE_NONE] = "NONE",
    [COMBAT_UNIT_TYPE_OTHER] = "OTHER",
    [COMBAT_UNIT_TYPE_PLAYER] = "PLAYER",
    [COMBAT_UNIT_TYPE_PLAYER_COMPANION] = "PLAYER_COMPANION",
    [COMBAT_UNIT_TYPE_PLAYER_PET] = "PLAYER_PET",
    [COMBAT_UNIT_TYPE_TARGET_DUMMY] = "TARGET_DUMMY",
}

local HARD = "hard"
local IMMOB = "immobilize"
local SOFT = "soft"

local CC_OPTIONS = {
    [ACTION_RESULT_CHARMED] = {display = "CHARMED", type = HARD},
    [ACTION_RESULT_DISORIENTED] = {display = "DISORIENTED", type = HARD},
    [ACTION_RESULT_LEVITATED] = {display = "LEVITATED", type = HARD},
    [ACTION_RESULT_SILENCED] = {display = "SILENCED", type = SOFT},

    -- verified
    [ACTION_RESULT_FEARED] = {display = "FEARED", type = HARD},
    [ACTION_RESULT_KNOCKBACK] = {display = "KNOCKBACK", type = SOFT},
    [ACTION_RESULT_ROOTED] = {display = "ROOTED", type = IMMOB},
    [ACTION_RESULT_SNARED] = {display = "SNARED", type = SOFT},
    [ACTION_RESULT_STAGGERED] = {display = "STAGGERED", type = SOFT},
    [ACTION_RESULT_STUNNED] = {display = "STUNNED", type = HARD},
}

-- "volume" is just the number of times to play it at the same time lol
local TYPE_OPTIONS = {
    [HARD] = {color = "FF0000", showVisual = true, sound = SOUNDS.DEATH_RECAP_KILLING_BLOW_SHOWN, volume = 2},
    [IMMOB] = {color = "FF5500", showVisual = false},
    [SOFT] = {color = "FFAA00", showVisual = false},
}

--* EVENT_COMBAT_EVENT (*[ActionResult|#ActionResult]* _result_, *bool* _isError_, *string* _abilityName_, *integer* _abilityGraphic_, *[ActionSlotType|#ActionSlotType]* _abilityActionSlotType_, *string* _sourceName_, *[CombatUnitType|#CombatUnitType]* _sourceType_, *string* _targetName_, *[CombatUnitType|#CombatUnitType]* _targetType_, *integer* _hitValue_, *[CombatMechanicFlags|#CombatMechanicFlags]* _powerType_, *[DamageType|#DamageType]* _damageType_, *bool* _log_, *integer* _sourceUnitId_, *integer* _targetUnitId_, *integer* _abilityId_, *integer* _overflow_)
local function OnCombatEvent(_, result, _, _, _, _, sourceName, sourceType, _, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    local ccResult = CC_RESULTS[result]
    if (not ccResult) then return end

    local options = CC_OPTIONS[result]
    local typeOptions = TYPE_OPTIONS[options.type]

    if (options.display) then
        local textColor = ""
        if (sourceType == COMBAT_UNIT_TYPE_PLAYER) then
            textColor = "|c888888"
        elseif (sourceType == COMBAT_UNIT_TYPE_GROUP) then
            textColor = "|cFF00FF"
        end
        Crutch.dbgOther(string.format("cc |c%s%s|r %s%s (%d) %d from %s (%s)",
            typeOptions.color,
            options.display,
            textColor,
            GetAbilityName(abilityId),
            abilityId,
            hitValue,
            sourceName,
            UNIT_TYPES[sourceType] or "???"))
    end

    -- If source type is player, it's usually player trying to cast stuff while stunned
    -- It could be self stuns like entering portals but that doesn't need alerts
    -- Sometimes they come from GROUP too, like radiating regen and meridia's favor, for some reason
    -- So just stick to strictly enemy NONE for now
    if (sourceType ~= COMBAT_UNIT_TYPE_NONE) then return end

    if (typeOptions.sound) then
        for i = 1, typeOptions.volume do
            PlaySound(typeOptions.sound)
        end
    end

    if (typeOptions.showVisual) then
        Crutch.OnHardCCed(abilityId)
    end
end

function Crutch.InitializeCC()
    -- EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CC", EVENT_EFFECT_CHANGED, OnEffectChanged)
    -- EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CC", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CC", EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CC", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end
