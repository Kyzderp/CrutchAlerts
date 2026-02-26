local Crutch = CrutchAlerts
local C = Crutch.Constants

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
            Crutch.DisplayProminent(C.ID.STATIC)
        end
    end
end

-- Display (and ding?) when reaching too many poison stacks
local function OnPoisonStacksChanged(_, changeType, _, _, _, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    if (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) then
        -- # of stacks that are dangerous probably depends on the role
        if (stackCount >= Crutch.savedOptions.dreadsailreef.volatileThreshold) then
            Crutch.DisplayProminent(C.ID.POISON)
        end
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
local CLEAVE_RADIUS = 3600 -- Radius of the donut
local INNER_RADIUS = 1500 -- Inner of donut
local CLEAVE_ANGLE = 25 / 180 * math.pi

-- Janky af geometry
local function GetArcingCleavePoints(sign)
    local _, tankX, _, tankZ = GetUnitRawWorldPosition(tankTag)

    -- Pretend there is a circle at CENTER_X, CENTER_Z
    local originTankX = tankX - CENTER_X
    local originTankZ = tankZ - CENTER_Z

    -- Find the angle to the current tank spot
    local angle = math.atan(originTankZ / originTankX)
    if (originTankX < 0) then
        angle = angle + math.pi
    end

    local newAngle = angle + (sign * CLEAVE_ANGLE)
    local x1 = CLEAVE_RADIUS * math.cos(newAngle)
    local z1 = CLEAVE_RADIUS * math.sin(newAngle)

    local x2 = INNER_RADIUS * math.cos(newAngle)
    local z2 = INNER_RADIUS * math.sin(newAngle)

    -- And add the center back
    return x1 + CENTER_X, z1 + CENTER_Z, x2 + CENTER_X, z2 + CENTER_Z
end


local cleaveEnabled = false

local function Uncleave()
    cleaveEnabled = false
    Crutch.RemoveLine(1)
    Crutch.RemoveLine(2)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ArcingCleaveTarget", EVENT_COMBAT_EVENT)
end

local function ShowArcingCleave(overrideX, overrideY, overrideZ, overrideRadius, overrideAngle)
    Uncleave()
    if (not Crutch.savedOptions.dreadsailreef.showArcingCleave) then
        return
    end
    cleaveEnabled = true

    if (overrideX) then CENTER_X = overrideX end
    if (overrideY) then CLEAVE_Y = overrideY end
    if (overrideZ) then CENTER_Z = overrideZ end
    if (overrideRadius) then CLEAVE_RADIUS = overrideRadius end
    if (overrideAngle) then CLEAVE_ANGLE = overrideAngle end


    -- Detect aggro
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ArcingCleaveTarget", EVENT_COMBAT_EVENT, OnArcingCleave)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ArcingCleaveTarget", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 163901)

    -- Draw lines
    Crutch.SetLineColor(1, 1, 0, 0.8, 0, false, 1)
    Crutch.DrawLineWithProvider(function()
        local startX, startZ, endX, endZ = GetArcingCleavePoints(1)
        return startX, CLEAVE_Y, startZ, endX, CLEAVE_Y, endZ
    end, 1)

    Crutch.SetLineColor(1, 1, 0, 0.8, 0, false, 2)
    Crutch.DrawLineWithProvider(function()
        local startX, startZ, endX, endZ = GetArcingCleavePoints(-1)
        return startX, CLEAVE_Y, startZ, endX, CLEAVE_Y, endZ
    end, 2)
end
Crutch.ShowArcingCleave = ShowArcingCleave
-- Linchal on mushroom patch
-- /script CrutchAlerts.ShowArcingCleave(57158, 19610,  96815, 3600, 25 / 180 * math.pi)
-- /script CrutchAlerts.ShowArcingCleave()

-- Enable Cleave lines if the boss is present
local function TryEnablingTaleriaCleave()
    local _, powerMax, _ = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (powerMax == 181632304 -- Hardmode
        or powerMax == 100906840 -- Veteran
        or powerMax == 29538220) then -- Normal
        if (not cleaveEnabled) then
            ShowArcingCleave()
        end
    else
        if (cleaveEnabled) then
            Uncleave()
        end
    end
end
Crutch.TryEnablingTaleriaCleave = TryEnablingTaleriaCleave


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
local function GetUnitNameIfExists(unitTag)
    if (DoesUnitExist(unitTag)) then
        return GetUnitName(unitTag)
    end
end

function Crutch.RegisterDreadsailReef()
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
    local showStatic
    if (IsConsoleUI()) then
        showStatic = Crutch.savedOptions.console.showProminent
    else
        showStatic = Crutch.savedOptions.dreadsailreef.alertStaticStacks
    end

    if (showStatic) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED, OnLightningStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 163575)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED, OnLightningStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 169688)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
    end

    -- Volatile Stacks
    local showVolatile
    if (IsConsoleUI()) then
        showVolatile = Crutch.savedOptions.console.showProminent
    else
        showVolatile = Crutch.savedOptions.dreadsailreef.alertVolatileStacks
    end

    if (showVolatile) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRVolatileBoss", EVENT_EFFECT_CHANGED, OnPoisonStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRVolatileBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 174835)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRVolatileBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRVolatileOther", EVENT_EFFECT_CHANGED, OnPoisonStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRVolatileOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 174932)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRVolatileOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
    end

    -- Taleria cleave
    Crutch.RegisterBossChangedListener("CrutchDreadsailReef", TryEnablingTaleriaCleave)

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Dreadsail Reef")
end

function Crutch.UnregisterDreadsailReef()
    -- Domes
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRDestructiveEmber", EVENT_EFFECT_CHANGED, OnDestructiveEmber)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRPiercingHailstone", EVENT_EFFECT_CHANGED, OnPiercingHailstone)

    -- Lightning Stacks
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED)

    -- Volatile Stacks
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRVolatileBoss", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRVolatileOther", EVENT_EFFECT_CHANGED)

    -- Taleria cleave
    Crutch.UnregisterBossChangedListener("CrutchDreadsailReef")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Dreadsail Reef")
end
