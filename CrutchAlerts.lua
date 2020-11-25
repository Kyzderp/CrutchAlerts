-----------------------------------------------------------
-- CrutchAlerts
-- @author Kyzeragon
-----------------------------------------------------------

CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts
Crutch.name = "CrutchAlerts"

Crutch.registered = {
    begin = false,
    test = false,
    others = false,
    interrupts = false,
}

--[[
    unlock
    debug line
    debug chat spam
    other debug
    general
        show begin
            hide from self
        show gained
            hide from self
        hide hitvalue below X
            use ability whitelist
        extend 1ms hitvalues by X
        use self/group ability blacklist
        use enemy ability blacklist
    trials
        hrc
        aa
        so
        mol
        as
        hof
        cr
        ss
        ka
        ma
        brp
        vh
--]]

-- Defaults
local defaultOptions = {
    display = {
        x = 0,
        y = GuiRoot:GetHeight() / 3,
    },
    unlock = false,
    debugLine = false,
    debugChatSpam = false,
    debugOther = false,
    general = {
        showBegin = true,
            beginHideSelf = false,
        showGained = true,
        hitValueBelowThreshold = 75,
            hitValueUseWhitelist = true,
        hitValueAboveThreshold = 60000, -- nothing above 1 minute... right?
        useNonNoneBlacklist = true,
        useNoneBlacklist = true,
    },
    instance = {
        hrc = true,
        aa = true,
        so = true,
        mol = true,
        as = true,
        hof = true,
        cr = true,
        ss = true,
        ka = true,
        ma = true,
        brp = true,
        vh = true,
    },
}

function CrutchAlerts:SavePosition()
    local x, y = CrutchAlertsContainer:GetCenter()
    Crutch.savedOptions.display.x = x
    Crutch.savedOptions.display.y = y
end

---------------------------------------------------------------------
-- Initialize 
local function Initialize()
    -- Settings and saved variables
    Crutch.savedOptions = ZO_SavedVars:NewAccountWide("CrutchAlertsSavedVariables", 1, "Options", defaultOptions)
    Crutch:CreateSettingsMenu()

    -- Position
    CrutchAlertsContainer:SetAnchor(CENTER, GuiRoot, TOP, Crutch.savedOptions.display.x, Crutch.savedOptions.display.y)
    CrutchAlertsContainerBackdrop:SetHidden(not Crutch.savedOptions.display.unlock)

    -- Register events
    if (Crutch.savedOptions.general.showBegin) then
        Crutch.RegisterBegin()
    end
    if (Crutch.savedOptions.general.showGained) then
        Crutch.RegisterGained()
    end
    Crutch.RegisterInterrupts()
    Crutch.RegisterTest()
    Crutch.RegisterOthers()

    Crutch.RegisterEffectChanged() -- TODO: only do this when in group?

    -- Register for when entering zone
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Activated", EVENT_PLAYER_ACTIVATED,
        function(_, initial)
            Crutch.groupMembers = {} -- clear the cache
        end)
end


---------------------------------------------------------------------
-- On load
local function OnAddOnLoaded(_, addonName)
    if addonName == Crutch.name then
        EVENT_MANAGER:UnregisterForEvent(Crutch.name, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end
 
EVENT_MANAGER:RegisterForEvent(Crutch.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

