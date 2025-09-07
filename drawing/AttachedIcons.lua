local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

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
-- Draw.unitIcons = unitIcons
-- /script d(CrutchAlerts.Drawing.unitIcons)

---------------------------------------------------------------------
-- Prioritization; logic for which icon to show
---------------------------------------------------------------------
local function RemoveAttachedIcon(key)
    Draw.RemoveWorldTexture(key)
end

-- Creates the actual 3D control with update function
local function CreateAttachedIcon(unitTag, texture, size, color, yOffset, callback)
    local _, x, y, z = GetUnitRawWorldPosition(unitTag)

    local function OnUpdate(control, setPositionFunc)
        local _, x, y, z = GetUnitRawWorldPosition(unitTag)
        setPositionFunc(x, y + yOffset, z)

        if (callback) then
            callback(control)
        end
    end

    local key = Draw.CreateWorldTexture(
        texture,
        x,
        y + yOffset,
        z,
        size / 150,
        size / 150,
        color,
        Crutch.savedOptions.drawing.attached.useDepthBuffers,
        true,
        nil,
        OnUpdate)

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
    local key = CreateAttachedIcon(unitTag, icon.texture, icon.size, icon.color, icon.yOffset, icon.callback)
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
    return unitTag == "player" or unitTag == playerGroupTag
end

local function RemoveIconForUnit(unitTag, uniqueName)
    if (unitTag == "player" and playerGroupTag) then
        unitTag = playerGroupTag
        Crutch.dbgSpam("Translating player tag to " .. playerGroupTag)
    end

    if (not unitIcons[unitTag]) then return end

    if (not unitIcons[unitTag].icons[uniqueName]) then
        -- d("|cFF0000No icon " .. uniqueName .. " for " .. unitTag .. "|r")
        return
    end

    Crutch.dbgSpam(string.format("RemoveIconForUnit %s (%s) %s was: |t100%%:100%%:%s|t", unitTag, GetUnitDisplayName(unitTag) or "???", uniqueName, unitIcons[unitTag].icons[uniqueName].texture))

    unitIcons[unitTag].icons[uniqueName] = nil

    ReevaluatePrioritization(unitTag)
end

local function SetIconForUnit(unitTag, uniqueName, priority, texture, size, color, yOffset, persistOutsideCombat, callback)
    if (unitTag == "player" and playerGroupTag) then
        unitTag = playerGroupTag
        Crutch.dbgSpam("Translating player tag to " .. playerGroupTag)
    end

    if (not unitIcons[unitTag]) then
        unitIcons[unitTag] = {
            icons = {}
        }
    end

    if (unitIcons[unitTag].icons[uniqueName]) then
        d(string.format("|cFFFF00Icon already exists for %s uniqueName %s, removing first and then replacing...|r", unitTag, uniqueName))
        RemoveIconForUnit(unitTag, uniqueName)
    end

    Crutch.dbgSpam(string.format("SetIconForUnit %s (%s) %s |t100%%:100%%:%s|t", unitTag, GetUnitDisplayName(unitTag) or "???", uniqueName, texture))

    if (not color) then
        color = {1, 1, 1}
    end

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
    }

    ReevaluatePrioritization(unitTag)
end

---------------------------------------------------------------------
-- Built-in icons
---------------------------------------------------------------------
-- LFG roles
local GROUP_ROLE_NAME = "CrutchAlertsGroupRole"
local GROUP_ROLE_PRIORITY = 100

local function CreateGroupRoleIcons()
    local showSelf = Crutch.savedOptions.drawing.attached.showSelfRole
    local tagsToDo = {}
    if (GetGroupSize() <= 1) then
        if (showSelf) then
            table.insert(tagsToDo, {unitTag = "player", role = GetSelectedLFGRole()})
        end
    else
        for i = 1, GetGroupSize() do
            local tag = GetGroupUnitTagByIndex(i)
            if (IsUnitOnline(tag) and (showSelf or not IsSelf(tag))) then
                local role = GetGroupMemberSelectedRole(tag)
                table.insert(tagsToDo, {unitTag = tag, role = role})
            end
        end
    end

    -- TODO: combine
    local textures = {
        [LFG_ROLE_DPS] = "esoui/art/lfg/gamepad/lfg_roleicon_dps.dds",
        [LFG_ROLE_HEAL] = "esoui/art/lfg/gamepad/lfg_roleicon_healer.dds",
        [LFG_ROLE_TANK] = "esoui/art/lfg/gamepad/lfg_roleicon_tank.dds",
    }

    local colors = {
        [LFG_ROLE_DPS] = Crutch.savedOptions.drawing.attached.dpsColor,
        [LFG_ROLE_HEAL] = Crutch.savedOptions.drawing.attached.healColor,
        [LFG_ROLE_TANK] = Crutch.savedOptions.drawing.attached.tankColor,
    }

    local options = {
        [LFG_ROLE_DPS] = Crutch.savedOptions.drawing.attached.showDps,
        [LFG_ROLE_HEAL] = Crutch.savedOptions.drawing.attached.showHeal,
        [LFG_ROLE_TANK] = Crutch.savedOptions.drawing.attached.showTank,
    }

    for _, player in ipairs(tagsToDo) do
        if (options[player.role]) then
            SetIconForUnit(player.unitTag,
                GROUP_ROLE_NAME,
                GROUP_ROLE_PRIORITY,
                textures[player.role],
                nil,
                colors[player.role],
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
local GROUP_DEAD_PRIORITY = 110
local DEAD_Y_OFFSET = 100

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

        local function Callback(control)
            local r, g, b
            if (IsUnitBeingResurrected(unitTag)) then
                r, g, b = unpack(Crutch.savedOptions.drawing.attached.rezzingColor)
            elseif (DoesUnitHaveResurrectPending(unitTag)) then
                r, g, b = unpack(Crutch.savedOptions.drawing.attached.pendingColor)
            else
                r, g, b = unpack(Crutch.savedOptions.drawing.attached.deadColor)
            end
            control:SetColor(r, g, b, Crutch.savedOptions.drawing.attached.opacity) -- TODO: more efficient
        end

        SetIconForUnit(unitTag,
            GROUP_DEAD_NAME,
            GROUP_DEAD_PRIORITY,
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

---------------------------------------------------------------------
-- Crown
local GROUP_CROWN_NAME = "CrutchAlertsGroupCrown"
local GROUP_CROWN_PRIORITY = 105
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
        GROUP_CROWN_PRIORITY,
        "esoui/art/icons/mapkey/mapkey_groupleader.dds",
        nil,
        Crutch.savedOptions.drawing.attached.crownColor,
        nil,
        true)
end

---------------------------------------------------------------------
local function RefreshGroup()
    -- Roles
    DestroyAllRoleIcons()
    CreateGroupRoleIcons()

    playerGroupTag = nil

    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if (AreUnitsEqual("player", tag)) then
            playerGroupTag = tag
        end

        -- Deaths
        if (IsUnitOnline(tag)) then
            OnDeathStateChanged(nil, tag, IsUnitDead(tag))
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
    OnDeathStateChanged(nil, "player", IsUnitDead("player"))
end
Draw.RefreshGroup = RefreshGroup
-- /script CrutchAlerts.Drawing.RefreshGroup()


---------------------------------------------------------------------
-- Built-in events
---------------------------------------------------------------------
local hooked = false
local function InitializeAttachedIcons()
    -- Group changes
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupActivated", EVENT_PLAYER_ACTIVATED, RefreshGroup)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupJoined", EVENT_GROUP_MEMBER_JOINED, RefreshGroup)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupLeft", EVENT_GROUP_MEMBER_LEFT, RefreshGroup)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupUpdate", EVENT_GROUP_UPDATE, function() Crutch.dbgOther("group update") RefreshGroup() end)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupRoleChanged", EVENT_GROUP_MEMBER_ROLE_CHANGED, RefreshGroup) -- TODO: could be more efficient
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupConnectedStatus", EVENT_GROUP_MEMBER_CONNECTED_STATUS, RefreshGroup) -- TODO: could be more efficient

    -- deadge
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "AttachedGroupDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedPlayerDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "AttachedPlayerDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    -- Self role change
    if (not hooked) then
        ZO_PostHook("UpdateSelectedLFGRole", RefreshGroup)
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
-- priority - order in which icons are displayed. Higher number takes precedence. Built-in role icons are currently 100, crown is 105, dead group member icons are 110
-- texture - path to the texture
-- size - size to display at. Default 100, but set via user settings
-- color - color of the icon, in format {r, g, b, a}. To use the user setting for alpha, leave out a, e.g. {1, 0.4, 0.8}
-- persistOutsideCombat - whether to keep this icon when exiting combat. Otherwise, icon is removed when all group members exit combat. Default false. Note: if the group isn't already in combat, the icon will still show, because it's only removed on combat exit
function Crutch.SetAttachedIconForUnit(unitTag, uniqueName, priority, texture, size, color, persistOutsideCombat)
    SetIconForUnit(unitTag, uniqueName, priority, texture, size, color, persistOutsideCombat)
end
-- /script CrutchAlerts.SetAttachedIconForUnit("player", "CrutchAlertsTest", 200, "esoui/art/icons/targetdummy_voriplasm_01.dds")

function Crutch.RemoveAttachedIconForUnit(unitTag, uniqueName)
    RemoveIconForUnit(unitTag, uniqueName)
end
-- /script CrutchAlerts.RemoveAttachedIconForUnit("player", "CrutchAlertsGroupDead")
