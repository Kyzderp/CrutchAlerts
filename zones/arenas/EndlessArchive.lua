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
    local negateCasters = {
        ["Silver Rose Stormcaster"] = true,
        ["Dro-m'Athra Conduit"] = true,
        ["Dremora Conduit"] = true,
        -- de
        ["Silberrosen-Sturmwirker"] = true,
        ["Silberrosen-Sturmwirkerin"] = true,
        ["dro-m'Athra-Medium"] = true,
        ["Dremora-Medium"] = true,
        -- es
        ["lanzador de tormentas de la Rosa Plateada"] = true,
        ["lanzadora de tormentas de la Rosa Plateada"] = true,
        ["conductor dro-m'Athra"] = true,
        ["conductora dro-m'Athra"] = true,
        ["dremora conductor"] = true,
        ["dremora conductora"] = true,
        -- fr
        ["lance-tempête de la Rose d'argent"] = true,
        ["canalisateur dro-m'Athra"] = true,
        ["conduit Drémora"] = true,
        -- jp
        ["銀の薔薇のストームキャスター"] = true,
        ["ドロ・マスラの伝送者"] = true,
        ["ドレモラ・コンデュイット"] = true,
        -- ru
        ["Призыватель бури Серебряной розы"] = true,
        ["Призывательница бури Серебряной розы"] = true,
        ["Проводник дро-м’Атра"] = true,
        ["Дремора-проводник"] = true,
        -- zh
        ["银玫瑰风暴法师"] = true,
        ["堕落虎人导能者"] = true,
        ["魔人导能法师"] = true,
    }
    -- ... check if it's a Fabled
    if (not DoesUnitExist("reticleover")
        or IsUnitDead("reticleover")
        or GetUnitTargetMarkerType("reticleover") ~= TARGET_MARKER_TYPE_NONE) then
        -- I THINK only Fabled are HARD difficulty, i.e. 2 square thingies. Bosses are DEADLY, trash is EASY besides some NORMAL like lurchers
        if (GetUnitDifficulty("reticleover") == MONSTER_DIFFICULTY_HARD) then
            -- Fabled
            -- Conduits on Taupezu Azzida are also HARD, but that's ok I think. I could do a mapId check but meh
            if (not Crutch.savedOptions.endlessArchive.markFabled) then
                return
            end
        elseif (negateCasters[zo_strformat("<<1>>", GetUnitName("reticleover"))]) then
            -- Negate caster
            if (not Crutch.savedOptions.endlessArchive.markNegate) then
                return
            end
        else
            -- Anything else
            return
        end
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
    if (Crutch.savedOptions.endlessArchive.markFabled or Crutch.savedOptions.endlessArchive.markNegate) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "EAReticle", EVENT_RETICLE_TARGET_CHANGED, OnReticleChanged)
    end

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Endless Archive")
end

function Crutch.UnregisterEndlessArchive()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "EACombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "EAReticle", EVENT_RETICLE_TARGET_CHANGED)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Endless Archive")
end
