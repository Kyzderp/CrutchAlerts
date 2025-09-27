local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Track Major Cowardice to decide whether to display prominent alert
---------------------------------------------------------------------
Crutch.majorCowardiceUnitIds = {}

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnMajorCowardice(_, changeType, _, _, _, _, _, _, _, _, _, _, _, unitName, unitId)
    if (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) then
        Crutch.majorCowardiceUnitIds[unitId] = true
        Crutch.dbgSpam(zo_strformat("|c00FF00<<1>> (<<2>>) got major cowardice|r", unitName, unitId))
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.majorCowardiceUnitIds[unitId] = nil
    end
end

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

local NEGATE_CASTERS = {
    ["silver rose stormcaster"] = true,
    ["dro-m'athra conduit"] = true,
    ["dremora conduit"] = true,
    -- de
    ["silberrosen-sturmwirker"] = true,
    ["silberrosen-sturmwirkerin"] = true,
    ["dro-m'athra-medium"] = true,
    ["dremora-medium"] = true,
    -- es
    ["lanzador de tormentas de la rosa plateada"] = true,
    ["lanzadora de tormentas de la rosa plateada"] = true,
    ["conductor dro-m'athra"] = true,
    ["conductora dro-m'athra"] = true,
    ["dremora conductor"] = true,
    ["dremora conductora"] = true,
    -- fr
    ["lance-tempête de la rose d'argent"] = true,
    ["canalisateur dro-m'athra"] = true,
    ["conduit drémora"] = true,
    -- jp
    ["銀の薔薇のストームキャスター"] = true,
    ["ドロ・マスラの伝送者"] = true,
    ["ドレモラ・コンデュイット"] = true,
    -- ru
    ["призыватель бури серебряной розы"] = true,
    ["призывательница бури серебряной розы"] = true,
    ["проводник дро-м’атра"] = true,
    ["дремора-проводник"] = true,
    -- zh
    ["银玫瑰风暴法师"] = true,
    ["堕落虎人导能者"] = true,
    ["魔人导能法师"] = true,
}

-- When reticle changes...
local function OnReticleChanged()
    -- ... check if it's valid
    if (not DoesUnitExist("reticleover")
        or IsUnitDead("reticleover")
        or GetUnitReaction("reticleover") ~= UNIT_REACTION_HOSTILE
        or GetUnitTargetMarkerType("reticleover") ~= TARGET_MARKER_TYPE_NONE) then
        return
    end

    -- I THINK only Fabled are HARD difficulty, i.e. 2 square thingies. Bosses are DEADLY, trash is EASY besides some NORMAL like lurchers
    if (GetUnitDifficulty("reticleover") == MONSTER_DIFFICULTY_HARD) then
        -- Fabled
        -- Conduits on Taupezu Azzida are also HARD, but that's ok I think. I could do a mapId check but meh
        if (not Crutch.savedOptions.endlessArchive.markFabled) then
            return
        end
    elseif (NEGATE_CASTERS[string.lower(zo_strformat("<<1>>", GetUnitName("reticleover")))]) then
        -- Negate caster
        if (not Crutch.savedOptions.endlessArchive.markNegate) then
            return
        end
    else
        -- Anything else
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
        Crutch.majorCowardiceUnitIds = {}
    end
end


---------------------------------------------------------------------
-- Icon for Elixir of Diminishing
---------------------------------------------------------------------
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnElixir(_, _, _, _, _, _, _, _, targetName, _, _, _, _, _, _, targetUnitId)
    local unitTag = Crutch.groupIdToTag[targetUnitId]

    if (not unitTag) then
        Crutch.dbgOther(zo_strformat("|cFF0000Couldn't find unit tag for <<1>> ID <<2>>", targetName, targetUnitId))
        return
    end

    -- Put an icon on the ground (get the position after the actual cast, 500ms)
    Crutch.dbgSpam(zo_strformat("Elixir on <<1>> (<<2>>)", unitTag, targetName))
    local _, x, y, z = GetUnitRawWorldPosition(unitTag)
    local key = Crutch.Drawing.CreatePlacedIcon("/esoui/art/inventory/inventory_consumables_tabicon_active.dds", x, y + 50, z, 100, {1, 0, 1})
    zo_callLater(function() Crutch.Drawing.RemovePlacedIcon(key) end, 16300)
end


---------------------------------------------------------------------
-- Puzzle cheating
---------------------------------------------------------------------
local puzzleSolutions = {
    [203317] = "3 1 4 6 5 2 -- left",
    [203319] = "3 1 4 6 5 2 -- left",
    [203321] = "3 1 4 6 5 2 -- left",
    [203323] = "3 1 4 6 5 2 -- left",
    [203325] = "3 1 4 6 5 2 -- left",
    [203327] = "3 1 4 6 5 2 -- left",

    [210720] = "1 6 2 4 5 3 -- right",
    [210722] = "1 6 2 4 5 3 -- right",
    [210724] = "1 6 2 4 5 3 -- right",
    [210726] = "1 6 2 4 5 3 -- right",
    [210728] = "1 6 2 4 5 3 -- right",
    [210730] = "1 6 2 4 5 3 -- right",

    [210778] = "5 1 4 2 3 6",
    [210780] = "5 1 4 2 3 6",
    [210782] = "5 1 4 2 3 6",
    [210784] = "5 1 4 2 3 6",
    [210786] = "5 1 4 2 3 6",
    [210788] = "5 1 4 2 3 6",

    [210739] = "2 5 1 4 3",
    [210741] = "2 5 1 4 3",
    [210743] = "2 5 1 4 3",
    [210745] = "2 5 1 4 3",
    [210747] = "2 5 1 4 3",
    [210749] = "2 5 1 4 3",

    [192440] = "5 3 4 1 2 6 -- right, right",
    [197209] = "5 3 4 1 2 6 -- right, right",
    [197216] = "5 3 4 1 2 6 -- right, right",
    [197219] = "5 3 4 1 2 6 -- right, right",
    [197222] = "5 3 4 1 2 6 -- right, right",
    [197226] = "5 3 4 1 2 6 -- right, right",

    [210759] = "5 2 6 4 3 1 -- left, right",
    [210761] = "5 2 6 4 3 1 -- left, right",
    [210763] = "5 2 6 4 3 1 -- left, right",
    [210765] = "5 2 6 4 3 1 -- left, right",
    [210767] = "5 2 6 4 3 1 -- left, right",
    [210769] = "5 2 6 4 3 1 -- left, right",

    [210798] = "1 5 4 2 3 6 -- left",
    [210800] = "1 5 4 2 3 6 -- left",
    [210802] = "1 5 4 2 3 6 -- left",
    [210804] = "1 5 4 2 3 6 -- left",
    [210806] = "1 5 4 2 3 6 -- left",
    [210808] = "1 5 4 2 3 6 -- left",

    -- TODO: 3 5 1 4 2 6 -- left
}

local function OnPuzzleSolution(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    if (puzzleSolutions[abilityId]) then
        Crutch.msg(puzzleSolutions[abilityId])
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Puzzle", EVENT_COMBAT_EVENT)
    end
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterEndlessArchive()
    usedMarkers = {}

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "EACombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "IAMajorCowardice", EVENT_EFFECT_CHANGED, OnMajorCowardice)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "IAMajorCowardice", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 147643)

    if (Crutch.savedOptions.endlessArchive.markFabled or Crutch.savedOptions.endlessArchive.markNegate) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "EAReticle", EVENT_RETICLE_TARGET_CHANGED, OnReticleChanged)
    end

    if (Crutch.savedOptions.endlessArchive.potionIcon) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "IAElixir", EVENT_COMBAT_EVENT, OnElixir)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "IAElixir", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 221794)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "IAElixir", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    end

    if (Crutch.savedOptions.endlessArchive.printPuzzleSolution) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Puzzle", EVENT_COMBAT_EVENT, OnPuzzleSolution)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Puzzle", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
    end

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Endless Archive")
end

function Crutch.UnregisterEndlessArchive()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "EACombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "IAMajorCowardice", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "EAReticle", EVENT_RETICLE_TARGET_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "IAElixir", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Puzzle", EVENT_COMBAT_EVENT)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Endless Archive")
end
