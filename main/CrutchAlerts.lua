-----------------------------------------------------------
-- CrutchAlerts
-- @author Kyzeragon
-----------------------------------------------------------
CrutchAlerts = {
    BossHealthBar = {},
    Drawing = {
        Animation = {},
    },
    Constants = {},
    InfoPanel = {},

    name = "CrutchAlerts",
    version = "2.10.0",

    unlock = false,
}
local Crutch = CrutchAlerts

Crutch.registered = {
    begin = false,
    test = false,
    enemy = false,
    others = false,
    interrupts = false,
}

-- currently: zmaja thresholds
-- /script CrutchAlerts.savedOptions.experimental = true

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
    infoPanelDisplay = {
        x = GuiRoot:GetWidth() / 4,
        y = -GuiRoot:GetHeight() * 3 / 8,
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
        showGained = true,
        showOthers = true,
        showProminent = true,
        hitValueBelowThreshold = 75,
        hitValueAboveThreshold = 60000, -- nothing above 1 minute... right?
        showDamageable = true,
        consolidateDamageableInInfoPanel = false,
        showRaidDiag = false,
        beginHideArcanist = false, -- has been changed to be its own thing, reusing the setting
        showJBeam = true,

        -- Custom IDs
        blacklist = {}, -- {[1234] = true,}
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
            useSupportIconsForDead = true,
            rezzingColor = {0.3, 0.7, 1},
            pendingColor = {1, 1, 1},
            deadColor = {1, 0, 0},

            showCrown = false,
            crownColor = {0, 1, 0},

            useDepthBuffers = false,
            size = 70,
            yOffset = 350,
            opacity = 0.8,

            individualIcons = {}, -- {["@Kyzeragon"] = "CrutchAlerts/assets/poop.dds",}
            -- /script CrutchAlerts.savedOptions.drawing.attached.individualIcons["@Kyzeragon"] = "CrutchAlerts/assets/poop.dds"
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
        horizontal = false,
        scale = 1,
        useFloorRounding = true,
        foreground = {179/256, 18/256, 7/256, 0.73},
        background = {16/256, 0, 0, 0.66},
    },
    infoPanel = {
        size = 30,
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
        showFlareIcon = true,
        dropFrostProminent = true,
        showFrostAlert = true,
        showFrostIcons = false,
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
    opulentordeal = {
        showAffinityIcons = true,
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

        panel = {
            showLeap = true,
            showClash = true,
        },
    },
    rockgrove = {
        sludgeSides = true,
        showSludgeIcons = false,
        showBleeding = "HEAL", -- "NEVER", "HEAL", "ALWAYS"
        showCurseIcons = true,

        showCursePreview = false,
        cursePreviewColor = {1, 1, 1, 0.2},
        showCurseLines = false,
        curseLineColor = {1, 1, 0, 0.5},
        showOthersCurseLines = false,
        othersCurseLineColor = {1, 1, 0, 0.5},

        spoofAbilitiesFirstTime = true,
        portalNumber = 0, -- 0 for none, 1, 2
        abilitiesToReplace = {},
        portalTimeMargin = 4000,

        panel = {
            showSludge = true,
            showBlitz = true,

            showTimeToPortal = true,
            showNumInPortal = true,
            showPortalDirection = true,
            showCursedGround = true,
            showScythe = true,
        },
    },
    sanitysedge = {
        showChimeraIcons = true,
        chimeraIconsSize = 150,
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

    x = CrutchAlertsInfoPanel:GetLeft()
    y = CrutchAlertsInfoPanel:GetTop()
    Crutch.savedOptions.infoPanelDisplay.x = x - oX
    Crutch.savedOptions.infoPanelDisplay.y = y - oY
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

    Crutch.dbgSpam(string.format("|c00FF00zoneId: %s (%d) -> %s (%d); mapId %s (%d)|r",
        GetZoneNameById(Crutch.zoneId) or "??", Crutch.zoneId or 0,
        GetZoneNameById(zoneId) or "??", zoneId or 0,
        GetMapNameById(GetCurrentMapId()) or "??", GetCurrentMapId() or 0))

    -- Unregister previous active trial, if applicable
    if (zoneUnregisters[Crutch.zoneId]) then
        zoneUnregisters[Crutch.zoneId](zoneId == Crutch.zoneId)
    end
    Crutch.UnregisterProminents(Crutch.zoneId)
    Crutch.UnregisterEffects(Crutch.zoneId)

    -- Register current active trial, if applicable
    if (zoneRegisters[zoneId]) then
        zoneRegisters[zoneId](zoneId == Crutch.zoneId)
    end
    Crutch.RegisterProminents(zoneId)
    Crutch.RegisterEffects(zoneId)
    Crutch.RegisterOthers()

    Crutch.zoneId = zoneId
end
Crutch.OnPlayerActivated = OnPlayerActivated

---------------------------------------------------------------------
-- First time player activated
---------------------------------------------------------------------
-- caveman profiling
local lastTime
local queuedMessages = {}
local function PrintTime(reason)
    if (not lastTime) then
        lastTime = GetGameTimeMilliseconds()
        return
    end

    local now = GetGameTimeMilliseconds()
    table.insert(queuedMessages, string.format("%d - %s",
        now - lastTime,
        reason))
    lastTime = now
end

local function OnPlayerActivatedFirstTime()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ActivatedFirstTime", EVENT_PLAYER_ACTIVATED)

    for _, msg in ipairs(queuedMessages) do
        Crutch.dbgOther(msg)
    end
end

---------------------------------------------------------------------
-- Initialize 
---------------------------------------------------------------------
local function Initialize()
    PrintTime("init")
    -- Settings and saved variables
    Crutch.AddProminentDefaults()
    Crutch.AddEffectDefaults()
    PrintTime("defaults done")
    Crutch.savedOptions = ZO_SavedVars:NewAccountWide("CrutchAlertsSavedVariables", 1, "Options", defaultOptions)

    if (Crutch.savedOptions.rockgrove.spoofAbilitiesFirstTime) then
        local abilities = Crutch.savedOptions.rockgrove.abilitiesToReplace
        abilities[38901] = true -- Quick Cloak
        abilities[22095] = true -- Solar Barrage
        abilities[32853] = true -- Flames of Oblivion
        abilities[23231] = true -- Hurricane
        abilities[118680] = true -- Skeletal Archer
        abilities[118726] = true -- Skeletal Arcanist
        Crutch.savedOptions.rockgrove.spoofAbilitiesFirstTime = false
    end

    if (Crutch.savedOptions.prominentV2FirstTime) then
        Crutch.InitProminentV2Options()
        Crutch.savedOptions.prominentV2FirstTime = false
    end
    PrintTime("savedOptions done")

    if (IsConsoleUI()) then
        Crutch.CreateConsoleGeneralSettingsMenu()
        Crutch.CreateConsoleContentSettingsMenu()
        Crutch.CreateConsoleDrawingSettingsMenu()
    else
        Crutch:CreateSettingsMenu()
    end
    PrintTime("settings done")

    -- Position
    CrutchAlertsContainer:SetAnchor(CENTER, GuiRoot, TOP, Crutch.savedOptions.display.x, Crutch.savedOptions.display.y)
    CrutchAlertsDamageable:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.damageableDisplay.x, Crutch.savedOptions.damageableDisplay.y)
    CrutchAlertsCloudrest:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.spearsDisplay.x, Crutch.savedOptions.spearsDisplay.y)
    CrutchAlertsMawOfLorkhaj:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.cursePadsDisplay.x, Crutch.savedOptions.cursePadsDisplay.y)
    CrutchAlertsCausticCarrion:SetAnchor(TOPLEFT, GuiRoot, CENTER, Crutch.savedOptions.carrionDisplay.x, Crutch.savedOptions.carrionDisplay.y)
    CrutchAlertsInfoPanel:SetAnchor(TOPLEFT, GuiRoot, CENTER, Crutch.savedOptions.infoPanelDisplay.x, Crutch.savedOptions.infoPanelDisplay.y)
    PrintTime("positioning done")
    -- Register events
    if (Crutch.savedOptions.general.showBegin) then
        Crutch.RegisterBegin()
    end
    PrintTime("begin done")
    if (Crutch.savedOptions.general.showGained) then
        Crutch.RegisterGained()
    end
    PrintTime("gained done")
    Crutch.RegisterOthers()
    PrintTime("others done")

    -- Init general
    Crutch.InitializeStyles()
    PrintTime("styles done")
    Crutch.InitializeDamageable()
    PrintTime("damageable done")
    Crutch.InitializeDamageTaken()
    PrintTime("damage taken done")
    Crutch.RegisterInterrupts()
    PrintTime("interrupts done")
    Crutch.RegisterTest()
    PrintTime("test done")
    Crutch.RegisterStacks()
    PrintTime("stacks done")
    Crutch.RegisterEffectChanged()
    PrintTime("effect changed done")
    Crutch.RegisterFatecarver()
    PrintTime("fatecarver done")
    Crutch.InitializeGlobalEvents()
    PrintTime("global events done")
    Crutch.InitializeLineRenderSpace()
    PrintTime("line render done")
    Crutch.Drawing.InitializeRenderSpace()
    PrintTime("renderspace done")
    Crutch.Drawing.InitializeSpace()
    PrintTime("space done")
    Crutch.Drawing.InitializeAttachedIcons()
    PrintTime("attached icons done")
    Crutch.InitializeAbilityOverlay()
    PrintTime("ability overlays done")
    Crutch.InitializeInfoPanel()
    PrintTime("info panel done")

    -- Boss health bar
    Crutch.BossHealthBar.Initialize()
    PrintTime("bhb done")

    -- Data sharing
    Crutch.InitializeBroadcast()
    PrintTime("broadcast done")

    -- Debug chat panel
    if (LibFilteredChatPanel) then
        crutchLFCPFilter = LibFilteredChatPanel:CreateFilter(Crutch.name, "/esoui/art/ava/ava_rankicon64_volunteer.dds", {0.7, 0.7, 0.5}, false)
    end

    -- Register for when entering zone
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ActivatedFirstTime", EVENT_PLAYER_ACTIVATED, OnPlayerActivatedFirstTime)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    PrintTime("player activation register done")
    zoneUnregisters = {
        [635 ] = Crutch.UnregisterDragonstarArena,
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
        [1565] = Crutch.UnregisterOpulentOrdeal,

        [677 ] = Crutch.UnregisterMaelstromArena,
        [1436] = Crutch.UnregisterEndlessArchive,

        [1301] = Crutch.UnregisterCoralAerie,
        [1302] = Crutch.UnregisterShipwrightsRegret,
        [1471] = Crutch.UnregisterBedlamVeil,
        [1552] = Crutch.UnregisterBlackGemFoundry,
    }

    zoneRegisters = {
        [635 ] = Crutch.RegisterDragonstarArena,
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
        [1565] = Crutch.RegisterOpulentOrdeal,

        [677 ] = Crutch.RegisterMaelstromArena,
        [1436] = Crutch.RegisterEndlessArchive,

        [1301] = Crutch.RegisterCoralAerie,
        [1302] = Crutch.RegisterShipwrightsRegret,
        [1471] = Crutch.RegisterBedlamVeil,
        [1552] = Crutch.RegisterBlackGemFoundry,
    }
    PrintTime("finished")
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

