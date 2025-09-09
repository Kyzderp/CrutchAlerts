local Crutch = CrutchAlerts

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
-- EXECUTE FLARES
---------------------------------------------------------------------

-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnRoaringFlareGained(_, result, _, _, _, _, sourceName, sourceType, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
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
        Crutch.DisplayNotification(abilityId, label, hitValue, sourceUnitId, sourceName, sourceType, result, true)
        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(zo_strformat("|cFF7700<<1>> < LEFT|r", targetName))
        end
    elseif (abilityId == 110431) then
        local label = string.format("|cff7700%s |cff0000|t100%%:100%%:Esoui/Art/Buttons/large_rightarrow_up.dds:inheritcolor|t |caaaaaaRIGHT|r", targetName)
        Crutch.DisplayNotification(abilityId, label, hitValue, sourceUnitId, sourceName, sourceType, result, true)
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
local function OnOlorimeSpears(_, result, _, _, _, _, sourceName, sourceType, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (abilityId == 104019) then
        -- Spear has appeared
        spearsRevealed = spearsRevealed + 1
        Crutch.UpdateSpearsDisplay(spearsRevealed, spearsSent, orbsDunked)
        if (Crutch.savedOptions.cloudrest.spearsSound) then
            PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
        end
        local label = string.format("|cFFEA00Olorime Spear!|r (%d)", spearsRevealed)
        Crutch.DisplayNotification(abilityId, label, hitValue, sourceUnitId, sourceName, sourceType, result, false)

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
        Crutch.Drawing.OverrideDeadColor(unitTag, {0.8, 0.2, 1})
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
-- Register/Unregister
local origOSIUnitErrorCheck = nil
local origOSIGetIconDataForPlayer = nil

function Crutch.RegisterCloudrest()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Cloudrest")

    Crutch.RegisterExitedGroupCombatListener("ExtiedCombatCloudrest", function()
        Crutch.dbgOther("|cFF7777Resetting Cloudrest values|r")
        amuletSmashed = false
        spearsRevealed = 0
        spearsSent = 0
        orbsDunked = 0
        Crutch.UpdateSpearsDisplay(spearsRevealed, spearsSent, orbsDunked)
    end)

    -- Register break amulet
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CloudrestBreakAmulet", EVENT_COMBAT_EVENT, OnAmuletSmashed)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestBreakAmulet", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestBreakAmulet", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 106023) -- Breaking the amulet (takes 4 seconds)

    -- Register the Roaring Flares
    if (Crutch.savedOptions.cloudrest.showFlaresSides) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT, OnRoaringFlareGained)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) -- from enemy
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 103531) -- Flare 1 throughout the fight

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT, OnRoaringFlareGained)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) -- from enemy
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 110431) -- Flare 2 in execute
    end

    -- Register Olorime Spears - spear appearing
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "OlorimeSpears", EVENT_COMBAT_EVENT, OnOlorimeSpears)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OlorimeSpears", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OlorimeSpears", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OlorimeSpears", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 104019) -- Olorime Spears, hitvalue 1

    -- Register Welkynar's Light, 1250ms duration on person who sent spear
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "WelkynarsLight", EVENT_COMBAT_EVENT, OnOlorimeSpears)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "WelkynarsLight", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "WelkynarsLight", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 104036) -- hitvalue 1250

    -- Register Shadow Piercer Exit, 500 duration on person who dunked orb
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ShadowPiercerExit", EVENT_COMBAT_EVENT, OnOlorimeSpears)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ShadowPiercerExit", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ShadowPiercerExit", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 104047) -- hitvalue 500

    -- Register for Shadow World effect gained/faded
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ShadowWorldEffect", EVENT_EFFECT_CHANGED, OnShadowWorldChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ShadowWorldEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ShadowWorldEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ShadowWorldEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 108045)

    -- Register for Shadow of the Fallen effect gained/faded
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ShadowFallenEffect", EVENT_EFFECT_CHANGED, OnShadowOfTheFallenChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ShadowFallenEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ShadowFallenEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ShadowFallenEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 102271)

    -- Register summoning portal
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ShadowRealmCast", EVENT_COMBAT_EVENT, function()
        spearsRevealed = 0
        spearsSent = 0
        orbsDunked = 0
        Crutch.UpdateSpearsDisplay(spearsRevealed, spearsSent, orbsDunked)
    end)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ShadowRealmCast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 103946)

    if (Crutch.savedOptions.general.showRaidDiag) then
        -- Register someone dropping hoarfrost
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ShedHoarfrost", EVENT_COMBAT_EVENT, OnShedHoarfrost)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ShedHoarfrost", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ShedHoarfrost", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 103714)

        -- Register voltaic
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AmplificationDiag", EVENT_EFFECT_CHANGED, OnAmplificationChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "AmplificationDiag", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "AmplificationDiag", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 109022)
    end

    -- Override OdySupportIcons to also check whether the group member is in the same portal vs not portal
    if (OSI) then
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
                color = {0.8, 0.2, 1} -- Puuuuurpl
            end

            return icon, color, size, anim, offset, isMech
        end
    end

    -- Suppress attached icons when in different portal
    Crutch.Drawing.RegisterSuppressionFilter(PORTAL_SUPPRESSION_FILTER, CRPortalFilter)
end

function Crutch.UnregisterCloudrest()
    Crutch.UnregisterExitedGroupCombatListener("ExtiedCombatCloudrest")

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "CloudrestBreakAmulet", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OlorimeSpears", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "WelkynarsLight", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ShadowPiercerExit", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ShadowWorldEffect", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ShadowFallenEffect", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ShadowRealmCast", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ShedHoarfrost", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "AmplificationDiag", EVENT_EFFECT_CHANGED)

    if (OSI and origOSIUnitErrorCheck) then
        Crutch.dbgOther("|c88FFFF[CT]|r Restoring OSI.UnitErrorCheck and OSI.GetIconDataForPlayer")
        OSI.UnitErrorCheck = origOSIUnitErrorCheck
        OSI.GetIconDataForPlayer = origOSIGetIconDataForPlayer
    end

    Crutch.Drawing.UnregisterSuppressionFilter(PORTAL_SUPPRESSION_FILTER)

    amuletSmashed = false
    spearsRevealed = 0
    spearsSent = 0
    orbsDunked = 0
    Crutch.UpdateSpearsDisplay(spearsRevealed, spearsSent, orbsDunked)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Cloudrest")
end
