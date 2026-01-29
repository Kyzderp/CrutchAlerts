local Crutch = CrutchAlerts
local C = Crutch.Constants

local function GetNoSubtitlesZoneIdsAndNames()
    local ids = {}
    local names = {}
    for zoneId, _ in pairs(Crutch.savedOptions.subtitlesIgnoredZones) do
        table.insert(ids, zoneId)
        table.insert(names, string.format("%s (%d)", GetZoneNameById(zoneId), zoneId))
    end
    return ids, names
end

-------------------
-- Individual icons
local selectedIndividual
local individualNames = {}

local function RefreshIndividualIconNames()
    ZO_ClearTable(individualNames)
    for name, _ in pairs(Crutch.savedOptions.drawing.attached.individualIcons) do
        table.insert(individualNames, name)
    end
end

------------------
-- Rockgrove abilities to replace
local abilityNames = {}
local abilityIds = {}
local function UpdateAbilitiesToReplace()
    ZO_ClearTable(abilityNames)
    ZO_ClearTable(abilityIds)
    for id, _ in pairs(Crutch.savedOptions.rockgrove.abilitiesToReplace) do
        table.insert(abilityIds, id)
        table.insert(abilityNames, string.format("%s (%d)", GetAbilityName(id) or "", id))
    end
    CrutchAlerts_AbilitiesToReplace:UpdateChoices(abilityNames, abilityIds)
end

------------------
local function UnlockUI(value)
    Crutch.unlock = value
    CrutchAlertsContainer:SetMovable(value)
    CrutchAlertsContainer:SetMouseEnabled(value)
    CrutchAlertsContainerBackdrop:SetHidden(not value)
    if (value) then
        Crutch.DisplayNotification(47898, "Example Alert", 5000, 0, 0, 0, 0, 0, 0, 0, false)
    end

    CrutchAlertsDamageable:SetMovable(value)
    CrutchAlertsDamageable:SetMouseEnabled(value)
    CrutchAlertsDamageableBackdrop:SetHidden(not value)
    CrutchAlertsDamageableLabel:SetHidden(not value)
    if (value) then
        Crutch.DisplayDamageable(10)
    end

    CrutchAlertsCloudrest:SetMovable(value)
    CrutchAlertsCloudrest:SetMouseEnabled(value)
    CrutchAlertsCloudrestBackdrop:SetHidden(not value)
    if (value) then
        Crutch.UpdateSpearsDisplay(3, 2, 1)
    else
        Crutch.UpdateSpearsDisplay(0, 0, 0)
    end

    CrutchAlertsBossHealthBarContainer:SetMovable(value)
    CrutchAlertsBossHealthBarContainer:SetMouseEnabled(value)
    CrutchAlertsBossHealthBarContainer:SetHidden(not value)
    if (value and Crutch.savedOptions.bossHealthBar.enabled) then
        Crutch.BossHealthBar.ShowOrHideBars(true, false)
    else
        Crutch.BossHealthBar.ShowOrHideBars()
    end

    CrutchAlertsCausticCarrion:SetMovable(value)
    CrutchAlertsCausticCarrion:SetMouseEnabled(value)
    CrutchAlertsCausticCarrion:SetHidden(not value)

    CrutchAlertsMawOfLorkhaj:SetMovable(value)
    CrutchAlertsMawOfLorkhaj:SetMouseEnabled(value)
    CrutchAlertsMawOfLorkhaj:SetHidden(not value)

    CrutchAlertsInfoPanel:SetMovable(value)
    CrutchAlertsInfoPanel:SetMouseEnabled(value)
    if (value) then
        CrutchAlertsInfoPanel:SetHidden(false)
        Crutch.InfoPanel.SetLine(998, "Info Panel Line 1")
        Crutch.InfoPanel.CountDownDuration(999, "Portal 1: ", 10000)
    else
        Crutch.InfoPanel.RemoveLine(998)
        Crutch.InfoPanel.StopCount(999)
    end
end
Crutch.UnlockUI = UnlockUI

function Crutch:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "|c08BD1DCrutchAlerts|r",
        author = "Kyzeragon",
        version = Crutch.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = "Unlock UI",
            tooltip = "Unlock the frames for moving.\nShortcuts: |c99FF99/crutch lock|r and |c99FF99/crutch unlock|r",
            default = false,
            getFunc = function() return Crutch.unlock end,
            setFunc = UnlockUI,
            width = "full",
        },
---------------------------------------------------------------------
-- general
        {
            type = "submenu",
            name = "General",
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
                    name = "      Show non-enemy casts",
                    tooltip = "Show alerts for beginning of a cast if it is not from an enemy, e.g. player-sourced",
                    default = true,
                    getFunc = function() return not Crutch.savedOptions.general.beginHideSelf end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.beginHideSelf = not value
                        -- Re-register with filters
                        Crutch.UnregisterBegin()
                        Crutch.RegisterBegin()
                    end,
                    width = "full",
                    disabled = function() return not Crutch.savedOptions.general.showBegin end
                },
                {
                    type = "checkbox",
                    name = "Show gained casts",
                    tooltip = "Show alerts when you \"Gain\" a cast from an enemy (ACTION_RESULT_GAINED or manually curated ACTION_RESULT_GAINED_DURATION)",
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
                    name = "Show casts on others",
                    tooltip = "Show alerts when someone else in your group is targeted by a specific ability, or in some cases, when the enemy casts something on themselves. This is a manually curated list of abilities that are important enough to affect you, for example the Llothis cone (Defiling Dye Blast) or Rakkhat's kite (Darkness Falls)",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.general.showOthers end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.showOthers = value
                        Crutch.RegisterOthers()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Alert size",
                    tooltip = "The size to display the general alerts specified above",
                    min = 5,
                    max = 120,
                    step = 1,
                    default = 36,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.general.alertScale end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.alertScale = value
                        Crutch.DisplayNotification(47898, "Example Alert", 5000, 0, 0, 0, 0, 0, 0, 0, false)
                    end,
                },
                {
                    type = "checkbox",
                    name = "Show damageable timers",
                    tooltip = "For certain encounters, show a countdown to when the boss or important adds will become damageable, tauntable, return to the arena, etc. This works best on English client, with some support for other languages.",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.general.showDamageable end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.showDamageable = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "    Consolidate damageable to info panel",
                    tooltip = "Shows the damageable timers in the info panel, instead of as its own UI element",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.general.consolidateDamageableInInfoPanel end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.consolidateDamageableInInfoPanel = value
                    end,
                    width = "full",
                    disabled = function() return not Crutch.savedOptions.general.showDamageable end,
                },
                {
                    type = "divider",
                },
                {
                    type = "checkbox",
                    name = "Show arcanist timers",
                    tooltip = "Show \"alert\" timers for arcanist-specific channeled abilities that you cast, i.e. Fatecarver and Remedy Cascade",
                    default = true,
                    getFunc = function() return not Crutch.savedOptions.general.beginHideArcanist end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.beginHideArcanist = not value
                        Crutch.UnregisterFatecarver()
                        Crutch.RegisterFatecarver()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show dragonknight Magma Shell",
                    tooltip = "Show an \"alert\" timer for Magma Shell",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.general.effectMagmaShell end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.effectMagmaShell = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show templar Radiant Destruction",
                    tooltip = "Show \"alert\" timers for Radiant Destruction and morphs",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.general.showJBeam end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.showJBeam = value
                        Crutch.UnregisterFatecarver()
                        Crutch.RegisterFatecarver()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Fencer's Parry",
                    tooltip = "Show an \"alert\" timer for the duration of Fencer's Parry from scribing, along with when it is removed",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.general.effectParry end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.effectParry = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "submenu",
                    name = "Advanced IDs",
                    controls = {
                        {
                            type = "description",
                            text = "You can adjust the abilities that are shown in the general alerts here. This includes the casts on yourself and others as listed above. To find IDs, you can turn on |c99FF99CrutchAlerts > Debug > Show debug on alert|r, and the ID is the first number shown on the small gray text under the alert (ignore fake IDs starting with 888). Alternatively, you can find IDs from online sources such as ESOLogs, player-maintained spreadsheets, or UESP.",
                            width = "full",
                        },
                        {
                            type = "editbox",
                            name = "Blacklist IDs, separated by commas",
                            tooltip = "IDs added to this blacklist will no longer be shown in \"begin casts,\" \"gained casts,\" and \"casts on others.\" For example, to suppress Bahsei HM portal direction alerts, add 153517,153518",
                            default = "",
                            getFunc = function()
                                local str = ""
                                for id, _ in pairs(Crutch.savedOptions.general.blacklist) do
                                    str = string.format("%s%d, ", str, id)
                                end
                                return str
                            end,
                            setFunc = function(value)
                                local ids = {}
                                for _, id in ipairs({zo_strsplit(",", value)}) do
                                    id = tonumber(id)
                                    if (id) then
                                        ids[id] = true
                                    end
                                end
                                Crutch.savedOptions.general.blacklist = ids
                            end,
                            isExtraWide = true,
                            isMultiline = true,
                            width = "full",
                        },
                        {
                            type = "description",
                            text = function()
                                local str = "Current blacklist: "
                                for id, _ in pairs(Crutch.savedOptions.general.blacklist) do
                                    str = string.format("%s%s (%d), ", str, GetAbilityName(id) or "INVALID", id)
                                end
                                return str
                            end,
                            width = "full",
                        },
                    },
                },
            }
        },
-- boss health bar
        {
            type = "submenu",
            name = "Vertical Boss Health Bar",
            controls = {
                {
                    type = "checkbox",
                    name = "Show boss health bar",
                    tooltip = "Show vertical boss health bars with markers for percentage based mechanics",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.bossHealthBar.enabled end,
                    setFunc = function(value)
                        Crutch.savedOptions.bossHealthBar.enabled = value
                        Crutch.BossHealthBar.Initialize()
                        Crutch.BossHealthBar.UpdateScale()
                        CrutchAlertsBossHealthBarContainer:SetHidden(not value)
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Use horizontal bars",
                    tooltip = "Show the boss health bars from left to right instead of vertical. Warning: this is just a naive UI element rotation with some adjustments, so there may be things that display weirdly",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.bossHealthBar.horizontal end,
                    setFunc = function(value)
                        Crutch.savedOptions.bossHealthBar.horizontal = value
                        Crutch.BossHealthBar.UpdateRotation(true)
                        CrutchAlertsBossHealthBarContainer:SetHidden(false)
                    end,
                    width = "full",
                    disabled = function() return not Crutch.savedOptions.bossHealthBar.enabled end,
                },
                {
                    type = "slider",
                    name = "Size",
                    tooltip = "The size to display the vertical boss health bars. Note: some elements may not update size properly until a reload",
                    min = 5,
                    max = 20,
                    step = 1,
                    default = 10,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.bossHealthBar.scale * 10 end,
                    setFunc = function(value)
                        Crutch.savedOptions.bossHealthBar.scale = value / 10
                        Crutch.BossHealthBar.UpdateScale()
                        CrutchAlertsBossHealthBarContainer:SetHidden(false)
                    end,
                    disabled = function() return not Crutch.savedOptions.bossHealthBar.enabled end,
                },
                {
                    type = "colorpicker",
                    name = "Foreground color",
                    tooltip = "Foreground color of the bars. Does not apply to special cases like OC titans and AS minis. Note that this color includes opacity, so it may appear darker in the settings menu than it actually is",
                    default = ZO_ColorDef:New(unpack(Crutch.defaultOptions.bossHealthBar.foreground)),
                    getFunc = function() return unpack(Crutch.savedOptions.bossHealthBar.foreground) end,
                    setFunc = function(r, g, b, a)
                        Crutch.savedOptions.bossHealthBar.foreground = {r, g, b, a}
                        Crutch.BossHealthBar.UpdateColors()
                        CrutchAlertsBossHealthBarContainer:SetHidden(false)
                    end,
                    width = "half",
                },
                {
                    type = "colorpicker",
                    name = "Background color",
                    tooltip = "Background color of the bars. Does not apply to special cases like OC titans and AS minis. Note that this color includes opacity, so it may appear darker in the settings menu than it actually is",
                    default = ZO_ColorDef:New(unpack(Crutch.defaultOptions.bossHealthBar.background)),
                    getFunc = function() return unpack(Crutch.savedOptions.bossHealthBar.background) end,
                    setFunc = function(r, g, b, a)
                        Crutch.savedOptions.bossHealthBar.background = {r, g, b, a}
                        Crutch.BossHealthBar.UpdateColors()
                        CrutchAlertsBossHealthBarContainer:SetHidden(false)
                    end,
                    width = "half",
                },
                {
                    type = "checkbox",
                    name = "Use \"floor\" rounding",
                    tooltip = "Whether to use the \"floor\" or \"half round up\" rounding method to display boss health %.\n\nTurning this ON means the displayed health will be more accurate relative to the mechanic % labels.\n\nTurning this OFF means the displayed health will match the rest of the UI, including the default target attribute bars.\n\nFor more info on why this matters, see the WHY? below.",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.bossHealthBar.useFloorRounding end,
                    setFunc = function(value)
                        Crutch.savedOptions.bossHealthBar.useFloorRounding = value
                    end,
                    disabled = function() return not Crutch.savedOptions.bossHealthBar.enabled end,
                    width = "full",
                },
                {
                    type = "submenu",
                    name = "Rounding: Why?",
                    controls = {
                        {
                            type = "description",
                            text = "Health-based mechanics typically happen at percentages like 50.999%, but the default UI and most addons use \"zo_round\" to round the displayed health percentage. This is the common rounding method, such that 50.4 is rounded to 50, and 50.5 is rounded to 51. That means when we say a mechanic happens at 50%, it could still be displaying 51% on your UI! But not all 51%s mean that the mechanic is going to trigger either, because 51% is actually anywhere from 50.5% to 51.499%\n\nTo fix this, the \"floor\" rounding option rounds any decimal down to the smaller integer. That means 50.999 is rounded to 50, which lines up with how boss mechanics appear to be triggered. I left the common rounding method as an option though, because some people may prefer to have consistency across their UI, even if the difference is only half a percentage.",
                            width = "full",
                        }
                    },
                },
            }
        },
-- info panel
        {
            type = "submenu",
            name = "Info Panel",
            controls = {
                {
                    type = "slider",
                    name = "Size",
                    tooltip = "The size to display the info panel. The info panel is used to display some timers or other info, such as when a boss can cast the next mechanic",
                    min = 5,
                    max = 120,
                    step = 1,
                    default = 30,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.infoPanel.size end,
                    setFunc = function(value)
                        Crutch.savedOptions.infoPanel.size = value
                        Crutch.InfoPanel.ApplyStyle()
                        CrutchAlertsInfoPanel:SetHidden(false)
                        Crutch.InfoPanel.CountDownHardStop(998, "Info Panel Line 1", 10000, false)
                        Crutch.InfoPanel.CountDownHardStop(999, "Portal 1: ", 10000, true)
                    end,
                },
            },
        },
-- in-world icons
        {
            type = "submenu",
            name = "In-World Icons / Textures",
            controls = {
                {
                    type = "description",
                    text = "Crutch can use the 3D API to draw textures (mostly single icons) in the world, including ones attached to players, as well as on the ground for positioning or other mechanics. Note that in order for these icons to be occluded by game objects, e.g. not show behind walls, you must have \"SubSampling Quality\" set to \"High\" in your Video settings.",
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Update interval",
                    tooltip = "How often to update icons to follow players or face the camera, in milliseconds. Smaller interval appears smoother, but may reduce performance. Set to 0 to update every frame",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = Crutch.defaultOptions.drawing.interval,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.drawing.interval end,
                    setFunc = function(value)
                        Crutch.savedOptions.drawing.interval = value
                        Crutch.Drawing.ForceRestartPolling()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Use drawing levels",
                    tooltip = "Whether to show closer icons on top of farther icons. If OFF, icons may appear somewhat out of order when viewing one on top of another, or have transparent edges that clip other icons. If ON, there may be a slight performance reduction",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.drawing.useLevels end,
                    setFunc = function(value)
                        Crutch.savedOptions.drawing.useLevels = value
                    end,
                    width = "full",
                },
                -- Attached icons
                {
                    type = "submenu",
                    name = "Group Member Icons",
                    controls = {
                        {
                            type = "description",
                            text = "These are settings for icons attached to group members, which will also apply to icons shown from mechanics, such as MoL twins Aspects.",
                            width = "full",
                        },
                        {
                            type = "checkbox",
                            name = "Show group icon for self",
                            tooltip = "Whether to show the role, crown, and death icons for yourself. This setting does not affect icons from mechanics",
                            default = Crutch.defaultOptions.drawing.attached.showSelfRole,
                            getFunc = function() return Crutch.savedOptions.drawing.attached.showSelfRole end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.attached.showSelfRole = value
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Size",
                            tooltip = "General size of icons. Mechanic icons may display different sizes",
                            min = 0,
                            max = 400,
                            step = 10,
                            default = Crutch.defaultOptions.drawing.attached.size,
                            width = "full",
                            getFunc = function() return Crutch.savedOptions.drawing.attached.size end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.attached.size = value
                                Crutch.Drawing.RefreshGroup()
                            end,
                        },
                        {
                            type = "slider",
                            name = "Vertical offset",
                            tooltip = "Y coordinate offset for non-death icons",
                            min = 0,
                            max = 500,
                            step = 25,
                            default = Crutch.defaultOptions.drawing.attached.yOffset,
                            width = "full",
                            getFunc = function() return Crutch.savedOptions.drawing.attached.yOffset end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.attached.yOffset = value
                                Crutch.Drawing.RefreshGroup()
                            end,
                        },
                        {
                            type = "slider",
                            name = "Opacity",
                            tooltip = "How transparent the icons are. Mechanic icons may display differently",
                            min = 0,
                            max = 100,
                            step = 5,
                            default = Crutch.defaultOptions.drawing.attached.opacity * 100,
                            width = "full",
                            getFunc = function() return Crutch.savedOptions.drawing.attached.opacity * 100 end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.attached.opacity = value / 100
                                Crutch.Drawing.RefreshGroup()
                            end,
                        },
                        {
                            type = "checkbox",
                            name = "Hide icons behind objects",
                            tooltip = "Whether to use depth buffers to have icons be hidden by objects. For example, if this is ON, you won't be able to see the icon behind a tree. In order for this setting to work while ON, you must have \"SubSampling Quality\" set to \"High\" in your Video settings",
                            default = Crutch.defaultOptions.drawing.attached.useDepthBuffers,
                            getFunc = function() return Crutch.savedOptions.drawing.attached.useDepthBuffers end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.attached.useDepthBuffers = value
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "full",
                        },
                        {
                            type = "divider",
                        },
                        {
                            type = "checkbox",
                            name = "Show tanks",
                            tooltip = "Whether to show tank icons for group members with LFG role set as tank",
                            default = Crutch.defaultOptions.drawing.attached.showTank,
                            getFunc = function() return Crutch.savedOptions.drawing.attached.showTank end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.attached.showTank = value
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "half",
                        },
                        {
                            type = "colorpicker",
                            name = "Tank color",
                            tooltip = "Color of the tank icons",
                            default = ZO_ColorDef:New(unpack(Crutch.defaultOptions.drawing.attached.tankColor)),
                            getFunc = function() return unpack(Crutch.savedOptions.drawing.attached.tankColor) end,
                            setFunc = function(r, g, b)
                                Crutch.savedOptions.drawing.attached.tankColor = {r, g, b}
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "half",
                            disabled = function() return not Crutch.savedOptions.drawing.attached.showTank end
                        },
                        {
                            type = "checkbox",
                            name = "Show healers",
                            tooltip = "Whether to show healer icons for group members with LFG role set as healer",
                            default = Crutch.defaultOptions.drawing.attached.showHeal,
                            getFunc = function() return Crutch.savedOptions.drawing.attached.showHeal end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.attached.showHeal = value
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "half",
                        },
                        {
                            type = "colorpicker",
                            name = "Healer color",
                            tooltip = "Color of the healer icons",
                            default = ZO_ColorDef:New(unpack(Crutch.defaultOptions.drawing.attached.healColor)),
                            getFunc = function() return unpack(Crutch.savedOptions.drawing.attached.healColor) end,
                            setFunc = function(r, g, b)
                                Crutch.savedOptions.drawing.attached.healColor = {r, g, b}
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "half",
                            disabled = function() return not Crutch.savedOptions.drawing.attached.showHeal end
                        },
                        {
                            type = "checkbox",
                            name = "Show DPS",
                            tooltip = "Whether to show DPS icons for group members with LFG role set as DPS",
                            default = Crutch.defaultOptions.drawing.attached.showDps,
                            getFunc = function() return Crutch.savedOptions.drawing.attached.showDps end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.attached.showDps = value
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "half",
                        },
                        {
                            type = "colorpicker",
                            name = "DPS color",
                            tooltip = "Color of the DPS icons",
                            default = ZO_ColorDef:New(unpack(Crutch.defaultOptions.drawing.attached.dpsColor)),
                            getFunc = function() return unpack(Crutch.savedOptions.drawing.attached.dpsColor) end,
                            setFunc = function(r, g, b)
                                Crutch.savedOptions.drawing.attached.dpsColor = {r, g, b}
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "half",
                            disabled = function() return not Crutch.savedOptions.drawing.attached.showDps end
                        },
                        {
                            type = "checkbox",
                            name = "Show crown",
                            tooltip = "Whether to show a crown icon for the group leader",
                            default = Crutch.defaultOptions.drawing.attached.showCrown,
                            getFunc = function() return Crutch.savedOptions.drawing.attached.showCrown end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.attached.showCrown = value
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "half",
                        },
                        {
                            type = "colorpicker",
                            name = "Crown color",
                            tooltip = "Color of the crown icon",
                            default = ZO_ColorDef:New(unpack(Crutch.defaultOptions.drawing.attached.crownColor)),
                            getFunc = function() return unpack(Crutch.savedOptions.drawing.attached.crownColor) end,
                            setFunc = function(r, g, b)
                                Crutch.savedOptions.drawing.attached.crownColor = {r, g, b}
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "half",
                            disabled = function() return not Crutch.savedOptions.drawing.attached.showCrown end
                        },
                        {
                            type = "divider",
                        },
                        {
                            type = "checkbox",
                            name = "Show dead group members",
                            tooltip = "Whether to show skull icons for group members who are deadge",
                            default = Crutch.defaultOptions.drawing.attached.showDead,
                            getFunc = function() return Crutch.savedOptions.drawing.attached.showDead end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.attached.showDead = value
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "half",
                        },
                        {
                            type = "checkbox",
                            name = "Use support icons for dead",
                            tooltip = "When a tank or healer is dead, use the respective role icons instead of the skull icon, to make it easier to prioritize their rezzes",
                            default = Crutch.defaultOptions.drawing.attached.useSupportIconsForDead,
                            getFunc = function() return Crutch.savedOptions.drawing.attached.useSupportIconsForDead end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.attached.useSupportIconsForDead = value
                                Crutch.Drawing.RefreshGroup()
                            end,
                            disabled = function() return not Crutch.savedOptions.drawing.attached.showDead end,
                            width = "half",
                        },
                        {
                            type = "colorpicker",
                            name = "Dead color",
                            tooltip = "Color of the dead player icons",
                            default = ZO_ColorDef:New(unpack(Crutch.defaultOptions.drawing.attached.deadColor)),
                            getFunc = function() return unpack(Crutch.savedOptions.drawing.attached.deadColor) end,
                            setFunc = function(r, g, b)
                                Crutch.savedOptions.drawing.attached.deadColor = {r, g, b}
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "half",
                            disabled = function() return not Crutch.savedOptions.drawing.attached.showDead end
                        },
                        {
                            type = "colorpicker",
                            name = "Resurrecting color",
                            tooltip = "Color of the dead player icons while being resurrected",
                            default = ZO_ColorDef:New(unpack(Crutch.defaultOptions.drawing.attached.rezzingColor)),
                            getFunc = function() return unpack(Crutch.savedOptions.drawing.attached.rezzingColor) end,
                            setFunc = function(r, g, b)
                                Crutch.savedOptions.drawing.attached.rezzingColor = {r, g, b}
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "half",
                            disabled = function() return not Crutch.savedOptions.drawing.attached.showDead end
                        },
                        {
                            type = "colorpicker",
                            name = "Rez pending color",
                            tooltip = "Color of the dead player icons when resurrection is pending",
                            default = ZO_ColorDef:New(unpack(Crutch.defaultOptions.drawing.attached.pendingColor)),
                            getFunc = function() return unpack(Crutch.savedOptions.drawing.attached.pendingColor) end,
                            setFunc = function(r, g, b)
                                Crutch.savedOptions.drawing.attached.pendingColor = {r, g, b}
                                Crutch.Drawing.RefreshGroup()
                            end,
                            width = "half",
                            disabled = function() return not Crutch.savedOptions.drawing.attached.showDead end
                        },
                        {
                            type = "submenu",
                            name = "Individual Player Icons",
                            controls = {
                                -- Attached Individual Icons
                                {
                                    type = "description",
                                    text = "You can add individual icons for specific players here when they are in your group. They show over role and crown icons, while death and mechanic icons show over the individual icons. Note: these icons will always show on top of objects.",
                                    width = "full",
                                },
                                {
                                    type = "editbox",
                                    name = "Add new player icon",
                                    tooltip = "Add a new individual player icon by typing the full account name here, e.g. @Kyzeragon. Case sensitive! If you set an icon for yourself, it will only show if you have \"Show group icon for self\" enabled under Group Member Icons settings",
                                    getFunc = function() return "" end,
                                    setFunc = function(name)
                                        if (not name or name == "") then return end

                                        if (not Crutch.savedOptions.drawing.attached.individualIcons[name]) then
                                            Crutch.AddIndividualIcon(name)
                                        end

                                        selectedIndividual = name

                                        CrutchAlerts_IndividualIconsAddEditbox.editbox:SetText("")
                                    end,
                                    isMultiline = false,
                                    isExtraWide = false,
                                    width = "full",
                                    reference = "CrutchAlerts_IndividualIconsAddEditbox",
                                },
                                {
                                    type = "divider",
                                    width = "half",
                                },
                                {
                                    type = "dropdown",
                                    name = "Select player to edit",
                                    tooltip = "Choose a player to edit individual icon for",
                                    choices = {},
                                    getFunc = function()
                                        RefreshIndividualIconNames()
                                        CrutchAlerts_IndividualIconsDropdown:UpdateChoices(individualNames, individualNames)
                                        return selectedIndividual
                                    end,
                                    setFunc = function(value)
                                        selectedIndividual = value
                                    end,
                                    width = "full",
                                    reference = "CrutchAlerts_IndividualIconsDropdown",
                                },
                                {
                                    type = "button",
                                    name = "Delete player icon",
                                    tooltip = "Delete this individual player icon. This cannot be undone!",
                                    func = function()
                                        Crutch.RemoveIndividualIcon(selectedIndividual)
                                        Crutch.Drawing.RefreshGroup()

                                        selectedIndividual = nil

                                        RefreshIndividualIconNames()
                                        CrutchAlerts_IndividualIconsDropdown:UpdateChoices(individualNames, individualNames)
                                    end,
                                    warning = "Delete this individual player icon. This cannot be undone!",
                                    isDangerous = true,
                                    width = "full",
                                    disabled = function() return selectedIndividual == nil end,
                                },
                                {
                                    type = "divider",
                                },
                                {
                                    type = "dropdown",
                                    name = "Texture type",
                                    tooltip = "The base icon texture to display for this player. If choosing LibCustomIcons, you must have LibCustomIcons enabled, or the icon will be blank (but still override role icons)",
                                    choices = {
                                        C.ICON_NONE,
                                        C.CIRCLE,
                                        C.DIAMOND,
                                        C.CHEVRON,
                                        C.CHEVRON_THIN,
                                        C.LCI,
                                        C.CUSTOM,
                                    },
                                    getFunc = function()
                                        if (selectedIndividual) then
                                            return Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].type
                                        end
                                    end,
                                    setFunc = function(value)
                                        Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].type = value
                                        Crutch.Drawing.RefreshGroup()
                                    end,
                                    width = "full",
                                    disabled = function() return selectedIndividual == nil end,
                                },
                                {
                                    type = "editbox",
                                    name = "Custom texture path",
                                    tooltip = "If using a \"Custom texture,\" the path of the texture. You can use base game textures or even textures from other addons. Examples: esoui/art/icons/targetdummy_voriplasm_01.dds or CrutchAlerts/assets/poop.dds\n\nFor base game textures, you can find them by using an addon like Circonians TextureIt, or online sources like UESP.\nFor addon textures, you can find them by browsing to the addon files and seeing where the files are, and using the same path, such as the CrutchAlerts poop path above, or OdySupportIcons/icons/lightning-bolt.dds",
                                    getFunc = function()
                                        if (selectedIndividual) then
                                            return Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].custom
                                        end
                                    end,
                                    setFunc = function(path)
                                        Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].custom = path
                                        Crutch.Drawing.RefreshGroup()
                                    end,
                                    isMultiline = false,
                                    isExtraWide = true,
                                    width = "full",
                                    disabled = function() return selectedIndividual == nil or Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].type ~= C.CUSTOM end,
                                },
                                {
                                    type = "colorpicker",
                                    name = "Texture color",
                                    tooltip = "Color of the icon texture",
                                    getFunc = function()
                                        if (selectedIndividual) then
                                            return unpack(Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].color)
                                        end
                                    end,
                                    setFunc = function(r, g, b, a)
                                        Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].color = {r, g, b, a}
                                        Crutch.Drawing.RefreshGroup()
                                    end,
                                    width = "half",
                                    disabled = function() return selectedIndividual == nil end,
                                },
                                {
                                    type = "slider",
                                    name = "Texture size",
                                    tooltip = "Size of icon texture",
                                    min = 0,
                                    max = 400,
                                    step = 10,
                                    getFunc = function()
                                        if (selectedIndividual) then
                                            return Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].size * 100
                                        end
                                    end,
                                    setFunc = function(value)
                                        Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].size = value / 100
                                        Crutch.Drawing.RefreshGroup()
                                    end,
                                    width = "half",
                                    disabled = function() return selectedIndividual == nil end,
                                },
                                {
                                    type = "divider",
                                    width = "half",
                                },
                                {
                                    type = "editbox",
                                    name = "Text",
                                    tooltip = "The text that appears on the icon",
                                    getFunc = function()
                                        if (selectedIndividual) then
                                            return Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].text
                                        end
                                    end,
                                    setFunc = function(text)
                                        Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].text = text
                                        Crutch.Drawing.RefreshGroup()
                                    end,
                                    isMultiline = true,
                                    isExtraWide = true,
                                    width = "full",
                                    disabled = function() return selectedIndividual == nil end,
                                },
                                {
                                    type = "colorpicker",
                                    name = "Text color",
                                    tooltip = "Color of the text",
                                    getFunc = function()
                                        if (selectedIndividual) then
                                            return unpack(Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].textColor)
                                        end
                                    end,
                                    setFunc = function(r, g, b, a)
                                        Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].textColor = {r, g, b, a}
                                        Crutch.Drawing.RefreshGroup()
                                    end,
                                    width = "half",
                                    disabled = function()
                                        if (selectedIndividual == nil) then return true end
                                        local text = Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].text
                                        return text == nil or text == ""
                                    end,
                                },
                                {
                                    type = "slider",
                                    name = "Text size",
                                    tooltip = "Size of the text",
                                    min = 0,
                                    max = 200,
                                    step = 1,
                                    getFunc = function()
                                        if (selectedIndividual) then
                                            return Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].textSize
                                        end
                                    end,
                                    setFunc = function(value)
                                        Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].textSize = value
                                        Crutch.Drawing.RefreshGroup()
                                    end,
                                    width = "half",
                                    disabled = function()
                                        if (selectedIndividual == nil) then return true end
                                        local text = Crutch.savedOptions.drawing.attached.individualIcons[selectedIndividual].text
                                        return text == nil or text == ""
                                    end,
                                }
                                -- TODO: a preview maybe?
                            },
                        },
                    },
                },
                -- placedPositioning icons
                {
                    type = "submenu",
                    name = "Positioning Markers",
                    controls = {
                        {
                            type = "description",
                            text = "These are settings for positioning-type markers placed on the ground, such as Lokkestiiz HM beam phase and Xoryn Tempest positions.",
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Opacity",
                            tooltip = "How transparent the markers are. Mechanic markers may display differently",
                            min = 0,
                            max = 100,
                            step = 5,
                            default = Crutch.defaultOptions.drawing.placedPositioning.opacity * 100,
                            width = "full",
                            getFunc = function() return Crutch.savedOptions.drawing.placedPositioning.opacity * 100 end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.placedPositioning.opacity = value / 100
                                Crutch.OnPlayerActivated()
                            end,
                        },
                        {
                            type = "checkbox",
                            name = "Hide icons behind objects",
                            tooltip = "Whether to use depth buffers to have icons be hidden by objects. For example, if this is ON, you won't be able to see the icon behind a tree. In order for this setting to work while ON, you must have \"SubSampling Quality\" set to \"High\" in your Video settings. Some markers, mainly ones that use text labels, will always show on top of objects regardless of this setting because of API limitations.",
                            default = Crutch.defaultOptions.drawing.placedPositioning.useDepthBuffers,
                            getFunc = function() return Crutch.savedOptions.drawing.placedPositioning.useDepthBuffers end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.placedPositioning.useDepthBuffers = value
                                Crutch.OnPlayerActivated()
                            end,
                            width = "full",
                        },
                        {
                            type = "checkbox",
                            name = "Use flat icons",
                            tooltip = "Whether to have icons lie flat on the ground, instead of facing the camera. No guarantees of being easy to read; they are upright when you are facing directly north",
                            default = Crutch.defaultOptions.drawing.placedPositioning.flat,
                            getFunc = function() return Crutch.savedOptions.drawing.placedPositioning.flat end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.placedPositioning.flat = value
                                Crutch.OnPlayerActivated()
                            end,
                            width = "full",
                        },
                    },
                },
                -- placedOriented icons
                {
                    type = "submenu",
                    name = "Oriented Textures",
                    controls = {
                        {
                            type = "description",
                            text = "These are settings for various textures that are drawn in the world, that are oriented in a certain way, instead of always facing the player. For example, circles drawn on the ground, like in HoF triplets, fall under this category.",
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Opacity",
                            tooltip = "How transparent the textures are. Mechanic textures may display differently",
                            min = 0,
                            max = 100,
                            step = 5,
                            default = Crutch.defaultOptions.drawing.placedOriented.opacity * 100,
                            width = "full",
                            getFunc = function() return Crutch.savedOptions.drawing.placedOriented.opacity * 100 end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.placedOriented.opacity = value / 100
                                Crutch.OnPlayerActivated()
                            end,
                        },
                        {
                            type = "checkbox",
                            name = "Hide textures behind objects",
                            tooltip = "Whether to use depth buffers to have textures be hidden by objects. For example, if this is ON, you won't be able to see the circle behind a tree. In order for this setting to work while ON, you must have \"SubSampling Quality\" set to \"High\" in your Video settings",
                            default = Crutch.defaultOptions.drawing.placedOriented.useDepthBuffers,
                            getFunc = function() return Crutch.savedOptions.drawing.placedOriented.useDepthBuffers end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.placedOriented.useDepthBuffers = value
                                Crutch.OnPlayerActivated()
                            end,
                            width = "full",
                        },
                    },
                },
                -- placedIcon icons
                {
                    type = "submenu",
                    name = "Other Icons",
                    controls = {
                        {
                            type = "description",
                            text = "These are settings for other icons that appear to face the player, such as thrown potions from IA Brewmasters.",
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Opacity",
                            tooltip = "How transparent the icons are. Mechanic icons may display differently",
                            min = 0,
                            max = 100,
                            step = 5,
                            default = Crutch.defaultOptions.drawing.placedIcon.opacity * 100,
                            width = "full",
                            getFunc = function() return Crutch.savedOptions.drawing.placedIcon.opacity * 100 end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.placedIcon.opacity = value / 100
                                Crutch.OnPlayerActivated()
                            end,
                        },
                        {
                            type = "checkbox",
                            name = "Hide icons behind objects",
                            tooltip = "Whether to use depth buffers to have icons be hidden by objects. For example, if this is ON, you won't be able to see the icon behind a tree. In order for this setting to work while ON, you must have \"SubSampling Quality\" set to \"High\" in your Video settings",
                            default = Crutch.defaultOptions.drawing.placedIcon.useDepthBuffers,
                            getFunc = function() return Crutch.savedOptions.drawing.placedIcon.useDepthBuffers end,
                            setFunc = function(value)
                                Crutch.savedOptions.drawing.placedIcon.useDepthBuffers = value
                                Crutch.OnPlayerActivated()
                            end,
                            width = "full",
                        },
                    },
                },
            },
        },
-- misc
        {
            type = "submenu",
            name = "Miscellaneous",
            controls = {
                {
                    type = "checkbox",
                    name = "Show subtitles in chat",
                    tooltip = "Show NPC dialogue subtitles in chat. The color formatting will be weird if there are multiple lines",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.showSubtitles end,
                    setFunc = function(value)
                        Crutch.savedOptions.showSubtitles = value
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "No-subtitles zones",
                    tooltip = "Subtitles will not be displayed in chat while in these zones. Select one from this dropdown to remove it",
                    choices = {},
                    choicesValues = {},
                    getFunc = function()
                        local ids, names = GetNoSubtitlesZoneIdsAndNames()
                        CrutchAlerts_NoSubtitlesZones:UpdateChoices(names, ids)
                    end,
                    setFunc = function(value)
                        Crutch.savedOptions.subtitlesIgnoredZones[value] = nil
                        CHAT_ROUTER:AddSystemMessage(string.format("Removed %s(%d) from subtitles ignored zones.", GetZoneNameById(value), value))
                        local ids, names = GetNoSubtitlesZoneIdsAndNames()
                        CrutchAlerts_NoSubtitlesZones:UpdateChoices(names, ids)
                    end,
                    width = "full",
                    reference = "CrutchAlerts_NoSubtitlesZones",
                    disabled = function() return not Crutch.savedOptions.showSubtitles end,
                },
                {
                    type = "editbox",
                    name = "Add no-subtitles zone ID",
                    tooltip = "Enter a zone ID to add to the ignore list",
                    getFunc = function()
                        return ""
                    end,
                    setFunc = function(value)
                        local zoneId = tonumber(value)
                        local zoneName = GetZoneNameById(zoneId)
                        if (not zoneId or not zoneName or zoneName == "") then
                            CHAT_ROUTER:AddSystemMessage(value .. " is not a valid zone ID!")
                            return
                        end
                        Crutch.savedOptions.subtitlesIgnoredZones[zoneId] = true
                        CHAT_ROUTER:AddSystemMessage(string.format("Added %s(%d) to subtitles ignored zones.", zoneName, zoneId))
                    end,
                    isMultiline = false,
                    isExtraWide = false,
                    width = "full",
                    disabled = function() return not Crutch.savedOptions.showSubtitles end,
                },
            }
        },
-- debug
        {
            type = "submenu",
            name = "Debug",
            controls = {
                {
                    type = "checkbox",
                    name = "Show raid lead diagnostics",
                    tooltip = "Shows possibly spammy info in the text chat when certain important events occur. For example, someone picking up fire dome in DSR",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.general.showRaidDiag end,
                    setFunc = function(value)
                        Crutch.savedOptions.general.showRaidDiag = value
                        Crutch.OnPlayerActivated()
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
                    tooltip = "Display a chat message almost every time any enabled combat event is procced -- very spammy!",
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
                    name = "Show line distance",
                    tooltip = "On mechanics where Crutch draws a line between tethered players, display the distance in meters on the line",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.debugLineDistance end,
                    setFunc = function(value)
                        Crutch.savedOptions.debugLineDistance = value
                    end,
                    width = "full",
                },
            },
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
            name = "Asylum Sanctorium",
            controls = {
                {
                    type = "checkbox",
                    name = "Play sound for cone on self",
                    tooltip = "Play a ding sound when Llothis' Defiling Dye Blast targets you",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.asylumsanctorium.dingSelfCone end,
                    setFunc = function(value)
                        Crutch.savedOptions.asylumsanctorium.dingSelfCone = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Play sound for cone on others",
                    tooltip = "Play a ding sound when Llothis' Defiling Dye Blast targets other players",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.asylumsanctorium.dingOthersCone end,
                    setFunc = function(value)
                        Crutch.savedOptions.asylumsanctorium.dingOthersCone = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show minis' health bars",
                    tooltip = "Shows Felms' and Llothis' health using the vertical boss health bars",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.asylumsanctorium.showMinisHp end,
                    setFunc = function(value)
                        Crutch.savedOptions.asylumsanctorium.showMinisHp = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return not Crutch.savedOptions.bossHealthBar.enabled end,
                },
            }
        },
        {
            type = "submenu",
            name = "Cloudrest",
            controls = Crutch.GetProminentSettings(1051, Crutch.GetEffectSettings(1051, {
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
                {
                    type = "checkbox",
                    name = "Show Hoarfrost timer",
                    tooltip = "Shows a timer for when you can drop Hoarfrost, and a timer after that for when Overwhelming Hoarfrost would kill you (on veteran)",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.cloudrest.showFrostAlert end,
                    setFunc = function(value)
                        Crutch.savedOptions.cloudrest.showFrostAlert = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Alert drop Hoarfrost",
                    tooltip = "Displays a prominent alert and ding sound when you can drop Hoarfrost",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.cloudrest.dropFrostProminent end,
                    setFunc = function(value)
                        Crutch.savedOptions.cloudrest.dropFrostProminent = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Hoarfrost icon",
                    tooltip = "Shows icons above players who currently have Hoarfrost",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.cloudrest.showFrostIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.cloudrest.showFrostIcons = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show flare sides",
                    tooltip = "On Z'Maja during execute with +Siroria, show which side each of the two people with Roaring Flares can go to (will be same sides as RaidNotifier)",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.cloudrest.showFlaresSides end,
                    setFunc = function(value)
                        Crutch.savedOptions.cloudrest.showFlaresSides = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show flare icon",
                    tooltip = "Shows icons above players who are targeted by Roaring Flare",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.cloudrest.showFlareIcon end,
                    setFunc = function(value)
                        Crutch.savedOptions.cloudrest.showFlareIcon = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Color Ody death icon",
                    tooltip = "Colors the OdySupportIcons death icon purple if a player's shade is still up",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.cloudrest.deathIconColor end,
                    setFunc = function(value)
                        Crutch.savedOptions.cloudrest.deathIconColor = value
                    end,
                    width = "full",
                    disabled = function() return OSI == nil or OSI.UnitErrorCheck == nil or OSI.GetIconDataForPlayer == nil end,
                },
            })),
        },
        {
            type = "submenu",
            name = "Dreadsail Reef",
            controls = Crutch.GetProminentSettings(1344, {
                {
                    type = "checkbox",
                    name = "Alert Building Static stacks",
                    tooltip = "Displays a prominent alert and ding sound if you reach too many Building Static (lightning) stacks",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.dreadsailreef.alertStaticStacks end,
                    setFunc = function(value)
                        Crutch.savedOptions.dreadsailreef.alertStaticStacks = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Building Static stacks threshold",
                    tooltip = "The minimum number of stacks of Building Static to show alert for",
                    min = 4,
                    max = 20,
                    step = 1,
                    default = 7,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.dreadsailreef.staticThreshold end,
                    setFunc = function(value)
                        Crutch.savedOptions.dreadsailreef.staticThreshold = value
                    end,
                    disabled = function() return not Crutch.savedOptions.dreadsailreef.alertStaticStacks end,
                },
                {
                    type = "checkbox",
                    name = "Alert Volatile Residue stacks",
                    tooltip = "Displays a prominent alert and ding sound if you reach too many Volatile Residue (poison) stacks",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.dreadsailreef.alertVolatileStacks end,
                    setFunc = function(value)
                        Crutch.savedOptions.dreadsailreef.alertVolatileStacks = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Volatile Residue stacks threshold",
                    tooltip = "The minimum number of stacks of Volatile Residue to show alert for",
                    min = 4,
                    max = 20,
                    step = 1,
                    default = 6,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.dreadsailreef.volatileThreshold end,
                    setFunc = function(value)
                        Crutch.savedOptions.dreadsailreef.volatileThreshold = value
                    end,
                    disabled = function() return not Crutch.savedOptions.dreadsailreef.alertVolatileStacks end,
                },
                {
                    type = "checkbox",
                    name = "Show Arcing Cleave guidelines",
                    tooltip = "Draws guidelines approximating where Taleria's Arcing Cleave will hit. I'm tired of seeing people stand behind tank!",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.dreadsailreef.showArcingCleave end,
                    setFunc = function(value)
                        Crutch.savedOptions.dreadsailreef.showArcingCleave = value
                        Crutch.TryEnablingTaleriaCleave()
                    end,
                    width = "full",
                },
            }),
        },
        {
            type = "submenu",
            name = "Halls of Fabrication",
            controls = Crutch.GetProminentSettings(975, {
                {
                    type = "checkbox",
                    name = "Show Shock Field for triplets",
                    tooltip = "In the triplets fight, shows the approximate outline of Shock Field even when it's not active",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.hallsoffabrication.showTripletsIcon end,
                    setFunc = function(value)
                        Crutch.savedOptions.hallsoffabrication.showTripletsIcon = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Assembly General icons",
                    tooltip = "Shows icons in the world for execute positions",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.hallsoffabrication.showAGIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.hallsoffabrication.showAGIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "    Assembly General icons size",
                    min = 20,
                    max = 300,
                    step = 10,
                    default = 150,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.hallsoffabrication.agIconsSize end,
                    setFunc = function(value)
                        Crutch.savedOptions.hallsoffabrication.agIconsSize = value
                        Crutch.OnPlayerActivated()
                    end,
                    disabled = function() return not Crutch.savedOptions.hallsoffabrication.showAGIcons end,
                },
            }),
        },
        {
            type = "submenu",
            name = "Kyne's Aegis",
            controls = Crutch.GetProminentSettings(1196, {
                {
                    type = "checkbox",
                    name = "Show Exploding Spear landing spot",
                    tooltip = "On trash packs with Half-Giant Raiders, shows circles at the approximate locations where Exploding Spears will land (may vary due to latency)",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.kynesaegis.showSpearIcon end,
                    setFunc = function(value)
                        Crutch.savedOptions.kynesaegis.showSpearIcon = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Blood Prison icon",
                    tooltip = "Shows icon above player who is targeted by Blood Prison, slightly before the bubble even shows up",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.kynesaegis.showPrisonIcon end,
                    setFunc = function(value)
                        Crutch.savedOptions.kynesaegis.showPrisonIcon = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Falgravn 2nd floor DPS stacks",
                    tooltip = "In the Falgravn fight, shows 1~4 DPS in the world for stacks",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.kynesaegis.showFalgravnIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.kynesaegis.showFalgravnIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "    Falgravn icon size",
                    min = 20,
                    max = 300,
                    step = 10,
                    default = 150,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.kynesaegis.falgravnIconsSize end,
                    setFunc = function(value)
                        Crutch.savedOptions.kynesaegis.falgravnIconsSize = value
                        Crutch.OnPlayerActivated()
                    end,
                    disabled = function() return not Crutch.savedOptions.kynesaegis.showFalgravnIcons end,
                },
            }),
        },
        {
            type = "submenu",
            name = "Lucent Citadel",
            controls = Crutch.GetProminentSettings(1478, Crutch.GetEffectSettings(1478, {
                {
                    type = "checkbox",
                    name = "Show Cavot Agnan spawn spot",
                    tooltip = "Shows icon for where Cavot Agnan will spawn",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.lucentcitadel.showCavotIcon end,
                    setFunc = function(value)
                        Crutch.savedOptions.lucentcitadel.showCavotIcon = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "    Cavot Agnan icon size",
                    tooltip = "The size of the icon for Cavot Agnan spawn",
                    min = 20,
                    max = 300,
                    step = 10,
                    default = 100,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.lucentcitadel.cavotIconSize end,
                    setFunc = function(value)
                        Crutch.savedOptions.lucentcitadel.cavotIconSize = value
                        Crutch.OnPlayerActivated()
                    end,
                    disabled = function() return not Crutch.savedOptions.lucentcitadel.showCavotIcon end,
                },
                {
                    type = "checkbox",
                    name = "Show Orphic Shattered Shard mirror icons",
                    tooltip = "Shows icons for each mirror on the Orphic Shattered Shard fight",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.lucentcitadel.showOrphicIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.lucentcitadel.showOrphicIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "    Orphic numbered icons",
                    tooltip = "Uses numbers 1~8 instead of cardinal directions N/SW/etc. for the mirror icons",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.lucentcitadel.orphicIconsNumbers end,
                    setFunc = function(value)
                        Crutch.savedOptions.lucentcitadel.orphicIconsNumbers = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return not Crutch.savedOptions.lucentcitadel.showOrphicIcons end,
                },
                {
                    type = "slider",
                    name = "    Orphic icons size",
                    tooltip = "The size of the mirror icons",
                    min = 20,
                    max = 300,
                    step = 10,
                    default = 150,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.lucentcitadel.orphicIconSize end,
                    setFunc = function(value)
                        Crutch.savedOptions.lucentcitadel.orphicIconSize = value
                        Crutch.OnPlayerActivated()
                    end,
                    disabled = function() return not Crutch.savedOptions.lucentcitadel.showOrphicIcons end,
                },
                {
                    type = "checkbox",
                    name = "Show Arcane Conveyance tether",
                    tooltip = "Shows a line connecting group members who are about to (or have already received) the Arcane Conveyance tether from Dariel Lemonds",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.lucentcitadel.showArcaneConveyance end,
                    setFunc = function(value)
                        Crutch.savedOptions.lucentcitadel.showArcaneConveyance = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Show Weakening Charge timer",
                    tooltip = "Shows an \"alert\" timer for Weakening Charge. If set to \"Tank Only\" it will display only if your LFG role is tank",
                    choices = {"Never", "Tank Only", "Always"},
                    choicesValues = {"NEVER", "TANK", "ALWAYS"},
                    getFunc = function()
                        return Crutch.savedOptions.lucentcitadel.showWeakeningCharge
                    end,
                    setFunc = function(value)
                        Crutch.savedOptions.lucentcitadel.showWeakeningCharge = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Xoryn Tempest position icons",
                    tooltip = "Shows icons for group member positions on the Xoryn fight for Tempest (and at the beginning of the trial, for practice purposes)",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.lucentcitadel.showTempestIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.lucentcitadel.showTempestIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "    Tempest icons size",
                    tooltip = "The size of the Tempest icons",
                    min = 20,
                    max = 300,
                    step = 10,
                    default = 150,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.lucentcitadel.tempestIconsSize end,
                    setFunc = function(value)
                        Crutch.savedOptions.lucentcitadel.tempestIconsSize = value
                        Crutch.OnPlayerActivated()
                    end,
                    disabled = function() return not Crutch.savedOptions.lucentcitadel.showTempestIcons end,
                },
            })),
        },
        {
            type = "submenu",
            name = "Maw of Lorkhaj",
            controls = Crutch.GetProminentSettings(725, Crutch.GetEffectSettings(725, {
                {
                    type = "checkbox",
                    name = "Show Zhaj'hassa cleanse pad cooldowns",
                    tooltip = "In the Zhaj'hassa fight, shows tiles with cooldown timers for 25 seconds (veteran)",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.mawoflorkhaj.showPads end,
                    setFunc = function(value)
                        Crutch.savedOptions.mawoflorkhaj.showPads = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Twins Aspect icons",
                    tooltip = "In the Vashai + S'kinrai fight, shows icons above players' heads with their Shadow or Lunar Aspect",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.mawoflorkhaj.showTwinsIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.mawoflorkhaj.showTwinsIcons = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Twins color swap",
                    tooltip = "In the twins fight, shows a prominent alert when you receive Shadow/Lunar Conversion",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.mawoflorkhaj.prominentColorSwap end,
                    setFunc = function(value)
                        Crutch.savedOptions.mawoflorkhaj.prominentColorSwap = value
                    end,
                    width = "full",
                },
            })),
        },
        {
            type = "submenu",
            name = "Opulent Ordeal",
            controls = Crutch.GetEffectSettings(1565, {
                {
                    type = "checkbox",
                    name = "Show Affinity icons",
                    tooltip = "Shows icons above players' heads with their respective Affinity debuffs",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.opulentordeal.showAffinityIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.opulentordeal.showAffinityIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
            }),
        },
        {
            type = "submenu",
            name = "Ossein Cage",
            controls = {
                {
                    type = "checkbox",
                    name = "Show group-wide Caustic Carrion",
                    tooltip = "Shows a progress bar for the group member with the highest number (and tick progress) of Caustic Carrion stacks. Changes color based on number of stacks, with a lower threshold on Jynorah + Skorkhif at 5 stacks for red",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.osseincage.showCarrion end,
                    setFunc = function(value)
                        Crutch.savedOptions.osseincage.showCarrion = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "    Show additional group members",
                    tooltip = "Shows additional debug-ish text under the Caustic Carrion progress bar for the stacks and tick time of all group members",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.osseincage.showCarrionIndividual end,
                    setFunc = function(value)
                        Crutch.savedOptions.osseincage.showCarrionIndividual = value
                    end,
                    width = "full",
                    disabled = function() return not Crutch.savedOptions.osseincage.showCarrion end
                },
                {
                    type = "checkbox",
                    name = "Show titans' health bars",
                    tooltip = "Shows Blazeforged Valneer's and Sparkstorm Myrinax's health using the vertical boss health bars",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.osseincage.showTitansHp end,
                    setFunc = function(value)
                        Crutch.savedOptions.osseincage.showTitansHp = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return not Crutch.savedOptions.bossHealthBar.enabled end,
                },
                {
                    type = "checkbox",
                    name = "Show curse positioning icons",
                    tooltip = "In the Jynorah + Skorkhif fight, shows icons in the world for close positioning",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.osseincage.showTwinsIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.osseincage.showTwinsIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "    Match AOCH icons",
                    tooltip = "Use icons that match Asquart's Ossein Cage Helper's icons",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.osseincage.useAOCHIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.osseincage.useAOCHIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return not Crutch.savedOptions.osseincage.showTwinsIcons end,
                },
                {
                    type = "checkbox",
                    name = "    Show middle icons",
                    tooltip = "Additionally shows a set of icons for positioning in the middle of the arena",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.osseincage.useMiddleIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.osseincage.useMiddleIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return not Crutch.savedOptions.osseincage.showTwinsIcons end,
                },
                {
                    type = "slider",
                    name = "    Curse positioning icons size",
                    min = 20,
                    max = 300,
                    step = 10,
                    default = 100,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.osseincage.twinsIconsSize end,
                    setFunc = function(value)
                        Crutch.savedOptions.osseincage.twinsIconsSize = value
                        Crutch.OnPlayerActivated()
                    end,
                    disabled = function() return not Crutch.savedOptions.osseincage.showTwinsIcons end,
                },
                {
                    type = "dropdown",
                    name = "Show Enfeeblement debuffs",
                    tooltip = "Shows icons on players afflicted by Sparking Enfeeblement, Blazing Enfeeblement, or both",
                    choices = {"Never", "Hardmode only", "Veteran + Hardmode", "Always"},
                    choicesValues = {"NEVER", "HM", "VET", "ALWAYS"},
                    default = "HM",
                    getFunc = function()
                        return Crutch.savedOptions.osseincage.showEnfeeblementIcons
                    end,
                    setFunc = function(value)
                        Crutch.savedOptions.osseincage.showEnfeeblementIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Print titan damage on HM",
                    tooltip = "On hardmode, prints to chat when you damage a titan, which would proc Reflective Scales. For now, it doesn't print until the titan health bars appear",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.osseincage.printHMReflectiveScales end,
                    setFunc = function(value)
                        Crutch.savedOptions.osseincage.printHMReflectiveScales = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Show Stricken timer",
                    tooltip = "Shows an \"alert\" timer for Stricken. If set to \"Tank Only\" it will display only if your LFG role is tank",
                    choices = {"Never", "Tank Only", "Always"},
                    choicesValues = {"NEVER", "TANK", "ALWAYS"},
                    default = "TANK",
                    getFunc = function()
                        return Crutch.savedOptions.osseincage.showStricken
                    end,
                    setFunc = function(value)
                        Crutch.savedOptions.osseincage.showStricken = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Dominator's Chains tether",
                    tooltip = "Shows a line connecting group members who are about to (or have already received) the Dominator's Chains tether from Overfiend Kazpian",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.osseincage.showChains end,
                    setFunc = function(value)
                        Crutch.savedOptions.osseincage.showChains = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
            },
        },
        {
            type = "submenu",
            name = "Rockgrove",
            controls = Crutch.GetProminentSettings(1263, Crutch.GetEffectSettings(1263, {
                {
                    type = "checkbox",
                    name = "Show Noxious Sludge sides",
                    tooltip = "Displays who should go left and who should go right for Noxious Sludge, matching Qcell's Rockgrove Helper",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.rockgrove.sludgeSides end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.sludgeSides = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Noxious Sludge icons",
                    tooltip = "Shows icons above players who receive Noxious Sludge from Oaxiltso",
                    default = Crutch.defaultOptions.rockgrove.showSludgeIcons,
                    getFunc = function() return Crutch.savedOptions.rockgrove.showSludgeIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.showSludgeIcons = value
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Show Bleeding timer",
                    tooltip = "Shows an \"alert\" timer for Bleeding from Flesh Abominations' Hemorrhaging Smack. If set to \"Self/Heal Only\" it will display only if your LFG role is healer or if the bleed is on yourself",
                    choices = {"Never", "Self/Heal Only", "Always"},
                    choicesValues = {"NEVER", "HEAL", "ALWAYS"},
                    default = "HEAL",
                    getFunc = function()
                        return Crutch.savedOptions.rockgrove.showBleeding
                    end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.showBleeding = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Death Touch icons",
                    tooltip = "Shows icons above group members' heads when they have Death Touch (Bahsei curse), counting down to when they would explode",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.rockgrove.showCurseIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.showCurseIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "description",
                    title = "|c08BD1DInfo Panel|r",
                    text = "Shows timers or other info in a consolidated panel. Unlock the UI or |c99FF99/crutch unlock|r to reposition the info panel.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show time until Noxious Sludge",
                    tooltip = "Shows the time until Oaxiltso may cast the next Noxious Sludge",
                    default = Crutch.defaultOptions.rockgrove.panel.showSludge,
                    getFunc = function() return Crutch.savedOptions.rockgrove.panel.showSludge end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.panel.showSludge = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show time until Savage Blitz",
                    tooltip = "Shows the time until Oaxiltso may make you flat. Hee hee.",
                    default = Crutch.defaultOptions.rockgrove.panel.showBlitz,
                    getFunc = function() return Crutch.savedOptions.rockgrove.panel.showBlitz end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.panel.showBlitz = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show time until portal",
                    tooltip = "Shows portal number and time until Bahsei can spawn the next portal on HM",
                    default = Crutch.defaultOptions.rockgrove.panel.showTimeToPortal,
                    getFunc = function() return Crutch.savedOptions.rockgrove.panel.showTimeToPortal end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.panel.showTimeToPortal = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show portal direction",
                    tooltip = "Shows the direction of the current portal on Bahsei HM",
                    default = Crutch.defaultOptions.rockgrove.panel.showPortalDirection,
                    getFunc = function() return Crutch.savedOptions.rockgrove.panel.showPortalDirection end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.panel.showPortalDirection = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show number of players in portal",
                    tooltip = "Shows the current number of players in portal on Bahsei HM",
                    default = Crutch.defaultOptions.rockgrove.panel.showNumInPortal,
                    getFunc = function() return Crutch.savedOptions.rockgrove.panel.showNumInPortal end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.panel.showNumInPortal = value
                    end,
                    width = "full",
                },
                {
                    type = "description",
                    title = "|c08BD1D[BETA] Curse Lines|r",
                    text = "Shows lines for potential curse AoE trajectories after Death Touch expires. All 4 possible directions are shown, but only 2 directions will have real AoEs.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show your curse preview lines",
                    tooltip = "Shows lines when you have Death Touch, so you can try to position them away from the group",
                    default = Crutch.defaultOptions.rockgrove.showCursePreview,
                    getFunc = function() return Crutch.savedOptions.rockgrove.showCursePreview end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.showCursePreview = value
                    end,
                    width = "half",
                },
                {
                    type = "colorpicker",
                    name = "Preview lines color",
                    tooltip = "Color of the preview lines for yourself",
                    default = ZO_ColorDef:New(unpack(Crutch.defaultOptions.rockgrove.cursePreviewColor)),
                    getFunc = function() return unpack(Crutch.savedOptions.rockgrove.cursePreviewColor) end,
                    setFunc = function(r, g, b, a)
                        Crutch.savedOptions.rockgrove.cursePreviewColor = {r, g, b, a}
                    end,
                    width = "half",
                    disabled = function() return not Crutch.savedOptions.rockgrove.showCursePreview end
                },
                {
                    type = "checkbox",
                    name = "Show your curse lines",
                    tooltip = "Shows lines when your Death Touch expires. The trajectory could be slightly inaccurate due to desync, especially if you're moving fast",
                    default = Crutch.defaultOptions.rockgrove.showCurseLines,
                    getFunc = function() return Crutch.savedOptions.rockgrove.showCurseLines end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.showCurseLines = value
                    end,
                    width = "half",
                },
                {
                    type = "colorpicker",
                    name = "Curse lines color",
                    tooltip = "Color of the curse lines for yourself",
                    default = ZO_ColorDef:New(unpack(Crutch.defaultOptions.rockgrove.curseLineColor)),
                    getFunc = function() return unpack(Crutch.savedOptions.rockgrove.curseLineColor) end,
                    setFunc = function(r, g, b, a)
                        Crutch.savedOptions.rockgrove.curseLineColor = {r, g, b, a}
                    end,
                    width = "half",
                    disabled = function() return not Crutch.savedOptions.rockgrove.showCurseLines end
                },
                {
                    type = "checkbox",
                    name = "Show group members' curse lines",
                    tooltip = "Shows lines when another player's Death Touch expires. The trajectory could be inaccurate due to desync, especially if the player is moving fast. Requires LibGroupBroadcast, and the other players must also have this version of CrutchAlerts with LibGroupBroadcast (they do not need to have curse lines on)",
                    default = Crutch.defaultOptions.rockgrove.showOthersCurseLines,
                    getFunc = function() return Crutch.savedOptions.rockgrove.showOthersCurseLines end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.showOthersCurseLines = value
                    end,
                    width = "half",
                    disabled = function() return LibGroupBroadcast == nil end,
                },
                {
                    type = "colorpicker",
                    name = "Group curse lines color",
                    tooltip = "Color of the curse lines for other group members",
                    default = ZO_ColorDef:New(unpack(Crutch.defaultOptions.rockgrove.othersCurseLineColor)),
                    getFunc = function() return unpack(Crutch.savedOptions.rockgrove.othersCurseLineColor) end,
                    setFunc = function(r, g, b, a)
                        Crutch.savedOptions.rockgrove.othersCurseLineColor = {r, g, b, a}
                    end,
                    width = "half",
                    disabled = function() return LibGroupBroadcast == nil or not Crutch.savedOptions.rockgrove.showOthersCurseLines end
                },
                {
                    type = "description",
                    title = "|c08BD1DMark Dangerous Abilities|r",
                    text = "Some AOE abilities are dangerous to have active when in Bahsei HM portals, because they may kill multiple ghosts at once. This feature can be configured to show a warning icon on the ability when it's almost time for your portal. For example, Solar Barrage lasts for 20s, and the margin (configure below) is 4s, so Solar Barrage's icon will have a warning at 16s before your portal spawns.",
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Portal number",
                    tooltip = "The portal number you are assigned to",
                    choices = {"None", "Portal 1", "Portal 2"},
                    choicesValues = {0, 1, 2},
                    getFunc = function()
                        return Crutch.savedOptions.rockgrove.portalNumber
                    end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.portalNumber = value
                    end,
                    width = "full",
                },
                {
                    type = "editbox",
                    name = "Add dangerous ability",
                    tooltip = "The ID of the ability to add to the list.\nUse |c99FF99/crutch printskills|r to see your currently equipped skill IDs",
                    default = "",
                    getFunc = function() return "" end,
                    setFunc = function(value)
                        if (value == "") then return end
                        local num = tonumber(value)
                        if (not num) then
                            Crutch.msg("Ability ID must be a number")
                            return
                        end
                        Crutch.savedOptions.rockgrove.abilitiesToReplace[num] = true
                        Crutch.msg(string.format("Added %s (%d) to abilities to replace.", GetAbilityName(num), num))
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Remove ability",
                    tooltip = "Select an ability from this dropdown to remove it from the list",
                    choices = {},
                    choicesValues = {},
                    getFunc = function()
                        UpdateAbilitiesToReplace()
                    end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.abilitiesToReplace[value] = nil
                        Crutch.msg(string.format("Removed %s(%d) from abilities to replace.", GetAbilityName(value), value))
                        UpdateAbilitiesToReplace()
                    end,
                    width = "full",
                    reference = "CrutchAlerts_AbilitiesToReplace",
                },
                {
                    type = "slider",
                    name = "Portal time margin",
                    tooltip = "The target number of milliseconds after portal spawns, for which you want the dangerous abilities to expire by. For example, setting it to 4000 means your Solar Barrage will be changed at 16 seconds before your portal, because the margin is 4 seconds and Solar Barrage lasts for 20 seconds",
                    min = 0,
                    max = 60000,
                    step = 500,
                    default = 4000,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.rockgrove.portalTimeMargin end,
                    setFunc = function(value)
                        Crutch.savedOptions.rockgrove.portalTimeMargin = value
                    end,
                },
            })),
        },
        {
            type = "submenu",
            name = "Sanity's Edge",
            controls = Crutch.GetProminentSettings(1427, {
                {
                    type = "checkbox",
                    name = "Show Chimera puzzle numbers",
                    tooltip = "In the Twelvane + Chimera fight, shows numbers on the puzzle glyphics",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.sanitysedge.showChimeraIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.sanitysedge.showChimeraIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Chimera icons size",
                    min = 20,
                    max = 300,
                    step = 10,
                    default = 150,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.sanitysedge.chimeraIconsSize end,
                    setFunc = function(value)
                        Crutch.savedOptions.sanitysedge.chimeraIconsSize = value
                        Crutch.OnPlayerActivated()
                    end,
                    disabled = function() return not Crutch.savedOptions.sanitysedge.showChimeraIcons end,
                },
                {
                    type = "checkbox",
                    name = "Show center of Ansuul arena",
                    tooltip = "In the Ansuul fight, shows an icon in the world on the center of the arena",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.sanitysedge.showAnsuulIcon end,
                    setFunc = function(value)
                        Crutch.savedOptions.sanitysedge.showAnsuulIcon = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Ansuul icon size",
                    min = 20,
                    max = 300,
                    step = 10,
                    default = 150,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.sanitysedge.ansuulIconSize end,
                    setFunc = function(value)
                        Crutch.savedOptions.sanitysedge.ansuulIconSize = value
                        Crutch.OnPlayerActivated()
                    end,
                    disabled = function() return not Crutch.savedOptions.sanitysedge.showAnsuulIcon end,
                },
            }),
        },
        {
            type = "submenu",
            name = "Sunspire",
            controls = Crutch.GetProminentSettings(1121, {
                {
                    type = "checkbox",
                    name = "Show Lokkestiiz HM beam position icons",
                    tooltip = "During flight phase on Lokkestiiz hardmode, shows 1~8 DPS and 2 healer positions in the world for Storm Fury",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.sunspire.showLokkIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.sunspire.showLokkIcons = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "    Lokkestiiz solo heal icons",
                    tooltip = "Use solo healer positions for the Lokkestiiz hardmode icons. This is for 9 damage dealers and 1 healer. If you change this option while at the Lokkestiiz fight, the new icons will show up the next time icons are displayed",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.sunspire.lokkIconsSoloHeal end,
                    setFunc = function(value)
                        Crutch.savedOptions.sunspire.lokkIconsSoloHeal = value
                    end,
                    width = "full",
                    disabled = function() return not Crutch.savedOptions.sunspire.showLokkIcons end,
                },
                {
                    type = "slider",
                    name = "Lokkestiiz HM icons size",
                    tooltip = "Updated size will show after the icons are hidden and shown again",
                    min = 20,
                    max = 300,
                    step = 10,
                    default = 150,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.sunspire.lokkIconsSize end,
                    setFunc = function(value)
                        Crutch.savedOptions.sunspire.lokkIconsSize = value
                    end,
                    disabled = function() return not Crutch.savedOptions.sunspire.showLokkIcons end,
                },
                {
                    type = "checkbox",
                    name = "Show some Lokkestiiz HM Storm Breath telegraphs",
                    tooltip = "During flight phase on Lokkestiiz hardmode, shows approximate telegraphs for some of the Storm Breaths and Storm Trails afterwards, mainly the ones that people tend to stand in...",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.sunspire.telegraphStormBreath end,
                    setFunc = function(value)
                        Crutch.savedOptions.sunspire.telegraphStormBreath = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Yolnahkriin position icons",
                    tooltip = "During flight phase on Yolnahkriin, shows icons in the world for where the next head stack and (right) wing stack will be when Yolnahkriin lands",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.sunspire.showYolIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.sunspire.showYolIcons = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "    Yolnahkriin left position icons",
                    tooltip = "Use left icons instead of right icons during flight phase on Yolnahkriin",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.sunspire.yolLeftIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.sunspire.yolLeftIcons = value
                    end,
                    width = "full",
                    disabled = function() return not Crutch.savedOptions.sunspire.showYolIcons end,
                },
                {
                    type = "slider",
                    name = "Yolnahkriin icons size",
                    min = 20,
                    max = 300,
                    step = 10,
                    default = 150,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.sunspire.yolIconsSize end,
                    setFunc = function(value)
                        Crutch.savedOptions.sunspire.yolIconsSize = value
                    end,
                    disabled = function() return not Crutch.savedOptions.sunspire.showYolIcons end,
                },
                {
                    type = "checkbox",
                    name = "Show players without Focused Fire",
                    tooltip = "When Yolnahkriin starts casting Focus Fire, show icons above players who do not have the Focused Fire debuff. This is mainly to help the OT not go to the wrong stack",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.sunspire.yolFocusedFire end,
                    setFunc = function(value)
                        Crutch.savedOptions.sunspire.yolFocusedFire = value
                    end,
                    width = "full",
                },
            }),
        },

        {
            type = "description",
            title = "Arenas",
            text = "Below are settings for special mechanics in specific arenas.",
            width = "full",
        },
        {
            type = "submenu",
            name = "Blackrose Prison",
            controls = Crutch.GetProminentSettings(1082, {}),
        },
        {
            type = "submenu",
            name = "Dragonstar Arena",
            controls = Crutch.GetProminentSettings(635, {
                {
                    type = "checkbox",
                    name = "Alert for NORMAL damage taken",
                    tooltip = "Displays annoying text and rings alarm bells if you start taking damage to certain abilities in NORMAL Dragonstar Arena. This is to facilitate afk farming, notifying you if manual intervention is needed. Included abilities: Nature's Blessing",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.dragonstar.normalDamageTaken end,
                    setFunc = function(value)
                        Crutch.savedOptions.dragonstar.normalDamageTaken = value
                    end,
                    width = "full",
                },
            }),
        },
        {
            type = "submenu",
            name = "Infinite Archive",
            controls = Crutch.GetProminentSettings(1436, {
                {
                    type = "checkbox",
                    name = "Auto mark Fabled",
                    tooltip = "When your reticle passes over Fabled enemies, automatically marks them with basegame target markers to make them easier to focus. It may sometimes mark incorrectly if you move too quickly and particularly if an NPC or your group member walks in front, but is otherwise mostly accurate",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.endlessArchive.markFabled end,
                    setFunc = function(value)
                        Crutch.savedOptions.endlessArchive.markFabled = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Auto mark Negate casters",
                    tooltip = "The same as auto marking Fabled above, but for enemies that can cast Negate Magic (Silver Rose Stormcaster, Dro-m'Athra Conduit, Dremora Conduit). They only cast Negate when you are close enough to them",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.endlessArchive.markNegate end,
                    setFunc = function(value)
                        Crutch.savedOptions.endlessArchive.markNegate = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Brewmaster elixir spot",
                    tooltip = "Displays an icon on where the Fabled Brewmaster may have thrown an Elixir of Diminishing. Note that it will not work on elixirs that are thrown at your group members' pets, but should for yourself, your pets, your companion, and your actual group member",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.endlessArchive.potionIcon end,
                    setFunc = function(value)
                        Crutch.savedOptions.endlessArchive.potionIcon = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Play sound for Uppercut / Power Bash",
                    tooltip = "Plays a ding sound when you are targeted by an Uppercut from 2-hander enemies or Power Bash from sword-n-board enemies, e.g. Ascendant Vanguard, Dro-m'Athra Sentinel, etc. Requires \"Begin\" casts on",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.endlessArchive.dingUppercut end,
                    setFunc = function(value)
                        Crutch.savedOptions.endlessArchive.dingUppercut = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Play sound for dangerous abilities",
                    tooltip = "Plays a ding sound for particularly dangerous abilities. Requires \"Begin\" casts on. Currently, this only includes:\n\n- Heavy Slash from Nerien'eth\n- Obliterate from Anka-Ra Destroyers on the Warrior encounter, because if you don't block or dodge them, the CC cannot be broken free of\n- Elixir of Diminishing from Brewmasters, which also stuns you for a duration",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.endlessArchive.dingDangerous end,
                    setFunc = function(value)
                        Crutch.savedOptions.endlessArchive.dingDangerous = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Print puzzle solution",
                    tooltip = "In the Corridor Puzzle room, when you get close to a switch, prints to chat the solution, if known, numbered from left to right. Currently missing 1 set of IDs, and works only for highest difficulty",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.endlessArchive.printPuzzleSolution end,
                    setFunc = function(value)
                        Crutch.savedOptions.endlessArchive.printPuzzleSolution = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
            }),
        },
        {
            type = "submenu",
            name = "Maelstrom Arena",
            controls = Crutch.GetProminentSettings(677, {
                {
                    type = "checkbox",
                    name = "Show the current round",
                    tooltip = "Displays a message in chat when a round starts. Also shows a message for final round soonTM, 15 seconds after the start of the second-to-last round",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.maelstrom.showRounds end,
                    setFunc = function(value)
                        Crutch.savedOptions.maelstrom.showRounds = value
                    end,
                    width = "full",
                },
                {
                    type = "editbox",
                    name = "Stage 1 extra text",
                    tooltip = "Extra text to display alongside the stage 1 final round soonTM alert",
                    default = Crutch.defaultOptions.maelstrom.stage1Boss,
                    getFunc = function() return Crutch.savedOptions.maelstrom.stage1Boss end,
                    setFunc = function(value)
                        Crutch.savedOptions.maelstrom.stage1Boss = value
                    end,
                    width = "full",
                },
                {
                    type = "editbox",
                    name = "Stage 2 extra text",
                    tooltip = "Extra text to display alongside the stage 2 final round soonTM alert",
                    default = Crutch.defaultOptions.maelstrom.stage2Boss,
                    getFunc = function() return Crutch.savedOptions.maelstrom.stage2Boss end,
                    setFunc = function(value)
                        Crutch.savedOptions.maelstrom.stage2Boss = value
                    end,
                    width = "full",
                },
                {
                    type = "editbox",
                    name = "Stage 3 extra text",
                    tooltip = "Extra text to display alongside the stage 3 final round soonTM alert",
                    default = Crutch.defaultOptions.maelstrom.stage3Boss,
                    getFunc = function() return Crutch.savedOptions.maelstrom.stage3Boss end,
                    setFunc = function(value)
                        Crutch.savedOptions.maelstrom.stage3Boss = value
                    end,
                    width = "full",
                },
                {
                    type = "editbox",
                    name = "Stage 4 extra text",
                    tooltip = "Extra text to display alongside the stage 4 final round soonTM alert",
                    default = Crutch.defaultOptions.maelstrom.stage4Boss,
                    getFunc = function() return Crutch.savedOptions.maelstrom.stage4Boss end,
                    setFunc = function(value)
                        Crutch.savedOptions.maelstrom.stage4Boss = value
                    end,
                    width = "full",
                },
                {
                    type = "editbox",
                    name = "Stage 5 extra text",
                    tooltip = "Extra text to display alongside the stage 5 final round soonTM alert",
                    default = Crutch.defaultOptions.maelstrom.stage5Boss,
                    getFunc = function() return Crutch.savedOptions.maelstrom.stage5Boss end,
                    setFunc = function(value)
                        Crutch.savedOptions.maelstrom.stage5Boss = value
                    end,
                    width = "full",
                },
                {
                    type = "editbox",
                    name = "Stage 6 extra text",
                    tooltip = "Extra text to display alongside the stage 6 final round soonTM alert",
                    default = Crutch.defaultOptions.maelstrom.stage6Boss,
                    getFunc = function() return Crutch.savedOptions.maelstrom.stage6Boss end,
                    setFunc = function(value)
                        Crutch.savedOptions.maelstrom.stage6Boss = value
                    end,
                    width = "full",
                },
                {
                    type = "editbox",
                    name = "Stage 7 extra text",
                    tooltip = "Extra text to display alongside the stage 7 final round soonTM alert",
                    default = Crutch.defaultOptions.maelstrom.stage7Boss,
                    getFunc = function() return Crutch.savedOptions.maelstrom.stage7Boss end,
                    setFunc = function(value)
                        Crutch.savedOptions.maelstrom.stage7Boss = value
                    end,
                    width = "full",
                },
                {
                    type = "editbox",
                    name = "Stage 8 extra text",
                    tooltip = "Extra text to display alongside the stage 8 final round soonTM alert",
                    default = Crutch.defaultOptions.maelstrom.stage8Boss,
                    getFunc = function() return Crutch.savedOptions.maelstrom.stage8Boss end,
                    setFunc = function(value)
                        Crutch.savedOptions.maelstrom.stage8Boss = value
                    end,
                    width = "full",
                },
                {
                    type = "editbox",
                    name = "Stage 9 extra text",
                    tooltip = "Extra text to display alongside the stage 9 final round soonTM alert",
                    default = Crutch.defaultOptions.maelstrom.stage9Boss,
                    getFunc = function() return Crutch.savedOptions.maelstrom.stage9Boss end,
                    setFunc = function(value)
                        Crutch.savedOptions.maelstrom.stage9Boss = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Alert for NORMAL damage taken",
                    tooltip = "Displays annoying text and rings alarm bells if you start taking damage to certain abilities in NORMAL Maelstrom Arena. This is to facilitate afk farming, notifying you if manual intervention is needed. Included abilities: Frigid Waters, Infectious Bite, Volatile Poison, Standard of Might, Molten Destruction",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.maelstrom.normalDamageTaken end,
                    setFunc = function(value)
                        Crutch.savedOptions.maelstrom.normalDamageTaken = value
                    end,
                    width = "full",
                },
            }),
        },
        {
            type = "submenu",
            name = "Vateshran Hollows",
            controls = Crutch.GetProminentSettings(1227, {
                {
                    type = "checkbox",
                    name = "Show missed score adds",
                    tooltip = "Works only in veteran, and should be used only if going for score. Skipped adds may be inaccurate if you skip entire pulls. The missed adds detection assumes that you do the secret blue side pull before the final blue side pull prior to Iozuzzunth",
                    default = false,
                    getFunc = function() return Crutch.savedOptions.vateshran.showMissedAdds end,
                    setFunc = function(value)
                        Crutch.savedOptions.vateshran.showMissedAdds = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
            }),
        },
        {
            type = "description",
            title = "Dungeons",
            text = "Below are settings for special mechanics in specific dungeons.",
            width = "full",
        },
        {
            type = "submenu",
            name = "Black Gem Foundry",
            controls = {
                {
                    type = "checkbox",
                    name = "Show Rupture preview line",
                    tooltip = "Shows a line during the ping pong phase on Quarrymaster Saldezaar, to help preview where you would get ponged to",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.blackGemFoundry.showRuptureLine end,
                    setFunc = function(value)
                        Crutch.savedOptions.blackGemFoundry.showRuptureLine = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
            }
        },
        {
            type = "submenu",
            name = "Shipwright's Regret",
            controls = {
                {
                    type = "checkbox",
                    name = "Suggest stacks for Soul Bomb",
                    tooltip = "Displays a notification for suggested person to stack on for Soul Bomb on Foreman Bradiggan hardmode when there are 2 bombs. Also shows an icon above that person's head. The suggested stack is alphabetical based on @ name",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.shipwrightsRegret.showBombStacks end,
                    setFunc = function(value)
                        Crutch.savedOptions.shipwrightsRegret.showBombStacks = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                },
            }
        },
    }

    LAM:RegisterAddonPanel("CrutchAlertsOptions", panelData)
    LAM:RegisterOptionControls("CrutchAlertsOptions", optionsData)
end