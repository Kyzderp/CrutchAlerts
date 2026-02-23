local Crutch = CrutchAlerts
local AS = Crutch.AsylumSanctorium
local C = Crutch.Constants

local FELMS_NAME = GetString(CRUTCH_BHB_SAINT_FELMS_THE_BOLD)


local PANEL_LLOTHIS_HEADER_INDEX = 5
local PANEL_LLOTHIS_BOLTS_INDEX = 6
local PANEL_LLOTHIS_CONE_INDEX = 7
local PANEL_FELMS_HEADER_INDEX = 8
local PANEL_FELMS_TELEPORT_INDEX = 9

local function StartLlothisHeader()
    -- TODO: count up
    -- TODO: proper name
    Crutch.InfoPanel.SetLine(PANEL_LLOTHIS_HEADER_INDEX, "Llothis")
end

local function SetBolts(msUntil)
    -- TODO: proper name
    Crutch.InfoPanel.CountDownDuration(PANEL_LLOTHIS_BOLTS_INDEX, "    |c64c200Bolts: ", msUntil)
end

local function SetCone(msUntil)
    -- TODO: proper name
    Crutch.InfoPanel.CountDownDuration(PANEL_LLOTHIS_CONE_INDEX, "    |c64c200Cone: ", msUntil)
end

local function StartFelmsHeader()
    -- TODO: count up
    -- TODO: proper name
    Crutch.InfoPanel.SetLine(PANEL_FELMS_HEADER_INDEX, FELMS_NAME)
end

local function SetTeleport(msUntil)
    -- TODO: proper name, color
    Crutch.InfoPanel.CountDownDuration(PANEL_FELMS_TELEPORT_INDEX, "    |cff0000Teleport Strike: ", msUntil)
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
