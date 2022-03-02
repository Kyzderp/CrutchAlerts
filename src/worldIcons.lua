CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
local function GetFalgravnIconsSize()
    return Crutch.savedOptions.kynesaegis.falgravnIconsSize
end

local function GetLokkIconsSize()
    return Crutch.savedOptions.sunspire.lokkIconsSize
end

local function GetYolIconsSize()
    return Crutch.savedOptions.sunspire.yolIconsSize
end

---------------------------------------------------------------------
local icons = {}

local data = {
    ["Falgravn2ndFloor1"] = {x = 24668, y = 14569, z = 9631, texture = "odysupporticons/icons/squares/squaretwo_blue_one.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}},
    ["Falgravn2ndFloor2"] = {x = 24654, y = 14569, z = 10398, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}},
    ["Falgravn2ndFloor3"] = {x = 25441, y = 14569, z = 10370, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}},
    ["Falgravn2ndFloor4"] = {x = 25468, y = 14569, z = 9620, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}},

    ["LokkBeam1"] = {x = 115110, y = 56100, z = 107060, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["LokkBeam2"] = {x = 114320, y = 56100, z = 107060, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["LokkBeam3"] = {x = 114320, y = 56100, z = 106390, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["LokkBeam4"] = {x = 115110, y = 56100, z = 106390, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["LokkBeam5"] = {x = 115110, y = 56100, z = 105760, texture = "odysupporticons/icons/squares/squaretwo_red_five.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["LokkBeam6"] = {x = 114320, y = 56100, z = 105760, texture = "odysupporticons/icons/squares/squaretwo_red_six.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["LokkBeam7"] = {x = 114320, y = 56100, z = 105090, texture = "odysupporticons/icons/squares/squaretwo_red_seven.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["LokkBeam8"] = {x = 115110, y = 56100, z = 105090, texture = "odysupporticons/icons/squares/squaretwo_red_eight.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["LokkBeamLH"] = {x = 115500, y = 56100, z = 106725, texture = "odysupporticons/icons/squares/squaretwo_yellow.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["LokkBeamRH"] = {x = 115500, y = 56100, z = 105425, texture = "odysupporticons/icons/squares/squaretwo_yellow.dds", size = GetLokkIconsSize, color = {1, 1, 1}},

    -- ["YolWing1"] = {x = 96021, y = 49697, z = 108422, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolWing2"] = {x = 97803, y = 49685, z = 108988, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolWing3"] = {x = 97121, y = 49722, z = 110613, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolWing4"] = {x = 95580, y = 49669, z = 110308, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    -- ["YolHead1"] = {x = 96004, y = 49690, z = 109008, texture = "odysupporticons/icons/squares/squaretwo_blue_one.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolHead2"] = {x = 97188, y = 49703, z = 109064, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolHead3"] = {x = 97196, y = 49689, z = 110024, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolHead4"] = {x = 96109, y = 49669, z = 110270, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = GetYolIconsSize, color = {1, 1, 1}},
}


---------------------------------------------------------------------
function Crutch.WorldIconsEnabled()
    return OSI ~= nil and OSI.CreatePositionIcon ~= nil
end

---------------------------------------------------------------------
function Crutch.EnableIcon(name)
    if (not Crutch.WorldIconsEnabled()) then
        return
    end

    if (icons[name]) then
        Crutch.dbgOther("|cFF0000Icon already enabled " .. name .. "|r")
        return
    end

    local iconData = data[name]
    if (not iconData) then
        d("|cFF0000Invalid icon name " .. name .. "|r")
        return
    end

    local icon = OSI.CreatePositionIcon(iconData.x, iconData.y, iconData.z, iconData.texture, iconData.size(), iconData.color)
    icons[name] = icon
end

function Crutch.DisableIcon(name)
    if (not Crutch.WorldIconsEnabled()) then
        return
    end

    if (not icons[name]) then
        return
    end

    OSI.DiscardPositionIcon(icons[name])
    icons[name] = nil
end
