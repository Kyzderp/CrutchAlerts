CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Twins
---------------------------------------------------------------------
local function OnDestructiveEmber(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    if (changeType == EFFECT_RESULT_GAINED) then
        Crutch.msg(zo_strformat("<<1>> picked up |cff6600fire dome", GetUnitDisplayName(unitTag)))
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.msg(zo_strformat("<<1>> put away |cff6600fire dome", GetUnitDisplayName(unitTag)))
    end
end

local function OnPiercingHailstone(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    if (changeType == EFFECT_RESULT_GAINED) then
        Crutch.msg(zo_strformat("<<1>> picked up |c8ef5f5ice dome", GetUnitDisplayName(unitTag)))
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.msg(zo_strformat("<<1>> put away |c8ef5f5ice dome", GetUnitDisplayName(unitTag)))
    end
end


---------------------------------------------------------------------
-- Reef Guardian
---------------------------------------------------------------------
-- Display (and ding?) when reaching too many lightning stacks
-- Zaps seem to come every 3.3 seconds
local function OnLightningStacksChanged(_, changeType, _, _, _, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    if (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) then
        -- # of stacks that are dangerous probably depends on the role
        if (stackCount >= Crutch.savedOptions.dreadsailreef.staticThreshold) then
            Crutch.DisplayProminent(888004)
        end
    end
end

-- Display (and ding?) when reaching too many poison stacks
local function OnPoisonStacksChanged(_, changeType, _, _, _, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    if (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) then
        -- # of stacks that are dangerous probably depends on the role
        if (stackCount >= Crutch.savedOptions.dreadsailreef.volatileThreshold) then
            Crutch.DisplayProminent(888006)
        end
    end
end

local numHearts = 0
local function OnHeartburn()
    numHearts = numHearts + 1

    local portalNumber = numHearts % 3
    if (portalNumber == 0) then portalNumber = 3 end
    Crutch.dbgOther(string.format("Reef Heart %d (Portal %d)", numHearts, portalNumber))
end

local function OnCombatStateChanged(_, inCombat)
    if (not inCombat) then
        -- Need to call later because combat briefly stops when accepting a rez during combat
        zo_callLater(function()
            if (not IsUnitInCombat("player")) then
                Crutch.dbgSpam("Resetting reef hearts")
                numHearts = 0
            end
        end, 3000)
    end
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterDreadsailReef()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRCombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    -- Chat output for who picks up domes
    if (Crutch.savedOptions.general.showRaidDiag) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRDestructiveEmber", EVENT_EFFECT_CHANGED, OnDestructiveEmber)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRDestructiveEmber", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 166209)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRDestructiveEmber", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRPiercingHailstone", EVENT_EFFECT_CHANGED, OnPiercingHailstone)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRPiercingHailstone", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 166178)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRPiercingHailstone", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    end

    -- Lightning Stacks
    if (Crutch.savedOptions.dreadsailreef.alertStaticStacks) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED, OnLightningStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 163575)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED, OnLightningStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 169688)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
    end

    -- Volatile Stacks
    if (Crutch.savedOptions.dreadsailreef.alertVolatileStacks) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRVolatileBoss", EVENT_EFFECT_CHANGED, OnPoisonStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRVolatileBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 174835)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRVolatileBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRVolatileOther", EVENT_EFFECT_CHANGED, OnPoisonStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRVolatileOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 174932)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRVolatileOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
    end

    -- Heartburn (portal)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRPortal", EVENT_COMBAT_EVENT, OnHeartburn)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRPortal", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRPortal", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 163692)

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Dreadsail Reef")
end

function Crutch.UnregisterDreadsailReef()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRCombatState", EVENT_PLAYER_COMBAT_STATE)

    -- Domes
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRDestructiveEmber", EVENT_EFFECT_CHANGED, OnDestructiveEmber)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRPiercingHailstone", EVENT_EFFECT_CHANGED, OnPiercingHailstone)

    -- Lightning Stacks
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED)

    -- Volatile Stacks
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRVolatileBoss", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRVolatileOther", EVENT_EFFECT_CHANGED)

    -- Heartburn (portal)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRPortal", EVENT_COMBAT_EVENT)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Dreadsail Reef")
end
