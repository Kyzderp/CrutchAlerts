-----------------------------------------------------------
-- CrutchAlerts
-- @author Kyzeragon
-----------------------------------------------------------

CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts
Crutch.name = "CrutchAlerts"
Crutch.version = "0.2.2"

Crutch.registered = {
    begin = false,
    test = false,
    enemy = false,
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
        unlock = false,
    },
    damageableDisplay = {
        x = 0,
        y = GuiRoot:GetHeight() / 5,
    },
    unlock = false,
    debugLine = false,
    debugChatSpam = false,
    debugOther = false,
    showSubtitles = true,
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

local trialUnregisters = {}
local trialRegisters = {}

function CrutchAlerts:SavePosition()
    local x, y = CrutchAlertsContainer:GetCenter()
    local oX, oY = GuiRoot:GetCenter()
    -- x is the offset from the center
    Crutch.savedOptions.display.x = x - oX
    Crutch.savedOptions.display.y = y

    x, y = CrutchAlertsDamageable:GetCenter()
    Crutch.savedOptions.damageableDisplay.x = x - oX
    Crutch.savedOptions.damageableDisplay.y = y - oY
end

local function OnPlayerActivated(_, initial)
    Crutch.groupMembers = {} -- clear the cache
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))

    -- Unregister previous active trial, if applicable
    if (trialUnregisters[Crutch.zoneId]) then
        trialUnregisters[Crutch.zoneId]()
    end

    -- Register current active trial, if applicable
    if (trialRegisters[zoneId]) then
        trialRegisters[zoneId]()
    end

    Crutch.zoneId = zoneId
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
    CrutchAlertsDamageable:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.damageableDisplay.x, Crutch.savedOptions.damageableDisplay.y)
    CrutchAlertsDamageableBackdrop:SetHidden(not Crutch.savedOptions.display.unlock)

    -- Register events
    if (Crutch.savedOptions.general.showBegin) then
        Crutch.RegisterBegin()
    end
    if (Crutch.savedOptions.general.showGained) then
        Crutch.RegisterGained()
    end

    -- Init general
    Crutch.InitializeDamageable()
    Crutch.RegisterInterrupts()
    Crutch.RegisterTest()
    Crutch.RegisterOthers()
    Crutch.RegisterStacks()
    Crutch.RegisterEffectChanged() -- TODO: only do this when in group?

    -- Register for when entering zone
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    trialUnregisters = {
        -- [635 ] = true,  -- Dragonstar Arena
        -- [636 ] = true,  -- Hel Ra Citadel
        -- [638 ] = true,  -- Aetherian Archive
        -- [639 ] = true,  -- Sanctum Ophidia
        -- [677 ] = true,  -- Maelstrom Arena
        -- [725 ] = true,  -- Maw of Lorkhaj
        -- [975 ] = true,  -- Halls of Fabrication
        -- [1000] = true,  -- Asylum Sanctorium
        [1051] = Crutch.UnregisterCloudrest,  -- Cloudrest
        -- [1082] = true,  -- Blackrose Prison
        -- [1121] = true,  -- Sunspire
        -- [1196] = true,  -- Kyne's Aegis
        -- [1227] = true,  -- Vateshran Hollows
    }

    trialRegisters = {
        -- [635 ] = true,  -- Dragonstar Arena
        -- [636 ] = true,  -- Hel Ra Citadel
        -- [638 ] = true,  -- Aetherian Archive
        -- [639 ] = true,  -- Sanctum Ophidia
        -- [677 ] = true,  -- Maelstrom Arena
        -- [725 ] = true,  -- Maw of Lorkhaj
        -- [975 ] = true,  -- Halls of Fabrication
        -- [1000] = true,  -- Asylum Sanctorium
        [1051] = Crutch.RegisterCloudrest,  -- Cloudrest
        -- [1082] = true,  -- Blackrose Prison
        -- [1121] = true,  -- Sunspire
        -- [1196] = true,  -- Kyne's Aegis
        -- [1227] = true,  -- Vateshran Hollows
    }
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

