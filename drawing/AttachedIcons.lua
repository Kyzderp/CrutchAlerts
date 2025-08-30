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
        icons = {
            [uniqueName] = {
                key = key,
                priority = 0, -- Higher shows before lower
            },
        },
    },
}
]]
local unitIcons = {}

---------------------------------------------------------------------
-- Internal API
---------------------------------------------------------------------
local Y_OFFSET = 300 -- TODO: setting

local function RemoveIconForUnit(unitTag, uniqueName)
    if (not unitIcons[unitTag]) then return end

    if (not unitIcons[unitTag].icons[uniqueName]) then
        d("|cFF0000No icon " .. uniqueName .. " for " .. unitTag .. "|r")
        return
    end

    Draw.RemoveWorldIcon(unitIcons[unitTag].icons[uniqueName].key)
    unitIcons[unitTag] = nil
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

    size = size or 150
    color = color or {1, 1, 1, 1}

    local _, x, y, z = GetUnitWorldPosition(unitTag)

    local function OnUpdate(control, setPositionFunc)
        local _, x, y, z = GetUnitWorldPosition(unitTag)
        setPositionFunc(x, y + Y_OFFSET, z)
    end
    local key = Draw.CreateWorldIcon(texture, x, y + Y_OFFSET, z, size / 150, size / 150, color, false, true, OnUpdate)

    unitIcons[unitTag].icons[uniqueName] = {
        key = key,
        priority = priority,
    }
end


---------------------------------------------------------------------
-- Built-in icons
---------------------------------------------------------------------
-- TODO: if something calls "player"

local function CreateGroupRoleIcons()
    local tagsToDo = {}
    if (GetGroupSize() <= 1) then
        -- TODO: setting
        table.insert(tagsToDo, {unitTag = "player", role = GetSelectedLFGRole()})
    else
        for i = 1, GetGroupSize() do
            local tag = GetGroupUnitTagByIndex(i)
            -- TODO: roles options
            local role = GetGroupMemberSelectedRole(tag)
            if (role == LFG_ROLE_TANK or role == LFG_ROLE_HEAL) then
                table.insert(tagsToDo, {unitTag = tag, role = role})
            end
        end
    end

    local textures = {
        [LFG_ROLE_DPS] = "esoui/art/lfg/gamepad/lfg_roleicon_dps.dds",
        [LFG_ROLE_HEAL] = "esoui/art/lfg/gamepad/lfg_roleicon_healer.dds",
        [LFG_ROLE_TANK] = "esoui/art/lfg/gamepad/lfg_roleicon_tank.dds",
    }

    local colors = {
        [LFG_ROLE_DPS] = {1, 0.2, 0.2},
        [LFG_ROLE_HEAL] = {1, 0.9, 0, 1},
        [LFG_ROLE_TANK] = {0, 0.6, 1, 1},
    }

    for _, player in ipairs(tagsToDo) do
        -- SetIconForUnit(unitTag, uniqueName, priority, texture, size, color)
        SetIconForUnit(player.unitTag,
            "CrutchAlertsGroupRole",
            1,
            textures[player.role],
            100,
            colors[player.role])
    end
end
Draw.CreateGroupRoleIcons = CreateGroupRoleIcons
-- /script CrutchAlerts.Drawing.CreateGroupRoleIcons()

---------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------

