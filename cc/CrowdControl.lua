local Crutch = CrutchAlerts

local MECHANIC_FLAGS = {
    [COMBAT_MECHANIC_FLAGS_DAEDRIC] = "DAEDRIC",
    [COMBAT_MECHANIC_FLAGS_HEALTH] = "HEALTH",
    [COMBAT_MECHANIC_FLAGS_MAGICKA] = "MAGICKA",
    [COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA] = "MOUNT_STAMINA",
    [COMBAT_MECHANIC_FLAGS_STAMINA] = "STAMINA",
    [COMBAT_MECHANIC_FLAGS_ULTIMATE] = "ULTIMATE",
    [COMBAT_MECHANIC_FLAGS_WEREWOLF] = "WEREWOLF",
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
    [ACTION_RESULT_DISORIENTED] = {display = "DISORIENTED", type = HARD},
    [ACTION_RESULT_LEVITATED] = {display = "LEVITATED", type = HARD},
    [ACTION_RESULT_SILENCED] = {display = "SILENCED", type = SOFT},

    -- verified
    [ACTION_RESULT_CHARMED] = {display = "CHARMED", type = HARD},
    [ACTION_RESULT_FEARED] = {display = "FEARED", type = HARD},
    [ACTION_RESULT_STUNNED] = {display = "STUNNED", type = HARD},

    [ACTION_RESULT_KNOCKBACK] = {display = "KNOCKBACK", type = SOFT},
    [ACTION_RESULT_ROOTED] = {display = "ROOTED", type = IMMOB},
    [ACTION_RESULT_SNARED] = {display = "SNARED", type = SOFT},
    [ACTION_RESULT_STAGGERED] = {display = "STAGGERED", type = SOFT},
}

-- "volume" is just the number of times to play it at the same time lol
local TYPE_OPTIONS = {
    [HARD] = {color = "FF0000", showVisual = true, sound = SOUNDS.DEATH_RECAP_KILLING_BLOW_SHOWN, volume = 2},
    [IMMOB] = {color = "FF5500", showVisual = false},
    [SOFT] = {color = "FFAA00", showVisual = false},
}

-- Some abilities shouldn't be shown or shouldn't play sound,
-- because they're spammy or can't break free anyway
local SUPPRESS = 1
local SILENT = 2
local CC_ABILITY_DATA = {
    [166794] = SUPPRESS, -- Current (DSR)
}


---------------------------------------------------------------------
-- CC begin
---------------------------------------------------------------------
-- When the player is cced, we also want to know the duration of the
-- cc, but this isn't provided in the ACTION_RESULT_STUNNED event. So
-- we'll keep track of the last ability that stunned/feared/etc., and
-- when the duration is received (should be immediately after), only
-- then display the visual.
local recentCCs = {} -- {[abilityId] = {result = ACTION_RESULT_STUNNED, time = 12355436}}

-- Tracking for initial stunned/feared/etc. result
-- EVENT_COMBAT_EVENT (*[ActionResult|#ActionResult]* _result_, *bool* _isError_, *string* _abilityName_, *integer* _abilityGraphic_, *[ActionSlotType|#ActionSlotType]* _abilityActionSlotType_, *string* _sourceName_, *[CombatUnitType|#CombatUnitType]* _sourceType_, *string* _targetName_, *[CombatUnitType|#CombatUnitType]* _targetType_, *integer* _hitValue_, *[CombatMechanicFlags|#CombatMechanicFlags]* _powerType_, *[DamageType|#DamageType]* _damageType_, *bool* _log_, *integer* _sourceUnitId_, *integer* _targetUnitId_, *integer* _abilityId_, *integer* _overflow_)
local function OnCombatEvent(_, result, _, _, _, _, sourceName, sourceType, _, _, hitValue, powerType, _, _, sourceUnitId, targetUnitId, abilityId)
    local options = CC_OPTIONS[result]
    if (not options) then return end

    local typeOptions = TYPE_OPTIONS[options.type]

    if (options.display) then
        local textColor = ""
        if (sourceType == COMBAT_UNIT_TYPE_PLAYER) then
            textColor = "|c888888"
        elseif (sourceType == COMBAT_UNIT_TYPE_GROUP) then
            textColor = "|cFF00FF"
        end
        Crutch.dbgOther(string.format("cc |c%s%s|r %s%s (%d) %d from %s (%s) - %s",
            typeOptions.color,
            options.display,
            textColor,
            GetAbilityName(abilityId),
            abilityId,
            hitValue,
            sourceName,
            UNIT_TYPES[sourceType] or "???",
            MECHANIC_FLAGS[powerType] or "???"))
    end

    -- Manual blacklist
    local abilityData = CC_ABILITY_DATA[abilityId]
    if (abilityData == SUPPRESS) then return end

    -- If source type is player, it's usually player trying to cast stuff while stunned
    -- It could be self stuns like entering portals but that doesn't need alerts
    -- Sometimes they come from GROUP too, like radiating regen and meridia's favor, for some reason
    -- So just stick to strictly enemy NONE for now
    if (sourceType ~= COMBAT_UNIT_TYPE_NONE) then return end

    if (typeOptions.sound and abilityData ~= SILENT) then
        for i = 1, typeOptions.volume do
            PlaySound(typeOptions.sound)
        end
    end

    if (typeOptions.showVisual) then
        -- Only care about getting the duration if we will show the visual
        recentCCs[abilityId] = {
            result = result,
            time = GetGameTimeMilliseconds(),
        }
    end
end

-- Tracking for cc duration
local function OnEffectGainedDuration(_, _, _, _, _, _, sourceName, _, _, _, hitValue, _, _, _, sourceUnitId, _, abilityId)
    local cc = recentCCs[abilityId]
    if (not cc) then return end

    -- This *seems* to only happen if it's a "fake" stun
    if (GetGameTimeMilliseconds() - cc.time > 100) then
        recentCCs[abilityId] = nil
        Crutch.dbgOther("|cFF0000CC effect duration received " .. (GetGameTimeMilliseconds() - cc.time) .. "ms after initial?!")
        return
    end

    Crutch.OnHardCCed(abilityId, cc.result, hitValue, sourceName)
end

---------------------------------------------------------------------
-- CC removal
---------------------------------------------------------------------
local function OnStunnedChanged(_, playerStunned)
    if (playerStunned) then
        Crutch.dbgOther("player stunned")
        Crutch.OnStunned()
    else
        Crutch.dbgOther("player no longer stunned")
        Crutch.OnNotStunned()
    end
end
-- TODO: enemy died seems to unstun? aspect of terror


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Crutch.InitializeCC()
    -- EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CC", EVENT_EFFECT_CHANGED, OnEffectChanged)
    -- EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CC", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CC", EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CC", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CCDuration", EVENT_COMBAT_EVENT, OnEffectGainedDuration)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CCDuration", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CCDuration", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CCStunnedChanged", EVENT_PLAYER_STUNNED_STATE_CHANGED, OnStunnedChanged)
end
