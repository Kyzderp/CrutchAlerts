-----------------------------------------------------------
-- CrutchAlerts
-- @author Kyzeragon
-----------------------------------------------------------

CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts
Crutch.name = "CrutchAlerts"

-- Defaults
local defaultOptions = {
    display = {
        x = 0,
        y = GuiRoot:GetHeight() / 3,
        enable = true,
        unlock = false,
    },
}

---------------------------------------------------------------------
-- Initialize 
local function Initialize()
    -- Settings and saved variables
    Crutch.savedOptions = ZO_SavedVars:NewAccountWide("CrutchAlertsSavedVariables", 1, "Options", defaultOptions)

    -- Position
    CrutchAlertsContainer:SetAnchor(CENTER, GuiRoot, TOP, Crutch.savedOptions.display.x, Crutch.savedOptions.display.y)
    CrutchAlertsContainer:SetHidden(not Crutch.savedOptions.display.enable)
    CrutchAlertsContainerBackdrop:SetHidden(not Crutch.savedOptions.display.unlock)

    -- Register events
    Crutch.RegisterBegin()
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

