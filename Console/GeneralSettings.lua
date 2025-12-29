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
        Crutch.DisplayNotification(47898, "Example Alert", 5000, 0, 0, 0, 0, 0, 0, 0, false)
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

function Crutch.CreateConsoleGeneralSettingsMenu()
    local settings = LibHarvensAddonSettings:AddAddon("CrutchAlerts - General", {
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
            Crutch.RegisterOthers()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Alerts position X",
        tooltip = "The horizontal position of the general alerts",
        min = - GuiRoot:GetWidth() / 2,
        max = GuiRoot:GetWidth() / 2,
        step = GuiRoot:GetWidth() / 64,
        default = Crutch.defaultOptions.display.x,
        getFunction = function() return Crutch.savedOptions.display.x end,
        setFunction = function(value)
            Crutch.savedOptions.display.x = value
            CrutchAlertsContainer:ClearAnchors()
            CrutchAlertsContainer:SetAnchor(CENTER, GuiRoot, TOP, Crutch.savedOptions.display.x, Crutch.savedOptions.display.y)
            Crutch.UnlockUI(true)
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Alerts position Y",
        tooltip = "The vertical position of the general alerts",
        min = 0,
        max = GuiRoot:GetHeight(),
        step = GuiRoot:GetHeight() / 64,
        default = Crutch.defaultOptions.display.y,
        getFunction = function() return Crutch.savedOptions.display.y end,
        setFunction = function(value)
            Crutch.savedOptions.display.y = value
            CrutchAlertsContainer:ClearAnchors()
            CrutchAlertsContainer:SetAnchor(CENTER, GuiRoot, TOP, Crutch.savedOptions.display.x, Crutch.savedOptions.display.y)
            Crutch.UnlockUI(true)
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Alerts size",
        tooltip = "The size of the general alerts",
        min = 5,
        max = 120,
        step = 1,
        default = Crutch.defaultOptions.general.alertScale,
        getFunction = function() return Crutch.savedOptions.general.alertScale end,
        setFunction = function(value)
            Crutch.savedOptions.general.alertScale = value
            Crutch.UnlockUI(true)
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
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Damageable timer position X",
        tooltip = "The horizontal position of the damageable timer",
        min = - GuiRoot:GetWidth() / 2,
        max = GuiRoot:GetWidth() / 2,
        step = GuiRoot:GetWidth() / 64,
        default = Crutch.defaultOptions.damageableDisplay.x,
        getFunction = function() return Crutch.savedOptions.damageableDisplay.x end,
        setFunction = function(value)
            Crutch.savedOptions.damageableDisplay.x = value
            CrutchAlertsDamageable:ClearAnchors()
            CrutchAlertsDamageable:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.damageableDisplay.x, Crutch.savedOptions.damageableDisplay.y)
            Crutch.UnlockUI(true)
        end,
        disable = function() return not Crutch.savedOptions.general.showDamageable end
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Damageable timer position Y",
        tooltip = "The vertical position of the damageable timer",
        min = - GuiRoot:GetHeight() / 2,
        max = GuiRoot:GetHeight() / 2,
        step = GuiRoot:GetHeight() / 64,
        default = Crutch.defaultOptions.damageableDisplay.y,
        getFunction = function() return Crutch.savedOptions.damageableDisplay.y end,
        setFunction = function(value)
            Crutch.savedOptions.damageableDisplay.y = value
            CrutchAlertsDamageable:ClearAnchors()
            CrutchAlertsDamageable:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.damageableDisplay.x, Crutch.savedOptions.damageableDisplay.y)
            Crutch.UnlockUI(true)
        end,
        disable = function() return not Crutch.savedOptions.general.showDamageable end
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

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Foreground color",
        tooltip = "Foreground color of the bars. Does not apply to special cases like OC titans and AS minis. Note that this color includes opacity, so it may appear darker in the settings menu than it actually is",
        default = Crutch.defaultOptions.bossHealthBar.foreground,
        getFunction = function() return unpack(Crutch.savedOptions.bossHealthBar.foreground) end,
        setFunction = function(r, g, b, a)
            Crutch.savedOptions.bossHealthBar.foreground = {r, g, b, a}
            Crutch.BossHealthBar.UpdateColors()
            Crutch.UnlockUI(true)
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Background color",
        tooltip = "Background color of the bars. Does not apply to special cases like OC titans and AS minis. Note that this color includes opacity, so it may appear darker in the settings menu than it actually is",
        default = Crutch.defaultOptions.bossHealthBar.background,
        getFunction = function() return unpack(Crutch.savedOptions.bossHealthBar.background) end,
        setFunction = function(r, g, b, a)
            Crutch.savedOptions.bossHealthBar.background = {r, g, b, a}
            Crutch.BossHealthBar.UpdateColors()
            Crutch.UnlockUI(true)
        end,
    })

    ---------------------------------------------------------------------
    -- blacklist IDs
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Advanced",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_EDIT,
        label = "Blacklist IDs, separated by commas",
        tooltip = "You can adjust the abilities that are shown in the general alerts here. This includes the casts on yourself and others as listed above. To find IDs, you can turn on \"Show debug on alert\" below, and the ID is the first number shown on the small gray text under the alert (ignore fake IDs starting with 888). Alternatively, you can find IDs from online sources such as ESOLogs, player-maintained spreadsheets, or UESP.\n\nIDs added to this blacklist will no longer be shown in \"begin casts,\" \"gained casts,\" and \"casts on others.\" For example, to suppress Bahsei HM portal direction alerts, add 153517,153518",
        getFunction = function()
            local str = ""
            for id, _ in pairs(Crutch.savedOptions.general.blacklist) do
                str = string.format("%s%d, ", str, id)
            end
            return str
        end,
        setFunction = function(value)
            local ids = {}
            for _, id in ipairs({zo_strsplit(",", value)}) do
                id = tonumber(id)
                if (id) then
                    ids[id] = true
                end
            end
            Crutch.savedOptions.general.blacklist = ids
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show debug on alert",
        tooltip = "Add a small line of text on alerts that shows IDs and other debug information",
        default = false,
        getFunction = function() return Crutch.savedOptions.debugLine end,
        setFunction = function(value)
            Crutch.savedOptions.debugLine = value
        end,
    })
end