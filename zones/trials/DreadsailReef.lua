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
-- Taleria
---------------------------------------------------------------------
local tankTag = "player"

-- Whoever Taleria last targeted with light attack
local function OnArcingCleave(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    local unitTag = Crutch.groupIdToTag[targetUnitId]
    if (unitTag ~= tankTag) then
        Crutch.dbgOther(zo_strformat("tank changed to |cFFFF00<<1>>", GetUnitDisplayName(unitTag)))
        tankTag = unitTag
    end
end

-- Taleria center
local CENTER_X = 169731
local CLEAVE_Y = 36126
local CENTER_Z = 29956
local CLEAVE_RADIUS = 3700 -- Radius of the donut
local CLEAVE_ANGLE = 23.5 / 180 * math.pi

-- Janky af geometry
local function GetArcingCleavePoints()
    local _, tankX, _, tankZ = GetUnitRawWorldPosition(tankTag)

    -- Pretend there is a circle at CENTER_X, CENTER_Z
    local originTankX = tankX - CENTER_X
    local originTankZ = tankZ - CENTER_Z

    -- Find the angle to the current tank spot
    local angle = math.atan(originTankZ / originTankX)
    if (originTankX < 0) then
        angle = angle + math.pi
    end

    local x1 = CLEAVE_RADIUS * math.cos(angle + CLEAVE_ANGLE)
    local z1 = CLEAVE_RADIUS * math.sin(angle + CLEAVE_ANGLE)

    local x2 = CLEAVE_RADIUS * math.cos(angle - CLEAVE_ANGLE)
    local z2 = CLEAVE_RADIUS * math.sin(angle - CLEAVE_ANGLE)

    -- And add the center back
    return x1 + CENTER_X, z1 + CENTER_Z, x2 + CENTER_X, z2 + CENTER_Z
end

local function Uncleave()
    Crutch.RemoveLine(1)
    Crutch.RemoveLine(2)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ArcingCleaveTarget", EVENT_COMBAT_EVENT)
end

local function ShowArcingCleave(overrideX, overrideY, overrideZ, overrideRadius, overrideAngle)
    if (overrideX) then CENTER_X = overrideX end
    if (overrideY) then CLEAVE_Y = overrideY end
    if (overrideZ) then CENTER_Z = overrideZ end
    if (overrideRadius) then CLEAVE_RADIUS = overrideRadius end
    if (overrideAngle) then CLEAVE_ANGLE = overrideAngle end

    Uncleave()

    -- Detect aggro
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ArcingCleaveTarget", EVENT_COMBAT_EVENT, OnArcingCleave)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ArcingCleaveTarget", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 163901)

    -- Draw lines
    Crutch.SetLineColor(1, 1, 0, 0.8, 0, false, 1)
    Crutch.DrawLineWithProvider(function()
        local endX, endZ, _, _ = GetArcingCleavePoints()
        return CENTER_X, CLEAVE_Y, CENTER_Z, endX, CLEAVE_Y, endZ
    end, 1)

    Crutch.SetLineColor(1, 1, 0, 0.8, 0, false, 2)
    Crutch.DrawLineWithProvider(function()
        local _, _, endX, endZ = GetArcingCleavePoints()
        return CENTER_X, CLEAVE_Y, CENTER_Z, endX, CLEAVE_Y, endZ
    end, 2)
end
Crutch.ShowArcingCleave = ShowArcingCleave
-- Linchal on mushroom patch
-- /script CrutchAlerts.ShowArcingCleave(57158, 19610,  96815, 3000, 12 / 180 * math.pi)
-- /script CrutchAlerts.ShowArcingCleave(169744, 36126,  29980, 3700, 23.5 / 180 * math.pi)
-- /script CrutchAlerts.ShowArcingCleave()


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
