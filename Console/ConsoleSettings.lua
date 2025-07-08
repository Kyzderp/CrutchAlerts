CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

local function UnlockUI(value)
    if (value) then
        local scene = SCENE_MANAGER:GetCurrentScene()
        local function OnSceneStateChanged(oldState, newState)
            if (newState == SCENE_HIDDEN) then
                scene:UnregisterCallback("StateChange", OnSceneStateChanged)
                UnlockUI(false)
            end
        end
        scene:RegisterCallback("StateChange", OnSceneStateChanged)
    end

    Crutch.unlock = value
    CrutchAlertsContainerBackdrop:SetHidden(not value)
    if (value) then
        Crutch.DisplayNotification(47898, "Example Alert", 5000, 0, 0, 0, 0, false)
    end

    CrutchAlertsDamageableBackdrop:SetHidden(not value)
    CrutchAlertsDamageableLabel:SetHidden(not value)
    if (value) then
        Crutch.DisplayDamageable(10)
    end

    CrutchAlertsCloudrestBackdrop:SetHidden(not value)
    if (value) then
        Crutch.UpdateSpearsDisplay(3, 2, 1)
    else
        Crutch.UpdateSpearsDisplay(0, 0, 0)
    end

    CrutchAlertsBossHealthBarContainer:SetHidden(not value)
    if (value and Crutch.savedOptions.bossHealthBar.enabled) then
        Crutch.BossHealthBar.ShowOrHideBars(true, false)
    else
        Crutch.BossHealthBar.ShowOrHideBars()
    end

    CrutchAlertsCausticCarrion:SetHidden(not value)

    CrutchAlertsMawOfLorkhaj:SetHidden(not value)
end
Crutch.UnlockUI = UnlockUI

local ADD_ICON_SETTINGS = false

function Crutch:CreateConsoleSettingsMenu()
    local settings = LibHarvensAddonSettings:AddAddon("CrutchAlerts", {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = function()
            UnlockUI(true)
        end,
    })

    if (not settings) then
        d("|cFF0000CrutchAlerts - unable to create settings?!|r")
        return
    end

---------------------------------------------------------------------
-- general
    
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Alerts",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show begin casts",
        tooltip = "Show alerts when you are targeted by the beginning of a cast (ACTION_RESULT_BEGIN)",
        default = true,
        setFunction = function(value)
            Crutch.savedOptions.general.showBegin = value
            if (value) then
                Crutch.RegisterBegin()
            else
                Crutch.UnregisterBegin()
            end
        end,
        getFunction = function() return Crutch.savedOptions.general.showBegin end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show non-enemy casts",
        tooltip = "Show alerts for beginning of a cast if it is not from an enemy, e.g. player-sourced",
        default = true,
        getFunction = function() return not Crutch.savedOptions.general.beginHideSelf end,
        setFunction = function(value)
            Crutch.savedOptions.general.beginHideSelf = not value
            -- Re-register with filters
            Crutch.UnregisterBegin()
            Crutch.RegisterBegin()
        end,
        disable = function() return not Crutch.savedOptions.general.showBegin end
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show gained casts",
        tooltip = "Show alerts when you \"Gain\" a cast from an enemy (ACTION_RESULT_GAINED or manually curated ACTION_RESULT_GAINED_DURATION)",
        default = true,
        getFunction = function() return Crutch.savedOptions.general.showGained end,
        setFunction = function(value)
            Crutch.savedOptions.general.showGained = value
            if (value) then
                Crutch.RegisterGained()
            else
                Crutch.UnregisterGained()
            end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show casts on others",
        tooltip = "Show alerts when someone else in your group is targeted by a specific ability, or in some cases, when the enemy casts something on themselves. This is a manually curated list of abilities that are important enough to affect you, for example the Llothis cone (Defiling Dye Blast) or Rakkhat's kite (Darkness Falls)",
        default = true,
        getFunction = function() return Crutch.savedOptions.general.showOthers end,
        setFunction = function(value)
            Crutch.savedOptions.general.showOthers = value
            if (value) then
                Crutch.RegisterOthers()
            else
                Crutch.UnregisterOthers()
            end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Special Timers",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show arcanist timers",
        tooltip = "Show \"alert\" timers for arcanist-specific channeled abilities that you cast, i.e. Fatecarver and Remedy Cascade",
        default = true,
        getFunction = function() return not Crutch.savedOptions.general.beginHideArcanist end,
        setFunction = function(value)
            Crutch.savedOptions.general.beginHideArcanist = not value
            Crutch.UnregisterFatecarver()
            Crutch.RegisterFatecarver()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show dragonknight Magma Shell",
        tooltip = "Show an \"alert\" timer for Magma Shell",
        default = true,
        getFunction = function() return Crutch.savedOptions.general.effectMagmaShell end,
        setFunction = function(value)
            Crutch.savedOptions.general.effectMagmaShell = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show templar Radiant Destruction",
        tooltip = "Show \"alert\" timers for Radiant Destruction and morphs",
        default = true,
        getFunction = function() return Crutch.savedOptions.general.showJBeam end,
        setFunction = function(value)
            Crutch.savedOptions.general.showJBeam = value
            Crutch.UnregisterFatecarver()
            Crutch.RegisterFatecarver()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Fencer's Parry",
        tooltip = "Show an \"alert\" timer for the duration of Fencer's Parry from scribing, along with when it is removed",
        default = true,
        getFunction = function() return Crutch.savedOptions.general.effectParry end,
        setFunction = function(value)
            Crutch.savedOptions.general.effectParry = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Other Settings",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show prominent alerts",
        tooltip = "Show large, obnoxious alerts, usually with a ding sound too, for a manually curated list of important mechanics that warrant your immediate attention",
        default = true,
        getFunction = function() return Crutch.savedOptions.console.showProminent end,
        setFunction = function(value)
            Crutch.savedOptions.console.showProminent = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show damageable timers",
        tooltip = "For certain encounters, show a countdown to when the boss or important adds will become damageable, tauntable, return to the arena, etc. This works best on English client, with some support for other languages.",
        default = true,
        getFunction = function() return Crutch.savedOptions.general.showDamageable end,
        setFunction = function(value)
            Crutch.savedOptions.general.showDamageable = value
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show raid lead diagnostics",
        tooltip = "Shows possibly spammy info in the text chat when certain important events occur. For example, someone picking up fire dome in DSR",
        default = false,
        getFunction = function() return Crutch.savedOptions.general.showRaidDiag end,
        setFunction = function(value)
            Crutch.savedOptions.general.showRaidDiag = value
            Crutch.OnPlayerActivated()
        end,
    })

    ---------------------------------------------------------------------
    -- BHB
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Vertical Boss Health Bar Settings",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show boss health bar",
        tooltip = "Show vertical boss health bars with markers for percentage based mechanics",
        default = true,
        getFunction = function() return Crutch.savedOptions.bossHealthBar.enabled end,
        setFunction = function(value)
            Crutch.savedOptions.bossHealthBar.enabled = value
            Crutch.BossHealthBar.Initialize()
            Crutch.BossHealthBar.UpdateScale()
            if (value) then
                Crutch.UnlockUI(true)
            end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Boss health bar size",
        tooltip = "The size to display the vertical boss health bars. Note: some elements may not update size properly until a reload",
        min = 5,
        max = 20,
        step = 1,
        default = 10,
        getFunction = function() return Crutch.savedOptions.bossHealthBar.scale * 10 end,
        setFunction = function(value)
            Crutch.savedOptions.bossHealthBar.scale = value / 10
            Crutch.BossHealthBar.UpdateScale()
            Crutch.UnlockUI(true)
        end,
        disable = function() return not Crutch.savedOptions.bossHealthBar.enabled end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Boss health bar position X",
        tooltip = "The horizontal position of the vertical boss health bars",
        min = - GuiRoot:GetWidth() / 2,
        max = GuiRoot:GetWidth() / 2,
        step = GuiRoot:GetWidth() / 64,
        default = Crutch.defaultOptions.bossHealthBarDisplay.x,
        getFunction = function() return Crutch.savedOptions.bossHealthBarDisplay.x end,
        setFunction = function(value)
            Crutch.savedOptions.bossHealthBarDisplay.x = value
            CrutchAlertsBossHealthBarContainer:ClearAnchors()
            CrutchAlertsBossHealthBarContainer:SetAnchor(TOPLEFT, GuiRoot, CENTER, 
                Crutch.savedOptions.bossHealthBarDisplay.x, Crutch.savedOptions.bossHealthBarDisplay.y)
            Crutch.UnlockUI(true)
        end,
        disable = function() return not Crutch.savedOptions.bossHealthBar.enabled end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Boss health bar position Y",
        tooltip = "The vertical position of the vertical boss health bars",
        min = - GuiRoot:GetHeight() / 2,
        max = GuiRoot:GetHeight() / 2,
        step = GuiRoot:GetHeight() / 64,
        default = Crutch.defaultOptions.bossHealthBarDisplay.y,
        getFunction = function() return Crutch.savedOptions.bossHealthBarDisplay.y end,
        setFunction = function(value)
            Crutch.savedOptions.bossHealthBarDisplay.y = value
            CrutchAlertsBossHealthBarContainer:ClearAnchors()
            CrutchAlertsBossHealthBarContainer:SetAnchor(TOPLEFT, GuiRoot, CENTER, 
                Crutch.savedOptions.bossHealthBarDisplay.x, Crutch.savedOptions.bossHealthBarDisplay.y)
            Crutch.UnlockUI(true)
        end,
        disable = function() return not Crutch.savedOptions.bossHealthBar.enabled end,
    })

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
        label = "Show flare sides",
        tooltip = "On Z'Maja during execute with +Siroria, show which side each of the two people with Roaring Flares can go to (will be same sides as RaidNotifier)",
        default = true,
        getFunction = function() return Crutch.savedOptions.cloudrest.showFlaresSides end,
        setFunction = function(value)
            Crutch.savedOptions.cloudrest.showFlaresSides = value
            Crutch.OnPlayerActivated()
        end,
    })

if (ADD_ICON_SETTINGS) then
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Color Ody death icon",
        tooltip = "Colors the OdySupportIcons death icon purple if a player's shade is still up. Requires OdySupportIcons",
        default = true,
        getFunction = function() return Crutch.savedOptions.cloudrest.deathIconColor end,
        setFunction = function(value)
            Crutch.savedOptions.cloudrest.deathIconColor = value
        end,
        disable = function() return OSI == nil end,
    })
end

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

if (ADD_ICON_SETTINGS) then
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Halls of Fabrication",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show safe spot for triplets",
        tooltip = "In the triplets fight, shows an icon in the world that is outside of Shock Field. Requires OdySupportIcons",
        default = true,
        getFunction = function() return Crutch.savedOptions.hallsoffabrication.showTripletsIcon end,
        setFunction = function(value)
            Crutch.savedOptions.hallsoffabrication.showTripletsIcon = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return OSI == nil end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Assembly General icons",
        tooltip = "Shows icons in the world for execute positions. Requires OdySupportIcons",
        default = true,
        getFunction = function() return Crutch.savedOptions.hallsoffabrication.showAGIcons end,
        setFunction = function(value)
            Crutch.savedOptions.hallsoffabrication.showAGIcons = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return OSI == nil end,
    })
end

if (ADD_ICON_SETTINGS) then
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Kyne's Aegis",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Exploding Spear landing spot",
        tooltip = "On trash packs with Half-Giant Raiders, show icons at the approximate locations where Exploding Spears will land. Requires OdySupportIcons",
        default = true,
        getFunction = function() return Crutch.savedOptions.kynesaegis.showSpearIcon end,
        setFunction = function(value)
            Crutch.savedOptions.kynesaegis.showSpearIcon = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return OSI == nil end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Blood Prison icon",
        tooltip = "Shows icon above player who is targeted by Blood Prison, slightly before the bubble even shows up. Requires OdySupportIcons",
        default = true,
        getFunction = function() return Crutch.savedOptions.kynesaegis.showPrisonIcon end,
        setFunction = function(value)
            Crutch.savedOptions.kynesaegis.showPrisonIcon = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return OSI == nil end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Falgravn 2nd floor DPS stacks",
        tooltip = "In the Falgravn fight, shows 1~4 DPS in the world for stacks. Requires OdySupportIcons",
        default = true,
        getFunction = function() return Crutch.savedOptions.kynesaegis.showFalgravnIcons end,
        setFunction = function(value)
            Crutch.savedOptions.kynesaegis.showFalgravnIcons = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return OSI == nil end,
    })
end

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Lucent Citadel",
    })

if (ADD_ICON_SETTINGS) then
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Cavot Agnan spawn spot",
        tooltip = "Shows icon for where Cavot Agnan will spawn. Requires OdySupportIcons",
        default = true,
        getFunction = function() return Crutch.savedOptions.lucentcitadel.showCavotIcon end,
        setFunction = function(value)
            Crutch.savedOptions.lucentcitadel.showCavotIcon = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return OSI == nil end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Orphic Shattered Shard mirror icons",
        tooltip = "Shows icons for each mirror on the Orphic Shattered Shard fight. Requires OdySupportIcons",
        default = true,
        getFunction = function() return Crutch.savedOptions.lucentcitadel.showOrphicIcons end,
        setFunction = function(value)
            Crutch.savedOptions.lucentcitadel.showOrphicIcons = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return OSI == nil end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "    Orphic numbered icons",
        tooltip = "Uses numbers 1~8 instead of cardinal directions N/SW/etc. for the mirror icons",
        default = false,
        getFunction = function() return Crutch.savedOptions.lucentcitadel.orphicIconsNumbers end,
        setFunction = function(value)
            Crutch.savedOptions.lucentcitadel.orphicIconsNumbers = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return not Crutch.savedOptions.lucentcitadel.showOrphicIcons end,
    })
end

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Arcane Conveyance tether",
        tooltip = "Shows a line connecting group members who are about to (or have already received) the Arcane Conveyance tether from Dariel Lemonds. If OdySupportIcons is enabled, also shows icons above their heads",
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

if (ADD_ICON_SETTINGS) then
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Xoryn Tempest position icons",
        tooltip = "Shows icons for group member positions on the Xoryn fight for Tempest (and at the beginning of the trial, for practice purposes). Requires OdySupportIcons",
        default = true,
        getFunction = function() return Crutch.savedOptions.lucentcitadel.showTempestIcons end,
        setFunction = function(value)
            Crutch.savedOptions.lucentcitadel.showTempestIcons = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return OSI == nil end,
    })
end

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
        tooltip = "Shows a line connecting group members who are about to (or have already received) the Dominator's Chains tether from Overfiend Kazpian. If OdySupportIcons is enabled, also shows icons above their heads",
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

if (ADD_ICON_SETTINGS) then
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Sanity's Edge",
    })


    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show center of Ansuul arena",
        tooltip = "In the Ansuul fight, shows an icon in the world on the center of the arena. Requires OdySupportIcons",
        default = true,
        getFunction = function() return Crutch.savedOptions.sanitysedge.showAnsuulIcon end,
        setFunction = function(value)
            Crutch.savedOptions.sanitysedge.showAnsuulIcon = value
            Crutch.OnPlayerActivated()
        end,
        disable = function() return OSI == nil end,
    })
end

if (ADD_ICON_SETTINGS) then
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Sunspire",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Lokkestiiz HM beam position icons",
        tooltip = "During flight phase on Lokkestiiz hardmode, shows 1~8 DPS and 2 healer positions in the world for Storm Fury. Requires OdySupportIcons",
        default = true,
        getFunction = function() return Crutch.savedOptions.sunspire.showLokkIcons end,
        setFunction = function(value)
            Crutch.savedOptions.sunspire.showLokkIcons = value
        end,
        disable = function() return OSI == nil end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "    Lokkestiiz solo heal icons",
        tooltip = "Use solo healer positions for the Lokkestiiz hardmode icons. This is for 9 damage dealers and 1 healer. If you change this option while at the Lokkestiiz fight, the new icons will show up the next time icons are displayed",
        default = false,
        getFunction = function() return Crutch.savedOptions.sunspire.lokkIconsSoloHeal end,
        setFunction = function(value)
            Crutch.savedOptions.sunspire.lokkIconsSoloHeal = value
        end,
        disable = function() return not Crutch.savedOptions.sunspire.showLokkIcons end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Yolnahkriin position icons",
        tooltip = "During flight phase on Yolnahkriin, shows icons in the world for where the next head stack and (right) wing stack will be when Yolnahkriin lands. Requires OdySupportIcons",
        default = true,
        getFunction = function() return Crutch.savedOptions.sunspire.showYolIcons end,
        setFunction = function(value)
            Crutch.savedOptions.sunspire.showYolIcons = value
        end,
        disable = function() return OSI == nil end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "    Yolnahkriin left position icons",
        tooltip = "Use left icons instead of right icons during flight phase on Yolnahkriin",
        default = false,
        getFunction = function() return Crutch.savedOptions.sunspire.yolLeftIcons end,
        setFunction = function(value)
            Crutch.savedOptions.sunspire.yolLeftIcons = value
        end,
        disable = function() return not Crutch.savedOptions.sunspire.showYolIcons end,
    })
end

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

if (ADD_ICON_SETTINGS) then
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Brewmaster elixir spot",
        tooltip = "Displays an icon on where the Fabled Brewmaster may have thrown an Elixir of Diminishing. Note that it will not work on elixirs that are thrown at your group members' pets, but should for yourself, your pets, your companion, and your actual group member. Requires OdySupportIcons",
        default = true,
        getFunction = function() return Crutch.savedOptions.endlessArchive.potionIcon end,
        setFunction = function(value)
            Crutch.savedOptions.endlessArchive.potionIcon = value
        end,
        disable = function() return OSI == nil end,
    })
end

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
        tooltip = "Plays a ding sound for particularly dangerous abilities. Requires \"Begin\" casts on. Currently, this only includes:\n\n- Obliterate from Anka-Ra Destroyers on the Warrior encounter, because if you don't block or dodge it, the CC cannot be broken free of\n- Elixir of Diminishing from Brewmasters, which also stuns you for a duration",
        default = true,
        getFunction = function() return Crutch.savedOptions.endlessArchive.dingDangerous end,
        setFunction = function(value)
            Crutch.savedOptions.endlessArchive.dingDangerous = value
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
        label = "Shipwright's Regret",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Suggest stacks for Soul Bomb",
        tooltip = "Displays a notification for suggested person to stack on for Soul Bomb on Foreman Bradiggan hardmode when there are 2 bombs. If OdySupportIcons is enabled, also shows an icon above that person's head. The suggested stack is alphabetical based on @ name",
        default = true,
        getFunction = function() return Crutch.savedOptions.shipwrightsRegret.showBombStacks end,
        setFunction = function(value)
            Crutch.savedOptions.shipwrightsRegret.showBombStacks = value
            Crutch.OnPlayerActivated()
        end,
    })
end