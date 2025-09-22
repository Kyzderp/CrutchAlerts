local Crutch = CrutchAlerts

local ADD_ICON_SETTINGS = false

function Crutch.CreateConsoleDrawingSettingsMenu()
    local settings = LibHarvensAddonSettings:AddAddon("CrutchAlerts - Icons", {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = function()
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
        label = "",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
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
        label = "",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
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

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Size",
        tooltip = "General size of icons. Mechanic icons may display different sizes",
        min = 0,
        max = 400,
        step = 10,
        default = Crutch.defaultOptions.drawing.attached.size,
        getFunction = function() return Crutch.savedOptions.drawing.attached.size end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.attached.size = value
            Crutch.Drawing.RefreshGroup()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Vertical offset",
        tooltip = "Y coordinate offset for non-death icons",
        min = 0,
        max = 500,
        step = 25,
        default = Crutch.defaultOptions.drawing.attached.yOffset,
        getFunction = function() return Crutch.savedOptions.drawing.attached.yOffset end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.attached.yOffset = value
            Crutch.Drawing.RefreshGroup()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Opacity",
        tooltip = "How transparent the icons are. Mechanic icons may display differently",
        min = 0,
        max = 100,
        step = 5,
        default = Crutch.defaultOptions.drawing.attached.opacity * 100,
        getFunction = function() return Crutch.savedOptions.drawing.attached.opacity * 100 end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.attached.opacity = value / 100
            Crutch.Drawing.RefreshGroup()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show tanks",
        tooltip = "Whether to show tank icons for group members with LFG role set as tank",
        default = Crutch.defaultOptions.drawing.attached.showTank,
        getFunction = function() return Crutch.savedOptions.drawing.attached.showTank end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.attached.showTank = value
            Crutch.Drawing.RefreshGroup()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Tank color",
        tooltip = "Color of the tank icons",
        default = Crutch.defaultOptions.drawing.attached.tankColor,
        getFunction = function() return unpack(Crutch.savedOptions.drawing.attached.tankColor) end,
        setFunction = function(r, g, b)
            Crutch.savedOptions.drawing.attached.tankColor = {r, g, b}
            Crutch.Drawing.RefreshGroup()
        end,
        disable = function() return not Crutch.savedOptions.drawing.attached.showTank end
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show healers",
        tooltip = "Whether to show healer icons for group members with LFG role set as healer",
        default = Crutch.defaultOptions.drawing.attached.showHeal,
        getFunction = function() return Crutch.savedOptions.drawing.attached.showHeal end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.attached.showHeal = value
            Crutch.Drawing.RefreshGroup()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Healer color",
        tooltip = "Color of the healer icons",
        default = Crutch.defaultOptions.drawing.attached.healColor,
        getFunction = function() return unpack(Crutch.savedOptions.drawing.attached.healColor) end,
        setFunction = function(r, g, b)
            Crutch.savedOptions.drawing.attached.healColor = {r, g, b}
            Crutch.Drawing.RefreshGroup()
        end,
        disable = function() return not Crutch.savedOptions.drawing.attached.showHeal end
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show DPS",
        tooltip = "Whether to show DPS icons for group members with LFG role set as DPS",
        default = Crutch.defaultOptions.drawing.attached.showDps,
        getFunction = function() return Crutch.savedOptions.drawing.attached.showDps end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.attached.showDps = value
            Crutch.Drawing.RefreshGroup()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "DPS color",
        tooltip = "Color of the DPS icons",
        default = Crutch.defaultOptions.drawing.attached.dpsColor,
        getFunction = function() return unpack(Crutch.savedOptions.drawing.attached.dpsColor) end,
        setFunction = function(r, g, b)
            Crutch.savedOptions.drawing.attached.dpsColor = {r, g, b}
            Crutch.Drawing.RefreshGroup()
        end,
        disable = function() return not Crutch.savedOptions.drawing.attached.showDps end
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show crown",
        tooltip = "Whether to show a crown icon for the group leader",
        default = Crutch.defaultOptions.drawing.attached.showCrown,
        getFunction = function() return Crutch.savedOptions.drawing.attached.showCrown end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.attached.showCrown = value
            Crutch.Drawing.RefreshGroup()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Crown color",
        tooltip = "Color of the crown icon",
        default = Crutch.defaultOptions.drawing.attached.crownColor,
        getFunction = function() return unpack(Crutch.savedOptions.drawing.attached.crownColor) end,
        setFunction = function(r, g, b)
            Crutch.savedOptions.drawing.attached.crownColor = {r, g, b}
            Crutch.Drawing.RefreshGroup()
        end,
        disable = function() return not Crutch.savedOptions.drawing.attached.showCrown end
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show dead group members",
        tooltip = "Whether to show skull icons for group members who are deadge",
        default = Crutch.defaultOptions.drawing.attached.showDead,
        getFunction = function() return Crutch.savedOptions.drawing.attached.showDead end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.attached.showDead = value
            Crutch.Drawing.RefreshGroup()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Dead color",
        tooltip = "Color of the dead player icons",
        default = Crutch.defaultOptions.drawing.attached.deadColor,
        getFunction = function() return unpack(Crutch.savedOptions.drawing.attached.deadColor) end,
        setFunction = function(r, g, b)
            Crutch.savedOptions.drawing.attached.deadColor = {r, g, b}
            Crutch.Drawing.RefreshGroup()
        end,
        disable = function() return not Crutch.savedOptions.drawing.attached.showDead end
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Resurrecting color",
        tooltip = "Color of the dead player icons while being resurrected",
        default = Crutch.defaultOptions.drawing.attached.rezzingColor,
        getFunction = function() return unpack(Crutch.savedOptions.drawing.attached.rezzingColor) end,
        setFunction = function(r, g, b)
            Crutch.savedOptions.drawing.attached.rezzingColor = {r, g, b}
            Crutch.Drawing.RefreshGroup()
        end,
        disable = function() return not Crutch.savedOptions.drawing.attached.showDead end
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Rez pending color",
        tooltip = "Color of the dead player icons when resurrection is pending",
        default = Crutch.defaultOptions.drawing.attached.pendingColor,
        getFunction = function() return unpack(Crutch.savedOptions.drawing.attached.pendingColor) end,
        setFunction = function(r, g, b)
            Crutch.savedOptions.drawing.attached.pendingColor = {r, g, b}
            Crutch.Drawing.RefreshGroup()
        end,
        disable = function() return not Crutch.savedOptions.drawing.attached.showDead end
    })

    ---------------------------------------------------------------------
    -- placedPositioning icons
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
        label = "Positioning Markers",
        tooltip = "These are settings for positioning-type markers placed on the ground, such as Lokkestiiz HM beam phase and Xoryn Tempest positions"
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Opacity",
        tooltip = "How transparent the markers are. Mechanic markers may display differently",
        min = 0,
        max = 100,
        step = 5,
        default = Crutch.defaultOptions.drawing.placedPositioning.opacity * 100,
        getFunction = function() return Crutch.savedOptions.drawing.placedPositioning.opacity * 100 end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.placedPositioning.opacity = value / 100
            Crutch.OnPlayerActivated()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Use flat icons",
        tooltip = "Whether to have icons lie flat on the ground, instead of facing the camera. No guarantees of being easy to read; they are upright when you are facing directly north",
        default = Crutch.defaultOptions.drawing.placedPositioning.flat,
        getFunction = function() return Crutch.savedOptions.drawing.placedPositioning.flat end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.placedPositioning.flat = value
            Crutch.OnPlayerActivated()
        end,
    })

    ---------------------------------------------------------------------
    -- placedOriented icons
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
        label = "Oriented Textures",
        tooltip = "These are settings for various textures that are drawn in the world, that are oriented in a certain way, instead of always facing the player. For example, circles drawn on the ground, like in HoF triplets, fall under this category"
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Opacity",
        tooltip = "How transparent the textures are. Mechanic textures may display differently",
        min = 0,
        max = 100,
        step = 5,
        default = Crutch.defaultOptions.drawing.placedOriented.opacity * 100,
        getFunction = function() return Crutch.savedOptions.drawing.placedOriented.opacity * 100 end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.placedOriented.opacity = value / 100
            Crutch.OnPlayerActivated()
        end,
    })

    ---------------------------------------------------------------------
    -- placedIcon icons
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
        label = "Other Icons",
        tooltip = "These are settings for other icons that appear to face the player, such as thrown potions from IA Brewmasters"
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Opacity",
        tooltip = "How transparent the icons are. Mechanic icons may display differently",
        min = 0,
        max = 100,
        step = 5,
        default = Crutch.defaultOptions.drawing.placedIcon.opacity * 100,
        getFunction = function() return Crutch.savedOptions.drawing.placedIcon.opacity * 100 end,
        setFunction = function(value)
            Crutch.savedOptions.drawing.placedIcon.opacity = value / 100
            Crutch.OnPlayerActivated()
        end,
    })

    ---------------------------------------------------------------------
end