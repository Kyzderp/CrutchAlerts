local Crutch = CrutchAlerts

local ADD_ICON_SETTINGS = false

function Crutch.CreateConsoleDrawingSettingsMenu()
    local settings = LibHarvensAddonSettings:AddAddon("CrutchAlerts - Icons", {
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
    -- general
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "General Settings",
        tooltip = "Crutch can use the 3D API to draw textures (mostly single icons) in the world, including ones attached to players, as well as on the ground for positioning or other mechanics"
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Update interval",
        tooltip = "How often to update icons to follow players or face the camera, in milliseconds. Smaller interval appears smoother, but may reduce performance. Set to 0 to update every frame",
        min = 0,
        max = 100,
        step = 1,
        default = Crutch.defaultOptions.drawing.interval,
        getFunction = function() return Crutch.savedOptions.drawing.interval end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.interval = value
            Crutch.Drawing.ForceRestartPolling()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Use drawing levels",
        tooltip = "Whether to show closer icons on top of farther icons. If OFF, icons may appear somewhat out of order when viewing one on top of another, or have transparent edges that clip other icons. If ON, there may be a slight performance reduction",
        default = true,
        getFunction = function() return Crutch.savedOptions.drawing.useLevels end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.useLevels = value
        end,
    })

    ---------------------------------------------------------------------
    -- Attached icons
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Group Member Icons",
        tooltip = "These are settings for icons attached to group members, which will also apply to icons shown from mechanics, such as MoL twins Aspects"
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show group icon for self",
        tooltip = "Whether to show the role, crown, and death icons for yourself. This setting does not affect icons from mechanics",
        default = Crutch.defaultOptions.drawing.attached.showSelfRole,
        getFunction = function() return Crutch.savedOptions.drawing.attached.showSelfRole end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.attached.showSelfRole = value
            Crutch.Drawing.RefreshGroup()
        end,
    })

    ---------------------------------------------------------------------
end