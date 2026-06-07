local Crutch = CrutchAlerts
local C = Crutch.Constants
Crutch.DreadsailReef = {}
local DSR = Crutch.DreadsailReef

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
local FIREBRAND_ID = 166472
local FROSTBRAND_ID = 166482
local firebrands = {}
local frostbrands = {}
local BRAND_SPOTS = {
    [1] = {x = 68548, y = 36075, z = 85175, displayName = "entrance"},
    [2] = {x = 69510, y = 36075, z = 85172, displayName = "center"},
}

-- Just take them in the order they come. Match Qcell's Dreadsail Reef Helper, 1 entrance 2 center.
local lastStacks = 0
local function StackBrands(abilityId, hitValue, sourceUnitId)
    if (#firebrands ~= 2 or #frostbrands ~= 2) then return end

    -- For some reason, most of the time the same events fire twice, second time only milliseconds after
    -- the first. So just don't display again if it already happened recently.
    if (GetGameTimeMilliseconds() - lastStacks < 3000) then
        ZO_ClearTable(firebrands)
        ZO_ClearTable(frostbrands)
        return
    end
    lastStacks = GetGameTimeMilliseconds()

    table.sort(firebrands, function(a, b) return GetUnitDisplayName(a) < GetUnitDisplayName(b) end)
    table.sort(frostbrands, function(a, b) return GetUnitDisplayName(a) < GetUnitDisplayName(b) end)

    local mySpot, partner
    for i = 1, 2 do
        if (AreUnitsEqual("player", firebrands[i])) then
            -- Player has firebrand
            mySpot = i
            partner = frostbrands[i]
        elseif (AreUnitsEqual("player", frostbrands[i])) then
            -- Player has frostbrand
            mySpot = i
            partner = firebrands[i]
        end

        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(string.format("Brands: %s & %s (%s)",
                GetUnitDisplayName(firebrands[i]),
                GetUnitDisplayName(frostbrands[i]),
                BRAND_SPOTS[i].displayName))
        end
    end

    -- If player has brand, show alert and pin
    if (mySpot) then
        local label = string.format("|cAAAAAASuggested stack: |cff00ff%s (%s)", GetUnitDisplayName(partner), BRAND_SPOTS[mySpot].displayName)
        Crutch.DisplayNotification(abilityId, label, hitValue, sourceUnitId, 0, 0, 0, 0, 0, 0, false)

        -- Put an icon on the ground
        local key = Crutch.Drawing.CreatePlacedIcon("/esoui/art/actionbar/stateoverlay_vulnerable.dds",
            BRAND_SPOTS[mySpot].x,
            BRAND_SPOTS[mySpot].y + 75,
            BRAND_SPOTS[mySpot].z,
            150, {1, 0, 1})
        zo_callLater(function() Crutch.Drawing.RemovePlacedIcon(key) end, hitValue)
    end

    ZO_ClearTable(firebrands)
    ZO_ClearTable(frostbrands)
end

local function OnFirebrand(_, result, _, _, _, _, _, _, _, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    local unitTag = Crutch.groupIdToTag[targetUnitId]
    if (not unitTag) then
        Crutch.dbgOther("|cFF0000Brand couldn't find tag for " .. targetUnitId)
        return
    end
    table.insert(firebrands, unitTag)
    StackBrands(abilityId, hitValue, sourceUnitId)
end

local function OnFrostbrand(_, result, _, _, _, _, _, _, _, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    local unitTag = Crutch.groupIdToTag[targetUnitId]
    if (not unitTag) then
        Crutch.dbgOther("|cFF0000Brand couldn't find tag for " .. targetUnitId)
        return
    end
    table.insert(frostbrands, unitTag)
    StackBrands(abilityId, hitValue, sourceUnitId)
end


---------------------------------------------------------------------
-- Trash
---------------------------------------------------------------------
local ELIXIR_ID = 170547
local function OnElixir(_, _, _, _, _, _, _, _, targetName, _, _, _, _, _, _, targetUnitId)
    local unitTag = Crutch.groupIdToTag[targetUnitId]

    if (not unitTag) then
        Crutch.dbgOther(zo_strformat("|cFF0000Elixir couldn't find unit tag for <<1>> ID <<2>>", targetName, targetUnitId))
        return
    end

    Crutch.dbgSpam(zo_strformat("Elixir on <<1>> (<<2>>)", targetName, unitTag))
    local _, x, y, z = GetUnitRawWorldPosition(unitTag)
    local key = Crutch.Drawing.CreatePlacedIcon("/esoui/art/inventory/inventory_consumables_tabicon_active.dds", x, y + 50, z, 100, {1, 0, 1})
    zo_callLater(function() Crutch.Drawing.RemovePlacedIcon(key) end, 16300) -- TODO: is duration same as IA?
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

local TALERIA_HM_HP = 181632304
local function IsTaleria()
    local _, powerMax, _ = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (powerMax == TALERIA_HM_HP
        or powerMax == 100906840 -- Veteran
        or powerMax == 29538220) then -- Normal
        return true
    end
    return false
end

local function IsTaleriaHM()
    local _, powerMax, _ = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    return powerMax == TALERIA_HM_HP
end

-- Enable Cleave lines if the boss is present
local function TryEnablingTaleriaCleave()
    if (IsTaleria()) then
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
-- Taleria Info Panel
---------------------------------------------------------------------
local PANEL_MAELSTROM_INDEX = 3
local PANEL_WINTER_STORM_INDEX = 4
local PANEL_BEHEMOTH_INDEX = 5
local PANEL_SIREN_INDEX = 6


---------------------------------------------------------------------
-- Maelstrom
local MAELSTROM_ID = 166292
local MAELSTROM_PREFIX = zo_strformat("|cfff1ab<<C:1>>: ", GetAbilityName(MAELSTROM_ID))

local callLaterId
-- 500ms cast time, 6000ms channeled
local function OnMaelstromGainedDuration(_, _, _, _, _, _, _, _, _, _, hitValue)
    Crutch.InfoPanel.CountDownDuration(PANEL_MAELSTROM_INDEX, MAELSTROM_PREFIX, hitValue)
    callLaterId = zo_callLater(function()
        -- outlier 27.632? not sure if related to tank death. 31.897, 32.332, 32.383, 32.46, 32.529, 32.798, 34.569, 35, 36.009, 36.144, 36.348, 36.71, 39.676, 39.836, 39.861, 39.962, 40.069, 40.173, 40.176, 40.301, 40.403, 40.412, 42.111, 44.079, 44.108, 45.234, 47.669, 47.895
        Crutch.InfoPanel.CountDownToTargetTime(PANEL_MAELSTROM_INDEX, MAELSTROM_PREFIX, GetGameTimeMilliseconds() + 31800)
        end, hitValue)
end


---------------------------------------------------------------------
-- Winter Storm
local WINTER_STORM_CW_ID = 175447
local WINTER_STORM_CCW_ID = 174866
local PLATFORM_FALL_ID = 167702
local WINTER_STORM_PREFIX = zo_strformat("|c00CCCC<<C:1>>: ", GetAbilityName(WINTER_STORM_CW_ID)) -- color matching CCA

local function OnWinterStorm()
    Crutch.InfoPanel.CountDownDuration(PANEL_WINTER_STORM_INDEX, WINTER_STORM_PREFIX, 110000) -- TODO
end


---------------------------------------------------------------------
-- Summon Behemoth
local BEHEMOTH_ID = 166928
local BEHEMOTH_PREFIX = zo_strformat("|c66CCFF<<C:1>>: ", GetAbilityName(BEHEMOTH_ID)) -- color matching CCA

local function OnBehemothSummoned()
    if (IsTaleriaHM()) then
        -- HM: 45.173, 45.251, 45.319, 45.635, 45.675, 45.683, 45.794, 45.859, 46.197, 46.425, 46.545, 46.655, 46.946, 47.312, 47.512, 47.918, 50.757, 55.651, 55.972, 56.326, 56.467, 58.114, 58.145
        Crutch.InfoPanel.CountDownDuration(PANEL_BEHEMOTH_INDEX, BEHEMOTH_PREFIX, 45000)
    else
        -- vet: 70.166, 69.249, 70.449, 67.299, 70.115, 63.015, 70.282, 65.015
        Crutch.InfoPanel.CountDownDuration(PANEL_BEHEMOTH_INDEX, BEHEMOTH_PREFIX, 63000) -- TODO: is it different for normal?
    end
end


---------------------------------------------------------------------
-- Summon Siren
local SIREN_ID = 166929
local SIREN_PREFIX = zo_strformat("|c9966FF<<C:1>>: ", GetAbilityName(SIREN_ID)) -- color matching CCA

local function OnSirenSummoned()
    -- 97.997, 103, 102, 106, 99, 103
    Crutch.InfoPanel.CountDownDuration(PANEL_SIREN_INDEX, SIREN_PREFIX, 98000) -- TODO
end


---------------------------------------------------------------------
local function OnPlatformFall()
    -- Bridge delays storm: TODO 63 62
    Crutch.InfoPanel.CountDownDuration(PANEL_WINTER_STORM_INDEX, WINTER_STORM_PREFIX, 60000)
    -- Bridge delays (or shortens) sirens? 39.136 27.796 26.355 33.797 31.005 39.124 33.785, 38, 39, 32
    -- vet: 25.327, 26.165, 30.399, 33.375, 33.563, 33.665, 33.78, 38.848, 39.252
    Crutch.InfoPanel.CountDownDuration(PANEL_SIREN_INDEX, SIREN_PREFIX, 25300)
end

local function OnCombat()
    if (IsTaleria()) then
        -- initial timer (to gained duration) 12.776, 13.011, 14.405, 14.207, 14.179
        Crutch.InfoPanel.CountDownDuration(PANEL_MAELSTROM_INDEX, MAELSTROM_PREFIX, 12000)
        -- initial timer (to begin) 6.159, 6.447, 5.967, 5.78, 5.771
        Crutch.InfoPanel.CountDownDuration(PANEL_BEHEMOTH_INDEX, BEHEMOTH_PREFIX, 5700)
    end
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
local function CleanUp()
    ZO_ClearTable(firebrands)
    ZO_ClearTable(frostbrands)
    Crutch.InfoPanel.StopCount(PANEL_MAELSTROM_INDEX)
    if (callLaterId) then
        zo_removeCallLater(callLaterId)
    end
    Crutch.InfoPanel.StopCount(PANEL_BEHEMOTH_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_WINTER_STORM_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_SIREN_INDEX)
end

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
    Crutch.RegisterEnteredGroupCombatListener("CrutchDSREnteredGroupCombat", OnCombat)
    Crutch.RegisterExitedGroupCombatListener("CrutchDSRExitedGroupCombat", CleanUp)

    -- Chat output for who picks up domes
    if (Crutch.savedOptions.general.showRaidDiag) then
        Crutch.RegisterForEffectChanged("DSRDestructiveEmber", OnDestructiveEmber, 166209, "group")
        Crutch.RegisterForEffectChanged("DSRPiercingHailstone", OnPiercingHailstone, 166178, "group")
    end

    -- Twins detection for which boss first
    Crutch.RegisterBossChangedListener("CrutchDSRBossChanged", OnBossesChanged)
    OnBossesChanged()

    -- Brands
    if (Crutch.savedOptions.dreadsailreef.stackBrands) then
        Crutch.RegisterForCombatEvent("DSRFirebrand", OnFirebrand, ACTION_RESULT_EFFECT_GAINED_DURATION, FIREBRAND_ID)
        Crutch.RegisterForCombatEvent("DSRFrostbrand", OnFrostbrand, ACTION_RESULT_EFFECT_GAINED_DURATION, FROSTBRAND_ID)
    end

    -- Brewmaster elixirs
    if (Crutch.savedOptions.dreadsailreef.showElixirs) then
        Crutch.RegisterForCombatEvent("DSRElixir", OnElixir, ACTION_RESULT_EFFECT_GAINED, ELIXIR_ID)
    end

    -- Lightning Stacks
    if (Crutch.savedOptions.dreadsailreef.alertStaticStacks) then
        Crutch.RegisterForEffectChanged("DSRStaticBoss", OnLightningStacksChanged, 163575, "player")
        Crutch.RegisterForEffectChanged("DSRStaticOther", OnLightningStacksChanged, 169688, "player")
    end

    -- Volatile Stacks
    if (Crutch.savedOptions.dreadsailreef.alertVolatileStacks) then
        Crutch.RegisterForEffectChanged("DSRVolatileBoss", OnPoisonStacksChanged, 174835, "player")
        Crutch.RegisterForEffectChanged("DSRVolatileOther", OnPoisonStacksChanged, 174932, "player")
    end

    -- Reef can run
    if (Crutch.savedOptions.experimental) then
        DSR.RegisterReefGuardian()
    end

    -- Taleria cleave
    Crutch.RegisterBossChangedListener("CrutchDreadsailReef", TryEnablingTaleriaCleave)

    -- Taleria info panel
    if (Crutch.savedOptions.dreadsailreef.infoPanel.showMaelstrom) then
        Crutch.RegisterForCombatEvent("DSRMaelstrom", OnMaelstromGainedDuration, ACTION_RESULT_EFFECT_GAINED_DURATION, MAELSTROM_ID)
    end
    if (Crutch.savedOptions.dreadsailreef.infoPanel.showBehemothSpawn) then
        Crutch.RegisterForCombatEvent("DSRBehemoth", OnBehemothSummoned, ACTION_RESULT_BEGIN, BEHEMOTH_ID)
    end
    if (Crutch.savedOptions.dreadsailreef.infoPanel.showWinterStorm) then
        Crutch.RegisterForCombatEvent("DSRWinterStorm", OnWinterStorm, ACTION_RESULT_EFFECT_GAINED, WINTER_STORM_CW_ID)
        Crutch.RegisterForCombatEvent("DSRWinterStormCCW", OnWinterStorm, ACTION_RESULT_EFFECT_GAINED, WINTER_STORM_CCW_ID)
    end
    if (Crutch.savedOptions.dreadsailreef.infoPanel.showSirenSpawn) then
        Crutch.RegisterForCombatEvent("DSRSiren", OnSirenSummoned, ACTION_RESULT_BEGIN, SIREN_ID)
    end
    if (Crutch.savedOptions.dreadsailreef.infoPanel.showSirenSpawn or Crutch.savedOptions.dreadsailreef.infoPanel.showWinterStorm) then
        Crutch.RegisterForCombatEvent("DSRPlatformFall", OnPlatformFall, ACTION_RESULT_EFFECT_GAINED, PLATFORM_FALL_ID) -- TODO: what action result?
    end

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Dreadsail Reef")
end

function Crutch.UnregisterDreadsailReef()
    Crutch.UnregisterEnteredGroupCombatListener("CrutchDSREnteredGroupCombat")
    Crutch.UnregisterExitedGroupCombatListener("CrutchDSRExitedGroupCombat")
    CleanUp()

    -- Domes
    Crutch.UnregisterForEffectChanged("DSRDestructiveEmber")
    Crutch.UnregisterForEffectChanged("DSRPiercingHailstone")

    -- Twins detection
    Crutch.UnregisterBossChangedListener("CrutchDSRBossChanged")
    Crutch.BossHealthBar.RemoveThresholdOverride(Crutch.GetCapitalizedString(CRUTCH_BHB_LYLANAR))

    -- Brands
    Crutch.UnregisterForCombatEvent("DSRFirebrand")
    Crutch.UnregisterForCombatEvent("DSRFrostbrand")

    -- Brewmaster elixir
    Crutch.UnregisterForCombatEvent("DSRElixir")

    -- Lightning Stacks
    Crutch.UnregisterForEffectChanged("DSRStaticBoss")
    Crutch.UnregisterForEffectChanged("DSRStaticOther")

    -- Volatile Stacks
    Crutch.UnregisterForEffectChanged("DSRVolatileBoss")
    Crutch.UnregisterForEffectChanged("DSRVolatileOther")

    -- Reef can run
    if (Crutch.savedOptions.experimental) then
        DSR.UnregisterReefGuardian()
    end

    -- Taleria cleave
    Crutch.UnregisterBossChangedListener("CrutchDreadsailReef")
    if (cleaveEnabled) then
        Uncleave()
    end

    -- Taleria info panel
    Crutch.UnregisterForCombatEvent("DSRMaelstrom")
    Crutch.UnregisterForCombatEvent("DSRBehemoth")
    Crutch.UnregisterForCombatEvent("DSRWinterStorm")
    Crutch.UnregisterForCombatEvent("DSRWinterStormCCW")
    Crutch.UnregisterForCombatEvent("DSRSiren")
    Crutch.UnregisterForCombatEvent("DSRPlatformFall")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Dreadsail Reef")
end
