local Crutch = CrutchAlerts
local AS = Crutch.AsylumSanctorium
local C = Crutch.Constants

local FELMS_NAME = zo_strformat("<<C:1>>", GetString(CRUTCH_BHB_SAINT_FELMS_THE_BOLD))

local PANEL_LLOTHIS_HEADER_INDEX = 5
local PANEL_LLOTHIS_BOLTS_INDEX = 6
local PANEL_LLOTHIS_CONE_INDEX = 7
local PANEL_FELMS_HEADER_INDEX = 8
local PANEL_FELMS_TELEPORT_INDEX = 9

local SUBITEM_SCALE = 0.7
local HEADER_SCALE = 1

local function StartLlothisHeader()
    -- TODO: count up
    -- TODO: proper name
    Crutch.InfoPanel.SetLine(PANEL_LLOTHIS_HEADER_INDEX, "Saint Llothis the Pious", HEADER_SCALE)
end

local function SetBolts(msUntil)
    -- TODO: proper name
    Crutch.InfoPanel.CountDownDuration(PANEL_LLOTHIS_BOLTS_INDEX, "    |c64c200Oppressive Bolts: ", msUntil, SUBITEM_SCALE)
end

local function SetCone(msUntil)
    -- TODO: proper name
    Crutch.InfoPanel.CountDownDuration(PANEL_LLOTHIS_CONE_INDEX, "    |c64c200Defiling Blast: ", msUntil, SUBITEM_SCALE)
end

local function StartFelmsHeader()
    -- TODO: count up
    Crutch.InfoPanel.SetLine(PANEL_FELMS_HEADER_INDEX, FELMS_NAME, HEADER_SCALE)
end

local function SetTeleport(msUntil)
    -- TODO: proper name, color
    Crutch.InfoPanel.CountDownDuration(PANEL_FELMS_TELEPORT_INDEX, "    |cff0000Teleport Strike: ", msUntil, SUBITEM_SCALE)
end

function AS.Test()
    StartLlothisHeader()
    SetBolts(12000)
    SetCone(20000)
    StartFelmsHeader()
    SetTeleport(25000)
end
-- /script CrutchAlerts.AsylumSanctorium.Test()


---------------------------------------------------------------------
-- "Events" called from AsylumSanctorium.lua
---------------------------------------------------------------------
function AS.OnLlothisDetectedPanel()
    StartLlothisHeader()
end

-- Minis remain dormant for 45s
function AS.OnLlothisDormantPanel(changeType)
    if (changeType == EFFECT_RESULT_GAINED) then
        SetBolts(45000)
        SetCone(46000) -- TODO
    elseif (changeType == EFFECT_RESULT_FADED) then
        -- TODO: ?
    end
end

function AS.OnFelmsDetectedPanel()
    StartFelmsHeader()
end

function AS.OnFelmsDormantPanel(changeType)
    if (changeType == EFFECT_RESULT_GAINED) then
        SetTeleport(45000)
    elseif (changeType == EFFECT_RESULT_FADED) then
        -- TODO: ?
    end
end


---------------------------------------------------------------------
-- Overall init
---------------------------------------------------------------------
function AS.RegisterMiniPanel()
end

function AS.UnregisterMiniPanel()
    Crutch.InfoPanel.StopCount(PANEL_LLOTHIS_HEADER_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_LLOTHIS_BOLTS_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_LLOTHIS_CONE_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_FELMS_HEADER_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_FELMS_TELEPORT_INDEX)
end
