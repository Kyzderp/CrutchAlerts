CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Automatic Fabled markers
---------------------------------------------------------------------
local availableMarkers = {
    -- I put them in this order because I think 7 and 8 (swords and skull) are harder to see
    TARGET_MARKER_TYPE_ONE,
    TARGET_MARKER_TYPE_FIVE,
    TARGET_MARKER_TYPE_TWO,
    TARGET_MARKER_TYPE_SEVEN,
    TARGET_MARKER_TYPE_SIX,
    TARGET_MARKER_TYPE_FOUR,
    TARGET_MARKER_TYPE_THREE,
    TARGET_MARKER_TYPE_EIGHT,
}

-- MONSTER_DIFFICULTY_NONE 0
-- MONSTER_DIFFICULTY_EASY 1
-- MONSTER_DIFFICULTY_NORMAL 2
-- MONSTER_DIFFICULTY_HARD 3
-- MONSTER_DIFFICULTY_DEADLY 4

local usedMarkers = {} -- [TARGET_MARKER_TYPE_EIGHT] = true,

-- Pick a marker that we haven't used recently. It gets reset upon leaving combat
local function GetUnusedMarker()
    for i = 1, 8 do
        -- If group leader, start at top
        local index = i
        if (not IsUnitGroupLeader("player")) then
            -- If not, start at 5. This hopefully makes it so they don't overlap
            index = i + 4
        end
        if (index > 8) then
            index = index - 8
        end

        local marker = availableMarkers[index]
        if (not usedMarkers[marker]) then
            return marker
        end
    end

    -- If it hits the end without finding one, then uhh idk, just start over
    usedMarkers = {}
    return IsUnitGroupLeader("player") and availableMarkers[1] or availableMarkers[5]
end

-- When reticle changes...
local function OnReticleChanged()
    -- ... check if it's a Fabled
    if (not DoesUnitExist("reticleover")
        or IsUnitDead("reticleover")
        or GetUnitTargetMarkerType("reticleover") ~= TARGET_MARKER_TYPE_NONE
        or GetUnitDifficulty("reticleover") ~= MONSTER_DIFFICULTY_HARD) then
        -- I THINK only Fabled are HARD difficulty, i.e. 2 square thingies. Bosses are DEADLY, trash is EASY besides some NORMAL like lurchers
        return
    end

    -- If so, find an unused marker
    local marker = GetUnusedMarker()

    -- And assign it to the reticle
    usedMarkers[marker] = true
    AssignTargetMarkerToReticleTarget(marker)
    Crutch.dbgSpam(string.format("Assigned %s to %s", marker, GetUnitName("reticleover")))
end

-- Reset used markers when exiting combat
local function OnCombatStateChanged(_, inCombat)
    if (not inCombat) then
        usedMarkers = {}
        Crutch.dbgSpam("Cleared usedMarkers")
    end
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterEndlessArchive()
    usedMarkers = {}

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "EACombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    if (Crutch.savedOptions.endlessArchive.markFabled) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "EAReticle", EVENT_RETICLE_TARGET_CHANGED, OnReticleChanged)
    end

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Endless Archive")
end

function Crutch.UnregisterEndlessArchive()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "EACombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "EAReticle", EVENT_RETICLE_TARGET_CHANGED)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Endless Archive")
end
