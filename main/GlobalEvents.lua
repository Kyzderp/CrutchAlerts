CrutchAlerts = CrutchAlerts or {}
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
        local groupTag = "group" .. i
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
-- Init
---------------------------------------------------------------------
function Crutch.InitializeGlobalEvents()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GlobalCombat", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
end

function Crutch.UninitializeGlobalEvents()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "GlobalCombat", EVENT_PLAYER_COMBAT_STATE)
end
