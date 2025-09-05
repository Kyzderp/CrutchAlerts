CrutchAlerts = CrutchAlerts or {}
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
