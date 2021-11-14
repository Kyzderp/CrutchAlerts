-----------------------------------------------------------
-- CrutchAlerts
-- @author Kyzeragon
-----------------------------------------------------------

CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts
Crutch.name = "CrutchAlerts"
Crutch.version = "0.6.1"

Crutch.registered = {
    begin = false,
    test = false,
    enemy = false,
    others = false,
    interrupts = false,
}

Crutch.unlock = false

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
    damageableDisplay = {
        x = 0,
        y = GuiRoot:GetHeight() / 5,
    },
    spearsDisplay = {
        x = GuiRoot:GetWidth() / 4,
        y = 0,
    },
    debugLine = false,
    debugChatSpam = false,
    debugOther = false,
    debugUi = false,
    showSubtitles = true,
    general = {
        showBegin = true,
            beginHideSelf = false,
        showGained = true,
        showProminent = true,
        hitValueBelowThreshold = 75,
            hitValueUseWhitelist = true,
        hitValueAboveThreshold = 60000, -- nothing above 1 minute... right?
        useNonNoneBlacklist = true,
        useNoneBlacklist = true,
    },
    cloudrest = {
        showSpears = true,
        spearsSound = true,
    },
    sunspire = {
        showLokkIcons = true,
        showYolIcons = true,
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
        rg = true,
        ma = true,
        brp = true,
        vh = true,
    },
}

local trialUnregisters = {}
local trialRegisters = {}

local crutchLFCPFilter = nil

---------------------------------------------------------------------
function CrutchAlerts:SavePosition()
    local x, y = CrutchAlertsContainer:GetCenter()
    local oX, oY = GuiRoot:GetCenter()
    -- x is the offset from the center
    Crutch.savedOptions.display.x = x - oX
    Crutch.savedOptions.display.y = y

    x, y = CrutchAlertsDamageable:GetCenter()
    Crutch.savedOptions.damageableDisplay.x = x - oX
    Crutch.savedOptions.damageableDisplay.y = y - oY

    x, y = CrutchAlertsCloudrest:GetCenter()
    Crutch.savedOptions.spearsDisplay.x = x - oX
    Crutch.savedOptions.spearsDisplay.y = y - oY
end

---------------------------------------------------------------------
function Crutch.dbgOther(text)
    if (Crutch.savedOptions.debugOther) then
        d("|c88FFFF[CO]|r " .. tostring(text))
    end
end

function Crutch.dbgSpam(text)
    if (Crutch.savedOptions.debugChatSpam) then
        if (crutchLFCPFilter) then
            crutchLFCPFilter:AddMessage(text)
        else
            d(text)
        end
    end
end

---------------------------------------------------------------------
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
    CrutchAlertsDamageable:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.damageableDisplay.x, Crutch.savedOptions.damageableDisplay.y)
    CrutchAlertsCloudrest:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.spearsDisplay.x, Crutch.savedOptions.spearsDisplay.y)

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
    Crutch.InitializeDebug()

    -- Debug chat panel
    if (LibFilteredChatPanel) then
        crutchLFCPFilter = LibFilteredChatPanel:CreateFilter(Crutch.name, "/esoui/art/ava/ava_rankicon64_volunteer.dds", {0.7, 0.7, 0.5}, false)
    end

    -- Register for when entering zone
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    trialUnregisters = {
        -- [635 ] = true,  -- Dragonstar Arena
        -- [636 ] = true,  -- Hel Ra Citadel
        -- [638 ] = true,  -- Aetherian Archive
        -- [639 ] = true,  -- Sanctum Ophidia
        -- [677 ] = true,  -- Maelstrom Arena
        [725 ] = Crutch.UnregisterMawOfLorkhaj,  -- Maw of Lorkhaj
        -- [975 ] = true,  -- Halls of Fabrication
        -- [1000] = true,  -- Asylum Sanctorium
        [1051] = Crutch.UnregisterCloudrest,  -- Cloudrest
        -- [1082] = true,  -- Blackrose Prison
        [1121] = Crutch.UnregisterSunspire,  -- Sunspire
        [1196] = Crutch.UnregisterKynesAegis,  -- Kyne's Aegis
        -- [1227] = true,  -- Vateshran Hollows
        [1263] = Crutch.UnregisterRockgrove,  -- Rockgrove
    }

    trialRegisters = {
        -- [635 ] = true,  -- Dragonstar Arena
        -- [636 ] = true,  -- Hel Ra Citadel
        -- [638 ] = true,  -- Aetherian Archive
        -- [639 ] = true,  -- Sanctum Ophidia
        -- [677 ] = true,  -- Maelstrom Arena
        [725 ] = Crutch.RegisterMawOfLorkhaj,  -- Maw of Lorkhaj
        -- [975 ] = true,  -- Halls of Fabrication
        -- [1000] = true,  -- Asylum Sanctorium
        [1051] = Crutch.RegisterCloudrest,  -- Cloudrest
        -- [1082] = true,  -- Blackrose Prison
        [1121] = Crutch.RegisterSunspire,  -- Sunspire
        [1196] = Crutch.RegisterKynesAegis,  -- Kyne's Aegis
        -- [1227] = true,  -- Vateshran Hollows
        [1263] = Crutch.RegisterRockgrove,  -- Rockgrove
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

