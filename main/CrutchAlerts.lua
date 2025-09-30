-----------------------------------------------------------
-- CrutchAlerts
-- @author Kyzeragon
-----------------------------------------------------------
CrutchAlerts = {
    BossHealthBar = {},
    Drawing = {},
}
local Crutch = CrutchAlerts
Crutch.name = "CrutchAlerts"
Crutch.version = "2.2.0-SNAPSHOT"

Crutch.registered = {
    begin = false,
    test = false,
    enemy = false,
    others = false,
    interrupts = false,
}

Crutch.unlock = false

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
        y = -GuiRoot:GetHeight() / 8,
    },
    cursePadsDisplay = {
        x = GuiRoot:GetWidth() / 4,
        y = -GuiRoot:GetHeight() / 8,
    },
    bossHealthBarDisplay = {
        x = -GuiRoot:GetWidth() * 3 / 8,
        y = -100,
    },
    carrionDisplay = {
        x = GuiRoot:GetWidth() * 3 / 16,
        y = -GuiRoot:GetHeight() / 8,
    },
    debugLine = false,
    debugChatSpam = false,
    debugOther = false,
    debugLineDistance = false,
    showSubtitles = false,
    subtitlesIgnoredZones = {},
    prominentV2FirstTime = true,
    general = {
        alertScale = 36,
        showBegin = true,
            beginHideSelf = false,
        beginHideArcanist = false,
        showGained = true,
        showOthers = true,
        showProminent = true,
        hitValueBelowThreshold = 75,
            hitValueUseWhitelist = true,
        hitValueAboveThreshold = 60000, -- nothing above 1 minute... right?
        useNonNoneBlacklist = true,
        useNoneBlacklist = true,
        showDamageable = true,
        showRaidDiag = false,
        showJBeam = true,
    },
    drawing = {
        useLevels = true, -- Whether to avoid clipping / appearing out of order
        interval = 10, -- ms between updates
        attached = {
            showSelfRole = false,

            showDps = false,
            dpsColor = {1, 0.5, 0},

            showHeal = false,
            healColor = {1, 0.9, 0},

            showTank = false,
            tankColor = {0, 0.6, 1},

            showDead = true,
            rezzingColor = {0.3, 0.7, 1},
            pendingColor = {1, 1, 1},
            deadColor = {1, 0, 0},

            showCrown = false,
            crownColor = {0, 1, 0},

            useDepthBuffers = false,
            size = 70,
            yOffset = 350,
            opacity = 0.8,
        },
        -- positioning marker icons that face the camera, placed in the world
        placedPositioning = {
            useDepthBuffers = false,
            opacity = 0.8,
            flat = false,
        },
        -- icons that face the player, placed in the world, like brewmaster potions
        placedIcon = {
            useDepthBuffers = false,
            opacity = 1,
        },
        -- mostly textures that are oriented a certain way, like telegraph circles
        placedOriented = {
            useDepthBuffers = true,
            opacity = 0.6,
        },
    },
    console = { -- Some console-specific settings?
        showProminent = true,
    },
    bossHealthBar = {
        enabled = true,
        scale = 1,
        useFloorRounding = true,
    },
    asylumsanctorium = {
        dingSelfCone = true,
        dingOthersCone = false,
        showMinisHp = true,
    },
    cloudrest = {
        showSpears = true,
        spearsSound = true,
        deathIconColor = true,
        showFlaresSides = true,
    },
    dreadsailreef = {
        alertStaticStacks = true,
        staticThreshold = 7,
        alertVolatileStacks = true,
        volatileThreshold = 6,
        showArcingCleave = false,
    },
    hallsoffabrication = {
        showTripletsIcon = true,
        tripletsIconSize = 150,
        showAGIcons = true,
        agIconsSize = 150,
    },
    kynesaegis = {
        showSpearIcon = true,
        showPrisonIcon = true,
        showFalgravnIcons = true,
        falgravnIconsSize = 150,
    },
    lucentcitadel = {
        alertDarkness = true,
        showKnotTimer = true,
        showCavotIcon = true,
        cavotIconSize = 100,
        showOrphicIcons = true,
        orphicIconsNumbers = false,
        orphicIconSize = 150,
        showWeakeningCharge = "TANK", -- "NEVER", "TANK", "ALWAYS"
        showTempestIcons = true,
        tempestIconsSize = 150,
        showArcaneConveyance = true,
        showArcaneConveyanceTether = true,
    },
    osseincage = {
        showStricken = "TANK", -- "NEVER", "TANK", "ALWAYS"
        showChains = true,
        showCarrion = true,
        showCarrionIndividual = false,
        showTitansHp = true,
        showTwinsIcons = false,
        useAOCHIcons = false,
        useMiddleIcons = true,
        twinsIconsSize = 100,
        showEnfeeblementIcons = "HM", -- "NEVER", "VET", "HM", "ALWAYS"
        printHMReflectiveScales = true,
    },
    rockgrove = {
        sludgeSides = true,
        showBleeding = "HEAL", -- "NEVER", "HEAL", "ALWAYS"
        showCurseIcons = true,

        showCursePreview = false,
        cursePreviewColor = {1, 1, 1, 0.2},
        showCurseLines = false,
        curseLineColor = {1, 0, 0, 0.7},
        showOthersCurseLines = false,
        othersCurseLineColor = {1, 0, 0, 0.7},
    },
    sanitysedge = {
        showAnsuulIcon = true,
        ansuulIconSize = 150,
    },
    sunspire = {
        showLokkIcons = true,
        lokkIconsSize = 150,
        lokkIconsSoloHeal = false,
        telegraphStormBreath = false,
        showYolIcons = true,
        yolLeftIcons = false,
        yolIconsSize = 150,
        yolFocusedFire = true,
    },
    mawoflorkhaj = {
        showPads = true,
        prominentColorSwap = true,
        showTwinsIcons = true,
    },
    maelstrom = {
        normalDamageTaken = false,
        showRounds = true,
        stage1Boss = "Equip boss setup!",
        stage2Boss = "Equip boss setup!",
        stage3Boss = "Equip boss setup!",
        stage4Boss = "Equip boss setup!",
        stage5Boss = "Equip boss setup!",
        stage6Boss = "Equip boss setup!",
        stage7Boss = "Equip boss setup!",
        stage8Boss = "",
        stage9Boss = "Equip boss setup!",
    },
    blackrose = {
        showCursed = true, -- Not used, just a placeholder. Not sure if I can put it in prominent V2
    },
    dragonstar = {
        normalDamageTaken = false,
    },
    endlessArchive = {
        markFabled = true,
        markNegate = false,
        dingUppercut = false,
        dingDangerous = true,
        potionIcon = true,
        printPuzzleSolution = true,
    },
    vateshran = {
        showMissedAdds = false,
    },
    blackGemFoundry = {
        showRuptureLine = true,
    },
    shipwrightsRegret = {
        showBombStacks = true,
    },
}
Crutch.defaultOptions = defaultOptions

local zoneUnregisters = {}
local zoneRegisters = {}

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

    x, y = CrutchAlertsMawOfLorkhaj:GetCenter()
    Crutch.savedOptions.cursePadsDisplay.x = x - oX
    Crutch.savedOptions.cursePadsDisplay.y = y - oY

    x = CrutchAlertsBossHealthBarContainer:GetLeft()
    y = CrutchAlertsBossHealthBarContainer:GetTop()
    Crutch.savedOptions.bossHealthBarDisplay.x = x - oX
    Crutch.savedOptions.bossHealthBarDisplay.y = y - oY

    x = CrutchAlertsCausticCarrion:GetLeft()
    y = CrutchAlertsCausticCarrion:GetTop()
    Crutch.savedOptions.carrionDisplay.x = x - oX
    Crutch.savedOptions.carrionDisplay.y = y - oY
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
-- Zone change
---------------------------------------------------------------------
local function OnPlayerActivated()
    -- clear the caches
    Crutch.groupIdToTag = {}
    Crutch.groupTagToId = {}
    Crutch.majorCowardiceUnitIds = {}

    -- Lock the UI if it was unlocked
    if (Crutch.unlock) then
        Crutch.UnlockUI(false)
    end

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))

    -- Unregister previous active trial, if applicable
    if (zoneUnregisters[Crutch.zoneId]) then
        zoneUnregisters[Crutch.zoneId]()
    end
    Crutch.UnregisterProminents(Crutch.zoneId)
    Crutch.UnregisterEffects(Crutch.zoneId)

    -- Register current active trial, if applicable
    if (zoneRegisters[zoneId]) then
        zoneRegisters[zoneId]()
    end
    Crutch.RegisterProminents(zoneId)
    Crutch.RegisterEffects(zoneId)

    Crutch.zoneId = zoneId
end
Crutch.OnPlayerActivated = OnPlayerActivated

---------------------------------------------------------------------
-- First time player activated
---------------------------------------------------------------------
local function OnPlayerActivatedFirstTime()
    -- Did I use to have stuff in here??
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ActivatedFirstTime", EVENT_PLAYER_ACTIVATED)
end

---------------------------------------------------------------------
-- Initialize 
---------------------------------------------------------------------
local function Initialize()
    -- Settings and saved variables
    Crutch.AddProminentDefaults()
    Crutch.AddEffectDefaults()
    Crutch.savedOptions = ZO_SavedVars:NewAccountWide("CrutchAlertsSavedVariables", 1, "Options", defaultOptions)
    if (Crutch.savedOptions.prominentV2FirstTime) then
        Crutch.InitProminentV2Options()
        Crutch.savedOptions.prominentV2FirstTime = false
    end

    if (IsConsoleUI()) then
        Crutch.CreateConsoleGeneralSettingsMenu()
        Crutch.CreateConsoleContentSettingsMenu()
        Crutch.CreateConsoleDrawingSettingsMenu()
    else
        Crutch:CreateSettingsMenu()
    end

    -- Position
    CrutchAlertsContainer:SetAnchor(CENTER, GuiRoot, TOP, Crutch.savedOptions.display.x, Crutch.savedOptions.display.y)
    CrutchAlertsDamageable:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.damageableDisplay.x, Crutch.savedOptions.damageableDisplay.y)
    CrutchAlertsCloudrest:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.spearsDisplay.x, Crutch.savedOptions.spearsDisplay.y)
    CrutchAlertsMawOfLorkhaj:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.cursePadsDisplay.x, Crutch.savedOptions.cursePadsDisplay.y)
    CrutchAlertsCausticCarrion:SetAnchor(TOPLEFT, GuiRoot, CENTER, Crutch.savedOptions.carrionDisplay.x, Crutch.savedOptions.carrionDisplay.y)

    -- Register events
    if (Crutch.savedOptions.general.showBegin) then
        Crutch.RegisterBegin()
    end
    if (Crutch.savedOptions.general.showGained) then
        Crutch.RegisterGained()
    end
    if (Crutch.savedOptions.general.showOthers) then
        Crutch.RegisterOthers()
    end

    -- Init general
    Crutch.InitializeStyles()
    Crutch.InitializeDamageable()
    Crutch.InitializeDamageTaken()
    Crutch.RegisterInterrupts()
    Crutch.RegisterTest()
    Crutch.RegisterStacks()
    Crutch.RegisterEffectChanged()
    Crutch.RegisterFatecarver()
    Crutch.InitializeGlobalEvents()
    Crutch.InitializeRenderSpace()
    Crutch.Drawing.Initialize()

    -- Boss health bar
    Crutch.BossHealthBar.Initialize()

    -- Data sharing
    Crutch.InitializeBroadcast()

    -- Debug chat panel
    if (LibFilteredChatPanel) then
        crutchLFCPFilter = LibFilteredChatPanel:CreateFilter(Crutch.name, "/esoui/art/ava/ava_rankicon64_volunteer.dds", {0.7, 0.7, 0.5}, false)
    end

    -- Register for when entering zone
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ActivatedFirstTime", EVENT_PLAYER_ACTIVATED, OnPlayerActivatedFirstTime)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    zoneUnregisters = {
        [639 ] = Crutch.UnregisterSanctumOphidia,
        [725 ] = Crutch.UnregisterMawOfLorkhaj,
        [975 ] = Crutch.UnregisterHallsOfFabrication,
        [1000] = Crutch.UnregisterAsylumSanctorium,
        [1051] = Crutch.UnregisterCloudrest,
        [1121] = Crutch.UnregisterSunspire,
        [1196] = Crutch.UnregisterKynesAegis,
        [1227] = Crutch.UnregisterVateshran,
        [1263] = Crutch.UnregisterRockgrove,
        [1344] = Crutch.UnregisterDreadsailReef,
        [1427] = Crutch.UnregisterSanitysEdge,
        [1478] = Crutch.UnregisterLucentCitadel,
        [1548] = Crutch.UnregisterOsseinCage,

        [677 ] = Crutch.UnregisterMaelstromArena,
        [1436] = Crutch.UnregisterEndlessArchive,

        [1301] = Crutch.UnregisterCoralAerie,
        [1302] = Crutch.UnregisterShipwrightsRegret,
        [1471] = Crutch.UnregisterBedlamVeil,
        [1552] = Crutch.UnregisterBlackGemFoundry,
    }

    zoneRegisters = {
        [639 ] = Crutch.RegisterSanctumOphidia,
        [725 ] = Crutch.RegisterMawOfLorkhaj,
        [975 ] = Crutch.RegisterHallsOfFabrication,
        [1000] = Crutch.RegisterAsylumSanctorium,
        [1051] = Crutch.RegisterCloudrest,
        [1121] = Crutch.RegisterSunspire,
        [1196] = Crutch.RegisterKynesAegis,
        [1227] = Crutch.RegisterVateshran,
        [1263] = Crutch.RegisterRockgrove,
        [1344] = Crutch.RegisterDreadsailReef,
        [1427] = Crutch.RegisterSanitysEdge,
        [1478] = Crutch.RegisterLucentCitadel,
        [1548] = Crutch.RegisterOsseinCage,

        [677 ] = Crutch.RegisterMaelstromArena,
        [1436] = Crutch.RegisterEndlessArchive,

        [1301] = Crutch.RegisterCoralAerie,
        [1302] = Crutch.RegisterShipwrightsRegret,
        [1471] = Crutch.RegisterBedlamVeil,
        [1552] = Crutch.RegisterBlackGemFoundry,
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

