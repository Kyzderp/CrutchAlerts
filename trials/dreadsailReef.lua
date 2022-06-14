CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

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

local numHearts = 0
local function OnHeartburn()
    numHearts = numHearts + 1

    local portalNumber = numHearts % 3
    if (portalNumber == 0) then portalNumber = 3 end
    Crutch.dbgOther(string.format("Reef Heart %d (Portal %d)", numHearts, portalNumber))
end

local function OnCombatStateChanged(_, inCombat)
    if (not inCombat) then
        Crutch.dbgSpam("Resetting reef hearts")
        numHearts = 0
    end
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterDreadsailReef()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRCombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    -- Lightning Stacks
    if (Crutch.savedOptions.dreadsailreef.alertStaticStacks) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED, OnLightningStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 163575)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED, OnLightningStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 169688)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
    end

    -- Heartburn (portal)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRPortal", EVENT_COMBAT_EVENT, OnHeartburn)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRPortal", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRPortal", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 163692)

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Dreadsail Reef")
end

function Crutch.UnregisterDreadsailReef()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRCombatState", EVENT_PLAYER_COMBAT_STATE)

    -- Lightning Stacks
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED)

    -- Heartburn (portal)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRPortal", EVENT_COMBAT_EVENT)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Dreadsail Reef")
end
