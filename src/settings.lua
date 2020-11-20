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

    local optionsData = {
        {
            type = "header",
            name = "|c08BD1DWhat to Show|r",
            width = "full",
        },
        -- {
        --     type = "checkbox",
        --     name = "Bank",
        --     tooltip = "Show icon in your personal bank",
        --     default = true,
        --     getFunc = function() return SetCollectionMarker.savedOptions.show.bank end,
        --     setFunc = function(value)
        --         SetCollectionMarker.savedOptions.show.bank = value
        --         SetCollectionMarker.OnSetCollectionUpdated()
        --     end,
        --     width = "full",
        -- },
    }

    SetCollectionMarker.addonPanel = LAM:RegisterAddonPanel("CrutchAlertsOptions", panelData)
    LAM:RegisterOptionControls("CrutchAlertsOptions", optionsData)
end