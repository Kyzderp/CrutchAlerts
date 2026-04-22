local Crutch = CrutchAlerts

local arcanistIds = {
    [185805] = true, -- Fatecarver (cost mag)
    [193331] = true, -- Fatecarver (cost stam)
    [183122] = true, -- Exhausting Fatecarver (cost mag)
    [193397] = true, -- Exhausting Fatecarver (cost stam)
    [186366] = true, -- Pragmatic Fatecarver (cost mag)
    [193398] = true, -- Pragmatic Fatecarver (cost stam)
    [183537] = true, -- Remedy Cascade (cost mag)
    [198309] = true, -- Remedy Cascade (cost stam)
    [186193] = true, -- Cascading Fortune (cost mag)
    [198330] = true, -- Cascading Fortune (cost stam)
    [186200] = true, -- Curative Surge (cost mag)
    [198537] = true, -- Curative Surge (cost stam)
}

local jbeamIds = {
    [63029] = true, -- Radiant Destruction
    [63044] = true, -- Radiant Glory
    [63046] = true, -- Radiant Oppression
}

-- TODO: these are just copied over from events.lua, lame
local resultStrings = {
    [ACTION_RESULT_BEGIN] = "BEGIN",
    [ACTION_RESULT_EFFECT_GAINED] = "GAIN",
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = "DUR",
    [ACTION_RESULT_EFFECT_FADED] = "FADED",
    [ACTION_RESULT_DAMAGE] = "DAMAGE",
}

local sourceStrings = {
    [COMBAT_UNIT_TYPE_GROUP] = "G",
    [COMBAT_UNIT_TYPE_NONE] = "N",
    [COMBAT_UNIT_TYPE_OTHER] = "O",
    [COMBAT_UNIT_TYPE_PLAYER] = "P",
    [COMBAT_UNIT_TYPE_PLAYER_COMPANION] = "C",
    [COMBAT_UNIT_TYPE_PLAYER_PET] = "PET",
    [COMBAT_UNIT_TYPE_TARGET_DUMMY] = "D",
}

local effectResults = {
    [EFFECT_RESULT_FADED] = "FADED",
    [EFFECT_RESULT_FULL_REFRESH] = "FULL_REFRESH",
    [EFFECT_RESULT_GAINED] = "GAINED",
    [EFFECT_RESULT_TRANSFER] = "TRANSFER",
    [EFFECT_RESULT_UPDATED] = "UPDATED",
}

local function OnChannel(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)

    if (hitValue <= 75) then return end

    -- Remove the timer if channel gets interrupted
    if (result == ACTION_RESULT_EFFECT_FADED) then
        Crutch.dbgSpam("channel faded (combat)")
        Crutch.Interrupted(targetUnitId, true)
        return
    end

    -- Start debug
    local resultString = ""
    if (result) then
        resultString = (resultStrings[result] or tostring(result))
    end

    local sourceString = ""
    if (sourceType) then
        sourceString = (sourceStrings[sourceType] or tostring(sourceType))
    end
    local targetString = ""
    if (targetType) then
        targetString = (sourceStrings[targetType] or tostring(targetType))
    elseif (targetType == nil) then
        targetString = "nil"
    end

    Crutch.dbgSpam(string.format("A %s(%d): %s(%d) in %d on %s (%d). %s.%s %s",
        sourceName,
        sourceUnitId,
        GetAbilityName(abilityId),
        abilityId,
        hitValue,
        targetName,
        targetUnitId,
        sourceString,
        targetString,
        resultString))
    -- End debug

    if (result == ACTION_RESULT_BEGIN) then
        Crutch.DisplayNotification(abilityId, GetAbilityName(abilityId), hitValue, sourceUnitId, sourceName, sourceType, targetUnitId, targetName, targetType, result)
    end
end

local function OnChannelFaded(_, changeType, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId, sourceType)
    if (changeType ~= EFFECT_RESULT_FADED) then return end
    if (sourceType ~= COMBAT_UNIT_TYPE_PLAYER) then return end

    -- Remove the timer if beam gets interrupted
    Crutch.dbgSpam("channel faded (effect)")
    Crutch.InterruptAbility(abilityId)
end


---------------------------------------------------------------------
-- Init
function Crutch.RegisterChannels()
    -- Eventually I should explore only registering these if Fatecarver is even slotted
    -- Also healy beam though
    if (not Crutch.savedOptions.general.beginHideArcanist) then
        Crutch.dbgOther("Registering Fatecarver/Remedy Cascade")
        for abilityId, _ in pairs(arcanistIds) do
            local eventName = "FC" .. tostring(abilityId)

            Crutch.RegisterForCombatEvent(eventName .. "Begin", OnChannel, ACTION_RESULT_BEGIN, abilityId, nil, COMBAT_UNIT_TYPE_PLAYER)
            Crutch.RegisterForCombatEvent(eventName .. "Faded", OnChannel, ACTION_RESULT_EFFECT_FADED, abilityId, nil, COMBAT_UNIT_TYPE_PLAYER)
        end
    end

    -- Jbeam
    if (Crutch.savedOptions.general.showJBeam) then
        Crutch.dbgOther("Registering Radiant Destruction")
        for abilityId, _ in pairs(jbeamIds) do
            local eventName = "JB" .. tostring(abilityId)

            Crutch.RegisterForCombatEvent(eventName .. "Begin", OnChannel, ACTION_RESULT_BEGIN, abilityId, COMBAT_UNIT_TYPE_PLAYER)
            Crutch.RegisterForEffectChanged(eventName .. "Faded", OnChannelFaded, abilityId)
        end
    end

    -- bad breath
    if (Crutch.savedOptions.general.showEngulfing) then
        Crutch.dbgOther("Registering Engulfing Dragonfire")
        local eventName = Crutch.name .. "Engulfing"

        Crutch.RegisterForCombatEvent("EngulfingBegin", OnChannel, ACTION_RESULT_BEGIN, 20930, COMBAT_UNIT_TYPE_PLAYER)
        Crutch.RegisterForEffectChanged("EngulfingFaded", OnChannelFaded, 20930)
    end

    -- werewolf
    if (Crutch.savedOptions.general.showClawFury) then
        Crutch.dbgOther("Registering Claw Fury")

        Crutch.RegisterForCombatEvent("ClawFuryBegin", OnChannel, ACTION_RESULT_BEGIN, 58864, COMBAT_UNIT_TYPE_PLAYER)
        Crutch.RegisterForEffectChanged("ClawFuryFaded", OnChannelFaded, 58864)
    end
end

-- For use from settings when toggling
function Crutch.UnregisterChannels()
    Crutch.dbgOther("Unregistering channeled attacks")
    for abilityId, _ in pairs(arcanistIds) do
        Crutch.UnregisterForCombatEvent("FC" .. tostring(abilityId) .. "Begin")
        Crutch.UnregisterForCombatEvent("FC" .. tostring(abilityId) .. "Faded")
    end

    for abilityId, _ in pairs(jbeamIds) do
        Crutch.UnregisterForCombatEvent("JB" .. tostring(abilityId) .. "Begin")
        Crutch.UnregisterForEffectChanged("JB" .. tostring(abilityId) .. "Faded")
    end

    Crutch.UnregisterForCombatEvent("EngulfingBegin")
    Crutch.UnregisterForEffectChanged("EngulfingFaded")

    Crutch.UnregisterForCombatEvent("ClawFuryBegin")
    Crutch.UnregisterForEffectChanged("ClawFuryFaded")
end
