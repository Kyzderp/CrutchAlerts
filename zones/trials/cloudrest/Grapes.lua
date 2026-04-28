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

local function UpdateDisplay()
    local text = ""

    for i = 1, numDead do
        text = text .. "|c888888|t100%:100%:/esoui/art/buttons/gamepad/ps5/nav_ps5_circle.dds:inheritcolor|t|r"
    end
    for i = 1, numFaceplanted do
        text = text .. "|c945E00|t100%:100%:/esoui/art/buttons/gamepad/ps5/nav_ps5_triangle.dds:inheritcolor|t|r"
    end
    for i = 1, numActive do
        text = text .. "|cFF00FF|t100%:100%:/esoui/art/buttons/gamepad/ps5/nav_ps5_circle.dds:inheritcolor|t|r"
    end

    if (text == "") then
        Crutch.InfoPanel.StopCount(PANEL_GRAPE_DISPLAY_INDEX)
    else
        Crutch.InfoPanel.SetLine(PANEL_GRAPE_DISPLAY_INDEX, text)
    end
end

local function ClearGrapes()
    EVENT_MANAGER:UnregisterForUpdate("CrutchClearGrapes")
    Crutch.dbgOther("clearing grapes now")
    numActive = 0
    numFaceplanted = 0
    numDead = 0
    UpdateDisplay()
end

local nextGrapeTarget = 0
local function ClearGrapesLater()
    Crutch.dbgOther("clearing grapes later (panel now)")
    Crutch.InfoPanel.StopCount(PANEL_GRAPE_TIMER_INDEX)
    Crutch.InfoPanel.CountDownToTargetTime(PANEL_GRAPE_TIMER_INDEX, GRAPE_SUMMON_PREFIX, nextGrapeTarget)
    EVENT_MANAGER:RegisterForUpdate("CrutchClearGrapes", 5000, ClearGrapes)
end

local function TestGrapes(active, faceplanted, dead)
    numActive = active
    numFaceplanted = faceplanted
    numDead = dead
    UpdateDisplay()
    Crutch.InfoPanel.CountDownDuration(PANEL_GRAPE_TIMER_INDEX, GRAPE_PREFIX, 22000)
end
CR.TestGrapes = TestGrapes
-- /script CrutchAlerts.Cloudrest.TestGrapes(1, 1, 1)


---------------------------------------------------------------------
-- Combat events
---------------------------------------------------------------------
-- This is just the Z'Maja cast; assume 3 active immediately
local function OnGrapesSummoned()
    numActive = 3
    numFaceplanted = 0
    numDead = 0
    UpdateDisplay()

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

    if (numActive == 0) then
        ClearGrapesLater()
    end
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
    Crutch.InfoPanel.StopCount(PANEL_GRAPE_DISPLAY_INDEX)
    UpdateDisplay()
end

function CR.RegisterGrapes()
    if (not Crutch.savedOptions.cloudrest.infoPanel.showGrapes) then return end

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
