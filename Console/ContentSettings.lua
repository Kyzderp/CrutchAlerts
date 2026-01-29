local Crutch = CrutchAlerts

local ADD_ICON_SETTINGS = false

function Crutch.CreateConsoleContentSettingsMenu()
    local settings = LibHarvensAddonSettings:AddAddon("CrutchAlerts - Trials / Arenas / Dungeons", {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = function()
            Crutch.UnlockUI(true)
        end,
    })

    if (not settings) then
        d("|cFF0000CrutchAlerts - unable to create settings?!|r")
        return
    end

    ---------------------------------------------------------------------
    -- trials
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Trials",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Asylum Sanctorium",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Play sound for cone on self",
        tooltip = "Play a ding sound when Llothis' Defiling Dye Blast targets you",
        default = true,
        getFunction = function() return Crutch.savedOptions.asylumsanctorium.dingSelfCone end,
        setFunction = function(value)
            Crutch.savedOptions.asylumsanctorium.dingSelfCone = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Play sound for cone on others",
        tooltip = "Play a ding sound when Llothis' Defiling Dye Blast targets other players",
        default = false,
        getFunction = function() return Crutch.savedOptions.asylumsanctorium.dingOthersCone end,
        setFunction = function(value)
            Crutch.savedOptions.asylumsanctorium.dingOthersCone = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show minis' health bars",
        tooltip = "Shows Felms' and Llothis' health using the vertical boss health bars",
        default = true,
        getFunction = function() return Crutch.savedOptions.asylumsanctorium.showMinisHp end,
        setFunction = function(value)
            Crutch.savedOptions.asylumsanctorium.showMinisHp = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return not Crutch.savedOptions.bossHealthBar.enabled end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Cloudrest",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show spears indicator",
        tooltip = "Show an indicator for how many spears are revealed, sent, and orbs dunked",
        default = true,
        getFunction = function() return Crutch.savedOptions.cloudrest.showSpears end,
        setFunction = function(value)
            Crutch.savedOptions.cloudrest.showSpears = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Spears indicator position X",
        tooltip = "The horizontal position of the spears indicator",
        min = - GuiRoot:GetWidth() / 2,
        max = GuiRoot:GetWidth() / 2,
        step = GuiRoot:GetWidth() / 64,
        default = Crutch.defaultOptions.spearsDisplay.x,
        getFunction = function() return Crutch.savedOptions.spearsDisplay.x end,
        setFunction = function(value)
            Crutch.savedOptions.spearsDisplay.x = value
            CrutchAlertsCloudrest:ClearAnchors()
            CrutchAlertsCloudrest:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.spearsDisplay.x, Crutch.savedOptions.spearsDisplay.y)
            Crutch.UnlockUI(true)
        end,
        disable = function() return not Crutch.savedOptions.cloudrest.showSpears end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Spears indicator position Y",
        tooltip = "The vertical position of the spears indicator",
        min = - GuiRoot:GetHeight() / 2,
        max = GuiRoot:GetHeight() / 2,
        step = GuiRoot:GetHeight() / 64,
        default = Crutch.defaultOptions.spearsDisplay.y,
        getFunction = function() return Crutch.savedOptions.spearsDisplay.y end,
        setFunction = function(value)
            Crutch.savedOptions.spearsDisplay.y = value
            CrutchAlertsCloudrest:ClearAnchors()
            CrutchAlertsCloudrest:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.spearsDisplay.x, Crutch.savedOptions.spearsDisplay.y)
            Crutch.UnlockUI(true)
        end,
        disable = function() return not Crutch.savedOptions.cloudrest.showSpears end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Play spears sound",
        tooltip = "Plays the champion point committed sound when a spear is revealed",
        default = true,
        getFunction = function() return Crutch.savedOptions.cloudrest.spearsSound end,
        setFunction = function(value)
            Crutch.savedOptions.cloudrest.spearsSound = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Hoarfrost timer",
        tooltip = "Shows a timer for when you can drop Hoarfrost, and a timer after that for when Overwhelming Hoarfrost would kill you (on veteran)",
        default = true,
        getFunction = function() return Crutch.savedOptions.cloudrest.showFrostAlert end,
        setFunction = function(value)
            Crutch.savedOptions.cloudrest.showFrostAlert = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Hoarfrost icon",
        tooltip = "Shows icons above players who currently have Hoarfrost",
        default = false,
        getFunction = function() return Crutch.savedOptions.cloudrest.showFrostIcons end,
        setFunction = function(value)
            Crutch.savedOptions.cloudrest.showFrostIcons = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show flare sides",
        tooltip = "On Z'Maja during execute with +Siroria, show which side each of the two people with Roaring Flares can go to",
        default = true,
        getFunction = function() return Crutch.savedOptions.cloudrest.showFlaresSides end,
        setFunction = function(value)
            Crutch.savedOptions.cloudrest.showFlaresSides = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show flare icon",
        tooltip = "Shows icons above players who are targeted by Roaring Flare",
        default = true,
        getFunction = function() return Crutch.savedOptions.cloudrest.showFlareIcon end,
        setFunction = function(value)
            Crutch.savedOptions.cloudrest.showFlareIcon = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Dreadsail Reef",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Arcing Cleave guidelines",
        tooltip = "Draws guidelines approximating where Taleria's Arcing Cleave will hit. I'm tired of seeing people stand behind tank!",
        default = false,
        getFunction = function() return Crutch.savedOptions.dreadsailreef.showArcingCleave end,
        setFunction = function(value)
            Crutch.savedOptions.dreadsailreef.showArcingCleave = value
            Crutch.TryEnablingTaleriaCleave()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Halls of Fabrication",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Shock Field for triplets",
        tooltip = "In the triplets fight, shows the approximate outline of Shock Field even when it's not active",
        default = true,
        getFunction = function() return Crutch.savedOptions.hallsoffabrication.showTripletsIcon end,
        setFunction = function(value)
            Crutch.savedOptions.hallsoffabrication.showTripletsIcon = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Assembly General icons",
        tooltip = "Shows icons in the world for execute positions",
        default = true,
        getFunction = function() return Crutch.savedOptions.hallsoffabrication.showAGIcons end,
        setFunction = function(value)
            Crutch.savedOptions.hallsoffabrication.showAGIcons = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Assembly General icons size",
        min = 20,
        max = 300,
        step = 10,
        default = 150,
        getFunction = function() return Crutch.savedOptions.hallsoffabrication.agIconsSize end,
        setFunction = function(value)
            Crutch.savedOptions.hallsoffabrication.agIconsSize = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return not Crutch.savedOptions.hallsoffabrication.showAGIcons end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Kyne's Aegis",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Exploding Spear landing spot",
        tooltip = "On trash packs with Half-Giant Raiders, shows circles at the approximate locations where Exploding Spears will land (may vary due to latency)",
        default = true,
        getFunction = function() return Crutch.savedOptions.kynesaegis.showSpearIcon end,
        setFunction = function(value)
            Crutch.savedOptions.kynesaegis.showSpearIcon = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Blood Prison icon",
        tooltip = "Shows icon above player who is targeted by Blood Prison, slightly before the bubble even shows up",
        default = true,
        getFunction = function() return Crutch.savedOptions.kynesaegis.showPrisonIcon end,
        setFunction = function(value)
            Crutch.savedOptions.kynesaegis.showPrisonIcon = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Falgravn 2nd floor DPS stacks",
        tooltip = "In the Falgravn fight, shows 1~4 DPS in the world for stacks",
        default = true,
        getFunction = function() return Crutch.savedOptions.kynesaegis.showFalgravnIcons end,
        setFunction = function(value)
            Crutch.savedOptions.kynesaegis.showFalgravnIcons = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Falgravn icons size",
        min = 20,
        max = 300,
        step = 10,
        default = 150,
        getFunction = function() return Crutch.savedOptions.kynesaegis.falgravnIconsSize end,
        setFunction = function(value)
            Crutch.savedOptions.kynesaegis.falgravnIconsSize = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return not Crutch.savedOptions.kynesaegis.showFalgravnIcons end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Lucent Citadel",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Cavot Agnan spawn spot",
        tooltip = "Shows icon for where Cavot Agnan will spawn",
        default = true,
        getFunction = function() return Crutch.savedOptions.lucentcitadel.showCavotIcon end,
        setFunction = function(value)
            Crutch.savedOptions.lucentcitadel.showCavotIcon = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Cavot Agnan icon size",
        min = 20,
        max = 300,
        step = 10,
        default = 100,
        getFunction = function() return Crutch.savedOptions.lucentcitadel.cavotIconSize end,
        setFunction = function(value)
            Crutch.savedOptions.lucentcitadel.cavotIconSize = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return not Crutch.savedOptions.lucentcitadel.showCavotIcon end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Orphic Shattered Shard mirror icons",
        tooltip = "Shows icons for each mirror on the Orphic Shattered Shard fight",
        default = true,
        getFunction = function() return Crutch.savedOptions.lucentcitadel.showOrphicIcons end,
        setFunction = function(value)
            Crutch.savedOptions.lucentcitadel.showOrphicIcons = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Orphic numbered icons",
        tooltip = "Uses numbers 1~8 instead of cardinal directions N/SW/etc. for the mirror icons",
        default = false,
        getFunction = function() return Crutch.savedOptions.lucentcitadel.orphicIconsNumbers end,
        setFunction = function(value)
            Crutch.savedOptions.lucentcitadel.orphicIconsNumbers = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return not Crutch.savedOptions.lucentcitadel.showOrphicIcons end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Orphic icons size",
        min = 20,
        max = 300,
        step = 10,
        default = 150,
        getFunction = function() return Crutch.savedOptions.lucentcitadel.orphicIconSize end,
        setFunction = function(value)
            Crutch.savedOptions.lucentcitadel.orphicIconSize = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return not Crutch.savedOptions.lucentcitadel.showOrphicIcons end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Arcane Conveyance tether",
        tooltip = "Shows a line connecting group members who are about to (or have already received) the Arcane Conveyance tether from Dariel Lemonds",
        default = true,
        getFunction = function() return Crutch.savedOptions.lucentcitadel.showArcaneConveyance end,
        setFunction = function(value)
            Crutch.savedOptions.lucentcitadel.showArcaneConveyance = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Show Weakening Charge timer",
        tooltip = "Shows an \"alert\" timer for Weakening Charge. If set to \"Tank Only\" it will display only if your LFG role is tank",
        getFunction = function()
            local names = {
                ["NEVER"] = "Never",
                ["TANK"] = "Tank Only",
                ["ALWAYS"] = "Always",
            }
            return names[Crutch.savedOptions.lucentcitadel.showWeakeningCharge]
        end,
        setFunction = function(combobox, name, item)
            Crutch.savedOptions.lucentcitadel.showWeakeningCharge = item.data
            Crutch.OnPlayerActivated()
        end,
        default = "Tank Only",
        items = {
            {
                name = "Never",
                data = "NEVER",
            },
            {
                name = "Tank Only",
                data = "TANK",
            },
            {
                name = "Always",
                data = "ALWAYS",
            },
        },
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Xoryn Tempest position icons",
        tooltip = "Shows icons for group member positions on the Xoryn fight for Tempest (and at the beginning of the trial, for practice purposes)",
        default = true,
        getFunction = function() return Crutch.savedOptions.lucentcitadel.showTempestIcons end,
        setFunction = function(value)
            Crutch.savedOptions.lucentcitadel.showTempestIcons = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Tempest icons size",
        min = 20,
        max = 300,
        step = 10,
        default = 150,
        getFunction = function() return Crutch.savedOptions.lucentcitadel.tempestIconsSize end,
        setFunction = function(value)
            Crutch.savedOptions.lucentcitadel.tempestIconsSize = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return not Crutch.savedOptions.lucentcitadel.showTempestIcons end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Maw of Lorkhaj",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Zhaj'hassa cleanse pad cooldowns",
        tooltip = "In the Zhaj'hassa fight, shows tiles with cooldown timers for 25 seconds (veteran)",
        default = true,
        getFunction = function() return Crutch.savedOptions.mawoflorkhaj.showPads end,
        setFunction = function(value)
            Crutch.savedOptions.mawoflorkhaj.showPads = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Cleanse pads position X",
        tooltip = "The horizontal position of the cleanse pads indicator",
        min = - GuiRoot:GetWidth() / 2,
        max = GuiRoot:GetWidth() / 2,
        step = GuiRoot:GetWidth() / 64,
        default = Crutch.defaultOptions.cursePadsDisplay.x,
        getFunction = function() return Crutch.savedOptions.cursePadsDisplay.x end,
        setFunction = function(value)
            Crutch.savedOptions.cursePadsDisplay.x = value
            CrutchAlertsMawOfLorkhaj:ClearAnchors()
            CrutchAlertsMawOfLorkhaj:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.cursePadsDisplay.x, Crutch.savedOptions.cursePadsDisplay.y)
            Crutch.UnlockUI(true)
        end,
        disable = function() return not Crutch.savedOptions.mawoflorkhaj.showPads end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Cleanse pads position Y",
        tooltip = "The vertical position of the cleanse pads indicator",
        min = - GuiRoot:GetHeight() / 2,
        max = GuiRoot:GetHeight() / 2,
        step = GuiRoot:GetHeight() / 64,
        default = Crutch.defaultOptions.cursePadsDisplay.y,
        getFunction = function() return Crutch.savedOptions.cursePadsDisplay.y end,
        setFunction = function(value)
            Crutch.savedOptions.cursePadsDisplay.y = value
            CrutchAlertsMawOfLorkhaj:ClearAnchors()
            CrutchAlertsMawOfLorkhaj:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.cursePadsDisplay.x, Crutch.savedOptions.cursePadsDisplay.y)
            Crutch.UnlockUI(true)
        end,
        disable = function() return not Crutch.savedOptions.mawoflorkhaj.showPads end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Twins Aspect icons",
        tooltip = "In the Vashai + S'kinrai fight, shows icons above players' heads with their Shadow or Lunar Aspect",
        default = true,
        getFunction = function() return Crutch.savedOptions.mawoflorkhaj.showTwinsIcons end,
        setFunction = function(value)
            Crutch.savedOptions.mawoflorkhaj.showTwinsIcons = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Ossein Cage",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show group-wide Caustic Carrion",
        tooltip = "Shows a progress bar for the group member with the highest number (and tick progress) of Caustic Carrion stacks. Changes color based on number of stacks, with a lower threshold on Jynorah + Skorkhif at 5 stacks for red",
        default = true,
        getFunction = function() return Crutch.savedOptions.osseincage.showCarrion end,
        setFunction = function(value)
            Crutch.savedOptions.osseincage.showCarrion = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Carrion position X",
        tooltip = "The horizontal position of the Carrion progress bar",
        min = - GuiRoot:GetWidth() / 2,
        max = GuiRoot:GetWidth() / 2,
        step = GuiRoot:GetWidth() / 64,
        default = Crutch.defaultOptions.carrionDisplay.x,
        getFunction = function() return Crutch.savedOptions.carrionDisplay.x end,
        setFunction = function(value)
            Crutch.savedOptions.carrionDisplay.x = value
            CrutchAlertsCausticCarrion:ClearAnchors()
            CrutchAlertsCausticCarrion:SetAnchor(TOPLEFT, GuiRoot, CENTER, Crutch.savedOptions.carrionDisplay.x, Crutch.savedOptions.carrionDisplay.y)
            Crutch.UnlockUI(true)
        end,
        disable = function() return not Crutch.savedOptions.osseincage.showCarrion end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Carrion position Y",
        tooltip = "The vertical position of the Carrion progress bar",
        min = - GuiRoot:GetHeight() / 2,
        max = GuiRoot:GetHeight() / 2,
        step = GuiRoot:GetHeight() / 64,
        default = Crutch.defaultOptions.carrionDisplay.y,
        getFunction = function() return Crutch.savedOptions.carrionDisplay.y end,
        setFunction = function(value)
            Crutch.savedOptions.carrionDisplay.y = value
            CrutchAlertsCausticCarrion:ClearAnchors()
            CrutchAlertsCausticCarrion:SetAnchor(TOPLEFT, GuiRoot, CENTER, Crutch.savedOptions.carrionDisplay.x, Crutch.savedOptions.carrionDisplay.y)
            Crutch.UnlockUI(true)
        end,
        disable = function() return not Crutch.savedOptions.osseincage.showCarrion end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show titans' health bars",
        tooltip = "Shows Blazeforged Valneer's and Sparkstorm Myrinax's health using the vertical boss health bars",
        default = true,
        getFunction = function() return Crutch.savedOptions.osseincage.showTitansHp end,
        setFunction = function(value)
            Crutch.savedOptions.osseincage.showTitansHp = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return not Crutch.savedOptions.bossHealthBar.enabled end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show curse positioning icons",
        tooltip = "In the Jynorah + Skorkhif fight, shows icons in the world for close positioning",
        default = true,
        getFunction = function() return Crutch.savedOptions.osseincage.showTwinsIcons end,
        setFunction = function(value)
            Crutch.savedOptions.osseincage.showTwinsIcons = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show middle icons",
        tooltip = "Additionally shows a set of icons for positioning in the middle of the arena",
        default = true,
        getFunction = function() return Crutch.savedOptions.osseincage.useMiddleIcons end,
        setFunction = function(value)
            Crutch.savedOptions.osseincage.useMiddleIcons = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return not Crutch.savedOptions.osseincage.showTwinsIcons end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Curse positioning icons size",
        min = 20,
        max = 300,
        step = 10,
        default = 100,
        getFunction = function() return Crutch.savedOptions.osseincage.twinsIconsSize end,
        setFunction = function(value)
            Crutch.savedOptions.osseincage.twinsIconsSize = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return not Crutch.savedOptions.osseincage.showTwinsIcons end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Show Enfeeblement debuffs",
        tooltip = "Shows icons on players afflicted by Sparking Enfeeblement, Blazing Enfeeblement, or both",
        getFunction = function()
            local names = {
                ["NEVER"] = "Never",
                ["HM"] = "Hardmode only",
                ["VET"] = "Veteran + Hardmode",
                ["ALWAYS"] = "Always",
            }
            return names[Crutch.savedOptions.osseincage.showEnfeeblementIcons]
        end,
        setFunction = function(combobox, name, item)
            Crutch.savedOptions.osseincage.showEnfeeblementIcons = item.data
            Crutch.OnPlayerActivated()
        end,
        default = "Hardmode only",
        items = {
            {
                name = "Never",
                data = "NEVER",
            },
            {
                name = "Hardmode only",
                data = "HM",
            },
            {
                name = "Veteran + Hardmode",
                data = "VET",
            },
            {
                name = "Always",
                data = "ALWAYS",
            },
        },
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Print titan damage on HM",
        tooltip = "On hardmode, prints to chat when you damage a titan, which would proc Reflective Scales. For now, it doesn't print until the titan health bars appear",
        default = true,
        getFunction = function() return Crutch.savedOptions.osseincage.printHMReflectiveScales end,
        setFunction = function(value)
            Crutch.savedOptions.osseincage.printHMReflectiveScales = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Show Stricken timer",
        tooltip = "Shows an \"alert\" timer for Stricken. If set to \"Tank Only\" it will display only if your LFG role is tank",
        getFunction = function()
            local names = {
                ["NEVER"] = "Never",
                ["TANK"] = "Tank Only",
                ["ALWAYS"] = "Always",
            }
            return names[Crutch.savedOptions.osseincage.showStricken]
        end,
        setFunction = function(combobox, name, item)
            Crutch.savedOptions.osseincage.showStricken = item.data
            Crutch.OnPlayerActivated()
        end,
        default = "Tank Only",
        items = {
            {
                name = "Never",
                data = "NEVER",
            },
            {
                name = "Tank Only",
                data = "TANK",
            },
            {
                name = "Always",
                data = "ALWAYS",
            },
        },
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Dominator's Chains tether",
        tooltip = "Shows a line connecting group members who are about to (or have already received) the Dominator's Chains tether from Overfiend Kazpian",
        default = true,
        getFunction = function() return Crutch.savedOptions.osseincage.showChains end,
        setFunction = function(value)
            Crutch.savedOptions.osseincage.showChains = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Rockgrove",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Noxious Sludge sides",
        tooltip = "Displays who should go left and who should go right for Noxious Sludge, matching Qcell's Rockgrove Helper",
        default = true,
        getFunction = function() return Crutch.savedOptions.rockgrove.sludgeSides end,
        setFunction = function(value)
            Crutch.savedOptions.rockgrove.sludgeSides = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Noxious Sludge icons",
        tooltip = "Shows icons above players who receive Noxious Sludge from Oaxiltso",
        default = Crutch.defaultOptions.rockgrove.showSludgeIcons,
        getFunction = function() return Crutch.savedOptions.rockgrove.showSludgeIcons end,
        setFunction = function(value)
            Crutch.savedOptions.rockgrove.showSludgeIcons = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Show Bleeding timer",
        tooltip = "Shows an \"alert\" timer for Bleeding from Flesh Abominations' Hemorrhaging Smack. If set to \"Self/Heal Only\" it will display only if your LFG role is healer or if the bleed is on yourself",
        getFunction = function()
            local names = {
                ["NEVER"] = "Never",
                ["HEAL"] = "Self/Heal Only",
                ["ALWAYS"] = "Always",
            }
            return names[Crutch.savedOptions.rockgrove.showBleeding]
        end,
        setFunction = function(combobox, name, item)
            Crutch.savedOptions.rockgrove.showBleeding = item.data
            Crutch.OnPlayerActivated()
        end,
        default = "Self/Heal Only",
        items = {
            {
                name = "Never",
                data = "NEVER",
            },
            {
                name = "Self/Heal Only",
                data = "HEAL",
            },
            {
                name = "Always",
                data = "ALWAYS",
            },
        },
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Death Touch icons",
        tooltip = "Shows icons above group members' heads when they have Death Touch (Bahsei curse), counting down to when they would explode",
        default = true,
        getFunction = function() return Crutch.savedOptions.rockgrove.showCurseIcons end,
        setFunction = function(value)
            Crutch.savedOptions.rockgrove.showCurseIcons = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Info Panel",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show time until Noxious Sludge",
        tooltip = "Shows the time until Oaxiltso may cast the next Noxious Sludge",
        default = Crutch.defaultOptions.rockgrove.panel.showSludge,
        getFunction = function() return Crutch.savedOptions.rockgrove.panel.showSludge end,
        setFunction = function(value)
            Crutch.savedOptions.rockgrove.panel.showSludge = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show time until Savage Blitz",
        tooltip = "Shows the time until Oaxiltso may make you flat. Hee hee.",
        default = Crutch.defaultOptions.rockgrove.panel.showBlitz,
        getFunction = function() return Crutch.savedOptions.rockgrove.panel.showBlitz end,
        setFunction = function(value)
            Crutch.savedOptions.rockgrove.panel.showBlitz = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show time until portal",
        tooltip = "Shows portal number and time until Bahsei can spawn the next portal on HM",
        default = Crutch.defaultOptions.rockgrove.panel.showTimeToPortal,
        getFunction = function() return Crutch.savedOptions.rockgrove.panel.showTimeToPortal end,
        setFunction = function(value)
            Crutch.savedOptions.rockgrove.panel.showTimeToPortal = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show portal direction",
        tooltip = "Shows the direction of the current portal on Bahsei HM",
        default = Crutch.defaultOptions.rockgrove.panel.showPortalDirection,
        getFunction = function() return Crutch.savedOptions.rockgrove.panel.showPortalDirection end,
        setFunction = function(value)
            Crutch.savedOptions.rockgrove.panel.showPortalDirection = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show number of players in portal",
        tooltip = "Shows the current number of players in portal on Bahsei HM",
        default = Crutch.defaultOptions.rockgrove.panel.showNumInPortal,
        getFunction = function() return Crutch.savedOptions.rockgrove.panel.showNumInPortal end,
        setFunction = function(value)
            Crutch.savedOptions.rockgrove.panel.showNumInPortal = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "[BETA] Curse Lines",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show your curse preview lines",
        tooltip = "Shows lines for potential curse AoE trajectories when you have Death Touch, so you can try to position them away from the group. All 4 possible directions are shown, but only 2 directions will have real AoEs",
        default = Crutch.defaultOptions.rockgrove.showCursePreview,
        getFunction = function() return Crutch.savedOptions.rockgrove.showCursePreview end,
        setFunction = function(value)
            Crutch.savedOptions.rockgrove.showCursePreview = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Preview lines color",
        tooltip = "Color of the preview lines for yourself",
        default = Crutch.defaultOptions.rockgrove.cursePreviewColor,
        getFunction = function() return unpack(Crutch.savedOptions.rockgrove.cursePreviewColor) end,
        setFunction = function(r, g, b, a)
            Crutch.savedOptions.rockgrove.cursePreviewColor = {r, g, b, a}
        end,
        disable = function() return not Crutch.savedOptions.rockgrove.showCursePreview end
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show your curse lines",
        tooltip = "Shows lines for potential curse AoE trajectories when your Death Touch expires. All 4 possible directions are shown, but only 2 directions have real AoEs. The trajectory could be slightly inaccurate due to desync, especially if you're moving fast",
        default = Crutch.defaultOptions.rockgrove.showCurseLines,
        getFunction = function() return Crutch.savedOptions.rockgrove.showCurseLines end,
        setFunction = function(value)
            Crutch.savedOptions.rockgrove.showCurseLines = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Curse lines color",
        tooltip = "Color of the curse lines for yourself",
        default = Crutch.defaultOptions.rockgrove.curseLineColor,
        getFunction = function() return unpack(Crutch.savedOptions.rockgrove.curseLineColor) end,
        setFunction = function(r, g, b, a)
            Crutch.savedOptions.rockgrove.curseLineColor = {r, g, b, a}
        end,
        disable = function() return not Crutch.savedOptions.rockgrove.showCurseLines end
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show group members' curse lines",
        tooltip = "Shows lines for potential curse AoE trajectories when another player's Death Touch expires. All 4 possible directions are shown, but only 2 directions have real AoEs. The trajectory could be inaccurate due to desync, especially if the player is moving fast. Requires LibGroupBroadcast, and the other players must also have this version of CrutchAlerts with LibGroupBroadcast (they do not need to have curse lines on)",
        default = Crutch.defaultOptions.rockgrove.showOthersCurseLines,
        getFunction = function() return Crutch.savedOptions.rockgrove.showOthersCurseLines end,
        setFunction = function(value)
            Crutch.savedOptions.rockgrove.showOthersCurseLines = value
        end,
        disable = function() return LibGroupBroadcast == nil end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Group curse lines color",
        tooltip = "Color of the curse lines for other group members",
        default = Crutch.defaultOptions.rockgrove.othersCurseLineColor,
        getFunction = function() return unpack(Crutch.savedOptions.rockgrove.othersCurseLineColor) end,
        setFunction = function(r, g, b, a)
            Crutch.savedOptions.rockgrove.othersCurseLineColor = {r, g, b, a}
        end,
        disable = function() return LibGroupBroadcast == nil or not Crutch.savedOptions.rockgrove.showOthersCurseLines end
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Mark Dangerous Abilities",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Portal number",
        tooltip = "Some AOE abilities are dangerous to have active when in Bahsei HM portals, because they may kill multiple ghosts at once. This feature can be configured to show a warning icon on the ability when it's almost time for your portal. For example, Solar Barrage lasts for 20s, and the margin (configure below) is 4s, so Solar Barrage's icon will have a warning at 16s before your portal spawns.",
        getFunction = function()
            local names = {
                [0] = "None",
                [1] = "Portal 1",
                [2] = "Portal 2",
            }
            return names[Crutch.savedOptions.rockgrove.portalNumber]
        end,
        setFunction = function(combobox, name, item)
            Crutch.savedOptions.rockgrove.portalNumber = item.data
        end,
        default = "None",
        items = {
            {
                name = "None",
                data = 0,
            },
            {
                name = "Portal 1",
                data = 1,
            },
            {
                name = "Portal 2",
                data = 2,
            },
        },
    })

    local selectedDangerousAbility = next(Crutch.savedOptions.rockgrove.abilitiesToReplace) or 0
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_EDIT,
        label = "Add dangerous ability",
        tooltip = "The ID of the ability to add to the list.\nUse |c99FF99/crutch printskills|r to see your currently equipped skill IDs",
        getFunction = function() return "" end,
        setFunction = function(text)
            if (text == "") then return end
            local num = tonumber(text)
            if (not num) then
                Crutch.msg("Ability ID must be a number")
                return
            end
            Crutch.savedOptions.rockgrove.abilitiesToReplace[num] = true
            Crutch.msg(string.format("Added %s (%d) to abilities to replace.", GetAbilityName(num), num))

            if (selectedDangerousAbility == 0) then
                selectedDangerousAbility = num
            end
        end,
    })

    local dangerousAbilityItems = {}
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Dangerous abilities",
        tooltip = "Select an ability from this list and use the button below to remove it from the list",
        getFunction = function()
            if (selectedDangerousAbility == 0) then
                return "None"
            end
            return string.format("%s (%d)", GetAbilityName(selectedDangerousAbility) or "", selectedDangerousAbility)
        end,
        setFunction = function(combobox, name, item)
            selectedDangerousAbility = item.data
        end,
        default = next(Crutch.savedOptions.rockgrove.abilitiesToReplace),
        items = function()
            ZO_ClearTable(dangerousAbilityItems)
            for id, _ in pairs(Crutch.savedOptions.rockgrove.abilitiesToReplace) do
                table.insert(dangerousAbilityItems, {
                    name = string.format("%s (%d)", GetAbilityName(id) or "", id),
                    data = id,
                })
            end

            -- why empty "dropdowns" gotta be such a pita?
            if (ZO_IsTableEmpty(dangerousAbilityItems)) then
                table.insert(dangerousAbilityItems, {name = "None", data = 0})
            end
            return dangerousAbilityItems
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Remove selected ability",
        tooltip = function() return selectedDangerousAbility and "Remove " .. selectedDangerousAbility .. " from the dangerous abilities list" or "" end,
        clickHandler = function()
            Crutch.savedOptions.rockgrove.abilitiesToReplace[selectedDangerousAbility] = nil
            selectedDangerousAbility = next(Crutch.savedOptions.rockgrove.abilitiesToReplace) or 0
        end,
        disable = function() return selectedDangerousAbility == 0 end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Portal time margin",
        tooltip = "The target number of milliseconds after portal spawns, for which you want the dangerous abilities to expire by. For example, setting it to 4000 means your Solar Barrage will be changed at 16 seconds before your portal, because the margin is 4 seconds and Solar Barrage lasts for 20 seconds",
        min = 0,
        max = 60000,
        step = 500,
        default = 4000,
        getFunction = function() return Crutch.savedOptions.rockgrove.portalTimeMargin end,
        setFunction = function(value)
            Crutch.savedOptions.rockgrove.portalTimeMargin = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Sanity's Edge",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Chimera puzzle numbers",
        tooltip = "In the Twelvane + Chimera fight, shows numbers on the puzzle glyphics",
        default = true,
        getFunction = function() return Crutch.savedOptions.sanitysedge.showChimeraIcons end,
        setFunction = function(value)
            Crutch.savedOptions.sanitysedge.showChimeraIcons = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Chimera icons size",
        min = 20,
        max = 300,
        step = 10,
        default = 150,
        getFunction = function() return Crutch.savedOptions.sanitysedge.chimeraIconsSize end,
        setFunction = function(value)
            Crutch.savedOptions.sanitysedge.chimeraIconsSize = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return not Crutch.savedOptions.sanitysedge.showChimeraIcons end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show center of Ansuul arena",
        tooltip = "In the Ansuul fight, shows an icon in the world on the center of the arena",
        default = true,
        getFunction = function() return Crutch.savedOptions.sanitysedge.showAnsuulIcon end,
        setFunction = function(value)
            Crutch.savedOptions.sanitysedge.showAnsuulIcon = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Ansuul icon size",
        min = 20,
        max = 300,
        step = 10,
        default = 150,
        getFunction = function() return Crutch.savedOptions.sanitysedge.ansuulIconSize end,
        setFunction = function(value)
            Crutch.savedOptions.sanitysedge.ansuulIconSize = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return not Crutch.savedOptions.sanitysedge.showAnsuulIcon end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Sunspire",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Lokkestiiz HM beam position icons",
        tooltip = "During flight phase on Lokkestiiz hardmode, shows 1~8 DPS and 2 healer positions in the world for Storm Fury",
        default = true,
        getFunction = function() return Crutch.savedOptions.sunspire.showLokkIcons end,
        setFunction = function(value)
            Crutch.savedOptions.sunspire.showLokkIcons = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Lokkestiiz solo heal icons",
        tooltip = "Use solo healer positions for the Lokkestiiz hardmode icons. This is for 9 damage dealers and 1 healer. If you change this option while at the Lokkestiiz fight, the new icons will show up the next time icons are displayed",
        default = false,
        getFunction = function() return Crutch.savedOptions.sunspire.lokkIconsSoloHeal end,
        setFunction = function(value)
            Crutch.savedOptions.sunspire.lokkIconsSoloHeal = value
        end,
        disable = function() return not Crutch.savedOptions.sunspire.showLokkIcons end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Lokkestiiz HM icons size",
        min = 20,
        max = 300,
        step = 10,
        default = 150,
        getFunction = function() return Crutch.savedOptions.sunspire.lokkIconsSize end,
        setFunction = function(value)
            Crutch.savedOptions.sunspire.lokkIconsSize = value
        end,
        disable = function() return not Crutch.savedOptions.sunspire.showLokkIcons end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show some Lokkestiiz HM Storm Breath telegraphs",
        tooltip = "During flight phase on Lokkestiiz hardmode, shows approximate telegraphs for some of the Storm Breaths and Storm Trails afterwards, mainly the ones that people tend to stand in...",
        default = false,
        getFunction = function() return Crutch.savedOptions.sunspire.telegraphStormBreath end,
        setFunction = function(value)
            Crutch.savedOptions.sunspire.telegraphStormBreath = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Yolnahkriin position icons",
        tooltip = "During flight phase on Yolnahkriin, shows icons in the world for where the next head stack and (right) wing stack will be when Yolnahkriin lands",
        default = true,
        getFunction = function() return Crutch.savedOptions.sunspire.showYolIcons end,
        setFunction = function(value)
            Crutch.savedOptions.sunspire.showYolIcons = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Yolnahkriin left position icons",
        tooltip = "Use left icons instead of right icons during flight phase on Yolnahkriin",
        default = false,
        getFunction = function() return Crutch.savedOptions.sunspire.yolLeftIcons end,
        setFunction = function(value)
            Crutch.savedOptions.sunspire.yolLeftIcons = value
        end,
        disable = function() return not Crutch.savedOptions.sunspire.showYolIcons end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Yolnahkriin icons size",
        min = 20,
        max = 300,
        step = 10,
        default = 150,
        getFunction = function() return Crutch.savedOptions.sunspire.yolIconsSize end,
        setFunction = function(value)
            Crutch.savedOptions.sunspire.yolIconsSize = value
        end,
        disable = function() return not Crutch.savedOptions.sunspire.showYolIcons end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show players without Focused Fire",
        tooltip = "When Yolnahkriin starts casting Focus Fire, show icons above players who do not have the Focused Fire debuff. This is mainly to help the OT not go to the wrong stack",
        default = true,
        getFunction = function() return Crutch.savedOptions.sunspire.yolFocusedFire end,
        setFunction = function(value)
            Crutch.savedOptions.sunspire.yolFocusedFire = value
        end,
    })

    ---------------------------------------------------------------------
    -- arenas
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Arenas",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Infinite Archive",
    })


    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Auto mark Fabled",
        tooltip = "When your reticle passes over Fabled enemies, automatically marks them with basegame target markers to make them easier to focus. It may sometimes mark incorrectly if you move too quickly and particularly if an NPC or your group member walks in front, but is otherwise mostly accurate",
        default = true,
        getFunction = function() return Crutch.savedOptions.endlessArchive.markFabled end,
        setFunction = function(value)
            Crutch.savedOptions.endlessArchive.markFabled = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Auto mark Negate casters",
        tooltip = "The same as auto marking Fabled above, but for enemies that can cast Negate Magic (Silver Rose Stormcaster, Dro-m'Athra Conduit, Dremora Conduit). They only cast Negate when you are close enough to them",
        default = false,
        getFunction = function() return Crutch.savedOptions.endlessArchive.markNegate end,
        setFunction = function(value)
            Crutch.savedOptions.endlessArchive.markNegate = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Brewmaster elixir spot",
        tooltip = "Displays an icon on where the Fabled Brewmaster may have thrown an Elixir of Diminishing. Note that it will not work on elixirs that are thrown at your group members' pets, but should for yourself, your pets, your companion, and your actual group member",
        default = true,
        getFunction = function() return Crutch.savedOptions.endlessArchive.potionIcon end,
        setFunction = function(value)
            Crutch.savedOptions.endlessArchive.potionIcon = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Play sound for Uppercut / Power Bash",
        tooltip = "Plays a ding sound when you are targeted by an Uppercut from 2-hander enemies or Power Bash from sword-n-board enemies, e.g. Ascendant Vanguard, Dro-m'Athra Sentinel, etc. Requires \"Begin\" casts on",
        default = false,
        getFunction = function() return Crutch.savedOptions.endlessArchive.dingUppercut end,
        setFunction = function(value)
            Crutch.savedOptions.endlessArchive.dingUppercut = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Play sound for dangerous abilities",
        tooltip = "Plays a ding sound for particularly dangerous abilities. Requires \"Begin\" casts on. Currently, this only includes:\n\n- Heavy Slash from Nerien'eth\n- Obliterate from Anka-Ra Destroyers on the Warrior encounter, because if you don't block or dodge it, the CC cannot be broken free of\n- Elixir of Diminishing from Brewmasters, which also stuns you for a duration",
        default = true,
        getFunction = function() return Crutch.savedOptions.endlessArchive.dingDangerous end,
        setFunction = function(value)
            Crutch.savedOptions.endlessArchive.dingDangerous = value
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Print puzzle solution",
        tooltip = "In the Corridor Puzzle room, when you get close to a switch, prints to chat the solution, if known, numbered from left to right. Currently missing 1 set of IDs, and works only for highest difficulty",
        default = true,
        getFunction = function() return Crutch.savedOptions.endlessArchive.printPuzzleSolution end,
        setFunction = function(value)
            Crutch.savedOptions.endlessArchive.printPuzzleSolution = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Maelstrom Arena",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show the current round",
        tooltip = "Displays a message in chat when a round starts. Also shows a message for final round soonTM, 15 seconds after the start of the second-to-last round",
        default = true,
        getFunction = function() return Crutch.savedOptions.maelstrom.showRounds end,
        setFunction = function(value)
            Crutch.savedOptions.maelstrom.showRounds = value
        end,
    })

    ---------------------------------------------------------------------
    -- dungeons
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Dungeons",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Black Gem Foundry",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Rupture preview line",
        tooltip = "Shows a line during the ping pong phase on Quarrymaster Saldezaar, to help preview where you would get ponged to",
        default = true,
        getFunction = function() return Crutch.savedOptions.blackGemFoundry.showRuptureLine end,
        setFunction = function(value)
            Crutch.savedOptions.blackGemFoundry.showRuptureLine = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Shipwright's Regret",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Suggest stacks for Soul Bomb",
        tooltip = "Displays a notification for suggested person to stack on for Soul Bomb on Foreman Bradiggan hardmode when there are 2 bombs. Also shows an icon above that person's head. The suggested stack is alphabetical based on @ name",
        default = true,
        getFunction = function() return Crutch.savedOptions.shipwrightsRegret.showBombStacks end,
        setFunction = function(value)
            Crutch.savedOptions.shipwrightsRegret.showBombStacks = value
            Crutch.OnPlayerActivated()
        end,
    })
end