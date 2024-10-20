CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Global is-group-in-combat, because when you die, you can become
-- "out of combat," but we don't actually want to trust this when
-- doing things like encounter state resets
---------------------------------------------------------------------
Crutch.groupInCombat = false

local function IsGroupInCombat()
    if (IsUnitInCombat("player")) then
        return true
    end

    if (not IsUnitGrouped("player")) then
        return false
    end

    for i = 1, GetGroupSize() do
        local groupTag = "group" .. i
        if (IsUnitInCombat(groupTag) and IsUnitOnline(groupTag)) then
            return true
        end
    end
    return false
end

local function OnCombatStateChanged(_, inCombat)
    if (inCombat) then
        Crutch.groupInCombat = true
    else
        Crutch.groupInCombat = IsGroupInCombat()
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
