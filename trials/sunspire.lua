CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

local isInCombat = false

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

---------------------------------------------------------------------
-- Lokkestiiz Icons
---------------------------------------------------------------------
local atLokk = false
local lokkHM = false
local lokkBeamPhase = false

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
Crutch.EnableLokkIcons = EnableLokkIcons

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

local function UpdateLokkIcons()
    Crutch.dbgOther(string.format("attempting to update icons atLokk: %s lokkHM: %s lokkBeamPhase: %s", tostring(atLokk), tostring(lokkHM), tostring(lokkBeamPhase)))
    if (atLokk and lokkHM and (lokkBeamPhase or not isInCombat)) then
        EnableLokkIcons()
    else
        DisableLokkIcons()
    end
end

local function IsBossLokkHM()
    local _, maxHealth = GetUnitPower("boss1", POWERTYPE_HEALTH)
    return maxHealth == 107806440
end

local function OnLokkFly()
    lokkBeamPhase = true
    lokkHM = IsBossLokkHM()
    UpdateLokkIcons()
end

local function OnLokkBeam()
    zo_callLater(function()
        lokkBeamPhase = false
        UpdateLokkIcons()
    end, 15000)
end

local function OnDifficultyChanged(text)
    local _, maxHealth = GetUnitPower("boss1", POWERTYPE_HEALTH)

    -- Lokkestiiz check
    if (maxHealth == 86245152 and lokkHM == true) then
        lokkHM = false
        UpdateLokkIcons()
    elseif (maxHealth == 107806440 and lokkHM == false) then
        lokkHM = true
        UpdateLokkIcons()
    else
        Crutch.dbgOther(string.format("maxHealth: %d lokkHM: %s", maxHealth or 0, lokkHM and "true" or "false"))
    end
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
    Crutch.EnableIcon("YolWing2")
    Crutch.EnableIcon("YolHead2")
    zo_callLater(function()
        Crutch.DisableIcon("YolWing2")
        Crutch.DisableIcon("YolHead2")
    end, 25000)
end

local function OnYolFly50()
    if (not Crutch.savedOptions.sunspire.showYolIcons) then return end
    Crutch.EnableIcon("YolWing3")
    Crutch.EnableIcon("YolHead3")
    zo_callLater(function()
        Crutch.DisableIcon("YolWing3")
        Crutch.DisableIcon("YolHead3")
    end, 25000)
end

local function OnYolFly25()
    if (not Crutch.savedOptions.sunspire.showYolIcons) then return end
    Crutch.EnableIcon("YolWing4")
    Crutch.EnableIcon("YolHead4")
    zo_callLater(function()
        Crutch.DisableIcon("YolWing4")
        Crutch.DisableIcon("YolHead4")
    end, 25000)
end

local function OnYolFly()
    local currHealth, maxHealth = GetUnitPower("boss1", POWERTYPE_HEALTH)
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

local prevBoss = nil
local function OnBossesChanged()
    -- Lokk: 86.2m / 107.8m : 86245152 / 107806440
    -- Yol: 129.4m / 161.7m
    -- Nahv: 103.5m / 129.4m
    local bossName = GetUnitName("boss1")
    if (prevBoss == bossName) then return end

    local _, maxHealth = GetUnitPower("boss1", POWERTYPE_HEALTH)

    -- Lokkestiiz check
    if (maxHealth == 86245152 or maxHealth == 107806440) then
        atLokk = true
        UpdateLokkIcons()
    else
        atLokk = false
        UpdateLokkIcons()
    end

    prevBoss = bossName
end

---------------------------------------------------------------------
-- Focused Fire
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
        EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "ClearIcons", 7000, function()
                EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "ClearIcons")
                for _, name in pairs(toClear) do
                    OSI.RemoveMechanicIconForUnit(name)
                end
                OSI.ResetMechanicIconSize()
            end)
    end
end

---------------------------------------------------------------------
-- General Listeners
---------------------------------------------------------------------
local function OnCombatStateChanged(_, inCombat)
    -- Reset
    isInCombat = inCombat
    if (not inCombat) then
        groupTimeBreach = {}
        lokkBeamPhase = false
    else
        -- Disable them as combat starts
        -- Crutch.dbgOther("disabling lokk icons because combat start")
        DisableLokkIcons()
        UpdateLokkIcons()
    end
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
-- Register/Unregister
local origOSIUnitErrorCheck = nil
local origQueueMessage = nil

function Crutch.RegisterSunspire()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Sunspire")

    lokkHM = false

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "SunspireCombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "SunspireBossChange", EVENT_BOSSES_CHANGED, OnBossesChanged)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "FocusFireBegin", EVENT_COMBAT_EVENT, OnFocusFireGained)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "FocusFireBegin", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "FocusFireBegin", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 121722)
    -- TODO: only show for self option

    -- Register for Time Breach effect gained/faded
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED, OnTimeBreachChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 121216)

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

    -- Hook into CSA display to get Lokk difficulty change
    origQueueMessage = CENTER_SCREEN_ANNOUNCE.QueueMessage
    CENTER_SCREEN_ANNOUNCE.QueueMessage = function(s, messageParams)
        -- Call this a second later, because sometimes the health hasn't changed yet
        zo_callLater(function()
            OnDifficultyChanged(messageParams:GetMainText())
        end, 1000)
        return origQueueMessage(s, messageParams)
    end

    if (not Crutch.WorldIconsEnabled()) then
        Crutch.msg("You must install OdySupportIcons 1.6.3+ to display in-world icons")
    end
end

function Crutch.UnregisterSunspire()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "SunspireCombatState", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "SunspireBossChange", EVENT_BOSSES_CHANGED)

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "FocusFireBegin", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TimeBreachEffect", EVENT_EFFECT_CHANGED)

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Gravechill80", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Gravechill50", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Gravechill20", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "StormFury", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Takeoff75", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Takeoff50", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Takeoff25", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TurnOffAim", EVENT_COMBAT_EVENT)

    if (OSI and origOSIUnitErrorCheck) then
        Crutch.dbgOther("|c88FFFF[CT]|r Restoring OSI.UnitErrorCheck")
        OSI.UnitErrorCheck = origOSIUnitErrorCheck
    end

    if (origQueueMessage) then
        Crutch.dbgOther("|c88FFFF[CT]|r Restoring CSA.QueueMessage")
        CENTER_SCREEN_ANNOUNCE.QueueMessage = origQueueMessage
    end

    atLokk = false
    lokkHM = false
    lokkBeamPhase = false
    DisableLokkIcons()
    DisableYolIcons()

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Sunspire")
end
