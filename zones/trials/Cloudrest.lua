local Crutch = CrutchAlerts
local C = Crutch.Constants

---------------------------------------------------------------------
local amuletSmashed = false
local spearsRevealed = 0
local spearsSent = 0
local orbsDunked = 0

---------------------------------------------------------------------
-- Portal
---------------------------------------------------------------------
local effectResults = {
    [EFFECT_RESULT_FADED] = "FADED",
    [EFFECT_RESULT_FULL_REFRESH] = "FULL_REFRESH",
    [EFFECT_RESULT_GAINED] = "GAINED",
    [EFFECT_RESULT_TRANSFER] = "TRANSFER",
    [EFFECT_RESULT_UPDATED] = "UPDATED",
}

local groupShadowWorld = {}

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnShadowWorldChanged(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    Crutch.dbgOther(string.format("|c8C00FF%s(%s): %d %s|r", GetUnitDisplayName(unitTag), unitTag, stackCount, effectResults[changeType]))

    local changed = false
    if (changeType == EFFECT_RESULT_GAINED) then
        groupShadowWorld[unitTag] = true
        changed = true
    elseif (changeType == EFFECT_RESULT_FADED) then
        groupShadowWorld[unitTag] = false
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

-- Also used for not showing alerts for Rele and Galenwe interruptibles while in portal
local function IsInShadowWorld(unitTag)
    if (not unitTag) then unitTag = Crutch.playerGroupTag end

    if (groupShadowWorld[unitTag] == true) then return true end

    return false
end
Crutch.IsInShadowWorld = IsInShadowWorld

local PORTAL_SUPPRESSION_FILTER = "CrutchAlertsCloudrestPortal"
local function CRPortalFilter(unitTag)
    return IsInShadowWorld(unitTag) == IsInShadowWorld(Crutch.playerGroupTag)
end


---------------------------------------------------------------------
-- Hoarfrost icons / alerts
---------------------------------------------------------------------
local FROST_UNIQUE_NAME = "CrutchAlertsCRHoarfrost"
local TIME_UNTIL_DROP = 5800
local HOARFROST_ID = 103695
local HOARFROST_EXECUTE_ID = 110516
local HOARFROST_CAST_ID = 105151
local HOARFROST_CAST_EXECUTE_ID = 110466

local numFrosts = {
    [HOARFROST_ID] = 0,
    [HOARFROST_EXECUTE_ID] = 0,
}

local frostDropCallLaterId -- It can disappear when taking portal jump pad?
local function OnFrostDroppable(abilityId)
    frostDropCallLaterId = nil

    -- Show regular timer
    if (Crutch.savedOptions.cloudrest.showFrostAlert) then
        local num = numFrosts[abilityId]
        local label = zo_strformat("|c8ef5f5Drop <<C:1>> (<<2>>) |cFF0000now!|r", GetAbilityName(abilityId), num == 3 and "last" or num)
        Crutch.DisplayNotification(abilityId, label, 9000 - TIME_UNTIL_DROP, 0, 0, 0, 0, 0, 0, 0, false) -- This would go away on normal because there's no Overwhelming, but whatever
    end

    -- Do prominent for drop frost
    local doProminent
    if (IsConsoleUI()) then
        doProminent = Crutch.savedOptions.console.showProminent
    else
        doProminent = Crutch.savedOptions.cloudrest.dropFrostProminent
    end

    if (doProminent) then
        Crutch.DisplayProminent(C.ID.DROP_FROST)
    end
end

local function OnHoarfrost(_, changeType, _, _, unitTag, beginTime, endTime, _, _, _, _, _, _, _, unitId, abilityId)
    if (changeType == EFFECT_RESULT_FADED) then
        Crutch.InterruptAbility(abilityId, true)
        Crutch.RemoveAttachedIconForUnit(unitTag, FROST_UNIQUE_NAME)

        if (AreUnitsEqual(unitTag, "player") and frostDropCallLaterId) then
            zo_removeCallLater(frostDropCallLaterId)
        end
    elseif (changeType == EFFECT_RESULT_GAINED) then
        -- Track the number of that particular frost
        local num = numFrosts[abilityId] + 1
        if (num == 4) then
            num = 1
        end
        numFrosts[abilityId] = num
        Crutch.dbgOther(GetUnitDisplayName(unitTag) .. " got hoarfrost #" .. num)

        -- If it's you...
        if (AreUnitsEqual(unitTag, "player")) then
            -- ... show timer until droppable...
            if (Crutch.savedOptions.cloudrest.showFrostAlert) then
                local label = zo_strformat("|c8ef5f5Drop <<C:1>> (<<2>>) in|r", GetAbilityName(abilityId), num == 3 and "last" or num)
                Crutch.DisplayNotification(abilityId, label, TIME_UNTIL_DROP, 0, 0, 0, 0, 0, 0, 0, false)
            end

            -- ... and also show drop timer/prominent later
            frostDropCallLaterId = zo_callLater(function() OnFrostDroppable(abilityId) end, TIME_UNTIL_DROP)
        end

        -- Add icon
        if (Crutch.savedOptions.cloudrest.showFrostIcons) then
            Crutch.SetAttachedIconForUnit(unitTag, FROST_UNIQUE_NAME, C.PRIORITY.MECHANIC_1_PRIORITY, "esoui/art/icons/heraldrycrests_misc_snowflake_01.dds", nil, {0, 0.9, 1})
        end
    end
end

-- Hoarfrost can get kinda weird if it gets taken into portal? So reset the numbers on new cast to be safe
local HOARFROST_CAST_TO_ID = {
    [HOARFROST_CAST_ID] = HOARFROST_ID,
    [HOARFROST_CAST_EXECUTE_ID] = HOARFROST_EXECUTE_ID,
}
local function OnHoarfrostCast(_, result, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    if (result == ACTION_RESULT_EFFECT_GAINED) then
        local frostId = HOARFROST_CAST_TO_ID[abilityId]
        numFrosts[frostId] = 0
        Crutch.dbgOther("resetting frost " .. frostId)
    end
end


---------------------------------------------------------------------
-- Voltaic initial
---------------------------------------------------------------------
local function OnVoltaicInitialDuration(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, _, abilityId)
    Crutch.DisplayNotification(abilityId, zo_strformat("<<C:1>>", GetAbilityName(abilityId)), hitValue, 0, 0, 0, 0, 0, 0, 0, false)
    Crutch.PlayMultiSound(SOUNDS.DUEL_BOUNDARY_WARNING, 3, 3, 1000)
end


---------------------------------------------------------------------
-- Flare icons
---------------------------------------------------------------------
local FLARE_UNIQUE_NAME = "CrutchAlertsCRFlare"

local cycleTime = 700
local function RoaringFlareUpdate(icon)
    local time = GetGameTimeMilliseconds() % cycleTime
    local t = time / cycleTime
    Crutch.Drawing.Animation.BoostUpdate(icon:GetCompositeTexture(), t)
end

local function OnRoaringFlareIcon(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    local unitTag = Crutch.groupIdToTag[targetUnitId]

    if (not unitTag) then return end

    Crutch.SetAttachedIconForUnit(
        unitTag,
        FLARE_UNIQUE_NAME,
        C.PRIORITY.MECHANIC_2_PRIORITY,
        nil,
        120,
        nil,
        false,
        RoaringFlareUpdate,
        {
            composite = {
                size = 1,
                init = function(composite)
                    Crutch.Drawing.Animation.BoostInitial(composite, C.RED, C.YELLOW)
                end,
            },
        })
    zo_callLater(function() Crutch.RemoveAttachedIconForUnit(unitTag, FLARE_UNIQUE_NAME) end, 7000)
end
Crutch.OnRoaringFlareIcon = OnRoaringFlareIcon
-- /script CrutchAlerts.groupIdToTag[12345] = "player" CrutchAlerts.OnRoaringFlareIcon(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 12345)


---------------------------------------------------------------------
-- EXECUTE FLARES
---------------------------------------------------------------------

-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnRoaringFlareGained(_, result, _, _, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (not amuletSmashed) then return end

    -- Actual display
    targetName = GetUnitDisplayName(Crutch.groupIdToTag[targetUnitId])
    if (targetName) then
        targetName = zo_strformat("<<1>>", targetName)
    else
        targetName = "UNKNOWN"
    end

    if (abilityId == 103531) then
        local label = string.format("|cff7700%s |cff0000|t100%%:100%%:Esoui/Art/Buttons/large_leftarrow_up.dds:inheritcolor|t |caaaaaaLEFT|r", targetName)
        Crutch.DisplayNotification(abilityId, label, hitValue, sourceUnitId, sourceName, sourceType, targetUnitId, targetName, targetType, result, true)
        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(zo_strformat("|cFF7700<<1>> < LEFT|r", targetName))
        end
    elseif (abilityId == 110431) then
        local label = string.format("|cff7700%s |cff0000|t100%%:100%%:Esoui/Art/Buttons/large_rightarrow_up.dds:inheritcolor|t |caaaaaaRIGHT|r", targetName)
        Crutch.DisplayNotification(abilityId, label, hitValue, sourceUnitId, sourceName, sourceType, targetUnitId, targetName, targetType, result, true)
        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(zo_strformat("|cFF7700<<1>> > RIGHT|r", targetName))
        end
    end
end

local function OnAmuletSmashed()
    amuletSmashed = true
end


---------------------------------------------------------------------
-- SPEARS
---------------------------------------------------------------------

-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnOlorimeSpears(_, result, _, _, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (abilityId == 104019) then
        -- Spear has appeared
        spearsRevealed = spearsRevealed + 1
        Crutch.UpdateSpearsDisplay(spearsRevealed, spearsSent, orbsDunked)
        if (Crutch.savedOptions.cloudrest.spearsSound) then
            PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
        end
        local label = string.format("|cFFEA00Olorime Spear!|r (%d)", spearsRevealed)
        Crutch.DisplayNotification(abilityId, label, hitValue, sourceUnitId, sourceName, sourceType, targetUnitId, targetName, targetType, result, false)

    elseif (abilityId == 104036) then
        -- Spear has been sent
        spearsSent = spearsSent + 1
        if (spearsRevealed < spearsSent) then spearsRevealed = spearsSent end
        Crutch.UpdateSpearsDisplay(spearsRevealed, spearsSent, orbsDunked)

    elseif (abilityId == 104047) then
        -- Orb has been dunked
        orbsDunked = orbsDunked + 1
        Crutch.UpdateSpearsDisplay(spearsRevealed, spearsSent, orbsDunked)
    end
end
-- /script CrutchAlerts.OnOlorimeSpears(104019)
function Crutch.OnOlorimeSpears(abilityId)
    OnOlorimeSpears(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, abilityId)
end

local function UpdateSpearsDisplay(spearsRevealed, spearsSent, orbsDunked)
    CrutchAlertsCloudrestSpear1:SetHidden(true)
    CrutchAlertsCloudrestSpear2:SetHidden(true)
    CrutchAlertsCloudrestSpear3:SetHidden(true)
    CrutchAlertsCloudrestCheck1:SetHidden(true)
    CrutchAlertsCloudrestCheck2:SetHidden(true)
    CrutchAlertsCloudrestCheck3:SetHidden(true)

    if (not Crutch.savedOptions.cloudrest.showSpears) then
        return
    end

    if (spearsRevealed == 0) then
        return
    end
    if (spearsRevealed >= 1) then
        CrutchAlertsCloudrestSpear1:SetHidden(false)
        if (spearsSent >= 1) then
            CrutchAlertsCloudrestSpear1:SetDesaturation(1)
        else
            CrutchAlertsCloudrestSpear1:SetDesaturation(0)
        end
    end
    if (spearsRevealed >= 2) then
        CrutchAlertsCloudrestSpear2:SetHidden(false)
        if (spearsSent >= 2) then
            CrutchAlertsCloudrestSpear2:SetDesaturation(1)
        else
            CrutchAlertsCloudrestSpear2:SetDesaturation(0)
        end
    end
    if (spearsRevealed >= 3) then
        CrutchAlertsCloudrestSpear3:SetHidden(false)
        if (spearsSent >= 3) then
            CrutchAlertsCloudrestSpear3:SetDesaturation(1)
        else
            CrutchAlertsCloudrestSpear3:SetDesaturation(0)
        end
    end

    if (orbsDunked >= 1) then
        CrutchAlertsCloudrestCheck1:SetHidden(false)
    end
    if (orbsDunked >= 2) then
        CrutchAlertsCloudrestCheck2:SetHidden(false)
    end
    if (orbsDunked >= 3) then
        CrutchAlertsCloudrestCheck3:SetHidden(false)
    end
end
Crutch.UpdateSpearsDisplay = UpdateSpearsDisplay

---------------------------------------------------------------------
-- Shade
---------------------------------------------------------------------
local groupShadowOfTheFallen = {}

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnShadowOfTheFallenChanged(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    Crutch.dbgOther(string.format("|cFF00FF%s(%s): %d %s|r", GetUnitDisplayName(unitTag), unitTag, stackCount, effectResults[changeType]))

    if (changeType == EFFECT_RESULT_GAINED) then
        groupShadowOfTheFallen[unitTag] = true
        Crutch.Drawing.OverrideDeadColor(unitTag, C.PURPLE)
    elseif (changeType == EFFECT_RESULT_FADED) then
        groupShadowOfTheFallen[unitTag] = false
        Crutch.Drawing.OverrideDeadColor(unitTag, nil)
    end
end

local function IsShadeUp(unitTag)
    return groupShadowOfTheFallen[unitTag] == true
end

---------------------------------------------------------------------
-- Diagnostics
---------------------------------------------------------------------
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnShedHoarfrost(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    local unitTag = Crutch.groupIdToTag[targetUnitId]
    Crutch.msg(zo_strformat("shed hoarfrost |cFF00FF<<1>>", GetUnitDisplayName(unitTag)))
end

local function OnAmplificationChanged(_, changeType, _, _, unitTag, _, _, stackCount)
    if (changeType == EFFECT_RESULT_GAINED) then
        Crutch.msg(zo_strformat("|c00FFFF<<1>> |cAAAAAAgained Amplification", GetUnitDisplayName(unitTag)))
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.msg(zo_strformat("|c00FFFF<<1>> |cAAAAAAlost Amplification at x<<2>>", GetUnitDisplayName(unitTag), stackCount))
    -- elseif (changeType == EFFECT_RESULT_UPDATED) then
    --     Crutch.msg(zo_strformat("|c00FFFF<<1>> |cAAAAAAupdated Amplification x<<2>>", GetUnitDisplayName(unitTag), stackCount))
    end
end

---------------------------------------------------------------------
-- Boss health bar thresholds
---------------------------------------------------------------------
local knownHealths = {[1] = {50}, [2] = {65, 35}, [3] = {75, 50, 25}}
local foundMiniShades = {} -- Key by unit id just in case there are dupes?
local zmajaThresholds = {}
local foundMinis = false

local function OverrideBHBThresholds()
    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "CRBossSpeedTimeout")

    foundMinis = true
    local numMinis = NonContiguousCount(foundMiniShades)
    ZO_ClearTable(zmajaThresholds)

    -- Add each threshold
    for _, threshold in ipairs(knownHealths[numMinis]) do
        zmajaThresholds[threshold] = "Mini"
    end

    Crutch.dbgOther("Inferred " .. numMinis .. " minis, overriding thresholds...")
    Crutch.BossHealthBar.AddThresholdOverride(Crutch.GetCapitalizedString(CRUTCH_BHB_ZMAJA), zmajaThresholds)
end

local function OnMiniBoss(_, _, _, _, _, _, _, _, _, _, _, _, _, _, sourceUnitId, targetUnitId)
    if (foundMinis) then return end

    -- We don't get the target names for this >:[
    Crutch.dbgSpam("detected a mini, unit ID " .. targetUnitId)
    foundMiniShades[targetUnitId] = true

    -- Since we've found a new shade, set a short timeout to wait for
    -- other shades to be found
    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "CRBossSpeedTimeout", 500, OverrideBHBThresholds)
end

---------------------------------------------------------------------
-- Reset/cleanup
local function ResetValuesOnWipe()
    Crutch.dbgSpam("|cFF7777Resetting Cloudrest values|r")
    amuletSmashed = false
    spearsRevealed = 0
    spearsSent = 0
    orbsDunked = 0
    Crutch.UpdateSpearsDisplay(spearsRevealed, spearsSent, orbsDunked)
    numFrosts[HOARFROST_ID] = 0
    numFrosts[HOARFROST_EXECUTE_ID] = 0

    -- mini detection
    foundMinis = false
    ZO_ClearTable(foundMiniShades)
    Crutch.BossHealthBar.RemoveThresholdOverride(Crutch.GetCapitalizedString(CRUTCH_BHB_ZMAJA))
end

---------------------------------------------------------------------
-- Register/Unregister
local origOSIUnitErrorCheck = nil
local origOSIGetIconDataForPlayer = nil

function Crutch.RegisterCloudrest()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Cloudrest")

    Crutch.RegisterExitedGroupCombatListener("ExitedCombatCloudrest", ResetValuesOnWipe)

    -- Register break amulet
    Crutch.RegisterForCombatEvent("CloudrestBreakAmulet", OnAmuletSmashed, ACTION_RESULT_EFFECT_GAINED, 106023) -- Breaking the amulet (takes 4 seconds)

    -- Register Flare icons
    if (Crutch.savedOptions.cloudrest.showFlareIcon) then
        Crutch.RegisterForCombatEvent("CloudrestFlareIcon1", OnRoaringFlareIcon, ACTION_RESULT_BEGIN, 103531, COMBAT_UNIT_TYPE_NONE) -- Flare 1 throughout the fight
        Crutch.RegisterForCombatEvent("CloudrestFlareIcon2", OnRoaringFlareIcon, ACTION_RESULT_BEGIN, 110431, COMBAT_UNIT_TYPE_NONE) -- Flare 2 in execute
    end

    -- Register Flare sides
    if (Crutch.savedOptions.cloudrest.showFlaresSides) then
        Crutch.RegisterForCombatEvent("CloudrestFlare1", OnRoaringFlareGained, ACTION_RESULT_BEGIN, 103531, COMBAT_UNIT_TYPE_NONE) -- Flare 1 throughout the fight
        Crutch.RegisterForCombatEvent("CloudrestFlare2", OnRoaringFlareGained, ACTION_RESULT_BEGIN, 110431, COMBAT_UNIT_TYPE_NONE) -- Flare 2 in execute
    end

    -- Register Hoarfrost for icons/alerts
    Crutch.RegisterForEffectChanged("CloudrestHoarfrost1", OnHoarfrost, HOARFROST_ID, "group")
    Crutch.RegisterForCombatEvent("CloudrestHoarfrostCast1", OnHoarfrostCast, nil, HOARFROST_CAST_ID)

    Crutch.RegisterForEffectChanged("CloudrestHoarfrost2", OnHoarfrost, HOARFROST_EXECUTE_ID, "group")
    Crutch.RegisterForCombatEvent("CloudrestHoarfrostCast2", OnHoarfrostCast, nil, HOARFROST_CAST_EXECUTE_ID)

    -- Register initial cast of voltaic to show how much time you have to swap to less important bar
    if (Crutch.savedOptions.cloudrest.showVoltaicAlert) then
        Crutch.RegisterForCombatEvent("VoltaicCurrentDuration", OnVoltaicInitialDuration, ACTION_RESULT_EFFECT_GAINED_DURATION, 103555, nil, COMBAT_UNIT_TYPE_PLAYER)
    end

    -- Register Olorime Spears - spear appearing
    Crutch.RegisterForCombatEvent("OlorimeSpears", OnOlorimeSpears, ACTION_RESULT_EFFECT_GAINED, 104019, COMBAT_UNIT_TYPE_NONE) -- Olorime Spears, hitvalue 1

    -- Register Welkynar's Light, 1250ms duration on person who sent spear
    Crutch.RegisterForCombatEvent("WelkynarsLight", OnOlorimeSpears, ACTION_RESULT_EFFECT_GAINED_DURATION, 104036) -- hitvalue 1250

    -- Register Shadow Piercer Exit, 500 duration on person who dunked orb
    Crutch.RegisterForCombatEvent("ShadowPiercerExit", OnOlorimeSpears, ACTION_RESULT_EFFECT_GAINED_DURATION, 104047) -- hitvalue 500

    -- Register for Shadow World effect gained/faded
    Crutch.RegisterForEffectChanged("ShadowWorldEffect", OnShadowWorldChanged, 108045, "group")
    -- And another ID for when you get knocked into portal by cone, because it's different... for some reason...
    Crutch.RegisterForEffectChanged("ShadowWorldEffectCone", OnShadowWorldChanged, 104620, "group")

    -- Register for Shadow of the Fallen effect gained/faded
    Crutch.RegisterForEffectChanged("ShadowFallenEffect", OnShadowOfTheFallenChanged, 102271, "group")

    -- Register summoning portal
    Crutch.RegisterForCombatEvent("ShadowRealmCast", function()
        spearsRevealed = 0
        spearsSent = 0
        orbsDunked = 0
        Crutch.UpdateSpearsDisplay(spearsRevealed, spearsSent, orbsDunked)
    end, nil, 103946)

    if (Crutch.savedOptions.general.showRaidDiag) then
        -- Register someone dropping hoarfrost
        Crutch.RegisterForCombatEvent("ShedHoarfrost", OnShedHoarfrost, ACTION_RESULT_EFFECT_GAINED_DURATION, 103714)

        -- Register voltaic
        Crutch.RegisterForEffectChanged("AmplificationDiag", OnAmplificationChanged, 109022, "group")
    end

    -- Listen for mini shades to determine Z'Maja thresholds
    if (Crutch.savedOptions.bossHealthBar.enabled) then
        Crutch.RegisterForCombatEvent("CRMiniBossDetect", OnMiniBoss, ACTION_RESULT_EFFECT_GAINED_DURATION, 105541)
    end

    -- Override OdySupportIcons to also check whether the group member is in the same portal vs not portal
    if (OSI and OSI.UnitErrorCheck and OSI.GetIconDataForPlayer) then
        Crutch.dbgOther("|c88FFFF[CT]|r Overriding OSI.UnitErrorCheck and OSI.GetIconDataForPlayer")
        origOSIUnitErrorCheck = OSI.UnitErrorCheck
        OSI.UnitErrorCheck = function(unitTag, allowSelf)
            local error = origOSIUnitErrorCheck(unitTag, allowSelf)
            if (error ~= 0) then
                return error
            end
            if (IsInShadowWorld(Crutch.playerGroupTag) == IsInShadowWorld(unitTag)) then
                return 0
            else
                return 8
            end
        end

        -- Override the dead icon to be purple with shade up
        origOSIGetIconDataForPlayer = OSI.GetIconDataForPlayer
        OSI.GetIconDataForPlayer = function(displayName, config, unitTag)
            local icon, color, size, anim, offset, isMech = origOSIGetIconDataForPlayer(displayName, config, unitTag)

            local isDead = unitTag and IsUnitDead(unitTag) or false
            if (config.dead and isDead and IsShadeUp(unitTag) and Crutch.savedOptions.cloudrest.deathIconColor) then
                color = C.PURPLE
            end

            return icon, color, size, anim, offset, isMech
        end
    end

    -- Suppress attached icons when in different portal
    Crutch.Drawing.RegisterSuppressionFilter(PORTAL_SUPPRESSION_FILTER, CRPortalFilter)
end

function Crutch.UnregisterCloudrest()
    Crutch.UnregisterExitedGroupCombatListener("ExitedCombatCloudrest")

    Crutch.UnregisterForCombatEvent("CloudrestBreakAmulet")
    Crutch.UnregisterForCombatEvent("CloudrestFlareIcon1")
    Crutch.UnregisterForCombatEvent("CloudrestFlareIcon2")
    Crutch.UnregisterForCombatEvent("CloudrestFlare1")
    Crutch.UnregisterForCombatEvent("CloudrestFlare2")
    Crutch.UnregisterForEffectChanged("CloudrestHoarfrost1")
    Crutch.UnregisterForCombatEvent("CloudrestHoarfrostCast1")
    Crutch.UnregisterForEffectChanged("CloudrestHoarfrost2")
    Crutch.UnregisterForCombatEvent("CloudrestHoarfrostCast2")
    Crutch.UnregisterForCombatEvent("VoltaicCurrentDuration")
    Crutch.UnregisterForCombatEvent("OlorimeSpears")
    Crutch.UnregisterForCombatEvent("WelkynarsLight")
    Crutch.UnregisterForCombatEvent("ShadowPiercerExit")
    Crutch.UnregisterForEffectChanged("ShadowWorldEffect")
    Crutch.UnregisterForEffectChanged("ShadowWorldEffectCone")
    Crutch.UnregisterForEffectChanged("ShadowFallenEffect")
    Crutch.UnregisterForCombatEvent("ShadowRealmCast")
    Crutch.UnregisterForCombatEvent("ShedHoarfrost")
    Crutch.UnregisterForEffectChanged("AmplificationDiag")
    Crutch.UnregisterForCombatEvent("CRMiniBossDetect")

    if (OSI and origOSIUnitErrorCheck) then
        Crutch.dbgOther("|c88FFFF[CT]|r Restoring OSI.UnitErrorCheck and OSI.GetIconDataForPlayer")
        OSI.UnitErrorCheck = origOSIUnitErrorCheck
        OSI.GetIconDataForPlayer = origOSIGetIconDataForPlayer
    end

    Crutch.Drawing.UnregisterSuppressionFilter(PORTAL_SUPPRESSION_FILTER)

    ResetValuesOnWipe()

    -- Clean up in case of PTE; unit tags may change
    Crutch.RemoveAllAttachedIcons(FROST_UNIQUE_NAME)
    Crutch.RemoveAllAttachedIcons(FLARE_UNIQUE_NAME)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Cloudrest")
end
