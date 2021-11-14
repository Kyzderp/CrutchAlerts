CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
local amuletSmashed = false
local spearsRevealed = 0
local spearsSent = 0
local orbsDunked = 0

---------------------------------------------------------------------
local effectResults = {
    [EFFECT_RESULT_FADED] = "FADED",
    [EFFECT_RESULT_FULL_REFRESH] = "FULL_REFRESH",
    [EFFECT_RESULT_GAINED] = "GAINED",
    [EFFECT_RESULT_TRANSFER] = "TRANSFER",
    [EFFECT_RESULT_UPDATED] = "UPDATED",
}

local groupShadowWorld = {}

local function DebugShadowWorld()
    local result = {}
    for unitTag, inShadowWorld in pairs(groupShadowWorld) do
        if (DoesUnitExist(unitTag)) then
            table.insert(result, string.format("|cAAAAAA%s |c44FF44%s |r%s - %d", unitTag, GetUnitDisplayName(unitTag), inShadowWorld and "portal" or "up", (OSI == nil) and "?" or OSI.UnitErrorCheck(unitTag)))
        end
    end

    local resultString = table.concat(result, "\n") .. "\nplayerGroupTag = " .. Crutch.playerGroupTag

    Crutch.DebugUI(resultString)
end
Crutch.DebugShadowWorld = DebugShadowWorld

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnShadowWorldChanged(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    Crutch.dbgOther(string.format("|c8C00FF%s(%s): %d %s|r", GetUnitDisplayName(unitTag), unitTag, stackCount, effectResults[changeType]))

    if (changeType == EFFECT_RESULT_GAINED) then
        groupShadowWorld[unitTag] = true
    elseif (changeType == EFFECT_RESULT_FADED) then
        groupShadowWorld[unitTag] = false
    end

    DebugShadowWorld()
end

---------------------------------------------------------------------
-- PLAYER STATE
---------------------------------------------------------------------
local function IsInShadowWorld(unitTag)
    if (not unitTag) then unitTag = Crutch.playerGroupTag end

    if (groupShadowWorld[unitTag] == true) then return true end

    return false
end
Crutch.IsInShadowWorld = IsInShadowWorld

local function OnWipe()
    -- Reset
    if (not IsUnitInCombat("player")) then
        Crutch.dbgOther("|cFF7777Resetting Cloudrest values|r")
        amuletSmashed = false
        spearsRevealed = 0
        spearsSent = 0
        orbsDunked = 0
        Crutch.UpdateSpearsDisplay(spearsRevealed, spearsSent, orbsDunked)
    end
end

local function OnCombatStateChanged(_, inCombat)
    -- This is weird because we exit combat when entering portal, so it shouldn't
    -- actually trigger a reset. Check again 3 seconds later whether we're out
    if (not inCombat) then
        zo_callLater(OnWipe, 3000)
    end
end

---------------------------------------------------------------------
-- EXECUTE FLARES
---------------------------------------------------------------------

-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnRoaringFlareGained(_, result, _, _, _, _, sourceName, sourceType, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (not amuletSmashed) then return end

    -- Actual display
    targetName = Crutch.groupMembers[targetUnitId]
    if (targetName) then
        targetName = zo_strformat("<<1>>", targetName)
    else
        targetName = "UNKNOWN"
    end

    if (abilityId == 103531) then
        local label = string.format("|cff7700%s |cff0000|t100%%:100%%:Esoui/Art/Buttons/large_leftarrow_up.dds:inheritcolor|t |caaaaaaLEFT|r", targetName)
        Crutch.DisplayNotification(abilityId, label, hitValue, sourceUnitId, sourceName, sourceType, result, true)
        -- /script CrutchAlerts.DisplayNotification(103531, string.format("|cff0000|t100%%:100%%:Esoui/Art/Buttons/large_leftarrow_up.dds:inheritcolor|t |cff7700%s |caaaaaaLEFT|r", "@TheClawlessConqueror"), 1, 0, 0, 0, 0)
    elseif (abilityId == 110431) then
        local label = string.format("|cff7700%s |cff0000|t100%%:100%%:Esoui/Art/Buttons/large_rightarrow_up.dds:inheritcolor|t |caaaaaaRIGHT|r", targetName)
        Crutch.DisplayNotification(abilityId, label, hitValue, sourceUnitId, sourceName, sourceType, result, true)
        -- /script CrutchAlerts.DisplayNotification(110431, string.format("|cff7700%s |caaaaaaRIGHT |cff0000|t100%%:100%%:Esoui/Art/Buttons/large_rightarrow_up.dds:inheritcolor|t|r", "@Kyzeragon"), 1, 0, 0, 0, 0)
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
-- Register/Unregister
local origOSIUnitErrorCheck = nil

function Crutch.RegisterCloudrest()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Cloudrest")
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CloudrestCombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    -- Register break amulet
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CloudrestBreakAmulet", EVENT_COMBAT_EVENT, OnAmuletSmashed)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestBreakAmulet", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestBreakAmulet", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 106023) -- Breaking the amulet (takes 4 seconds)

    -- Register the Roaring Flares
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT, OnRoaringFlareGained)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) -- from enemy
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 103531) -- Flare 1 throughout the fight

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT, OnRoaringFlareGained)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE) -- from enemy
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 110431) -- Flare 2 in execute

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

    -- Register summoning portal
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ShadowRealmCast", EVENT_COMBAT_EVENT, function()
        spearsRevealed = 0
        spearsSent = 0
        orbsDunked = 0
        Crutch.UpdateSpearsDisplay(spearsRevealed, spearsSent, orbsDunked)
    end)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ShadowRealmCast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 103946)

    -- Override OdySupportIcons to also check whether the group member is in the same portal vs not portal
    if (OSI) then
        Crutch.dbgOther("|c88FFFF[CT]|r Overriding OSI.UnitErrorCheck")
        origOSIUnitErrorCheck = OSI.UnitErrorCheck
        OSI.UnitErrorCheck = function(unitTag)
            local error = origOSIUnitErrorCheck(unitTag)
            if (error ~= 0) then
                return error
            end
            if (IsInShadowWorld(Crutch.playerGroupTag) == IsInShadowWorld(unitTag)) then
                return 0
            else
                return 8
            end
        end
    end
end

function Crutch.UnregisterCloudrest()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "CloudrestCombatState", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "CloudrestBreakAmulet", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "CloudrestFlare1", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "CloudrestFlare2", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OlorimeSpears", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "WelkynarsLight", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ShadowPiercerExit", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ShadowWorldEffect", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ShadowRealmCast", EVENT_COMBAT_EVENT)

    if (OSI and origOSIUnitErrorCheck) then
        Crutch.dbgOther("|c88FFFF[CT]|r Restoring OSI.UnitErrorCheck")
        OSI.UnitErrorCheck = origOSIUnitErrorCheck
    end

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Cloudrest")
end
