local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Message to user
---------------------------------------------------------------------
Crutch.messages = {}
function Crutch.msg(msg)
    if (not msg) then return end
    msg = "|c3bdb5e[CrutchAlerts]|caaaaaa " .. tostring(msg) .. "|r"
    if (CHAT_ROUTER) then
        CHAT_ROUTER:AddSystemMessage(msg)
    else
        Crutch.messages[#Crutch.messages + 1] = msg
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
