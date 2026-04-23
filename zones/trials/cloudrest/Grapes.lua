local Crutch = CrutchAlerts
local CR = Crutch.Cloudrest

local PANEL_GRAPE_TIMER_INDEX = 5
local PANEL_GRAPE_DISPLAY_INDEX = 6

-- TODO: better names?
local GRAPE_PREFIX = zo_strformat("|c9447ff<<C:1>>: ", GetAbilityName(105375))
local GRAPE_SUMMON_PREFIX = zo_strformat("|c9447ff<<C:1>>: ", GetAbilityName(105291))


---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
local numActive = 0
local numFaceplanted = 0
local numDead = 0

local grapes = {} -- {[unitId] = true}

local function GetGrapeString(color)
    return string.format("|c%s|t100%%:100%%:esoui/art/icons/targetdummy_voriplasm_01.dds:inheritcolor|t|r", color)
end

local function UpdateDisplay()
    local text = ""

    for i = 1, numActive do
        text = text .. GetGrapeString("FF0000")
    end
    for i = 1, numFaceplanted do
        text = text .. GetGrapeString("FFAA00")
    end
    for i = 1, numDead do
        text = text .. GetGrapeString("00FF00")
    end

    Crutch.InfoPanel.SetLine(PANEL_GRAPE_DISPLAY_INDEX, text)
end

local function ClearGrapes()
    EVENT_MANAGER:UnregisterForUpdate("CrutchClearGrapes")
    numActive = 0
    numFaceplanted = 0
    numDead = 0
    UpdateDisplay()
end

local nextGrapeTarget = 0
local function ClearGrapesLater()
    Crutch.InfoPanel.StopCount(PANEL_GRAPE_TIMER_INDEX)
    Crutch.InfoPanel.CountDownToTargetTIme(PANEL_GRAPE_TIMER_INDEX, GRAPE_PREFIX, nextGrapeTarget)
    EVENT_MANAGER:RegisterForUpdate("CrutchClearGrapes", 5000, ClearGrapes)
end


---------------------------------------------------------------------
-- Combat events
---------------------------------------------------------------------
-- This is just the Z'Maja cast; assume 3 active immediately
local function OnGrapesSummoned()
    numActive = 3
    numFaceplanted = 0
    numDead = 0

    Crutch.InfoPanel.CountDownDuration(PANEL_GRAPE_TIMER_INDEX, GRAPE_PREFIX, 22000) -- TODO
    nextGrapeTarget = GetGameTimeMilliseconds() + 33000 -- TODO
end

local function OnGrapeDied(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    if (not grapes[targetUnitId]) then return end
    Crutch.dbgOther("grape died " .. targetUnitId)

    grapes[targetUnitId] = nil

    numActive = numActive - 1
    numDead = numDead + 1

    UpdateDisplay()
end

local function OnFaceplanted(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    if (not grapes[targetUnitId]) then return end
    Crutch.dbgOther("faceplanted " .. targetUnitId)

    grapes[targetUnitId] = nil

    numActive = numActive - 1
    numFaceplanted = numFaceplanted + 1

    UpdateDisplay()

    if (numActive == 0) then
        ClearGrapesLater()
    end
end

-- The first event the grape gets is Shadow Bead Tick
local function OnGrapeActivated(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    Crutch.dbgOther("found grape " .. targetUnitId)
    grapes[targetUnitId] = true
end

local function OnGrapeCharged()
    -- TODO: need to handle the last ones? or do they trigger faceplanted?
    ClearGrapesLater()
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local function CleanUp()
    numActive = 0
    numFaceplanted = 0
    numDead = 0
    Crutch.InfoPanel.StopCount(PANEL_GRAPE_TIMER_INDEX)
    UpdateDisplay()
end

function CR.RegisterGrapes()
    Crutch.RegisterExitedGroupCombatListener("CRGrapesExitedCombat", CleanUp)

    Crutch.RegisterForCombatEvent("GrapesSummoned", OnGrapesSummoned, ACTION_RESULT_BEGIN, 105291)
    Crutch.RegisterForCombatEvent("GrapesDied", OnGrapeDied, ACTION_RESULT_DIED) -- TODO: filter unit type?
    Crutch.RegisterForCombatEvent("GrapesFaceplanted", OnFaceplanted, ACTION_RESULT_EFFECT_GAINED, 105363)
    Crutch.RegisterForCombatEvent("GrapesActive", OnGrapeActivated, ACTION_RESULT_EFFECT_GAINED, 105339)
    Crutch.RegisterForCombatEvent("GrapesCharge", OnGrapeCharged, nil, 105373)
end

function CR.UnregisterGrapes()
    Crutch.UnregisterExitedGroupCombatListener("CRGrapesExitedCombat")

    Crutch.UnregisterForCombatEvent("GrapesSummoned")
    Crutch.UnregisterForCombatEvent("GrapesDied")
    Crutch.UnregisterForCombatEvent("GrapesFaceplanted")
    Crutch.UnregisterForCombatEvent("GrapesActive")
    Crutch.UnregisterForCombatEvent("GrapesCharge")

    CleanUp()
end
