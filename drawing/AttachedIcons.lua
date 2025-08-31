CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.Drawing = CrutchAlerts.Drawing or {}
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
Draw.unitIcons = unitIcons
-- /script d(CrutchAlerts.Drawing.unitIcons)

---------------------------------------------------------------------
-- Prioritization; logic for which icon to show
---------------------------------------------------------------------
local NORMAL_Y_OFFSET = 350 -- TODO: setting

local function RemoveAttachedIcon(key)
    Draw.RemoveWorldIcon(key)
end

-- Creates the actual 3D control with update function
local function CreateAttachedIcon(unitTag, texture, size, color, yOffset, callback)
    local _, x, y, z = GetUnitWorldPosition(unitTag)

    local function OnUpdate(control, setPositionFunc)
        local _, x, y, z = GetUnitWorldPosition(unitTag)
        setPositionFunc(x, y + yOffset, z)

        if (callback) then
            callback(control)
        end
    end
    local key = Draw.CreateWorldIcon(texture, x, y + yOffset, z, size / 150, size / 150, color, false, true, OnUpdate)

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

    unitIcons[unitTag].icons[uniqueName] = nil

    ReevaluatePrioritization(unitTag)
end

local function SetIconForUnit(unitTag, uniqueName, priority, texture, size, color, yOffset, callback)
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

    unitIcons[unitTag].icons[uniqueName] = {
        priority = priority,
        texture = texture,
        size = size or 100,
        color = color or {1, 1, 1, 1},
        yOffset = yOffset or NORMAL_Y_OFFSET,
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
    local tagsToDo = {}
    if (GetGroupSize() <= 1) then
        -- TODO: setting
        table.insert(tagsToDo, {unitTag = "player", role = GetSelectedLFGRole()})
    else
        for i = 1, GetGroupSize() do
            local tag = GetGroupUnitTagByIndex(i)
            if (IsUnitOnline(tag)) then
                -- TODO: roles options
                local role = GetGroupMemberSelectedRole(tag)
                if (role == LFG_ROLE_TANK or role == LFG_ROLE_HEAL) then
                    table.insert(tagsToDo, {unitTag = tag, role = role})
                end
            end
        end
    end

    local textures = {
        [LFG_ROLE_DPS] = "esoui/art/lfg/gamepad/lfg_roleicon_dps.dds",
        [LFG_ROLE_HEAL] = "esoui/art/lfg/gamepad/lfg_roleicon_healer.dds",
        [LFG_ROLE_TANK] = "esoui/art/lfg/gamepad/lfg_roleicon_tank.dds",
    }

    local colors = {
        [LFG_ROLE_DPS] = {1, 0.2, 0.2, 1},
        [LFG_ROLE_HEAL] = {1, 0.9, 0, 1},
        [LFG_ROLE_TANK] = {0, 0.6, 1, 1},
    }

    for _, player in ipairs(tagsToDo) do
        -- SetIconForUnit(unitTag, uniqueName, priority, texture, size, color)
        SetIconForUnit(player.unitTag,
            GROUP_ROLE_NAME,
            GROUP_ROLE_PRIORITY,
            textures[player.role],
            100,
            colors[player.role],
            NORMAL_Y_OFFSET)
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
end

---------------------------------------------------------------------
-- Corpse icons
local GROUP_DEAD_NAME = "CrutchAlertsGroupDead"
local GROUP_DEAD_PRIORITY = 110
local DEAD_Y_OFFSET = 100 -- TODO: setting

local function OnDeathStateChanged(_, unitTag, isDead)
    if (isDead) then
        local function Callback(control)
            local color
            if (IsUnitBeingResurrected(unitTag)) then
                color = {0.3, 0.7, 1, 1}
            elseif (DoesUnitHaveResurrectPending(unitTag)) then
                color = {1, 1, 1, 1}
            else
                color = {1, 0, 0, 1}
            end
            control:SetColor(unpack(color)) -- TODO: more efficient
        end

        SetIconForUnit(unitTag,
            GROUP_DEAD_NAME,
            GROUP_DEAD_PRIORITY,
            "esoui/art/icons/mapkey/mapkey_groupboss.dds",
            100,
            {1, 0, 0, 1},
            DEAD_Y_OFFSET,
            Callback)
    else
        RemoveIconForUnit(unitTag, GROUP_DEAD_NAME)
    end
end

---------------------------------------------------------------------
-- Crown
-- TODO: /esoui/art/icons/mapkey/mapkey_groupleader.dds

---------------------------------------------------------------------
local function RefreshGroup()
    DestroyAllRoleIcons()
    CreateGroupRoleIcons()

    playerGroupTag = nil
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if (AreUnitsEqual("player", tag)) then
            playerGroupTag = tag
        end
        if (IsUnitOnline(tag)) then
            OnDeathStateChanged(nil, tag, IsUnitDead(tag))
        end
    end
end
Draw.RefreshGroup = RefreshGroup
-- /script CrutchAlerts.Drawing.RefreshGroup()


---------------------------------------------------------------------
-- Built-in events
---------------------------------------------------------------------
local function InitializeAttachedIcons()
    -- Group changes
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupActivated", EVENT_PLAYER_ACTIVATED, RefreshGroup)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupJoined", EVENT_GROUP_MEMBER_JOINED, RefreshGroup)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupLeft", EVENT_GROUP_MEMBER_LEFT, RefreshGroup)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupUpdate", EVENT_GROUP_UPDATE, function() d("group update") RefreshGroup() end)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupRoleChanged", EVENT_GROUP_MEMBER_ROLE_CHANGED, RefreshGroup) -- TODO: could be more efficient
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupConnectedStatus", EVENT_GROUP_MEMBER_CONNECTED_STATUS, RefreshGroup) -- TODO: could be more efficient

    -- deadge
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "AttachedGroupDeathState", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end
Draw.InitializeAttachedIcons = InitializeAttachedIcons

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
end
Draw.UnregisterAttachedIcons = UnregisterAttachedIcons

---------------------------------------------------------------------

---------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------
-- Add an icon for a (likely group member) unit
-- unitTag - the unit tag, e.g. "group1". If grouped, trying to use "player" will automatically use the group unit tag instead
-- uniqueName - unique name, such as your addon name + mechanic name
-- priority - order in which icons are displayed. Higher number takes precedence. Built-in role icons are currently 100, built-in dead group member icons are 110
-- texture - path to the texture
-- size - size to display at. Default 100
-- color - color of the icon, in format {r, g, b, a}. Default {1, 1, 1, 1}
-- yOffset - Y offset for the icon, to not overlap with player. Default 350
function Crutch.SetAttachedIconForUnit(unitTag, uniqueName, priority, texture, size, color, yOffset)
    SetIconForUnit(unitTag, uniqueName, priority, texture, size, color, yOffset)
end
-- /script CrutchAlerts.SetAttachedIconForUnit("player", "CrutchAlertsTest", 200, "esoui/art/icons/targetdummy_voriplasm_01.dds")

function Crutch.RemoveAttachedIconForUnit(unitTag, uniqueName)
    RemoveIconForUnit(unitTag, uniqueName)
end
