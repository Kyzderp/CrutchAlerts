local Crutch = CrutchAlerts
local C = Crutch.Constants

local selectedIndividual
local individualNames = {}

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

    local mainSettings, individualIconSubSettings

    -- When user adds individual players, they show up as single buttons that can be pressed to open "submenu"
    local individualPlayerSubmenus = {}
    local names = {}

    local function CreateNewIndividualIconSubmenuButtonTable(name)
        return {
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = name,
            tooltip = "Edit individual player icon for " .. name,
            clickHandler = function()
                selectedIndividual = name
                settings:RemoveAllSettings()
                settings:AddSettings(individualIconSubSettings)
            end,
        }
    end

    local function AddIndividualIconButtons()
        -- Alphabetize
        ZO_ClearTable(names)
        for name, _ in pairs(Crutch.savedOptions.drawing.attached.individualIcons) do
            table.insert(names, name)
        end
        table.sort(names)

        -- TODO: alphabetize
        for _, name in ipairs(names) do
            individualPlayerSubmenus[name] = individualPlayerSubmenus[name] or CreateNewIndividualIconSubmenuButtonTable(name)
            settings:AddSetting(individualPlayerSubmenus[name])
        end
    end

    individualIconSubSettings = {
        {
            type = LibHarvensAddonSettings.ST_LABEL,
            label = function() return selectedIndividual end,
        },
        {
            type = LibHarvensAddonSettings.ST_DROPDOWN,
            label = "Texture type",
            tooltip = "The base icon texture to display for this player",
            getFunction = function()
                if (selectedIndividual and Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual]) then
                    return Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].type
                end
            end,
            setFunction = function(combobox, name, item)
                Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].type = name
                Crutch.Drawing.RefreshGroup()
            end,
            items = {
                {
                    name = C.ICON_NONE,
                    data = C.ICON_NONE,
                },
                {
                    name = C.CIRCLE,
                    data = C.CIRCLE,
                },
                {
                    name = C.DIAMOND,
                    data = C.DIAMOND,
                },
                {
                    name = C.CHEVRON,
                    data = C.CHEVRON,
                },
                {
                    name = C.CHEVRON_THIN,
                    data = C.CHEVRON_THIN,
                },
                -- TODO: LCI when console gets it
                {
                    name = C.CUSTOM,
                    data = C.CUSTOM,
                },
            },
        },
        {
            type = LibHarvensAddonSettings.ST_EDIT,
            label = "Custom texture path",
            tooltip = "If using a \"Custom texture,\" the path of the texture. You can use base game textures or even textures from other addons. Examples: esoui/art/icons/targetdummy_voriplasm_01.dds or CrutchAlerts/assets/poop.dds\n\nFor base game textures, you can find them via online sources like UESP.",
            getFunction = function()
                if (selectedIndividual and Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual]) then
                    return Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].custom
                end
            end,
            setFunction = function(path)
                Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].custom = path
                Crutch.Drawing.RefreshGroup()
            end,
            disable = function() return selectedIndividual == nil or not Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual] or Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].type ~= C.CUSTOM end,
        },
        {
            type = LibHarvensAddonSettings.ST_COLOR,
            label = "Texture color",
            tooltip = "Color of the icon texture",
            getFunction = function()
                if (selectedIndividual and Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual]) then
                    return unpack(Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].color)
                end
            end,
            setFunction = function(r, g, b, a)
                Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].color = {r, g, b, a}
                Crutch.Drawing.RefreshGroup()
            end,
        },
        {
            type = LibHarvensAddonSettings.ST_SLIDER,
            label = "Texture size",
            tooltip = "Size of icon texture",
            min = 0,
            max = 400,
            step = 10,
            getFunction = function()
                if (selectedIndividual and Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual]) then
                    return Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].size * 100
                end
            end,
            setFunction = function(value)
                Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].size = value / 100
                Crutch.Drawing.RefreshGroup()
            end,
        },
        {
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "",
        },
        {
            type = LibHarvensAddonSettings.ST_EDIT,
            label = "Text",
            tooltip = "The text that appears on the icon",
            getFunction = function()
                if (selectedIndividual and Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual]) then
                    return Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].text
                end
            end,
            setFunction = function(text)
                Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].text = text
                Crutch.Drawing.RefreshGroup()
            end,
        },
        {
            type = LibHarvensAddonSettings.ST_COLOR,
            label = "Text color",
            tooltip = "Color of the text",
            getFunction = function()
                if (selectedIndividual and Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual]) then
                    return unpack(Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].textColor)
                end
            end,
            setFunction = function(r, g, b, a)
                Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].textColor = {r, g, b, a}
                Crutch.Drawing.RefreshGroup()
            end,
            disable = function()
                if (not selectedIndividual or not Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual]) then return true end
                local text = Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].text
                return text == nil or text == ""
            end,
        },
        {
            type = LibHarvensAddonSettings.ST_SLIDER,
            label = "Text size",
            tooltip = "Size of the text",
            min = 0,
            max = 200,
            step = 1,
            getFunction = function()
                if (selectedIndividual and Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual]) then
                    return Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].textSize
                end
            end,
            setFunction = function(value)
                Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].textSize = value
                Crutch.Drawing.RefreshGroup()
            end,
            disable = function()
                if (not selectedIndividual or not Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual]) then return true end
                local text = Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].text
                return text == nil or text == ""
            end,
        },
        {
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = "Back",
            tooltip = "Go back to main settings",
            clickHandler = function()
                settings:RemoveAllSettings()
                settings:AddSettings(mainSettings)
                AddIndividualIconButtons()
            end,
        },
        {
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = "Delete player icon",
            tooltip = "Delete this individual player icon. This cannot be undone!",
            clickHandler = function()
                Crutch.RemoveIndividualIcon(selectedIndividual)
                Crutch.Drawing.RefreshGroup()

                individualPlayerSubmenus[selectedIndividual] = nil
                settings:RemoveAllSettings()
                settings:AddSettings(mainSettings)
                AddIndividualIconButtons()
            end,
        },
    }


    mainSettings = {
        ---------------------------------------------------------------------
        -- general
        {
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "",
        },
        {
            type = LibHarvensAddonSettings.ST_LABEL,
            label = "General Settings",
            tooltip = "Crutch can use the 3D API to draw textures (mostly single icons) in the world, including ones attached to players, as well as on the ground for positioning or other mechanics"
        },
        {
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
        },
        {
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = "Use drawing levels",
            tooltip = "Whether to show closer icons on top of farther icons. If OFF, icons may appear somewhat out of order when viewing one on top of another, or have transparent edges that clip other icons. If ON, there may be a slight performance reduction",
            default = true,
            getFunction = function() return Crutch.savedOptions.drawing.useLevels end,
            setFunction = function(value)
                Crutch.savedOptions.drawing.useLevels = value
            end,
        },
        ---------------------------------------------------------------------
        -- Attached icons
        {
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "",
        },
        {
            type = LibHarvensAddonSettings.ST_LABEL,
            label = "Group Member Icons",
            tooltip = "These are settings for icons attached to group members, which will also apply to icons shown from mechanics, such as MoL twins Aspects"
        },
        {
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = "Show group icon for self",
            tooltip = "Whether to show the role, crown, and death icons for yourself. This setting does not affect icons from mechanics",
            default = Crutch.defaultOptions.drawing.attached.showSelfRole,
            getFunction = function() return Crutch.savedOptions.drawing.attached.showSelfRole end,
            setFunction = function(value)
                Crutch.savedOptions.drawing.attached.showSelfRole = value
                Crutch.Drawing.RefreshGroup()
            end,
        },
        {
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
        },
        {
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
        },
        {
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
        },
        {
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "",
        },
        {
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = "Show tanks",
            tooltip = "Whether to show tank icons for group members with LFG role set as tank",
            default = Crutch.defaultOptions.drawing.attached.showTank,
            getFunction = function() return Crutch.savedOptions.drawing.attached.showTank end,
            setFunction = function(value)
                Crutch.savedOptions.drawing.attached.showTank = value
                Crutch.Drawing.RefreshGroup()
            end,
        },
        {
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
        },
        {
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = "Show healers",
            tooltip = "Whether to show healer icons for group members with LFG role set as healer",
            default = Crutch.defaultOptions.drawing.attached.showHeal,
            getFunction = function() return Crutch.savedOptions.drawing.attached.showHeal end,
            setFunction = function(value)
                Crutch.savedOptions.drawing.attached.showHeal = value
                Crutch.Drawing.RefreshGroup()
            end,
        },
        {
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
        },
        {
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = "Show DPS",
            tooltip = "Whether to show DPS icons for group members with LFG role set as DPS",
            default = Crutch.defaultOptions.drawing.attached.showDps,
            getFunction = function() return Crutch.savedOptions.drawing.attached.showDps end,
            setFunction = function(value)
                Crutch.savedOptions.drawing.attached.showDps = value
                Crutch.Drawing.RefreshGroup()
            end,
        },
        {
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
        },
        {
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = "Show crown",
            tooltip = "Whether to show a crown icon for the group leader",
            default = Crutch.defaultOptions.drawing.attached.showCrown,
            getFunction = function() return Crutch.savedOptions.drawing.attached.showCrown end,
            setFunction = function(value)
                Crutch.savedOptions.drawing.attached.showCrown = value
                Crutch.Drawing.RefreshGroup()
            end,
        },
        {
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
        },
        {
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "",
        },
        {
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = "Show dead group members",
            tooltip = "Whether to show skull icons for group members who are deadge",
            default = Crutch.defaultOptions.drawing.attached.showDead,
            getFunction = function() return Crutch.savedOptions.drawing.attached.showDead end,
            setFunction = function(value)
                Crutch.savedOptions.drawing.attached.showDead = value
                Crutch.Drawing.RefreshGroup()
            end,
        },
        {
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
        },
        {
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
        },
        {
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
        },
        ---------------------------------------------------------------------
        -- placedPositioning icons
        {
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "",
        },
        {
            type = LibHarvensAddonSettings.ST_LABEL,
            label = "Positioning Markers",
            tooltip = "These are settings for positioning-type markers placed on the ground, such as Lokkestiiz HM beam phase and Xoryn Tempest positions"
        },
        {
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
        },
        {
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = "Use flat icons",
            tooltip = "Whether to have icons lie flat on the ground, instead of facing the camera. No guarantees of being easy to read; they are upright when you are facing directly north",
            default = Crutch.defaultOptions.drawing.placedPositioning.flat,
            getFunction = function() return Crutch.savedOptions.drawing.placedPositioning.flat end,
            setFunction = function(value)
                Crutch.savedOptions.drawing.placedPositioning.flat = value
                Crutch.OnPlayerActivated()
            end,
        },
        ---------------------------------------------------------------------
        -- placedOriented icons
        {
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "",
        },
        {
            type = LibHarvensAddonSettings.ST_LABEL,
            label = "Oriented Textures",
            tooltip = "These are settings for various textures that are drawn in the world, that are oriented in a certain way, instead of always facing the player. For example, circles drawn on the ground, like in HoF triplets, fall under this category"
        },
        {
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
        },
        ---------------------------------------------------------------------
        -- placedIcon icons
        {
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "",
        },
        {
            type = LibHarvensAddonSettings.ST_LABEL,
            label = "Other Icons",
            tooltip = "These are settings for other icons that appear to face the player, such as thrown potions from IA Brewmasters"
        },
        {
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
        },
        ---------------------------------------------------------------------
        -- individual icons
        {
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "",
        },
        {
            type = LibHarvensAddonSettings.ST_LABEL,
            label = "Individual Player Icons",
            tooltip = "You can add individual icons for specific players here when they are in your group. They show over role and crown icons, while death and mechanic icons show over the individual icons. I recommend reloading UI after you finish adding icons, both to save in case of crashes, and also because this icon creation has some memory impact."
        },
        {
            type = LibHarvensAddonSettings.ST_EDIT,
            label = "Add new player icon",
            tooltip = "Add a new individual player icon by typing the full account name here, e.g. @Kyzeragon. Case sensitive! If you set an icon for yourself, it will only show if you have \"Show group icon for self\" enabled under Group Member Icons settings",
            getFunction = function() return "" end,
            setFunction = function(name)
                if (not name or name == "") then return end

                if (not Crutch.savedOptions.drawing.attached.individualIcons[name]) then
                    Crutch.AddIndividualIcon(name)

                    individualPlayerSubmenus[name] = individualPlayerSubmenus[name] or CreateNewIndividualIconSubmenuButtonTable(name)

                    -- Insert at the top of the list so it can be used immediately; names will
                    -- be alphabetized later when returning from the submenu
                    settings:AddSetting(individualPlayerSubmenus[name], #mainSettings)
                end

                selectedIndividual = name
            end,
        },
    }

    settings:AddSettings(mainSettings)
    AddIndividualIconButtons()
    
    ---------------------------------------------------------------------
end