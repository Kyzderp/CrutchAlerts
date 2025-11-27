local Crutch = CrutchAlerts
local Draw = Crutch.Drawing
local C = Crutch.Constants

---------------------------------------------------------------------
-- A bit of a framework to show icons attached to players
---------------------------------------------------------------------
--[[
{
    [unitTag] = {
        key = key, -- Only showing 1 at a time, so only need the 1 key
        active = uniqueName,
        icons = {
            [uniqueName] = {
                priority = 0, -- Higher shows before lower
                texture = "",
                size = 100,
                color = {1, 1, 1, 1},
                callback = function(control) end,
            },
        },
    },
}
]]
local unitIcons = {}
Draw.unitIcons = unitIcons
-- /script d(CrutchAlerts.Drawing.unitIcons)

local function DumpUnitIcons()
    d("============== attached icons dump ==============")
    for tag, data in pairs(unitIcons) do
        d(string.format("%s (%s)\n----key: %s\n----active: %s", GetUnitDisplayName(tag) or "NO USER", tag, data.key or "NO KEY", data.active or "NO ACTIVE"))
        for uniqueName, icon in pairs(data.icons) do
            d(string.format("----%s: %d [|t100%%:100%%:%s|t]", uniqueName, icon.priority or "no priority?!", icon.texture or "no texture"))
        end
    end
end
Draw.DumpUnitIcons = DumpUnitIcons
-- /script CrutchAlerts.Drawing.DumpUnitIcons()

---------------------------------------------------------------------
-- Prioritization; logic for which icon to show
---------------------------------------------------------------------
local function RemoveAttachedIcon(key)
    Draw.RemoveWorldTexture(key)
end

-- Creates the actual 3D control with update function
local function CreateAttachedIcon(unitTag, texture, size, color, yOffset, callback, spaceOptions)
    local _, x, y, z = GetUnitRawWorldPosition(unitTag)

    local function OnUpdate(icon)
        local _, x, y, z = GetUnitRawWorldPosition(unitTag)
        icon:SetPosition(x, y + yOffset, z)

        if (callback) then
            callback(icon)
        end
    end

    local key
    if (spaceOptions) then
        key = Draw.CreateSpaceControl(
            x,
            y + yOffset,
            z,
            true, -- faceCamera
            nil, -- orientation
            spaceOptions,
            OnUpdate)
    else
        key = Draw.CreateWorldTexture(
            texture,
            x,
            y + yOffset,
            z,
            size / 100,
            size / 100,
            color,
            Crutch.savedOptions.drawing.attached.useDepthBuffers,
            true,
            nil,
            OnUpdate)
    end

    return key
end

local function ReevaluatePrioritization(unitTag)
    if (not unitIcons[unitTag]) then return end

    local highestPriority = -1
    local highestName
    for uniqueName, iconData in pairs(unitIcons[unitTag].icons) do
        if (iconData.priority >= highestPriority) then
            highestPriority = iconData.priority
            highestName = uniqueName
        end
    end

    local currentKey = unitIcons[unitTag].key

    -- No icons
    if (not highestName) then
        if (currentKey) then
            RemoveAttachedIcon(currentKey)
            unitIcons[unitTag].key = nil
            unitIcons[unitTag].active = nil
        end
        return
    end

    -- This icon is already fine
    if (unitIcons[unitTag].active == highestName) then return end

    -- Else, draw the highest priority one
    if (currentKey) then
        RemoveAttachedIcon(currentKey)
    end
    local icon = unitIcons[unitTag].icons[highestName]
    local key = CreateAttachedIcon(unitTag, icon.texture, icon.size, icon.color, icon.yOffset, icon.callback, icon.spaceOptions)
    unitIcons[unitTag].key = key
    unitIcons[unitTag].active = highestName
end


---------------------------------------------------------------------
-- Internal API
---------------------------------------------------------------------
-- If player is grouped but someone tries to add an icon for "player"
-- just use the group unit tag
local playerGroupTag

local function IsSelf(unitTag)
    if (unitTag == "player") then
        return true
    end

    if (AreUnitsEqual("player", unitTag)) then
        playerGroupTag = unitTag
        return true
    end

    return false
end

local function RemoveIconForUnit(unitTag, uniqueName, forcePlayer)
    if (unitTag == "player" and playerGroupTag and not forcePlayer) then
        unitTag = playerGroupTag
        Crutch.dbgSpam("Translating player tag to " .. playerGroupTag .. " to remove " .. uniqueName)
    end

    if (not unitIcons[unitTag]) then return end

    if (not unitIcons[unitTag].icons[uniqueName]) then
        -- d("|cFF0000No icon " .. uniqueName .. " for " .. unitTag .. "|r")
        return
    end

    Crutch.dbgSpam(string.format("RemoveIconForUnit %s (%s) %s was: |t100%%:100%%:%s|t", unitTag, GetUnitDisplayName(unitTag) or "???", uniqueName, unitIcons[unitTag].icons[uniqueName].texture or "blank.dds"))

    unitIcons[unitTag].icons[uniqueName] = nil

    ReevaluatePrioritization(unitTag)
end

local function SetIconForUnit(unitTag, uniqueName, priority, texture, size, color, yOffset, persistOutsideCombat, callback, spaceOptions)
    if (unitTag == "player" and playerGroupTag) then
        unitTag = playerGroupTag
        Crutch.dbgSpam("Translating player tag to " .. playerGroupTag  .. " to set " .. uniqueName)
    end

    if (not unitIcons[unitTag]) then
        unitIcons[unitTag] = {
            icons = {}
        }
    end

    if (unitIcons[unitTag].icons[uniqueName]) then
        Crutch.dbgSpam(string.format("Icon already exists for %s uniqueName %s, removing first and then replacing...", unitTag, uniqueName))
        RemoveIconForUnit(unitTag, uniqueName)
    end

    Crutch.dbgSpam(string.format("SetIconForUnit %s (%s) %s |t100%%:100%%:%s|t", unitTag, GetUnitDisplayName(unitTag) or "???", uniqueName, texture or "blank.dds"))

    color = color or C.WHITE

    local r, g, b, a = unpack(color)
    if (not a) then
        a = Crutch.savedOptions.drawing.attached.opacity
    end

    unitIcons[unitTag].icons[uniqueName] = {
        priority = priority,
        texture = texture,
        size = size or Crutch.savedOptions.drawing.attached.size,
        color = {r, g, b, a},
        yOffset = yOffset or Crutch.savedOptions.drawing.attached.yOffset,
        persistOutsideCombat = persistOutsideCombat,
        callback = callback,
        spaceOptions = spaceOptions,
    }

    ReevaluatePrioritization(unitTag)
end

---------------------------------------------------------------------
-- Suppressing icons, used to not show icons in opposite portals or
-- when failing other checks, e.g. zone
---------------------------------------------------------------------
-- This is kinda hacky, basically just displaying a blank icon at
-- high priority to suppress other icons. It would be more proper to
-- not create any icons.
local SUPPRESS_NAME = "CrutchAlertsSuppress"
local suppressionFilters = {} -- {[name] = function(unitTag) return true end,}

-- Suppression is auto removed upon combat end
local function SuppressIcons(unitTag)
    SetIconForUnit(unitTag, SUPPRESS_NAME, C.PRIORITY.SUPPRESS, "blank.dds")
end

local function UnsuppressIcons(unitTag)
    RemoveIconForUnit(unitTag, SUPPRESS_NAME)
end

local function ShouldUnitBeShown(unitTag)
    -- Self is always valid. Whether to show self is done elsewhere
    if (AreUnitsEqual("player", unitTag)) then
        return true
    end

    -- Check all filters. If any return false, the icon should be suppressed
    for _, filter in pairs(suppressionFilters) do
        if (not filter(unitTag)) then
            return false
        end
    end

    return true
end

local function EvaluateSuppressionFor(unitTag)
    if (not ShouldUnitBeShown(unitTag)) then
        SuppressIcons(unitTag)
    else
        UnsuppressIcons(unitTag)
    end
end
Draw.EvaluateSuppressionFor = EvaluateSuppressionFor

-- Must be called to update suppression, so it should be called when
-- you enter a portal. This is already called from RefreshGroup as well.
local function EvaluateAllSuppression()
    -- Intentionally use index here, instead of GetGroupUnitTagByIndex,
    -- in order to clean up tags that no longer exist
    for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        local unitTag = "group" .. tostring(i)

        if (not DoesUnitExist(unitTag)) then
            -- No player exists / just left group, so clean up the old icon
            UnsuppressIcons(unitTag)
        elseif (IsUnitOnline(unitTag)) then
            EvaluateSuppressionFor(unitTag)
        end
    end
end
Draw.EvaluateAllSuppression = EvaluateAllSuppression

-- Register a filter for suppressing icons.
-- filterFunc is called with parameter unitTag.
-- If the function returns false, icons for the tag will be suppressed.
local function RegisterSuppressionFilter(name, filterFunc)
    Crutch.dbgSpam("Registering suppression filter " .. name)
    suppressionFilters[name] = filterFunc
    EvaluateAllSuppression()
end
Draw.RegisterSuppressionFilter = RegisterSuppressionFilter

local function UnregisterSuppressionFilter(name)
    Crutch.dbgSpam("Unregistering suppression filter " .. name)
    suppressionFilters[name] = nil
    EvaluateAllSuppression()
end
Draw.UnregisterSuppressionFilter = UnregisterSuppressionFilter

local suppressionInitialized = false
local function InitializeSuppression()
    if (suppressionInitialized) then return end
    suppressionInitialized = true

    -- Built-in filters for suppressing icons when not in the same zone etc.
    RegisterSuppressionFilter("CrutchAlertsSameWorld", function(unitTag)
        -- Different instance is still same world
        return IsGroupMemberInSameWorldAsPlayer(unitTag)
    end)

    RegisterSuppressionFilter("CrutchAlertsRemoteRegion", function(unitTag)
        -- Different instance counts as remote region
        return not IsGroupMemberInRemoteRegion(unitTag)
    end)
end

---------------------------------------------------------------------
-- Built-in icons
---------------------------------------------------------------------
-- LFG roles
local GROUP_ROLE_NAME = "CrutchAlertsGroupRole"
local GROUP_ROLE_PRIORITY = 100

local ROLE_SETTINGS = {
    [LFG_ROLE_DPS] = {
        texture = "esoui/art/lfg/gamepad/lfg_roleicon_dps.dds",
        color = function() return Crutch.savedOptions.drawing.attached.dpsColor end,
        show = function() return Crutch.savedOptions.drawing.attached.showDps end,
    },
    [LFG_ROLE_HEAL] = {
        texture = "esoui/art/lfg/gamepad/lfg_roleicon_healer.dds",
        color = function() return Crutch.savedOptions.drawing.attached.healColor end,
        show = function() return Crutch.savedOptions.drawing.attached.showHeal end,
    },
    [LFG_ROLE_TANK] = {
        texture = "esoui/art/lfg/gamepad/lfg_roleicon_tank.dds",
        color = function() return Crutch.savedOptions.drawing.attached.tankColor end,
        show = function() return Crutch.savedOptions.drawing.attached.showTank end,
    },
}

local tagsToDo = {}
local function CreateGroupRoleIcons()
    local showSelf = Crutch.savedOptions.drawing.attached.showSelfRole
    ZO_ClearTable(tagsToDo)
    if (GetGroupSize() <= 1) then
        if (showSelf) then
            tagsToDo["player"] = GetSelectedLFGRole()
        end
    else
        for i = 1, GetGroupSize() do
            local tag = GetGroupUnitTagByIndex(i)
            if (tag and IsUnitOnline(tag) and (showSelf or not IsSelf(tag))) then
                local role = GetGroupMemberSelectedRole(tag)
                tagsToDo[tag] = role
            end
        end
    end


    for unitTag, role in pairs(tagsToDo) do
        local settings = ROLE_SETTINGS[role]
        if (settings and settings.show()) then
            SetIconForUnit(unitTag,
                GROUP_ROLE_NAME,
                C.PRIORITY.GROUP_ROLE,
                settings.texture,
                nil,
                settings.color(),
                nil,
                true)
        end
    end
end
Draw.CreateGroupRoleIcons = CreateGroupRoleIcons
-- /script CrutchAlerts.Drawing.CreateGroupRoleIcons()

local function DestroyAllRoleIcons()
    for unitTag, tagData in pairs(unitIcons) do
        if (tagData.icons[GROUP_ROLE_NAME]) then
            RemoveIconForUnit(unitTag, GROUP_ROLE_NAME)
        end
    end
    RemoveIconForUnit("player", GROUP_ROLE_NAME)
end

---------------------------------------------------------------------
-- Corpse icons
local GROUP_DEAD_NAME = "CrutchAlertsGroupDead"
local DEAD_Y_OFFSET = 100
local deadColorOverrides = {} -- {[unitTag] = {0, 1, 0},}

local function OnDeathStateChanged(_, unitTag, isDead)
    if (isDead) then
        -- No deadge
        if (not Crutch.savedOptions.drawing.attached.showDead) then
            RemoveIconForUnit(unitTag, GROUP_DEAD_NAME)
            return
        end

        -- No self
        if (IsSelf(unitTag) and not Crutch.savedOptions.drawing.attached.showSelfRole) then
            RemoveIconForUnit(unitTag, GROUP_DEAD_NAME)
            return
        end

        local function Callback(icon)
            local r, g, b
            if (DoesUnitHaveResurrectPending(unitTag)) then
                r, g, b = unpack(Crutch.savedOptions.drawing.attached.pendingColor)
            elseif (deadColorOverrides[unitTag]) then
                r, g, b = unpack(deadColorOverrides[unitTag])
            elseif (IsUnitBeingResurrected(unitTag)) then
                r, g, b = unpack(Crutch.savedOptions.drawing.attached.rezzingColor)
            else
                r, g, b = unpack(Crutch.savedOptions.drawing.attached.deadColor)
            end
            icon:SetColor(r, g, b)
        end

        SetIconForUnit(unitTag,
            GROUP_DEAD_NAME,
            C.PRIORITY.GROUP_DEAD,
            "esoui/art/icons/mapkey/mapkey_groupboss.dds",
            nil,
            Crutch.savedOptions.drawing.attached.deadColor,
            DEAD_Y_OFFSET,
            true,
            Callback)
    else
        RemoveIconForUnit(unitTag, GROUP_DEAD_NAME)
    end
end

-- Override the dead and rezzing colors. That means pending color
-- still takes priority over this. Set to nil to remove the override.
local function OverrideDeadColor(unitTag, color)
    deadColorOverrides[unitTag] = color
end
Draw.OverrideDeadColor = OverrideDeadColor

---------------------------------------------------------------------
-- Crown
local GROUP_CROWN_NAME = "CrutchAlertsGroupCrown"
local currentCrown

local function OnCrownChange(_, unitTag)
    if (currentCrown) then
        RemoveIconForUnit(currentCrown, GROUP_CROWN_NAME)
        currentCrown = nil
    end

    -- No crown
    if (not Crutch.savedOptions.drawing.attached.showCrown) then
        return
    end

    -- No self
    if (IsSelf(unitTag) and not Crutch.savedOptions.drawing.attached.showSelfRole) then
        return
    end

    currentCrown = unitTag

    SetIconForUnit(unitTag,
        GROUP_CROWN_NAME,
        C.PRIORITY.GROUP_CROWN,
        "esoui/art/icons/mapkey/mapkey_groupleader.dds",
        nil,
        Crutch.savedOptions.drawing.attached.crownColor,
        nil,
        true)
end


---------------------------------------------------------------------
-- Group refresh
---------------------------------------------------------------------
local function RefreshGroup()
    Crutch.dbgSpam("|c0055FF[draw]|r doing RefreshGroup")
    -- Do a first pass because unit tags could have changed.
    -- This could probably be done as part of another loop, but meh.
    -- Also probably could use Crutch.playerGroupTag...
    playerGroupTag = nil
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if (AreUnitsEqual("player", tag)) then
            playerGroupTag = tag
            break
        end
    end

    -- Roles
    DestroyAllRoleIcons()
    CreateGroupRoleIcons()

    Draw.DestroyIndividualIcons()

    for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        -- Intentionally use index here, instead of GetGroupUnitTagByIndex,
        -- in order to clean up tags that no longer exist
        local tag = "group" .. tostring(i)

        if (not DoesUnitExist(tag)) then
            -- No player exists / just left group, so clean up the old icon
            OnDeathStateChanged(nil, tag, false)
        else
            -- Deaths
            if (IsUnitOnline(tag)) then
                OnDeathStateChanged(nil, tag, IsUnitDead(tag))

                -- Individual icon
                Draw.MaybeSetIndividualIcon(tag)
            else
                -- Sometimes offline players are also dead, but it doesn't
                -- make sense to show dead icon if they're offline
                OnDeathStateChanged(nil, tag, false)
            end

            -- Crown
            if (IsUnitGroupLeader(tag)) then
                OnCrownChange(nil, tag)
            end

        end
    end

    -- Self
    OnDeathStateChanged(nil, "player", IsUnitDead("player"))
    Draw.MaybeSetIndividualIcon("player")

    -- Suppression
    EvaluateAllSuppression()
end
Draw.RefreshGroup = RefreshGroup
-- /script CrutchAlerts.Drawing.RefreshGroup()

local function RefreshGroupTimeout()
    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "AttachedGroupRefreshTimeout", 200, function()
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "AttachedGroupRefreshTimeout")
        RefreshGroup()
    end)
end

---------------------------------------------------------------------
-- Built-in events
---------------------------------------------------------------------
local hooked = false
local function InitializeAttachedIcons()
    -- Group changes
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupActivated", EVENT_PLAYER_ACTIVATED, function() Crutch.dbgSpam("|c0055FF[draw]|r RefreshGroupTimeout reason: player activated") RefreshGroupTimeout() end)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupJoined", EVENT_GROUP_MEMBER_JOINED, function() Crutch.dbgSpam("|c0055FF[draw]|r RefreshGroupTimeout reason: member joined") RefreshGroupTimeout() end)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupLeft", EVENT_GROUP_MEMBER_LEFT, function() Crutch.dbgSpam("|c0055FF[draw]|r RefreshGroupTimeout reason: member left") RefreshGroupTimeout() end)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupUpdate", EVENT_GROUP_UPDATE, function() Crutch.dbgSpam("|c0055FF[draw]|r RefreshGroupTimeout reason: update") RefreshGroupTimeout() end)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupRoleChanged", EVENT_GROUP_MEMBER_ROLE_CHANGED, function() Crutch.dbgSpam("|c0055FF[draw]|r RefreshGroupTimeout reason: member role change") RefreshGroupTimeout() end) -- TODO: could be more efficient
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupConnectedStatus", EVENT_GROUP_MEMBER_CONNECTED_STATUS, function() Crutch.dbgSpam("|c0055FF[draw]|r RefreshGroupTimeout reason: member connected status") RefreshGroupTimeout() end) -- TODO: could be more efficient

    -- deadge
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "AttachedGroupDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedPlayerDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "AttachedPlayerDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    -- Self role change
    if (not hooked) then
        ZO_PostHook("UpdateSelectedLFGRole", function() Crutch.dbgSpam("|c0055FF[draw]|r RefreshGroupTimeout reason: UpdateSelectedLFGRole") RefreshGroupTimeout() end)
        hooked = true
    end

    -- Crown
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupLeader", EVENT_LEADER_UPDATE, OnCrownChange) -- TODO: could be more efficient

    -- Combat persistence
    Crutch.RegisterExitedGroupCombatListener("CrutchAttachedIconsCombat", function()
        for unitTag, tagData in pairs(unitIcons) do
            for uniqueName, iconData in pairs(tagData.icons) do
                if (not iconData.persistOutsideCombat) then
                    RemoveIconForUnit(unitTag, uniqueName)
                end
            end
        end
    end)

    -- Suppression
    InitializeSuppression()
end
Draw.InitializeAttachedIcons = InitializeAttachedIcons

-- TODO: use this at some point?
local function UnregisterAttachedIcons()
    -- Group changes
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "AttachedGroupActivated", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "AttachedGroupJoined", EVENT_GROUP_MEMBER_JOINED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "AttachedGroupLeft", EVENT_GROUP_MEMBER_LEFT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "AttachedGroupUpdate", EVENT_GROUP_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "AttachedGroupRoleChanged", EVENT_GROUP_MEMBER_ROLE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "AttachedGroupConnectedStatus", EVENT_GROUP_MEMBER_CONNECTED_STATUS)

    -- deadge
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "AttachedGroupDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "AttachedPlayerDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)

    -- Crown
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "AttachedGroupLeader", EVENT_LEADER_UPDATE)

    -- Combat persistence
    Crutch.UnregisterExitedGroupCombatListener("CrutchAttachedIconsCombat")
end
Draw.UnregisterAttachedIcons = UnregisterAttachedIcons

---------------------------------------------------------------------

---------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------
-- Add an icon for a (likely group member) unit
-- unitTag - the unit tag, e.g. "group1". If grouped, trying to use "player" will automatically use the group unit tag instead
-- uniqueName - unique name, such as your addon name + mechanic name
-- priority - order in which icons are displayed. Higher number takes precedence. Built-in role icons are currently 100, crown is 105, dead group member icons are 110. See main/Constants.lua for priorities
-- texture - path to the texture
-- size - size to display at. Default 100, but set via user settings
-- color - color of the icon, in format {r, g, b, a}. To use the user setting for alpha, leave out a, e.g. {1, 0.4, 0.8}
-- persistOutsideCombat - whether to keep this icon when exiting combat. Otherwise, icon is removed when all group members exit combat. Default false. Note: if the group isn't already in combat, the icon will still show, because it's only removed on combat exit
-- callback - same as updateFunc documented in Drawing.lua:CreateWorldTexture
-- spaceOptions - optional table that forces the icon to use the Space API regardless of user's depth buffer setting. See SpaceDrawing.lua: CreateSpaceControl
function Crutch.SetAttachedIconForUnit(unitTag, uniqueName, priority, texture, size, color, persistOutsideCombat, callback, spaceOptions)
    if (priority < 0 or priority > 10000) then
        Crutch.msg("|cFF0000Invalid priority for " .. uniqueName .. " icon; use 0~10000")
        return
    end
    SetIconForUnit(unitTag, uniqueName, priority, texture, size, color, nil, persistOutsideCombat, callback, spaceOptions)
end
-- /script CrutchAlerts.SetAttachedIconForUnit("player", "CrutchAlertsTest", 200, "esoui/art/icons/targetdummy_voriplasm_01.dds")

function Crutch.RemoveAttachedIconForUnit(unitTag, uniqueName)
    RemoveIconForUnit(unitTag, uniqueName)
end
-- /script CrutchAlerts.RemoveAttachedIconForUnit("player", "CrutchAlertsTest")

-- Recommend using this to clean up all mechanic icons upon leaving instance; unit
-- tags can change on rezone, so simply keeping track of tags may not be enough
function Crutch.RemoveAllAttachedIcons(uniqueName)
    for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        RemoveIconForUnit("group" .. tostring(i), uniqueName)
    end
    RemoveIconForUnit("player", uniqueName, true)
end
