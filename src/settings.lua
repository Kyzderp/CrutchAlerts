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
    unlock = false,
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
            tooltip = "Unlock the alert frames for moving",
            default = false,
            getFunc = function() return Crutch.savedOptions.unlock end,
            setFunc = function(value)
                Crutch.savedOptions.unlock = value
                CrutchAlertsContainer:SetMovable(value)
                CrutchAlertsContainer:SetMouseEnabled(value)
                CrutchAlertsContainerBackdrop:SetHidden(not value)

                CrutchAlertsDamageable:SetMovable(value)
                CrutchAlertsDamageable:SetMouseEnabled(value)
                CrutchAlertsDamageableBackdrop:SetHidden(not value)
                CrutchAlertsDamageableLabel:SetHidden(not value)
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Debug on Alert",
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
            name = "Show Debug Chat Spam",
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
            name = "Show Other Debug",
            tooltip = "Display other debug messages",
            default = false,
            getFunc = function() return Crutch.savedOptions.debugOther end,
            setFunc = function(value)
                Crutch.savedOptions.debugOther = value
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
                    name = "Show Begin Casts",
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
                    name = "      Ignore Non-Enemy Casts",
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
                    name = "Show Gained Casts",
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
                    name = "Show Prominent Alerts",
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
        }
    }

    CrutchAlerts.addonPanel = LAM:RegisterAddonPanel("CrutchAlertsOptions", panelData)
    LAM:RegisterOptionControls("CrutchAlertsOptions", optionsData)
end