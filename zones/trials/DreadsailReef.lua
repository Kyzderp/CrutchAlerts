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

local twinsThresholds = {
    normHealth = 10906420,
    vetHealth = 27943440,
    hmHealth = 55886880,
    ["Normal"] = {
        [90] = "Atronach",
        [80] = "Atronach",
        [70] = "2nd Teleports",
        [65] = "1st Teleports",
        boss1 = {},
        boss2 = {},
    },
    ["Veteran"] = {
        [90] = "Atronach",
        [80] = "Atronach",
        [70] = "2nd Teleports",
        [65] = "1st Teleports",
        boss1 = {},
        boss2 = {},
    },
    ["Hardmode"] = {
        [90] = "Same-color Atro",
        [85] = "Off-color Atro",
        [80] = "Same-color Atro",
        [75] = "Off-color Atro",
        [70] = "2nd Teleports",
        [65] = "1st Teleports",
        boss1 = {},
        boss2 = {},
    }
}

-- Unsure if Turli bar only shows up when nearing arena? or when he starts talking?
-- When a boss' health drops below max, we know it's the twin that's active
local function OnBossHealthDrop(_, unitTag, _, _, powerValue, powerMax, powerEffectiveMax)
    if (not IsUnitInCombat("player")) then return end -- Boss health can change due to turning on HM

    if (powerValue >= powerMax) then return end

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRTwinsHealth", EVENT_POWER_UPDATE)
    Crutch.dbgOther(unitTag .. " damaged")

    local DIFFICULTIES = {"Normal", "Veteran", "Hardmode"}
    for _, difficulty in ipairs(DIFFICULTIES) do
        for i = 1, 2 do
            local boss = "boss" .. i
            local tab = twinsThresholds[difficulty][boss]
            ZO_ClearTable(tab)

            if (difficulty == "Normal" or difficulty == "Veteran") then
                tab[90] = "Atronach"
                tab[80] = "Atronach"
            else
                tab[90] = "Same-color Atro"
                tab[85] = "Off-color Atro"
                tab[80] = "Same-color Atro"
                tab[75] = "Off-color Atro"
            end

            -- The boss that was damaged first will have the 65% teleport
            if (boss == unitTag) then
                tab[65] = "1st Teleports"
            else
                tab[70] = "2nd Teleports"
            end
        end
    end

    Crutch.BossHealthBar.AddThresholdOverride(Crutch.GetCapitalizedString(CRUTCH_BHB_LYLANAR), twinsThresholds)
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
        Crutch.dbgSpam(zo_strformat("tank changed to |cFFFF00<<1>>", GetUnitDisplayName(unitTag)))
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
    Crutch.UnregisterForCombatEvent("ArcingCleaveTarget")
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
    Crutch.RegisterForCombatEvent("ArcingCleaveTarget", OnArcingCleave, nil, 163901)

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

-- Twins health
local function OnBossesChanged()
    if (zo_strformat("<<1>>", GetString(CRUTCH_BHB_LYLANAR)) == zo_strformat("<<1>>", GetUnitNameIfExists("boss1") or "")) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRTwinsHealth", EVENT_POWER_UPDATE, OnBossHealthDrop)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRTwinsHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRTwinsHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
    else
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRTwinsHealth", EVENT_POWER_UPDATE)
        Crutch.BossHealthBar.RemoveThresholdOverride(Crutch.GetCapitalizedString(CRUTCH_BHB_LYLANAR))
    end
end

function Crutch.RegisterDreadsailReef()
    -- Chat output for who picks up domes
    if (Crutch.savedOptions.general.showRaidDiag) then
        Crutch.RegisterForEffectChanged("DSRDestructiveEmber", OnDestructiveEmber, 166209, "group")
        Crutch.RegisterForEffectChanged("DSRPiercingHailstone", OnPiercingHailstone, 166178, "group")
    end

    -- Twins detection for which boss first
    Crutch.RegisterBossChangedListener("CrutchDSRBossChanged", OnBossesChanged)
    OnBossesChanged()

    -- Lightning Stacks
    local showStatic
    if (IsConsoleUI()) then
        showStatic = Crutch.savedOptions.console.showProminent
    else
        showStatic = Crutch.savedOptions.dreadsailreef.alertStaticStacks
    end

    if (showStatic) then
        Crutch.RegisterForEffectChanged("DSRStaticBoss", OnLightningStacksChanged, 163575, "player")
        Crutch.RegisterForEffectChanged("DSRStaticOther", OnLightningStacksChanged, 169688, "player")
    end

    -- Volatile Stacks
    local showVolatile
    if (IsConsoleUI()) then
        showVolatile = Crutch.savedOptions.console.showProminent
    else
        showVolatile = Crutch.savedOptions.dreadsailreef.alertVolatileStacks
    end

    if (showVolatile) then
        Crutch.RegisterForEffectChanged("DSRVolatileBoss", OnPoisonStacksChanged, 174835, "player")
        Crutch.RegisterForEffectChanged("DSRVolatileOther", OnPoisonStacksChanged, 174932, "player")
    end

    -- Taleria cleave
    Crutch.RegisterBossChangedListener("CrutchDreadsailReef", TryEnablingTaleriaCleave)

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Dreadsail Reef")
end

function Crutch.UnregisterDreadsailReef()
    -- Domes
    Crutch.UnregisterForEffectChanged("DSRDestructiveEmber")
    Crutch.UnregisterForEffectChanged("DSRPiercingHailstone")

    -- Twins detection
    Crutch.UnregisterBossChangedListener("CrutchDSRBossChanged")
    Crutch.BossHealthBar.RemoveThresholdOverride(Crutch.GetCapitalizedString(CRUTCH_BHB_LYLANAR))

    -- Lightning Stacks
    Crutch.UnregisterForEffectChanged("DSRStaticBoss")
    Crutch.UnregisterForEffectChanged("DSRStaticOther")

    -- Volatile Stacks
    Crutch.UnregisterForEffectChanged("DSRVolatileBoss")
    Crutch.UnregisterForEffectChanged("DSRVolatileOther")

    -- Taleria cleave
    Crutch.UnregisterBossChangedListener("CrutchDreadsailReef")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Dreadsail Reef")
end
