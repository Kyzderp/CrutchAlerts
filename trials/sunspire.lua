CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

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
    if (Crutch.savedOptions.debugOther) then
        d(string.format("|c8C00FF%s(%s): %d %s|r", GetUnitDisplayName(unitTag), unitTag, stackCount, effectResults[changeType]))
    end

    if (changeType == EFFECT_RESULT_GAINED) then
        groupTimeBreach[unitTag] = true
    elseif (changeType == EFFECT_RESULT_FADED) then
        groupTimeBreach[unitTag] = false
    end
end

local function IsInNahvPortal(unitTag)
    if (not unitTag) then unitTag = Crutch.playerGroupTag end

    if (groupTimeBreach[unitTag]) then return true end

    return false
end
Crutch.IsInNahvPortal = IsInNahvPortal

local function OnCombatStateChanged(_, inCombat)
    -- Reset
    if (not inCombat) then
        groupTimeBreach = {}
    end
end

---------------------------------------------------------------------
-- Check each group member to see who has the Focused Fire DEBUFF
local function OnFocusFireGained(_, result, _, _, _, _, sourceName, sourceType, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    local toClear = {}
    for g = 1, GetGroupSize() do
        local unitTag = "group" .. tostring(g)
        local hasFocusedFire = false
        for i = 1, GetNumBuffs(unitTag) do
            local buffName, _, _, _, stackCount, iconFilename, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unitTag, i)
            if (abilityId == 121726) then
                d(string.format("|cAAAAAA%s|r has %d x %s", GetUnitDisplayName(unitTag), stackCount, buffName))
                hasFocusedFire = true
                break
            end
        end

        if (OSI and not hasFocusedFire) then
            OSI.SetMechanicIconForUnit(GetUnitDisplayName(unitTag), "odysupporticons/icons/squares/marker_lightblue.dds")
            table.insert(toClear, GetUnitDisplayName(unitTag))
        end
    end

    -- Clear icons 7 seconds later
    if (OSI) then
        OSI.SetMechanicIconSize(200)
        EVENT_MANAGER:RegisterForUpdate(CrutchAlerts.name .. "ClearIcons", 7000, function()
                EVENT_MANAGER:UnregisterForUpdate(CrutchAlerts.name .. "ClearIcons")
                for _, name in pairs(toClear) do
                    OSI.RemoveMechanicIconForUnit(name)
                end
                OSI.ResetMechanicIconSize()
            end)
    end
end

---------------------------------------------------------------------
-- Register/Unregister
local origOSIUnitErrorCheck = nil

function Crutch.RegisterSunspire()
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CT]|r Registered Sunspire") end

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "SunspireCombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    EVENT_MANAGER:RegisterForEvent(CrutchAlerts.name .. "FocusFireBegin", EVENT_COMBAT_EVENT, OnFocusFireGained)
    EVENT_MANAGER:AddFilterForEvent(CrutchAlerts.name .. "FocusFireBegin", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(CrutchAlerts.name .. "FocusFireBegin", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 121722)
    -- TODO: only show for self option

    -- Register for Time Breach effect gained/faded
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED, OnTimeBreachChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 121216)

     -- Override OdySupportIcons to also check whether the group member is in the same portal vs not portal
    if (OSI) then
        if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CT]|r Overriding OSI.UnitErrorCheck") end
        origOSIUnitErrorCheck = OSI.UnitErrorCheck
        OSI.UnitErrorCheck = function(unitTag)
            local error = origOSIUnitErrorCheck(unitTag)
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

    if (not Crutch.WorldIconsEnabled()) then
        Crutch.msg("You must install OdySupportIcons 1.6.3+ to display in-world icons")
    else
        -- TODO: only show these in vet, and HM, and optionally only during flight phase
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

        Crutch.EnableIcon("YolWing2")
        Crutch.EnableIcon("YolWing3")
        Crutch.EnableIcon("YolWing4")
        Crutch.EnableIcon("YolHead2")
        Crutch.EnableIcon("YolHead3")
        Crutch.EnableIcon("YolHead4")
    end
end

function Crutch.UnregisterSunspire()
    EVENT_MANAGER:UnregisterForEvent(CrutchAlerts.name .. "FocusFireBegin", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED, OnTimeBreachChanged)

    if (OSI and origOSIUnitErrorCheck) then
        if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CT]|r Restoring OSI.UnitErrorCheck") end
        OSI.UnitErrorCheck = origOSIUnitErrorCheck
    end

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

    Crutch.DisableIcon("YolWing2")
    Crutch.DisableIcon("YolWing3")
    Crutch.DisableIcon("YolWing4")
    Crutch.DisableIcon("YolHead2")
    Crutch.DisableIcon("YolHead3")
    Crutch.DisableIcon("YolHead4")

    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CT]|r Unregistered Sunspire") end
end
