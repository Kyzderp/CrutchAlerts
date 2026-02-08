local Crutch = CrutchAlerts
local RG = Crutch.Rockgrove
local C = Crutch.Constants


---------------------------------------------------------------------
-- Bahsei
---------------------------------------------------------------------
local effectResults = {
    [EFFECT_RESULT_FADED] = "FADED",
    [EFFECT_RESULT_FULL_REFRESH] = "FULL_REFRESH",
    [EFFECT_RESULT_GAINED] = "|cb95effGAINED",
    [EFFECT_RESULT_TRANSFER] = "TRANSFER",
    [EFFECT_RESULT_UPDATED] = "UPDATED",
}

local groupBitterMarrow = {}

local function UpdatePlayersInPortal()
    if (not Crutch.savedOptions.rockgrove.panel.showNumInPortal) then return end
    local count = 0
    local names = ""
    for unitTag, hasMarrow in pairs(groupBitterMarrow) do
        if (hasMarrow == true) then
            count = count + 1
            names = string.format("%s%s(%s) ", names, GetUnitDisplayName(unitTag), unitTag)
        end
    end
    Crutch.InfoPanel.SetLine(RG.PANEL_PORTAL_COUNT_INDEX, "|c9999ff" .. count .. " in portal")
    Crutch.InfoPanel.SetLine(RG.PANEL_PORTAL_PLAYERS_INDEX, "|c9999ff" .. names, 0.4)
end

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnBitterMarrowChanged(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    Crutch.dbgOther(string.format("|c8C00FF%s(%s): %d %s|r", GetUnitDisplayName(unitTag), unitTag, stackCount, effectResults[changeType]))

    local changed = false
    if (changeType == EFFECT_RESULT_GAINED) then
        groupBitterMarrow[unitTag] = true
        changed = true
    elseif (changeType == EFFECT_RESULT_FADED) then
        groupBitterMarrow[unitTag] = false
        changed = true
    end

    -- Update suppression
    if (changed) then
        -- If it was the player entering or exiting portal, all units need to be refreshed
        if (AreUnitsEqual("player", unitTag)) then
            Crutch.Drawing.EvaluateAllSuppression()
            RG.linesHidden = groupBitterMarrow[unitTag]
        else
            Crutch.Drawing.EvaluateSuppressionFor(unitTag)
        end

        UpdatePlayersInPortal()
    end
end

-- Player state
local function IsInBahseiPortal(unitTag)
    if (not unitTag) then unitTag = Crutch.playerGroupTag end

    if (groupBitterMarrow[unitTag] == true) then return true end

    return false
end

-- Suppression for attached icons
local PORTAL_SUPPRESSION_FILTER = "CrutchAlertsBahseiPortal"
local function BahseiPortalFilter(unitTag)
    return IsInBahseiPortal(unitTag) == IsInBahseiPortal(Crutch.playerGroupTag)
end


---------------------------------------------------------------------
-- Pre-portal ability icons & portal timers
---------------------------------------------------------------------
-- 20s to start
-- 50s after previous finished
local nextPortal = 1
local nextPortalTimer = 20
local function OnPortalSummoned(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    Crutch.InfoPanel.StopCount(RG.PANEL_PORTAL_TIMER_INDEX)
    UpdatePlayersInPortal()

    if (Crutch.savedOptions.rockgrove.panel.showPortalDirection) then
        local display = Crutch.format[abilityId]
        if (display) then
            Crutch.InfoPanel.SetLine(RG.PANEL_PORTAL_DIRECTION_INDEX, "|c9999ff" .. display.text)
        end
    end
end

local spoofedAbilities = {} -- Just for cleanup. {abilityId = true}

local function SpoofIcon(abilityId)
    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "BahseiIconChange" .. abilityId)
    spoofedAbilities[abilityId] = true
    Crutch.SetAbilityOverlay(abilityId)
    Crutch.dbgOther("Changing " .. GetAbilityName(abilityId))
end

local function UnspoofAllIcons()
    for abilityId, _ in pairs(spoofedAbilities) do
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "BahseiIconChange" .. abilityId)
        Crutch.RemoveAbilityOverlay(abilityId)
    end
end

-- Target time after portal spawns, e.g. Quick Cloak lasts 30s, margin is 4s, so icon should be changed at 26s before next portal
local function MaybeChangeIconLater(abilityId, msUntilPortal)
    if (not Crutch.savedOptions.rockgrove.abilitiesToReplace[abilityId]) then return end

    -- Time in ms until icon change
    local delay = msUntilPortal + Crutch.savedOptions.rockgrove.portalTimeMargin - GetAbilityDuration(abilityId)
    Crutch.dbgOther("Will change " .. GetAbilityName(abilityId) .. " icon in " .. delay .. "ms")
    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "BahseiIconChange" .. abilityId, delay, function() SpoofIcon(abilityId) end)
end

local function IsMyPortal(nextPortal)
    local myPortal = Crutch.savedOptions.rockgrove.portalNumber
    if (myPortal == 0) then return false end

    return myPortal == nextPortal
end

local function OnPortalEnded()
    nextPortal = (nextPortal == 1) and 2 or 1

    Crutch.InfoPanel.RemoveLine(RG.PANEL_PORTAL_COUNT_INDEX)
    Crutch.InfoPanel.RemoveLine(RG.PANEL_PORTAL_PLAYERS_INDEX)
    Crutch.InfoPanel.RemoveLine(RG.PANEL_PORTAL_DIRECTION_INDEX)

    if (Crutch.savedOptions.rockgrove.panel.showTimeToPortal) then
        Crutch.InfoPanel.CountDownDuration(RG.PANEL_PORTAL_TIMER_INDEX, "|c9999ffPortal " .. nextPortal .. ": ", 50000)
    end

    UnspoofAllIcons()

    if (not IsMyPortal(nextPortal)) then return end

    -- Check if any skills are slotted
    for i = 3, 8 do
        MaybeChangeIconLater(GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY), 50000)
        MaybeChangeIconLater(GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP), 50000)
    end
end

local function OnEnteredCombat()
    -- Check that it's Bahsei HM
    local _, maxHp = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (maxHp ~= 123882576) then
        return
    end

    if (Crutch.savedOptions.rockgrove.panel.showTimeToPortal) then
        Crutch.InfoPanel.CountDownDuration(RG.PANEL_PORTAL_TIMER_INDEX, "|c9999ffPortal 1: ", 20000)
    end

    if (not IsMyPortal(1)) then return end

    -- Check if any skills are slotted
    for i = 3, 8 do
        MaybeChangeIconLater(GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY), 20000)
        MaybeChangeIconLater(GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP), 20000)
    end
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
local origOSIUnitErrorCheck = nil

function RG.RegisterBahseiPortal()
    Crutch.RegisterEnteredGroupCombatListener("RockgroveBahseiPortalEnteredCombat", OnEnteredCombat)

    Crutch.RegisterExitedGroupCombatListener("RockgroveBahseiPortalExitedCombat", function()
        nextPortal = 1
        nextPortalTimer = 20
        UnspoofAllIcons()
        ZO_ClearTable(groupBitterMarrow)
        Crutch.InfoPanel.StopCount(RG.PANEL_PORTAL_TIMER_INDEX)
        Crutch.InfoPanel.RemoveLine(RG.PANEL_PORTAL_COUNT_INDEX)
        Crutch.InfoPanel.RemoveLine(RG.PANEL_PORTAL_PLAYERS_INDEX)
        Crutch.InfoPanel.RemoveLine(RG.PANEL_PORTAL_DIRECTION_INDEX)
    end)

    -- Register for Bahsei portal effect gained/faded
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED, OnBitterMarrowChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 153423)

    -- Register for Portal summon and end
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Clockwise", EVENT_COMBAT_EVENT, OnPortalSummoned)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Clockwise", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Clockwise", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153517)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CounterClockwise", EVENT_COMBAT_EVENT, OnPortalSummoned)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CounterClockwise", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CounterClockwise", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153518)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "PortalExplode", EVENT_COMBAT_EVENT, OnPortalEnded)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "PortalExplode", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "PortalExplode", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153662)

    -- Override OdySupportIcons to also check whether the group member is in the same portal vs not portal
    if (OSI and OSI.UnitErrorCheck) then
        Crutch.dbgOther("|c88FFFF[CT]|r Overriding OSI.UnitErrorCheck")
        origOSIUnitErrorCheck = OSI.UnitErrorCheck
        OSI.UnitErrorCheck = function(unitTag, allowSelf)
            local error = origOSIUnitErrorCheck(unitTag, allowSelf)
            if (error ~= 0) then
                return error
            end
            if (IsInBahseiPortal(Crutch.playerGroupTag) == IsInBahseiPortal(unitTag)) then
                return 0
            else
                return 8
            end
        end
    end

    -- Suppress attached icons when in different portal
    Crutch.Drawing.RegisterSuppressionFilter(PORTAL_SUPPRESSION_FILTER, BahseiPortalFilter)
end

function RG.UnregisterBahseiPortal()
    ZO_ClearTable(groupBitterMarrow)
    Crutch.UnregisterEnteredGroupCombatListener("RockgroveBahseiPortalEnteredCombat", OnEnteredCombat)

    Crutch.UnregisterExitedGroupCombatListener("RockgroveBahseiPortalExitedCombat")

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Clockwise", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "CounterClockwise", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "PortalExplode", EVENT_COMBAT_EVENT)

    if (OSI and origOSIUnitErrorCheck) then
        Crutch.dbgOther("|c88FFFF[CT]|r Restoring OSI.UnitErrorCheck")
        OSI.UnitErrorCheck = origOSIUnitErrorCheck
    end

    Crutch.Drawing.UnregisterSuppressionFilter(PORTAL_SUPPRESSION_FILTER)
end
