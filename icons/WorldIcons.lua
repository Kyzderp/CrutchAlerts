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

local function GetTripletsIconSize()
    return Crutch.savedOptions.hallsoffabrication.tripletsIconSize
end

local function GetAGIconsSize()
    return Crutch.savedOptions.hallsoffabrication.agIconsSize * 0.8
end

local function GetAnsuulIconSize()
    return Crutch.savedOptions.sanitysedge.ansuulIconSize
end

local function GetOrphicIconSize()
    return Crutch.savedOptions.lucentcitadel.orphicIconSize * 0.8 -- Round icons from code take up the full texture but appear smaller
    -- 0.7 for my old full square icons
end

local function GetOrphicNumIconSize()
    return Crutch.savedOptions.lucentcitadel.orphicIconSize
end

local function GetZhajIconsSize()
    return Crutch.savedOptions.mawoflorkhaj.zhajIconSize
end

---------------------------------------------------------------------
local icons = {}

local data = {
    ["Falgravn2ndFloor1"] = {x = 24668, y = 14569, z = 9631, texture = "odysupporticons/icons/squares/squaretwo_blue_one.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}},
    ["Falgravn2ndFloor2"] = {x = 24654, y = 14569, z = 10398, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}},
    ["Falgravn2ndFloor3"] = {x = 25441, y = 14569, z = 10370, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}},
    ["Falgravn2ndFloor4"] = {x = 25468, y = 14569, z = 9620, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}},

    -- Traditional Lokkestiiz
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

    -- Solo Healer Lokkestiiz from Floliroy
    ["SHLokkBeam1"] = {x = 113880, y = 56100, z = 106880, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["SHLokkBeam2"] = {x = 114080, y = 56100, z = 106360, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["SHLokkBeam3"] = {x = 114080, y = 56100, z = 105640, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["SHLokkBeam4"] = {x = 113880, y = 56100, z = 105120, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["SHLokkBeam5"] = {x = 114480, y = 56100, z = 107200, texture = "odysupporticons/icons/squares/squaretwo_red_five.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["SHLokkBeam6"] = {x = 114650, y = 56100, z = 106570, texture = "odysupporticons/icons/squares/squaretwo_red_six.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["SHLokkBeam7"] = {x = 114650, y = 56100, z = 105460, texture = "odysupporticons/icons/squares/squaretwo_red_seven.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["SHLokkBeam8"] = {x = 114480, y = 56100, z = 104880, texture = "odysupporticons/icons/squares/squaretwo_red_eight.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["SHLokkBeam9"] = {x = 114730, y = 56100, z = 106050, texture = "odysupporticons/icons/squares/squaretwo_red.dds", size = GetLokkIconsSize, color = {1, 1, 1}},
    ["SHLokkBeamH"] = {x = 116400, y = 56100, z = 106050, texture = "odysupporticons/icons/squares/squaretwo_yellow.dds", size = GetLokkIconsSize, color = {1, 1, 1}},

    -- ["YolWing1"] = {x = 96021, y = 49697, z = 108422, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolWing2"] = {x = 97803, y = 49685, z = 108988, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolWing3"] = {x = 97121, y = 49722, z = 110613, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolWing4"] = {x = 95580, y = 49669, z = 110308, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    -- ["YolHead1"] = {x = 96004, y = 49690, z = 109008, texture = "odysupporticons/icons/squares/squaretwo_blue_one.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolHead2"] = {x = 97188, y = 49703, z = 109064, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolHead3"] = {x = 97196, y = 49689, z = 110024, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolHead4"] = {x = 96109, y = 49669, z = 110270, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    -- Left Yolnahkriin from B7TxSpeed
    ["YolLeftWing2"] = {x = 96409, y = 49689, z = 108324, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolLeftWing3"] = {x = 97863, y = 49695, z = 109303, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolLeftWing4"] = {x = 96867, y = 49700, z = 110960, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolLeftHead2"] = {x = 96827, y = 49689, z = 108889, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolLeftHead3"] = {x = 97502, y = 49704, z = 109702, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = GetYolIconsSize, color = {1, 1, 1}},
    ["YolLeftHead4"] = {x = 96498, y = 49694, z = 110533, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = GetYolIconsSize, color = {1, 1, 1}},

    -- Dreadsail Reef
    -- ["1"] = {x = 165854, y = 39829, z = 82552, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = 100, color = {1, 1, 1}},
    -- ["1"] = {x = 169034, y = 39803, z = 76927, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = 100, color = {1, 1, 1}},
    -- ["1"] = {x = 175531, y = 39838, z = 77263, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = 100, color = {1, 1, 1}},
    -- ["1"] = {x = 179205, y = 39803, z = 82502, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = 100, color = {1, 1, 1}},
    -- ["1"] = {x = 175853, y = 39827, z = 87736, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = 100, color = {1, 1, 1}},
    -- ["1"] = {x = 168984, y = 39803, z = 87860, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = 100, color = {1, 1, 1}},

    -- Halls of Fabrication
    ["TripletsSafe"] = {x = 29758, y = 52950, z = 73169, texture = "odysupporticons/icons/emoji-poop.dds", size = GetTripletsIconSize, color = {1, 1, 1}},

    -- Assembly General
    ["AGN"] = {x = 75001, y = 54955, z = 69658, texture = "CrutchAlerts/icons/assets/N.dds", size = GetAGIconsSize, color = {1, 1, 1}},
    ["AGNE"] = {x = 75610, y = 54919, z = 69394, texture = "odysupporticons/icons/squares/squaretwo_green_one.dds", size = GetAGIconsSize, color = {1, 1, 1}},
    ["AGE"] = {x = 75380, y = 54955, z = 69982, texture = "CrutchAlerts/icons/assets/E.dds", size = GetAGIconsSize, color = {1, 1, 1}},
    ["AGSE"] = {x = 75601, y = 54919, z = 70600, texture = "odysupporticons/icons/squares/squaretwo_green_two.dds", size = GetAGIconsSize, color = {1, 1, 1}},
    ["AGS"] = {x = 75006, y = 54956, z = 70319, texture = "CrutchAlerts/icons/assets/S.dds", size = GetAGIconsSize, color = {1, 1, 1}},
    ["AGSW"] = {x = 74410, y = 54918, z = 70614, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetAGIconsSize, color = {1, 1, 1}},
    ["AGW"] = {x = 74630, y = 54956, z = 70005, texture = "CrutchAlerts/icons/assets/W.dds", size = GetAGIconsSize, color = {1, 1, 1}},
    ["AGNW"] = {x = 74405, y = 54919, z = 69422, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetAGIconsSize, color = {1, 1, 1}},

    -- Sanity's Edge
    ["AnsuulCenter"] = {x = 200093, y = 30199, z = 40023, texture = "odysupporticons/icons/emoji-poop.dds", size = GetAnsuulIconSize, color = {1, 1, 1}},

    -- Mirrors on Orphic Shattered Shard
    ["OrphicN"] = {x = 149348, y = 22880, z = 85334, texture = "CrutchAlerts/icons/assets/N.dds", size = GetOrphicIconSize, color = {1, 1, 1}},
    ["OrphicNE"] = {x = 151041, y = 22880, z = 86169, texture = "CrutchAlerts/icons/assets/NE.dds", size = GetOrphicIconSize, color = {1, 1, 1}},
    ["OrphicE"] = {x = 151956, y = 22880, z = 87950, texture = "CrutchAlerts/icons/assets/E.dds", size = GetOrphicIconSize, color = {1, 1, 1}},
    ["OrphicSE"] = {x = 151169, y = 22880, z = 89708, texture = "CrutchAlerts/icons/assets/SE.dds", size = GetOrphicIconSize, color = {1, 1, 1}},
    ["OrphicS"] = {x = 149272, y = 22880, z = 90657, texture = "CrutchAlerts/icons/assets/S.dds", size = GetOrphicIconSize, color = {1, 1, 1}},
    ["OrphicSW"] = {x = 147477, y = 22880, z = 89756, texture = "CrutchAlerts/icons/assets/SW.dds", size = GetOrphicIconSize, color = {1, 1, 1}},
    ["OrphicW"] = {x = 146628, y = 22880, z = 87851, texture = "CrutchAlerts/icons/assets/W.dds", size = GetOrphicIconSize, color = {1, 1, 1}},
    ["OrphicNW"] = {x = 147488, y = 22880, z = 86178, texture = "CrutchAlerts/icons/assets/NW.dds", size = GetOrphicIconSize, color = {1, 1, 1}},

    ["OrphicNum1"] = {x = 149348, y = 22867, z = 85334, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetOrphicNumIconSize, color = {1, 1, 1}},
    ["OrphicNum2"] = {x = 151041, y = 22864, z = 86169, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetOrphicNumIconSize, color = {1, 1, 1}},
    ["OrphicNum3"] = {x = 151956, y = 22867, z = 87950, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetOrphicNumIconSize, color = {1, 1, 1}},
    ["OrphicNum4"] = {x = 151169, y = 22864, z = 89708, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetOrphicNumIconSize, color = {1, 1, 1}},
    ["OrphicNum5"] = {x = 149272, y = 22868, z = 90657, texture = "odysupporticons/icons/squares/squaretwo_red_five.dds", size = GetOrphicNumIconSize, color = {1, 1, 1}},
    ["OrphicNum6"] = {x = 147477, y = 22869, z = 89756, texture = "odysupporticons/icons/squares/squaretwo_red_six.dds", size = GetOrphicNumIconSize, color = {1, 1, 1}},
    ["OrphicNum7"] = {x = 146628, y = 22867, z = 87851, texture = "odysupporticons/icons/squares/squaretwo_red_seven.dds", size = GetOrphicNumIconSize, color = {1, 1, 1}},
    ["OrphicNum8"] = {x = 147488, y = 22868, z = 86178, texture = "odysupporticons/icons/squares/squaretwo_red_eight.dds", size = GetOrphicNumIconSize, color = {1, 1, 1}},

    -- Zhaj'hassa
    -- except these are terrible... WIP
    ["ZhajM1"] = {x = 103036, y = 45930, z = 128336, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetZhajIconsSize, color = {1, 1, 1}},
    ["ZhajM2"] = {x = 103134, y = 45919, z = 127905, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetZhajIconsSize, color = {1, 1, 1}},
    ["ZhajM3"] = {x = 102853, y = 45947, z = 127674, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetZhajIconsSize, color = {1, 1, 1}},
    ["ZhajM4"] = {x = 102563, y = 45948, z = 127971, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetZhajIconsSize, color = {1, 1, 1}},
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
        Crutch.dbgOther("|cFF0000Invalid icon name " .. name .. "|r")
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
