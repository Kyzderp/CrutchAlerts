local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Time Breach
---------------------------------------------------------------------
local effectResults = {
    [EFFECT_RESULT_FADED] = "FADED",
    [EFFECT_RESULT_FULL_REFRESH] = "FULL_REFRESH",
    [EFFECT_RESULT_GAINED] = "GAINED",
    [EFFECT_RESULT_TRANSFER] = "TRANSFER",
    [EFFECT_RESULT_UPDATED] = "UPDATED",
}

local groupTimeBreach = {}

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnTimeBreachChanged(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    Crutch.dbgOther(string.format("|c8C00FF%s(%s): %d %s|r", GetUnitDisplayName(unitTag), unitTag, stackCount, effectResults[changeType]))

    local changed = false
    if (changeType == EFFECT_RESULT_GAINED) then
        groupTimeBreach[unitTag] = true
        changed = true
    elseif (changeType == EFFECT_RESULT_FADED) then
        groupTimeBreach[unitTag] = false
        changed = true
    end

    -- Update suppression
    if (changed) then
        -- If it was the player entering or exiting portal, all units need to be refreshed
        if (AreUnitsEqual("player", unitTag)) then
            Crutch.Drawing.EvaluateAllSuppression()
        else
            Crutch.Drawing.EvaluateSuppressionFor(unitTag)
        end
    end
end

local function IsInNahvPortal(unitTag)
    if (not unitTag) then unitTag = Crutch.playerGroupTag end

    if (groupTimeBreach[unitTag]) then return true end

    return false
end
Crutch.IsInNahvPortal = IsInNahvPortal

-- Suppression for attached icons
local PORTAL_SUPPRESSION_FILTER = "CrutchAlertsNahvPortal"
local function NahvPortalFilter(unitTag)
    return IsInNahvPortal(unitTag) == IsInNahvPortal(Crutch.playerGroupTag)
end

---------------------------------------------------------------------
-- Lokkestiiz Icons
---------------------------------------------------------------------
local function EnableLokkIcons()
    if (not Crutch.savedOptions.sunspire.showLokkIcons) then return end

    if (Crutch.savedOptions.sunspire.lokkIconsSoloHeal) then
        Crutch.EnableIcon("SHLokkBeam1")
        Crutch.EnableIcon("SHLokkBeam2")
        Crutch.EnableIcon("SHLokkBeam3")
        Crutch.EnableIcon("SHLokkBeam4")
        Crutch.EnableIcon("SHLokkBeam5")
        Crutch.EnableIcon("SHLokkBeam6")
        Crutch.EnableIcon("SHLokkBeam7")
        Crutch.EnableIcon("SHLokkBeam8")
        Crutch.EnableIcon("SHLokkBeam9")
        Crutch.EnableIcon("SHLokkBeamH")
    else
        Crutch.EnableIcon("LokkBeam1")
        Crutch.EnableIcon("LokkBeam2")
        Crutch.EnableIcon("LokkBeam3")
        Crutch.EnableIcon("LokkBeam4")
        Crutch.EnableIcon("LokkBeam5")
        Crutch.EnableIcon("LokkBeam6")
        Crutch.EnableIcon("LokkBeam7")
        Crutch.EnableIcon("LokkBeam8")
        Crutch.EnableIcon("LokkBeamLH")
        Crutch.EnableIcon("LokkBeamRH")
    end
end

local function DisableLokkIcons()
    Crutch.DisableIcon("SHLokkBeam1")
    Crutch.DisableIcon("SHLokkBeam2")
    Crutch.DisableIcon("SHLokkBeam3")
    Crutch.DisableIcon("SHLokkBeam4")
    Crutch.DisableIcon("SHLokkBeam5")
    Crutch.DisableIcon("SHLokkBeam6")
    Crutch.DisableIcon("SHLokkBeam7")
    Crutch.DisableIcon("SHLokkBeam8")
    Crutch.DisableIcon("SHLokkBeam9")
    Crutch.DisableIcon("SHLokkBeamH")

    Crutch.DisableIcon("LokkBeam1")
    Crutch.DisableIcon("LokkBeam2")
    Crutch.DisableIcon("LokkBeam3")
    Crutch.DisableIcon("LokkBeam4")
    Crutch.DisableIcon("LokkBeam5")
    Crutch.DisableIcon("LokkBeam6")
    Crutch.DisableIcon("LokkBeam7")
    Crutch.DisableIcon("LokkBeam8")
    Crutch.DisableIcon("LokkBeamLH")
    Crutch.DisableIcon("LokkBeamRH")
end

local LOKK_HM_HEALTH = 97025800
local function MaybeEnableLokkIcons()
    if (not Crutch.savedOptions.sunspire.showLokkIcons) then return end

    local _, maxHealth = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (maxHealth == LOKK_HM_HEALTH) then
        EnableLokkIcons()
    end
end

-- Show icons during flight phase
local function OnLokkFly()
    MaybeEnableLokkIcons()
end

-- Hide icons after beam is over
local function OnLokkBeam()
    zo_callLater(function()
        DisableLokkIcons()
    end, 15000)
end

-- We also want to show icons before the fight starts. You'll either walk into
-- a Lokk that already has HM turned on (bosses changed) or you'll already be
-- at Lokk when HM changes (max health power update)
local function OnBossesChanged()
    -- Lokk: 86.2m / 107.8m : 86245152 / 107806440
    -- Lost Depths: 77620640 / 97025800
    -- Yol: 129.4m / 161.7m
    -- Nahv: 103.5m / 129.4m
    local _, maxHealth = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)

    -- Lokkestiiz HM check
    if (maxHealth == LOKK_HM_HEALTH) then
        MaybeEnableLokkIcons()
    else
        -- Otherwise, leaving Lokk (or could be a wipe)
        DisableLokkIcons()
    end
end

-- Make changes to icons only if the max health changed
local prevMaxHealth = 0
local function OnPowerUpdate(_, _, _, _, _, powerMax)
    if (prevMaxHealth == powerMax) then
        return
    end
    prevMaxHealth = powerMax

    -- Lokkestiiz HM check
    if (powerMax == LOKK_HM_HEALTH) then
        MaybeEnableLokkIcons()
    else
        -- Otherwise, it could be turning off HM
        DisableLokkIcons()
    end
end


---------------------------------------------------------------------
-- Storm Breath
---------------------------------------------------------------------
local xX, xY, xZ = 114941, 56106, 105959
local function Do20StormBreath()
    local poopKey = Crutch.Drawing.CreatePlacedIcon("CrutchAlerts/assets/poop.dds", xX, xY, xZ, 50, {1, 0, 0})
    zo_callLater(function() Crutch.Drawing.RemovePlacedIcon(poopKey) end, 60000)

    local key3 = Crutch.Drawing.CreateWorldTexture(
        "CrutchAlerts/assets/floor/square.dds",
        xX, xY, xZ,
        50,
        8,
        {1, 0, 0, 0.2},
        true,
        false,
        {math.pi/2, math.pi/4 + 0.13, 0},
        nil)
    zo_callLater(function() Crutch.Drawing.RemoveWorldTexture(key3) end, 18000)

    -- second strafe ~8.3s later
    zo_callLater(function()
        local key4 = Crutch.Drawing.CreateWorldTexture(
            "CrutchAlerts/assets/floor/square.dds",
            xX, xY + 1, xZ,
            50,
            8,
            {1, 0, 0, 0.2},
            true,
            false,
            {math.pi/2, math.pi*3/4 + 0.19, 0},
            nil)
        zo_callLater(function() Crutch.Drawing.RemoveWorldTexture(key4) end, 18000)
    end, 8300)
end
Crutch.Do20StormBreath = Do20StormBreath

local function RegisterStormBreath()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "StormBreath1", EVENT_COMBAT_EVENT, function()
        local key = Crutch.Drawing.CreateWorldTexture(
            "CrutchAlerts/assets/floor/square.dds",
            114900, 56105, 106100,
            50,
            8,
            {1, 0, 0, 0.2},
            true,
            false,
            {math.pi/2, 0.03, 0},
            nil)
        zo_callLater(function() Crutch.Drawing.RemoveWorldTexture(key) end, 18000)
    end)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "StormBreath1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 119596)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "StormBreath1", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)

    -- storm breath 20%
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "StormBreath3", EVENT_COMBAT_EVENT, Do20StormBreath)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "StormBreath3", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 122961)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "StormBreath3", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
end

local function UnregisterStormBreath()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "StormBreath1", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "StormBreath3", EVENT_COMBAT_EVENT)
end

---------------------------------------------------------------------
-- Yolnahkriin Icons
---------------------------------------------------------------------
local function DisableYolIcons()
    Crutch.DisableIcon("YolWing2")
    Crutch.DisableIcon("YolWing3")
    Crutch.DisableIcon("YolWing4")
    Crutch.DisableIcon("YolHead2")
    Crutch.DisableIcon("YolHead3")
    Crutch.DisableIcon("YolHead4")
end

local function OnYolFly75()
    if (not Crutch.savedOptions.sunspire.showYolIcons) then return end
    if (Crutch.savedOptions.sunspire.yolLeftIcons) then
        Crutch.EnableIcon("YolLeftWing2")
        Crutch.EnableIcon("YolLeftHead2")
    else
        Crutch.EnableIcon("YolWing2")
        Crutch.EnableIcon("YolHead2")
    end
    zo_callLater(function()
        Crutch.DisableIcon("YolWing2")
        Crutch.DisableIcon("YolHead2")
        Crutch.DisableIcon("YolLeftWing2")
        Crutch.DisableIcon("YolLeftHead2")
    end, 25000)
end

local function OnYolFly50()
    if (not Crutch.savedOptions.sunspire.showYolIcons) then return end
    if (Crutch.savedOptions.sunspire.yolLeftIcons) then
        Crutch.EnableIcon("YolLeftWing3")
        Crutch.EnableIcon("YolLeftHead3")
    else
        Crutch.EnableIcon("YolWing3")
        Crutch.EnableIcon("YolHead3")
    end
    zo_callLater(function()
        Crutch.DisableIcon("YolWing3")
        Crutch.DisableIcon("YolHead3")
        Crutch.DisableIcon("YolLeftWing3")
        Crutch.DisableIcon("YolLeftHead3")
    end, 25000)
end

local function OnYolFly25()
    if (not Crutch.savedOptions.sunspire.showYolIcons) then return end
    if (Crutch.savedOptions.sunspire.yolLeftIcons) then
        Crutch.EnableIcon("YolLeftWing4")
        Crutch.EnableIcon("YolLeftHead4")
    else
        Crutch.EnableIcon("YolWing4")
        Crutch.EnableIcon("YolHead4")
    end
    zo_callLater(function()
        Crutch.DisableIcon("YolWing4")
        Crutch.DisableIcon("YolHead4")
        Crutch.DisableIcon("YolLeftWing4")
        Crutch.DisableIcon("YolLeftHead4")
    end, 25000)
end

local function OnYolFly()
    local currHealth, maxHealth = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    local percent = currHealth / maxHealth
    if (percent < 0.3) then
        OnYolFly25()
    elseif (percent < 0.55) then
        OnYolFly50()
    elseif (percent < 0.8) then
        OnYolFly75()
    else
        Crutch.dbgOther("|cFF0000??????????????????????|r")
    end
end


---------------------------------------------------------------------
-- Focused Fire
---------------------------------------------------------------------
local FOCUSED_FIRE_UNIQUE_NAME = "CrutchAlertsSSFocusedFire"

-- Check each group member to see who has the Focused Fire DEBUFF
local function OnFocusFireGained(_, result, _, _, _, _, sourceName, sourceType, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    local toClear = {}
    for g = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(g)
        local hasFocusedFire = false
        for i = 1, GetNumBuffs(unitTag) do
            local buffName, _, _, _, stackCount, iconFilename, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unitTag, i)
            if (abilityId == 121726) then
                if (Crutch.savedOptions.general.showRaidDiag) then
                    Crutch.msg(zo_strformat("|cAAAAAA<<1>> has <<2>> x <<3>>", GetUnitDisplayName(unitTag), stackCount, buffName))
                end
                hasFocusedFire = true
                break
            end
        end

        if (Crutch.savedOptions.sunspire.yolFocusedFire and not hasFocusedFire) then
            Crutch.SetAttachedIconForUnit(unitTag, FOCUSED_FIRE_UNIQUE_NAME, 500, "CrutchAlerts/assets/shape/chevron.dds", 30, {0, 1, 1, 0.6}, false)
            table.insert(toClear, unitTag)
        end
    end

    -- Clear icons 7 seconds later
    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "ClearIcons", 7000, function()
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "ClearIcons")
        for _, unitTag in pairs(toClear) do
            Crutch.RemoveAttachedIconForUnit(unitTag, FOCUSED_FIRE_UNIQUE_NAME)
        end
    end)
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
-- Register/Unregister
local origOSIUnitErrorCheck = nil

function Crutch.RegisterSunspire()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Sunspire")

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "FocusFireBegin", EVENT_COMBAT_EVENT, OnFocusFireGained)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "FocusFireBegin", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "FocusFireBegin", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 121722)
    -- TODO: only show for self option

    -- Register for Time Breach effect gained/faded
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED, OnTimeBreachChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 121216)

    if (Crutch.savedOptions.sunspire.showLokkIcons) then
        Crutch.RegisterBossChangedListener("CrutchSunspire", OnBossesChanged)
        Crutch.RegisterEnteredGroupCombatListener("CrutchSunspire", DisableLokkIcons)

        -- Register for Lokk difficulty change
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "SunspireHealthUpdate", EVENT_POWER_UPDATE, OnPowerUpdate)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "SunspireHealthUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss1")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "SunspireHealthUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)

        -- Register for Lokk flying (Gravechill)
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Gravechill80", EVENT_COMBAT_EVENT, OnLokkFly)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Gravechill80", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 122820)
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Gravechill50", EVENT_COMBAT_EVENT, OnLokkFly)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Gravechill50", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 122821)
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Gravechill20", EVENT_COMBAT_EVENT, OnLokkFly)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Gravechill20", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 122822)

        -- Register for Lokk beam (Storm Fury)
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "StormFury", EVENT_COMBAT_EVENT, OnLokkBeam)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "StormFury", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "StormFury", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 115702)

        -- Trigger initial "changes," in case a reload was done while at Lokk
        OnBossesChanged()
    end

    if (Crutch.savedOptions.sunspire.telegraphStormBreath) then
        RegisterStormBreath()
    end

    -- Register for Yol flying (Takeoff)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Takeoff75", EVENT_COMBAT_EVENT, OnYolFly75)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Takeoff75", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 124910)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Takeoff50", EVENT_COMBAT_EVENT, OnYolFly50)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Takeoff50", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 124915)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Takeoff25", EVENT_COMBAT_EVENT, OnYolFly25)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Takeoff25", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 124916)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TurnOffAim", EVENT_COMBAT_EVENT, OnYolFly)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TurnOffAim", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TurnOffAim", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 125693)

     -- Override OdySupportIcons to also check whether the group member is in the same portal vs not portal
    if (OSI) then
        Crutch.dbgOther("|c88FFFF[CT]|r Overriding OSI.UnitErrorCheck")
        origOSIUnitErrorCheck = OSI.UnitErrorCheck
        OSI.UnitErrorCheck = function(unitTag, allowSelf)
            local error = origOSIUnitErrorCheck(unitTag, allowSelf)
            if (error ~= 0) then
                return error
            end
            if (IsInNahvPortal() ~= IsInNahvPortal(unitTag)) then
                return 8
            else
                return 0
            end
        end
    end

    -- Suppress attached icons when in different portal
    Crutch.Drawing.RegisterSuppressionFilter(PORTAL_SUPPRESSION_FILTER, NahvPortalFilter)
end

function Crutch.UnregisterSunspire()

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "FocusFireBegin", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED)

    -- Lokk
    Crutch.UnregisterBossChangedListener("CrutchSunspire")
    Crutch.UnregisterEnteredGroupCombatListener("CrutchSunspire")
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "SunspireHealthUpdate", EVENT_POWER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Gravechill80", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Gravechill50", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Gravechill20", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "StormFury", EVENT_COMBAT_EVENT)

    UnregisterStormBreath()

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Takeoff75", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Takeoff50", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Takeoff25", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TurnOffAim", EVENT_COMBAT_EVENT)

    if (OSI and origOSIUnitErrorCheck) then
        Crutch.dbgOther("|c88FFFF[CT]|r Restoring OSI.UnitErrorCheck")
        OSI.UnitErrorCheck = origOSIUnitErrorCheck
    end

    Crutch.Drawing.UnregisterSuppressionFilter(PORTAL_SUPPRESSION_FILTER)

    DisableLokkIcons()
    DisableYolIcons()

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Sunspire")
end
