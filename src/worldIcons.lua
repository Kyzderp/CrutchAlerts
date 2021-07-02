CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
local icons = {}

local data = {
    ["Falgravn2ndFloor1"] = {x = 24668, y = 14569, z = 9631, texture = "odysupporticons/icons/squares/squaretwo_blue_one.dds", size = 200, color = {1, 1, 1}},
    ["Falgravn2ndFloor2"] = {x = 24654, y = 14569, z = 10398, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = 200, color = {1, 1, 1}},
    ["Falgravn2ndFloor3"] = {x = 25441, y = 14569, z = 10370, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = 200, color = {1, 1, 1}},
    ["Falgravn2ndFloor4"] = {x = 25468, y = 14569, z = 9620, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = 200, color = {1, 1, 1}},
}


---------------------------------------------------------------------
function Crutch.EnableIcon(name)
    if (not OSI or not OSI.CreatePositionIcon) then
        d("|cFF0000Requires OdySupportIcons to display in-world icons|r")
        return
    end

    local iconData = data[name]
    if (not iconData) then
        d("|cFF0000Invalid icon name " .. name .. "|r")
        return
    end

    local icon = OSI.CreatePositionIcon(iconData.x, iconData.y, iconData.z, iconData.texture, iconData.size, iconData.color)
    icons[name] = icon
end

function Crutch.DisableIcon(name)
    if (not OSI or not OSI.CreatePositionIcon) then
        return
    end

    if (not icons[name]) then
        return
    end

    OSI.DiscardPositionIcon(icons[name])
    icons[name] = nil
end
