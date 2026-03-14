local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Message to user
---------------------------------------------------------------------
local queuedMessages = {}
function Crutch.msg(msg)
    if (not msg) then return end
    msg = "|c3bdb5e[CrutchAlerts]|caaaaaa " .. tostring(msg) .. "|r"
    if (CHAT_ROUTER) then
        CHAT_ROUTER:AddSystemMessage(msg)
    else
        table.insert(queuedMessages, msg)
    end
end

function Crutch.Warn(msg)
    if (not msg) then return end
    local chatWarning = "|c3bdb5e[CrutchAlerts] |cFF0000W" ..
                        "|cFF7F00A" ..
                        "|cFFFF00R" ..
                        "|c00FF00N" ..
                        "|c0000FFI" ..
                        "|c2E2B5FN" ..
                        "|c8B00FFG" ..
                        "|cFF00FF: " .. msg .. "|r"
    if (CHAT_ROUTER) then
        CHAT_ROUTER:AddSystemMessage(chatWarning)
    else
        table.insert(queuedMessages, chatWarning)
    end
end

function Crutch.ShowQueuedMessages()
    if (CHAT_ROUTER) then
        for _, msg in ipairs(queuedMessages) do
            CHAT_ROUTER:AddSystemMessage(msg)
        end
    end
end

---------------------------------------------------------------------
-- Getting lang string with caps format
---------------------------------------------------------------------
function Crutch.GetCapitalizedString(id)
    return zo_strformat("<<C:1>>", GetString(id))
end

---------------------------------------------------------------------
-- Distance
---------------------------------------------------------------------
function Crutch.GetSquaredDistance(x1, y1, z1, x2, y2, z2)
    local dx = x1 - x2
    local dy = y1 - y2
    local dz = z1 - z2
    return dx * dx + dy * dy + dz * dz
end

function Crutch.GetUnitTagsDistance(unitTag1, unitTag2)
    if (unitTag1 == unitTag2) then return 0 end
    local p1zone, p1x, p1y, p1z = GetUnitWorldPosition(unitTag1)
    local p2zone, p2x, p2y, p2z = GetUnitWorldPosition(unitTag2)
    if (p1zone ~= p2zone) then
        return 2147483647
    end
    return zo_sqrt(Crutch.GetSquaredDistance(p1x, p1y, p1z, p2x, p2y, p2z)) / 100
end


---------------------------------------------------------------------
-- HSL to RGB
-- https://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion
---------------------------------------------------------------------
local function HueToRGB(p, q, t)
    if (t < 0) then t = t + 1 end
    if (t > 1) then t = t - 1 end
    if (t < 1 / 6) then
        return p + (q - p) * 6 * t
    end
    if (t < 0.5) then
        return q
    end
    if (t < 2 / 3) then
        return p + (q - p) * (2 / 3 - t) * 6
    end
    return p
end

-- ZOS has RGB to HSL but not backwards :sadge:
function Crutch.ConvertHSLToRGB(h, s, l)
    if (saturation == 0) then
        return l, l, l
    else
        local q = (l < 0.5) and (l * (1 + s)) or (l + s - l * s)
        local p = 2 * l - q
        return HueToRGB(p, q, h + 1 / 3), HueToRGB(p, q, h), HueToRGB(p, q, h - 1 / 3)
    end
end


---------------------------------------------------------------------
-- Roles stored in 3 bits
-- Tank, Healer, DPS
---------------------------------------------------------------------
local BITMASKS = {
    [LFG_ROLE_TANK] = 4,
    [LFG_ROLE_HEAL] = 2,
    [LFG_ROLE_DPS] = 1,
}

local function IsValidRole(role)
    return BITMASKS[role] ~= nil
end
Crutch.IsValidRole = IsValidRole

-- Whether the specified role's bit is set in the setting
-- Returns true or false, or nil if the role is not valid
local function IsRoleSet(setting, role)
    if (not IsValidRole(role)) then
        return nil
    end

    return BitAnd(setting, BITMASKS[role]) ~= 0
end
Crutch.IsRoleSet = IsRoleSet

local function WithRoles(tank, healer, dps)
    return (tank and BITMASKS[LFG_ROLE_TANK] or 0) + (healer and BITMASKS[LFG_ROLE_HEAL] or 0) + (dps and BITMASKS[LFG_ROLE_DPS] or 0)
end

-- Converts a value like 6 to {LFG_ROLE_TANK, LFG_ROLE_HEAL}
local function RoleValueToTable(setting)
    local tab = {}
    for role, _ in pairs(BITMASKS) do
        if (IsRoleSet(setting, role)) then
            table.insert(tab, role)
        end
    end
    return tab
end
Crutch.RoleValueToTable = RoleValueToTable

-- Converts a table like {LFG_ROLE_TANK, LFG_ROLE_HEAL} to 6
local function RoleTableToValue(tab)
    local tank, healer, dps
    for _, role in ipairs(tab) do -- Surely there's a nicer way, but lazy atm
        if (role == LFG_ROLE_TANK) then tank = true end
        if (role == LFG_ROLE_HEAL) then healer = true end
        if (role == LFG_ROLE_DPS) then dps = true end
    end
    return WithRoles(tank, healer, dps)
end
Crutch.RoleTableToValue = RoleTableToValue


---------------------------------------------------------------------
-- Role conversion for LAM, since multiSelect is currently broken
-- with choicesValues
---------------------------------------------------------------------
local ROLE_STRING_TO_CONSTANT = {
    Tank = LFG_ROLE_TANK,
    Healer = LFG_ROLE_HEAL,
    DPS = LFG_ROLE_DPS,
}

local ROLE_CONSTANT_TO_STRING = {
    [LFG_ROLE_TANK] = "Tank",
    [LFG_ROLE_HEAL] = "Healer",
    [LFG_ROLE_DPS] = "DPS",
}

-- choices = {"Tank", "Healer", "DPS"}
-- values = choices
-- returns 7
local function ConvertRoleStringsToValue(values)
    local result = {}
    for _, roleString in ipairs(values) do
        table.insert(result, ROLE_STRING_TO_CONSTANT[roleString])
    end
    return RoleTableToValue(result)
end
Crutch.ConvertRoleStringsToValue = ConvertRoleStringsToValue

-- setting = 7
-- returns {"Tank", "Healer", "DPS"}
local function ConvertRoleValueToStrings(setting)
    local tab = RoleValueToTable(setting)
    -- Should be fine to just change in place
    for i, role in ipairs(tab) do
        tab[i] = ROLE_CONSTANT_TO_STRING[role]
    end
    return tab
end
Crutch.ConvertRoleValueToStrings = ConvertRoleValueToStrings

-- Console settings
local ROLE_SETTING_TO_STRING = {
    [0] = "Off",
    [1] = "DPS",
    [2] = "Healer",
    [3] = "Healer + DPS",
    [4] = "Tank",
    [5] = "Tank + DPS",
    [6] = "Tank + Healer",
    [7] = "All roles",
}
local function ConvertRoleValueToConsoleString(setting)
    return ROLE_SETTING_TO_STRING[setting]
end
Crutch.ConvertRoleValueToConsoleString = ConvertRoleValueToConsoleString
