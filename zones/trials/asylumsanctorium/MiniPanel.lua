local Crutch = CrutchAlerts
local AS = Crutch.AsylumSanctorium
local C = Crutch.Constants

local FELMS_NAME = zo_strformat("<<C:1>>", GetString(CRUTCH_BHB_SAINT_FELMS_THE_BOLD))
local LLOTHIS_NAME = zo_strformat("<<C:1>>", GetString(CRUTCH_BHB_SAINT_LLOTHIS_THE_PIOUS))
local BOLTS_NAME = "   |c3a9dd6" .. GetAbilityName(95687) .. ": " -- Oppressive Bolts (actual ability is Soul Stained Corruption)
local CONE_NAME = "   |c64c200" .. GetAbilityName(95545) .. ": " -- Defiling Dye Blast
local FART_NAME = "   |c9447ff" .. GetAbilityName(98356) .. ": " -- Noxious Gas (actual ability is Pernicious Transmission)
local TELEPORT_NAME = "   |cd63a3a" .. GetAbilityName(99138) .. ": "

local PANEL_LLOTHIS_HEADER_INDEX = 5
local PANEL_LLOTHIS_BOLTS_INDEX = 6
local PANEL_LLOTHIS_CONE_INDEX = 7
local PANEL_LLOTHIS_FART_INDEX = 8
local PANEL_DUMMY_INDEX = 9
local PANEL_FELMS_HEADER_INDEX = 10
local PANEL_FELMS_TELEPORT_INDEX = 11

local SUBITEM_SCALE = 1
local HEADER_SCALE = 0.7

---------------------------------------------------------------------
-- Role-specific settings
---------------------------------------------------------------------
local function IsSettingEnabled(setting)
    local isRoleSet = Crutch.IsRoleSet(setting, GetSelectedLFGRole())
    if (isRoleSet == nil) then return true end -- Just show everything if the role is not valid
    return isRoleSet
end

---------------------------------------------------------------------
-- Info Panel UI
---------------------------------------------------------------------
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

------- Llothis
local llothisDormant = false
local llothisDisplaying = false
local function StartLlothisHeader()
    if (not IsSettingEnabled(Crutch.savedOptions.asylumsanctorium.panel.showLlothisHeader)) then return end
    llothisDisplaying = true
    Crutch.InfoPanel.CountUp(PANEL_LLOTHIS_HEADER_INDEX, "|cCCCCCC" .. LLOTHIS_NAME .. ": ", HEADER_SCALE, DecorateElapsedTimer)
end
local function CountDownToLlothis()
    if (not IsSettingEnabled(Crutch.savedOptions.asylumsanctorium.panel.showLlothisHeader)) then return end
    llothisDisplaying = true
    Crutch.InfoPanel.CountDownDuration(PANEL_LLOTHIS_HEADER_INDEX, "|cCCCCCC" .. LLOTHIS_NAME .. ": ", 45000, HEADER_SCALE)
end

local function SetBolts(msUntil)
    if (not IsSettingEnabled(Crutch.savedOptions.asylumsanctorium.panel.showLlothisBolts)) then return end
    llothisDisplaying = true
    Crutch.InfoPanel.CountDownDuration(PANEL_LLOTHIS_BOLTS_INDEX, BOLTS_NAME, msUntil, SUBITEM_SCALE)
end

local function SetCone(msUntil)
    if (not IsSettingEnabled(Crutch.savedOptions.asylumsanctorium.panel.showLlothisCone)) then return end
    llothisDisplaying = true
    Crutch.InfoPanel.CountDownDuration(PANEL_LLOTHIS_CONE_INDEX, CONE_NAME, msUntil, SUBITEM_SCALE)
end

local function SetFart(msUntil)
    if (not IsSettingEnabled(Crutch.savedOptions.asylumsanctorium.panel.showLlothisTeleport)) then return end
    llothisDisplaying = true
    Crutch.InfoPanel.CountDownDuration(PANEL_LLOTHIS_FART_INDEX, FART_NAME, msUntil, SUBITEM_SCALE)
end

------- Felms
local felmsDormant = false
local function StartFelmsHeader()
    if (not IsSettingEnabled(Crutch.savedOptions.asylumsanctorium.panel.showFelmsHeader)) then return end
    if (llothisDisplaying) then
        Crutch.InfoPanel.SetLine(PANEL_DUMMY_INDEX, " ", 0.3) -- Fake spacing
    end
    Crutch.InfoPanel.CountUp(PANEL_FELMS_HEADER_INDEX, "|cCCCCCC" .. FELMS_NAME .. ": ", HEADER_SCALE, DecorateElapsedTimer)
end
local function CountDownToFelms()
    if (not IsSettingEnabled(Crutch.savedOptions.asylumsanctorium.panel.showFelmsHeader)) then return end
    Crutch.InfoPanel.CountDownDuration(PANEL_FELMS_HEADER_INDEX, "|cCCCCCC" .. FELMS_NAME .. ": ", 45000, HEADER_SCALE)
end

local function SetTeleport(msUntil)
    if (not IsSettingEnabled(Crutch.savedOptions.asylumsanctorium.panel.showFelmsTeleport)) then return end
    Crutch.InfoPanel.CountDownDuration(PANEL_FELMS_TELEPORT_INDEX, TELEPORT_NAME, msUntil, SUBITEM_SCALE)
end

function AS.Test()
    StartLlothisHeader()
    SetBolts(12000)
    SetCone(20000)
    SetFart(1000)
    StartFelmsHeader()
    SetTeleport(25000)
end
-- /script CrutchAlerts.AsylumSanctorium.Test()


---------------------------------------------------------------------
-- More events
---------------------------------------------------------------------
-- Llothis begins casting for 1s, channels for 6s, sending out 6(?) bolts. Next occurrence seems to be after finish, not start?
local function OnBoltsBegin()
    if (not IsSettingEnabled(Crutch.savedOptions.asylumsanctorium.panel.showLlothisBolts)) then return end
    Crutch.dbgOther("bolts begin")
    Crutch.InfoPanel.StopCount(PANEL_LLOTHIS_BOLTS_INDEX)
    Crutch.InfoPanel.SetLine(PANEL_LLOTHIS_BOLTS_INDEX, BOLTS_NAME .. "|cFF0000INTERRUPT!", SUBITEM_SCALE)
end

local function OnBoltsFaded()
    Crutch.dbgOther("bolts end")
    if (not llothisDormant) then
        SetBolts(12000)
    end
end

local function OnInterrupted(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    if (AS.llothisId ~= targetUnitId) then return end

    Crutch.dbgOther("bolts interrupted")
    if (not llothisDormant) then
        SetBolts(12000)
    end
end

local function OnFart()
    if (not llothisDormant) then
        SetFart(25000) -- TODO
    end
end

-- TODO: is it before or after finishing?
local function OnCone(_, _, _, _, _, _, _, _, targetName, _, hitValue)
    if (hitValue ~= 2000) then return end
    Crutch.dbgOther("cone begin")
    SetCone(21000) -- TODO
end

local function OnFelmsJump()
    Crutch.dbgOther("felms jump")
    -- TODO: only after 3rd or something
    if (not felmsDormant) then
        SetTeleport(20500) -- TODO
    end
end

---------------------------------------------------------------------
-- "Events" called from AsylumSanctorium.lua
---------------------------------------------------------------------
function AS.OnLlothisDetectedPanel()
    StartLlothisHeader()
    SetBolts(12000) -- TODO
    SetCone(11000) -- TODO
    SetFart(0) -- TODO
end

-- Minis remain dormant for 45s
function AS.OnLlothisDormantPanel(changeType)
    if (changeType == EFFECT_RESULT_GAINED) then
        CountDownToLlothis()
        SetBolts(45000)
        SetCone(46000) -- TODO
        SetFart(46000) -- TODO
        llothisDormant = true
    elseif (changeType == EFFECT_RESULT_FADED) then
        StartLlothisHeader()
        llothisDormant = false
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
        felmsDormant = true
    elseif (changeType == EFFECT_RESULT_FADED) then
        StartFelmsHeader()
        felmsDormant = false
    end
end


---------------------------------------------------------------------
-- Overall init
---------------------------------------------------------------------
function AS.RegisterMiniPanel()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASPanelBoltsBegin", EVENT_COMBAT_EVENT, OnBoltsBegin)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASPanelBoltsBegin", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASPanelBoltsBegin", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 95585)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASPanelBoltsFaded", EVENT_COMBAT_EVENT, OnBoltsFaded)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASPanelBoltsFaded", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASPanelBoltsFaded", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 95585)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASPanelInterrupted", EVENT_COMBAT_EVENT, OnInterrupted)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASPanelInterrupted", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_INTERRUPT)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASPanelCone", EVENT_COMBAT_EVENT, OnCone)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASPanelCone", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASPanelCone", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 95545)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASPanelFart", EVENT_COMBAT_EVENT, OnFart)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASPanelFart", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASPanelFart", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 99819)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ASPanelTeleportStrike", EVENT_COMBAT_EVENT, OnFelmsJump)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASPanelTeleportStrike", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ASPanelTeleportStrike", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 99138)
end

function AS.UnregisterMiniPanel()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASPanelBoltsBegin", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASPanelBoltsFaded", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASPanelInterrupted", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASPanelCone", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASPanelFart", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ASPanelTeleportStrike", EVENT_COMBAT_EVENT)

    Crutch.InfoPanel.StopCount(PANEL_LLOTHIS_HEADER_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_LLOTHIS_BOLTS_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_LLOTHIS_CONE_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_LLOTHIS_FART_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_DUMMY_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_FELMS_HEADER_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_FELMS_TELEPORT_INDEX)

    llothisDisplaying = false
    llothisDormant = false
    felmsDormant = false
end
