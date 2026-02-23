local Crutch = CrutchAlerts
local AS = Crutch.AsylumSanctorium
local C = Crutch.Constants

local FELMS_NAME = zo_strformat("<<C:1>>", GetString(CRUTCH_BHB_SAINT_FELMS_THE_BOLD))

local PANEL_LLOTHIS_HEADER_INDEX = 5
local PANEL_LLOTHIS_BOLTS_INDEX = 6
local PANEL_LLOTHIS_CONE_INDEX = 7
-- TODO: llothis port?
local PANEL_FELMS_HEADER_INDEX = 8
local PANEL_FELMS_TELEPORT_INDEX = 9

local SUBITEM_SCALE = 0.7
local HEADER_SCALE = 1

local function DecorateElapsedTimer(ms)
    local colons = FormatTimeSeconds(ms / 1000, TIME_FORMAT_STYLE_COLONS)
    if (ms >= 180000) then
        return "|cFF0000" .. colons
    elseif (ms >= 170000) then
        return "|cFFAA00" .. colons
    elseif (ms >= 135000) then
        return "|cFFFF00" .. colons
    else
        return "|cFFFFFF" .. colons
    end
end

-------
local function StartLlothisHeader()
    -- TODO: proper name
    Crutch.InfoPanel.CountUp(PANEL_LLOTHIS_HEADER_INDEX, "Saint Llothis the Pious: ", HEADER_SCALE, DecorateElapsedTimer)
end
local function CountDownToLlothis()
    Crutch.InfoPanel.CountDownDuration(PANEL_LLOTHIS_HEADER_INDEX, "Saint Llothis the Pious: ", 45000, HEADER_SCALE)
end

local function SetBolts(msUntil)
    -- TODO: proper name
    Crutch.InfoPanel.CountDownDuration(PANEL_LLOTHIS_BOLTS_INDEX, "    |c64c200Oppressive Bolts: ", msUntil, SUBITEM_SCALE)
end

local function SetCone(msUntil)
    -- TODO: proper name
    Crutch.InfoPanel.CountDownDuration(PANEL_LLOTHIS_CONE_INDEX, "    |c64c200Defiling Blast: ", msUntil, SUBITEM_SCALE)
end

-------
local function StartFelmsHeader()
    Crutch.InfoPanel.CountUp(PANEL_FELMS_HEADER_INDEX, FELMS_NAME .. ": ", HEADER_SCALE, DecorateElapsedTimer)
end
local function CountDownToFelms()
    Crutch.InfoPanel.CountDownDuration(PANEL_FELMS_HEADER_INDEX, FELMS_NAME .. ": ", 45000, HEADER_SCALE)
end

local function SetTeleport(msUntil)
    -- TODO: proper name
    Crutch.InfoPanel.CountDownDuration(PANEL_FELMS_TELEPORT_INDEX, "    |cd63a3aTeleport Strike: ", msUntil, SUBITEM_SCALE)
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
    SetBolts(12000) -- TODO
    SetCone(11000) -- TODO
end

-- Minis remain dormant for 45s
function AS.OnLlothisDormantPanel(changeType)
    if (changeType == EFFECT_RESULT_GAINED) then
        CountDownToLlothis()
        SetBolts(45000)
        SetCone(46000) -- TODO
    elseif (changeType == EFFECT_RESULT_FADED) then
        StartLlothisHeader()
    end
end

function AS.OnFelmsDetectedPanel()
    StartFelmsHeader()
    SetTeleport(11000) -- TODO
end

function AS.OnFelmsDormantPanel(changeType)
    if (changeType == EFFECT_RESULT_GAINED) then
        CountDownToFelms()
        SetTeleport(45000)
    elseif (changeType == EFFECT_RESULT_FADED) then
        StartFelmsHeader()
    end
end


---------------------------------------------------------------------
-- Overall init
---------------------------------------------------------------------
function AS.RegisterMiniPanel()
    -- TODO: initial timers
end

function AS.UnregisterMiniPanel()
    Crutch.InfoPanel.StopCount(PANEL_LLOTHIS_HEADER_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_LLOTHIS_BOLTS_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_LLOTHIS_CONE_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_FELMS_HEADER_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_FELMS_TELEPORT_INDEX)
end
