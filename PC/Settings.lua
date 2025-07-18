CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

local function GetNoSubtitlesZoneIdsAndNames()
    local ids = {}
    local names = {}
    for zoneId, _ in pairs(Crutch.savedOptions.subtitlesIgnoredZones) do
        table.insert(ids, zoneId)
        table.insert(names, string.format("%s (%d)", GetZoneNameById(zoneId), zoneId))
    end
    return ids, names
end

local function UnlockUI(value)
    Crutch.unlock = value
    CrutchAlertsContainer:SetMovable(value)
    CrutchAlertsContainer:SetMouseEnabled(value)
    CrutchAlertsContainerBackdrop:SetHidden(not value)
    if (value) then
        Crutch.DisplayNotification(47898, "Example Alert", 5000, 0, 0, 0, 0, false)
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
end
Crutch.UnlockUI = UnlockUI

function Crutch:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if (not LAM) then d("|cFF0000CrutchAlerts currently has no settings on console.|r") return end
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
            tooltip = "Unlock the frames for moving",
            default = false,
            getFunc = function() return Crutch.unlock end,
            setFunc = UnlockUI,
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
                        if (value) then
                            Crutch.RegisterOthers()
                        else
                            Crutch.UnregisterOthers()
                        end
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
                        Crutch.DisplayNotification(47898, "Example Alert", 5000, 0, 0, 0, 0, false)
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
            }
        },
-- boss health bar
        {
            type = "submenu",
            name = "Vertical Boss Health Bar Settings",
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
-- subtitles
        {
            type = "submenu",
            name = "Miscellaneous Settings",
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
            name = "Debug Settings",
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
                    name = "Color Ody death icon",
                    tooltip = "Colors the OdySupportIcons death icon purple if a player's shade is still up. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.cloudrest.deathIconColor end,
                    setFunc = function(value)
                        Crutch.savedOptions.cloudrest.deathIconColor = value
                    end,
                    width = "full",
                    disabled = function() return OSI == nil end,
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
                    name = "Show safe spot for triplets",
                    tooltip = "In the triplets fight, shows an icon in the world that is outside of Shock Field. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.hallsoffabrication.showTripletsIcon end,
                    setFunc = function(value)
                        Crutch.savedOptions.hallsoffabrication.showTripletsIcon = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return OSI == nil end,
                },
                {
                    type = "slider",
                    name = "Triplets icon size",
                    min = 20,
                    max = 300,
                    step = 10,
                    default = 150,
                    width = "full",
                    getFunc = function() return Crutch.savedOptions.hallsoffabrication.tripletsIconSize end,
                    setFunc = function(value)
                        Crutch.savedOptions.hallsoffabrication.tripletsIconSize = value
                        Crutch.OnPlayerActivated()
                    end,
                    disabled = function() return not Crutch.savedOptions.hallsoffabrication.showTripletsIcon end,
                },
                {
                    type = "checkbox",
                    name = "Show Assembly General icons",
                    tooltip = "Shows icons in the world for execute positions. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.hallsoffabrication.showAGIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.hallsoffabrication.showAGIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return OSI == nil end,
                },
                {
                    type = "slider",
                    name = "Assembly General icons size",
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
                    tooltip = "On trash packs with Half-Giant Raiders, show icons at the approximate locations where Exploding Spears will land. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.kynesaegis.showSpearIcon end,
                    setFunc = function(value)
                        Crutch.savedOptions.kynesaegis.showSpearIcon = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return OSI == nil end,
                },
                {
                    type = "checkbox",
                    name = "Show Blood Prison icon",
                    tooltip = "Shows icon above player who is targeted by Blood Prison, slightly before the bubble even shows up. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.kynesaegis.showPrisonIcon end,
                    setFunc = function(value)
                        Crutch.savedOptions.kynesaegis.showPrisonIcon = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return OSI == nil end,
                },
                {
                    type = "checkbox",
                    name = "Show Falgravn 2nd floor DPS stacks",
                    tooltip = "In the Falgravn fight, shows 1~4 DPS in the world for stacks. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.kynesaegis.showFalgravnIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.kynesaegis.showFalgravnIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return OSI == nil end,
                },
                {
                    type = "slider",
                    name = "Falgravn icon size",
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
                    tooltip = "Shows icon for where Cavot Agnan will spawn. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.lucentcitadel.showCavotIcon end,
                    setFunc = function(value)
                        Crutch.savedOptions.lucentcitadel.showCavotIcon = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return OSI == nil end,
                },
                {
                    type = "slider",
                    name = "Cavot Agnan icon size",
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
                    tooltip = "Shows icons for each mirror on the Orphic Shattered Shard fight. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.lucentcitadel.showOrphicIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.lucentcitadel.showOrphicIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return OSI == nil end,
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
                    name = "Orphic icon size",
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
                    tooltip = "Shows a line connecting group members who are about to (or have already received) the Arcane Conveyance tether from Dariel Lemonds. If OdySupportIcons is enabled, also shows icons above their heads",
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
                    tooltip = "Shows icons for group member positions on the Xoryn fight for Tempest (and at the beginning of the trial, for practice purposes). Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.lucentcitadel.showTempestIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.lucentcitadel.showTempestIcons = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return OSI == nil end,
                },
                {
                    type = "slider",
                    name = "Xoryn Tempest icon size",
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
                    name = "Show Twins Color Swap",
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
                    type = "dropdown",
                    name = "Show Stricken timer",
                    tooltip = "Shows an \"alert\" timer for Stricken. If set to \"Tank Only\" it will display only if your LFG role is tank",
                    choices = {"Never", "Tank Only", "Always"},
                    choicesValues = {"NEVER", "TANK", "ALWAYS"},
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
                    tooltip = "Shows a line connecting group members who are about to (or have already received) the Dominator's Chains tether from Overfiend Kazpian. If OdySupportIcons is enabled, also shows icons above their heads",
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
            })),
        },
        {
            type = "submenu",
            name = "Sanity's Edge",
            controls = Crutch.GetProminentSettings(1427, {
                {
                    type = "checkbox",
                    name = "Show center of Ansuul arena",
                    tooltip = "In the Ansuul fight, shows an icon in the world on the center of the arena. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.sanitysedge.showAnsuulIcon end,
                    setFunc = function(value)
                        Crutch.savedOptions.sanitysedge.showAnsuulIcon = value
                        Crutch.OnPlayerActivated()
                    end,
                    width = "full",
                    disabled = function() return OSI == nil end,
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
                    tooltip = "During flight phase on Lokkestiiz hardmode, shows 1~8 DPS and 2 healer positions in the world for Storm Fury. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.sunspire.showLokkIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.sunspire.showLokkIcons = value
                    end,
                    width = "full",
                    disabled = function() return OSI == nil end,
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
                    name = "Lokkestiiz HM icon size",
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
                    name = "Show Yolnahkriin position icons",
                    tooltip = "During flight phase on Yolnahkriin, shows icons in the world for where the next head stack and (right) wing stack will be when Yolnahkriin lands. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.sunspire.showYolIcons end,
                    setFunc = function(value)
                        Crutch.savedOptions.sunspire.showYolIcons = value
                    end,
                    width = "full",
                    disabled = function() return OSI == nil end,
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
                    name = "Yolnahkriin icon size",
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
                    tooltip = "Displays an icon on where the Fabled Brewmaster may have thrown an Elixir of Diminishing. Note that it will not work on elixirs that are thrown at your group members' pets, but should for yourself, your pets, your companion, and your actual group member. Requires OdySupportIcons",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.endlessArchive.potionIcon end,
                    setFunc = function(value)
                        Crutch.savedOptions.endlessArchive.potionIcon = value
                    end,
                    width = "full",
                    disabled = function() return OSI == nil end,
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
                    tooltip = "Plays a ding sound for particularly dangerous abilities. Requires \"Begin\" casts on. Currently, this only includes:\n\n- Obliterate from Anka-Ra Destroyers on the Warrior encounter, because if you don't block or dodge it, the CC cannot be broken free of\n- Elixir of Diminishing from Brewmasters, which also stuns you for a duration",
                    default = true,
                    getFunc = function() return Crutch.savedOptions.endlessArchive.dingDangerous end,
                    setFunc = function(value)
                        Crutch.savedOptions.endlessArchive.dingDangerous = value
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
            name = "Shipwright's Regret",
            controls = {
                {
                    type = "checkbox",
                    name = "Suggest stacks for Soul Bomb",
                    tooltip = "Displays a notification for suggested person to stack on for Soul Bomb on Foreman Bradiggan hardmode when there are 2 bombs. If OdySupportIcons is enabled, also shows an icon above that person's head. The suggested stack is alphabetical based on @ name",
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