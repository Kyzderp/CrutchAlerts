local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Listeners from other files
-- Fires only when Crutch.groupInCombat changes
---------------------------------------------------------------------
local enteredListeners = {} -- {["CrutchSunspire"] = OnEnteredCombat,}
local exitedListeners = {} -- {["CrutchSunspire"] = OnExitedCombat,}
function Crutch.RegisterEnteredGroupCombatListener(name, listener)
    enteredListeners[name] = listener
    Crutch.dbgSpam("Registered entering group combat listener " .. name)
end

function Crutch.RegisterExitedGroupCombatListener(name, listener)
    exitedListeners[name] = listener
    Crutch.dbgSpam("Registered exiting group combat listener " .. name)
end

function Crutch.UnregisterEnteredGroupCombatListener(name)
    enteredListeners[name] = nil
    Crutch.dbgSpam("Unregistered entering group combat listener " .. name)
end

function Crutch.UnregisterExitedGroupCombatListener(name)
    exitedListeners[name] = nil
    Crutch.dbgSpam("Unregistered exiting group combat listener " .. name)
end


---------------------------------------------------------------------
-- Global is-group-in-combat, because when you die, you can become
-- "out of combat," but we don't actually want to trust this when
-- doing things like encounter state resets
---------------------------------------------------------------------
Crutch.groupInCombat = false

local function SetGroupInCombat(value)
    if (Crutch.groupInCombat and value == false) then
        -- Change: exited combat
        -- Put this inside so the value isn't changed before the if statement, S.P.E.
        Crutch.groupInCombat = false
        for _, listener in pairs(exitedListeners) do
            listener()
        end
    elseif (not Crutch.groupInCombat and value == true) then
        -- Change: entered combat
        Crutch.groupInCombat = true
        for _, listener in pairs(enteredListeners) do
            listener()
        end
    end
end

local function IsGroupInCombat()
    if (IsUnitInCombat("player")) then
        Crutch.dbgSpam("player is in combat; true")
        return true
    end

    if (not IsUnitGrouped("player")) then
        Crutch.dbgSpam("player is not grouped; false")
        return false
    end

    for i = 1, GetGroupSize() do
        local groupTag = GetGroupUnitTagByIndex(i)
        if (IsUnitInCombat(groupTag) and IsUnitOnline(groupTag)) then
            Crutch.dbgSpam(GetUnitDisplayName(groupTag) .. "(" .. groupTag .. ") is still in combat; true")
            return true
        end
    end

    Crutch.dbgSpam("group is not in combat; false")
    return false
end

local function OnCombatStateChanged(_, inCombat)
    if (inCombat) then
        SetGroupInCombat(true)
        Crutch.dbgSpam("self inCombat true")
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "GlobalCombatStateUpdate")
    else
        SetGroupInCombat(IsGroupInCombat())
        if (Crutch.groupInCombat) then
            -- Check again later if the other players have gotten out of combat
            EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "GlobalCombatStateUpdate", 1000, function() OnCombatStateChanged(_, IsUnitInCombat("player")) end)
        else
            EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "GlobalCombatStateUpdate")
        end
    end
end


---------------------------------------------------------------------
-- Listeners from other files
-- listener: function to be called when bosses actually change
-- param1: boss1IsSame - whether boss1 is the same as before the change
---------------------------------------------------------------------
local bossListeners = {} -- {["CrutchDreadsailReef"] = OnBossesChanged,}
function Crutch.RegisterBossChangedListener(name, listener)
    bossListeners[name] = listener
    Crutch.dbgSpam("Registered boss change listener " .. name)
end

function Crutch.UnregisterBossChangedListener(name)
    bossListeners[name] = nil
    Crutch.dbgSpam("Unregistered boss change listener " .. name)
end


---------------------------------------------------------------------
-- EVENT_BOSSES_CHANGED (and also player activation)
---------------------------------------------------------------------
local function GetUnitNameIfExists(unitTag)
    if (DoesUnitExist(unitTag)) then
        return GetUnitName(unitTag)
    end
end

local function GetFirstValidBossTag()
    for i = 1, BOSS_RANK_ITERATION_END do
        local unitTag = "boss" .. tostring(i)
        if (DoesUnitExist(unitTag)) then
            return unitTag
        end
    end
    return ""
end


local prevBosses = ""
local prevBoss1 = ""
local function OnBossesChanged()
    local bossHash = ""

    for i = 1, BOSS_RANK_ITERATION_END do
        local name = GetUnitNameIfExists("boss" .. tostring(i))
        if (name and name ~= "") then
            bossHash = bossHash .. name
        end
    end

    -- Only trigger off bosses truly changing (sometimes the event fires for no apparent reason?)
    if (bossHash ~= prevBosses) then
        prevBosses = bossHash
        local boss1 = GetUnitName(GetFirstValidBossTag()) or ""

        for _, listener in pairs(bossListeners) do
            listener(prevBoss1 == boss1)
        end
        prevBoss1 = boss1
    end
end


---------------------------------------------------------------------
-- Polling
---------------------------------------------------------------------
local updateListeners = {}

local function Poll()
    for _, listener in pairs(updateListeners) do
        listener()
    end
end

local polling = false
local function UpdatePolling()
    local empty = ZO_IsTableEmpty(updateListeners)
    if (not polling and not empty) then
        EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "GlobalPolling", 100, Poll)
        Poll()
        polling = true
        Crutch.dbgOther("starting polling")
    elseif (polling and empty) then
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "GlobalPolling")
        polling = false
        Crutch.dbgOther("stopping polling")
    end
end

function Crutch.RegisterUpdateListener(name, listener)
    updateListeners[name] = listener
    Crutch.dbgSpam("Registered update listener " .. name)
    listener()
    UpdatePolling()
end

function Crutch.UnregisterUpdateListener(name)
    updateListeners[name] = nil
    Crutch.dbgSpam("Unregistered update listener " .. name)
    UpdatePolling()
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Crutch.InitializeGlobalEvents()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GlobalCombat", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GlobalBossesChanged", EVENT_BOSSES_CHANGED, OnBossesChanged)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GlobalPlayerActivated", EVENT_PLAYER_ACTIVATED, OnBossesChanged)
end

function Crutch.UninitializeGlobalEvents()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "GlobalCombat", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "GlobalBossesChanged", EVENT_BOSSES_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "GlobalPlayerActivated", EVENT_PLAYER_ACTIVATED)
end
