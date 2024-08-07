CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

local fatecarverIds = {
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

local function OnFatecarver(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)

    if (hitValue <= 75) then return end

    -- Remove the timer if fatecarver gets interrupted
    if (result == ACTION_RESULT_EFFECT_FADED) then
        Crutch.dbgSpam("fatecarver faded")
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
        Crutch.DisplayNotification(abilityId, GetAbilityName(abilityId), hitValue, sourceUnitId, sourceName, sourceType, result)
    end
end


---------------------------------------------------------------------
-- Init
function Crutch.RegisterFatecarver()
    -- Obviously only need to do this if the player is an arcanist.
    -- Eventually I should explore only registering these if Fatecarver is even slotted
    -- Also healy beam though
    if (GetUnitClassId("player") == 117 and not Crutch.savedOptions.general.beginHideArcanist) then
        Crutch.dbgOther("Registering Fatecarver/Remedy Cascade")
        for abilityId, _ in pairs(fatecarverIds) do
            local eventName = Crutch.name .. "FC" .. tostring(abilityId)

            EVENT_MANAGER:RegisterForEvent(eventName .. "Begin", EVENT_COMBAT_EVENT, OnFatecarver)
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- interrupted self only
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId) -- interrupted self only
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Begin", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)

            EVENT_MANAGER:RegisterForEvent(eventName .. "Faded", EVENT_COMBAT_EVENT, OnFatecarver)
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Faded", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- interrupted self only
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Faded", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId) -- interrupted self only
            EVENT_MANAGER:AddFilterForEvent(eventName .. "Faded", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
        end
    else
        Crutch.dbgSpam("Skipping Fatecarver registration, not an arcanist or has setting off")
    end
end

-- For use from settings when toggling
function Crutch.UnregisterFatecarver()
    Crutch.dbgOther("Unregistering Fatecarver/Remedy Cascade")
    for abilityId, _ in pairs(fatecarverIds) do
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "FC" .. tostring(abilityId) .. "Begin", EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "FC" .. tostring(abilityId) .. "Faded", EVENT_COMBAT_EVENT)
    end
end
