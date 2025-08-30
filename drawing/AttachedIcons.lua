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
            },
        },
    },
}
]]
local unitIcons = {}

---------------------------------------------------------------------
-- Prioritization; logic for which icon to show
---------------------------------------------------------------------
local Y_OFFSET = 300 -- TODO: setting

local function RemoveAttachedIcon(key)
    Draw.RemoveWorldIcon(key)
end

local function CreateAttachedIcon(unitTag, texture, size, color)
    local _, x, y, z = GetUnitWorldPosition(unitTag)

    local function OnUpdate(control, setPositionFunc)
        local _, x, y, z = GetUnitWorldPosition(unitTag)
        setPositionFunc(x, y + Y_OFFSET, z)
    end
    local key = Draw.CreateWorldIcon(texture, x, y + Y_OFFSET, z, size / 150, size / 150, color, false, true, OnUpdate)

    return key
end

local function ReevaluatePrioritization(unitTag)
    if (not unitIcons[unitTag]) then return end

    local highestPriority = 0
    local highestName
    for uniqueName, iconData in pairs(unitIcons[unitTag].icons) do
        if (iconData.priority > highestPriority) then
            highestPriority = iconData.priority
            highestName = uniqueName
        end
    end

    local currentKey = unitIcons[unitTag].key

    -- No icons
    if (not highestName) then
        if (currentKey) then
            RemoveAttachedIcon(currentKey)
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
    local key = CreateAttachedIcon(unitTag, icon.texture, icon.size, icon.color)
    unitIcons[unitTag].key = key
    unitIcons[unitTag].active = highestName
end


---------------------------------------------------------------------
-- Internal API
---------------------------------------------------------------------
local function RemoveIconForUnit(unitTag, uniqueName)
    if (not unitIcons[unitTag]) then return end

    if (not unitIcons[unitTag].icons[uniqueName]) then
        d("|cFF0000No icon " .. uniqueName .. " for " .. unitTag .. "|r")
        return
    end

    RemoveAttachedIcon(unitIcons[unitTag].key)
    unitIcons[unitTag] = nil

    ReevaluatePrioritization(unitTag)
end

local function SetIconForUnit(unitTag, uniqueName, priority, texture, size, color)
    if (not unitIcons[unitTag]) then
        unitIcons[unitTag] = {
            icons = {}
        }
    end

    if (unitIcons[unitTag].icons[uniqueName]) then
        d(string.format("|cFFFF00Icon already exists for %s uniqueName %s, removing first and then replacing...|r", unitTag, uniqueName))
        RemoveIconForUnit(unitTag, uniqueName)
    end

    unitIcons[unitTag].key = key
    unitIcons[unitTag].icons[uniqueName] = {
        priority = priority,
        texture = texture,
        size = size or 100,
        color = color or {1, 1, 1, 1},
    }

    ReevaluatePrioritization(unitTag)
end

---------------------------------------------------------------------
-- Built-in icons
---------------------------------------------------------------------
-- TODO: if something calls "player"
local GROUP_ROLE_NAME = "CrutchAlertsGroupRole"

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
            1,
            textures[player.role],
            100,
            colors[player.role])
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

local function RefreshGroup()
    DestroyAllRoleIcons()
    CreateGroupRoleIcons()
end
Draw.RefreshGroup = RefreshGroup
-- /script CrutchAlerts.Drawing.RefreshGroup()


---------------------------------------------------------------------
---------------------------------------------------------------------
local function InitializeAttachedIcons()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupActivated", EVENT_PLAYER_ACTIVATED, RefreshGroup)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupJoined", EVENT_GROUP_MEMBER_JOINED, RefreshGroup)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupLeft", EVENT_GROUP_MEMBER_LEFT, RefreshGroup)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupUpdate", EVENT_GROUP_UPDATE, function() d("group update") RefreshGroup() end)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupRoleChanged", EVENT_GROUP_MEMBER_ROLE_CHANGED, RefreshGroup) -- TODO: could be more efficient
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AttachedGroupConnectedStatus", EVENT_GROUP_MEMBER_CONNECTED_STATUS, RefreshGroup) -- TODO: could be more efficient
end
Draw.InitializeAttachedIcons = InitializeAttachedIcons

---------------------------------------------------------------------

---------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------

