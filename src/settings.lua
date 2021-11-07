CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

function Crutch:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "|c08BD1DCrutch Alerts|r",
        author = "Kyzeragon",
        version = Crutch.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

-- TODO: extend hitvalue by X
--[[
local defaultOptions = {
    display = {
        x = 0,
        y = GuiRoot:GetHeight() / 3,
    },
    debugLine = false,
    debugChatSpam = false,
    debugOther = false,
    general = {
        showBegin = true,
            beginHideSelf = false,
        showGained = true,
            gainedHideSelf = false,
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
--]]

    local optionsData = {
        {
            type = "checkbox",
            name = "Unlock",
            tooltip = "Unlock the frames for moving",
            default = false,
            getFunc = function() return Crutch.unlock end,
            setFunc = function(value)
                Crutch.unlock = value
                CrutchAlertsContainer:SetMovable(value)
                CrutchAlertsContainer:SetMouseEnabled(value)
                CrutchAlertsContainerBackdrop:SetHidden(not value)

                CrutchAlertsDamageable:SetMovable(value)
                CrutchAlertsDamageable:SetMouseEnabled(value)
                CrutchAlertsDamageableBackdrop:SetHidden(not value)
                CrutchAlertsDamageableLabel:SetHidden(not value)

                CrutchAlertsCloudrest:SetMovable(value)
                CrutchAlertsCloudrest:SetMouseEnabled(value)
                CrutchAlertsCloudrestBackdrop:SetHidden(not value)
                if (value) then
                    Crutch.UpdateSpearsDisplay(3, 2, 1)
                else
                    Crutch.UpdateSpearsDisplay(0, 0, 0)
                end
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show debug on alert",
            tooltip = "Add a small line of text on alerts that shows IDs and other debug information",
            default = false,
            getFunc = function() return Crutch.savedOptions.debugLine end,
            setFunc = function(value)
                Crutch.savedOptions.debugLine = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show debug chat spam",
            tooltip = "Display a chat message every time any event is procced -- very spammy!",
            default = false,
            getFunc = function() return Crutch.savedOptions.debugChatSpam end,
            setFunc = function(value)
                Crutch.savedOptions.debugChatSpam = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show other debug",
            tooltip = "Display other debug messages",
            default = false,
            getFunc = function() return Crutch.savedOptions.debugOther end,
            setFunc = function(value)
                Crutch.savedOptions.debugOther = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show debug UI",
            tooltip = "Display a UI element that may or may not contain useful debug",
            default = false,
            getFunc = function() return Crutch.savedOptions.debugUi end,
            setFunc = function(value)
                Crutch.savedOptions.debugUi = value
                Crutch.InitializeDebug()
            end,
            width = "full",
        },
---------------------------------------------------------------------
-- general
        {
            type = "submenu",
            name = "General Settings",
            controls = {
                {
                    type = "checkbox",
                    name = "Show begin casts",
                    tooltip = "Show alerts when you are targeted by the beginning of a cast (ACTION_RESULT_BEGIN)",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.general.showBegin end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.showBegin = value
                        if (value) then
                            Crutch.RegisterBegin()
                        else
                            Crutch.UnregisterBegin()
                        end
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "      Ignore non-enemy casts",
                    tooltip = "Don't show alerts for beginning of a cast if it is not from an enemy, e.g. player-sourced",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.general.beginHideSelf end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.beginHideSelf = value
                        -- Re-register with filters
                        Crutch.UnregisterBegin()
                        Crutch.RegisterBegin()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show gained casts",
                    tooltip = "Show alerts when you \"Gain\" a cast from an enemy (ACTION_RESULT_GAINED / ACTION_RESULT_GAINED_DURATION)",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.general.showGained end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.showGained = value
                        if (value) then
                            Crutch.RegisterGained()
                        else
                            Crutch.UnregisterGained()
                        end
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show prominent alerts",
                    tooltip = "Show VERY large letters and in some cases a ding sound for certain alerts",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.general.showProminent end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.showProminent = value
                    end,
                    width = "full",
                },
            }
        },
        {
            type = "submenu",
            name = "Miscellaneous Settings",
            controls = {
                {
                    type = "checkbox",
                    name = "Show subtitles in chat",
                    tooltip = "Show NPC dialogue subtitles in chat. The color formatting will be weird if there are multiple lines",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.showSubtitles end,
                    setFunc = function(value)
                        Crutch.savedOptions.showSubtitles = value
                    end,
                    width = "full",
                },
            }
        },
---------------------------------------------------------------------
-- trials
        {
            type = "description",
            title = "Trials",
            text = "Below are settings for special mechanics in specific trials.",
            width = "full",
        },
        {
            type = "submenu",
            name = "Cloudrest",
            controls = {
                {
                    type = "checkbox",
                    name = "Show spears indicator",
                    tooltip = "Show an indicator for how many spears are revealed, sent, and orbs dunked",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.cloudrest.showSpears end,
                    setFunc = function(value)
                        Crutch.savedOptions.cloudrest.showSpears = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Play spears sound",
                    tooltip = "Plays the champion point committed sound when a spear is revealed",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.cloudrest.spearsSound end,
                    setFunc = function(value)
                        Crutch.savedOptions.cloudrest.spearsSound = value
                    end,
                    width = "full",
                },
            }
        },
        {
            type = "submenu",
            name = "Sunspire",
            controls = {
                {
                    type = "checkbox",
                    name = "Show Lokkestiiz HM beam position icons",
                    tooltip = "During flight phase on Lokkestiiz hardmode, shows 1~8 DPS and 2 healer positions in the world for Storm Fury. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.sunspire.showLokkIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.sunspire.showLokkIcons = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Yolnahkriin position icons",
                    tooltip = "During flight phase on Yolnahkriin, shows icons in the world for where the next head stack and (right) wing stack will be when Yolnahkriin lands. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.sunspire.showYolIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.sunspire.showYolIcons = value
                    end,
                    width = "full",
                },
            }
        },
    }

    CrutchAlerts.addonPanel = LAM:RegisterAddonPanel("CrutchAlertsOptions", panelData)
    LAM:RegisterOptionControls("CrutchAlertsOptions", optionsData)
end