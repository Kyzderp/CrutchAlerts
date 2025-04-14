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

local function GetCavotIconSize()
    return Crutch.savedOptions.lucentcitadel.cavotIconSize
end

local function GetOrphicIconSize()
    return Crutch.savedOptions.lucentcitadel.orphicIconSize * 0.8 -- Round icons from code take up the full texture but appear smaller
    -- 0.7 for my old full square icons
end

local function GetOrphicNumIconSize()
    return Crutch.savedOptions.lucentcitadel.orphicIconSize
end

local function GetTempestIconsSize()
    return Crutch.savedOptions.lucentcitadel.tempestIconsSize
end

local function GetZhajIconsSize()
    return Crutch.savedOptions.mawoflorkhaj.zhajIconSize
end

---------------------------------------------------------------------
local icons = {}

local data = {
    ["Falgravn2ndFloor1"] = {x = 24668, y = 14569, z = 9631, texture = "odysupporticons/icons/squares/squaretwo_blue_one.dds", size = GetFalgravnIconsSize},
    ["Falgravn2ndFloor2"] = {x = 24654, y = 14569, z = 10398, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = GetFalgravnIconsSize},
    ["Falgravn2ndFloor3"] = {x = 25441, y = 14569, z = 10370, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = GetFalgravnIconsSize},
    ["Falgravn2ndFloor4"] = {x = 25468, y = 14569, z = 9620, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = GetFalgravnIconsSize},
    ["Falgravn2ndFloorH1"] = {x = 24268, y = 14569, z = 10000, texture = "odysupporticons/icons/squares/squaretwo_orange_one.dds", size = GetFalgravnIconsSize},
    ["Falgravn2ndFloorH2"] = {x = 25838, y = 14569, z = 10000, texture = "odysupporticons/icons/squares/squaretwo_orange_two.dds", size = GetFalgravnIconsSize},

    -- Traditional Lokkestiiz
    ["LokkBeam1"] = {x = 115110, y = 56100, z = 107060, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetLokkIconsSize},
    ["LokkBeam2"] = {x = 114320, y = 56100, z = 107060, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetLokkIconsSize},
    ["LokkBeam3"] = {x = 114320, y = 56100, z = 106390, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetLokkIconsSize},
    ["LokkBeam4"] = {x = 115110, y = 56100, z = 106390, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetLokkIconsSize},
    ["LokkBeam5"] = {x = 115110, y = 56100, z = 105760, texture = "odysupporticons/icons/squares/squaretwo_red_five.dds", size = GetLokkIconsSize},
    ["LokkBeam6"] = {x = 114320, y = 56100, z = 105760, texture = "odysupporticons/icons/squares/squaretwo_red_six.dds", size = GetLokkIconsSize},
    ["LokkBeam7"] = {x = 114320, y = 56100, z = 105090, texture = "odysupporticons/icons/squares/squaretwo_red_seven.dds", size = GetLokkIconsSize},
    ["LokkBeam8"] = {x = 115110, y = 56100, z = 105090, texture = "odysupporticons/icons/squares/squaretwo_red_eight.dds", size = GetLokkIconsSize},
    ["LokkBeamLH"] = {x = 115500, y = 56100, z = 106725, texture = "odysupporticons/icons/squares/squaretwo_orange_one.dds", size = GetLokkIconsSize},
    ["LokkBeamRH"] = {x = 115500, y = 56100, z = 105425, texture = "odysupporticons/icons/squares/squaretwo_orange_two.dds", size = GetLokkIconsSize},

    -- Solo Healer Lokkestiiz from Floliroy
    ["SHLokkBeam1"] = {x = 113880, y = 56100, z = 106880, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetLokkIconsSize},
    ["SHLokkBeam2"] = {x = 114080, y = 56100, z = 106360, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetLokkIconsSize},
    ["SHLokkBeam3"] = {x = 114080, y = 56100, z = 105640, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetLokkIconsSize},
    ["SHLokkBeam4"] = {x = 113880, y = 56100, z = 105120, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetLokkIconsSize},
    ["SHLokkBeam5"] = {x = 114480, y = 56100, z = 107200, texture = "odysupporticons/icons/squares/squaretwo_red_five.dds", size = GetLokkIconsSize},
    ["SHLokkBeam6"] = {x = 114650, y = 56100, z = 106570, texture = "odysupporticons/icons/squares/squaretwo_red_six.dds", size = GetLokkIconsSize},
    ["SHLokkBeam7"] = {x = 114650, y = 56100, z = 105460, texture = "odysupporticons/icons/squares/squaretwo_red_seven.dds", size = GetLokkIconsSize},
    ["SHLokkBeam8"] = {x = 114480, y = 56100, z = 104880, texture = "odysupporticons/icons/squares/squaretwo_red_eight.dds", size = GetLokkIconsSize},
    ["SHLokkBeam9"] = {x = 114730, y = 56100, z = 106050, texture = "odysupporticons/icons/squares/squaretwo_red.dds", size = GetLokkIconsSize},
    ["SHLokkBeamH"] = {x = 116400, y = 56100, z = 106050, texture = "odysupporticons/icons/squares/squaretwo_orange.dds", size = GetLokkIconsSize},

    -- ["YolWing1"] = {x = 96021, y = 49697, z = 108422, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetYolIconsSize},
    ["YolWing2"] = {x = 97803, y = 49685, z = 108988, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetYolIconsSize},
    ["YolWing3"] = {x = 97121, y = 49722, z = 110613, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetYolIconsSize},
    ["YolWing4"] = {x = 95580, y = 49669, z = 110308, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetYolIconsSize},
    -- ["YolHead1"] = {x = 96004, y = 49690, z = 109008, texture = "odysupporticons/icons/squares/squaretwo_blue_one.dds", size = GetYolIconsSize},
    ["YolHead2"] = {x = 97188, y = 49703, z = 109064, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = GetYolIconsSize},
    ["YolHead3"] = {x = 97196, y = 49689, z = 110024, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = GetYolIconsSize},
    ["YolHead4"] = {x = 96109, y = 49669, z = 110270, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = GetYolIconsSize},
    -- Left Yolnahkriin from B7TxSpeed
    ["YolLeftWing2"] = {x = 96409, y = 49689, z = 108324, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetYolIconsSize},
    ["YolLeftWing3"] = {x = 97863, y = 49695, z = 109303, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetYolIconsSize},
    ["YolLeftWing4"] = {x = 96867, y = 49700, z = 110960, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetYolIconsSize},
    ["YolLeftHead2"] = {x = 96827, y = 49689, z = 108889, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = GetYolIconsSize},
    ["YolLeftHead3"] = {x = 97502, y = 49704, z = 109702, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = GetYolIconsSize},
    ["YolLeftHead4"] = {x = 96498, y = 49694, z = 110533, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = GetYolIconsSize},

    -- Halls of Fabrication
    ["Sphere1"] = {x = 44087, y = 49977, z = 25581, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = function() return 100 end},
    ["Sphere2"] = {x = 43885, y = 49978, z = 26656, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = function() return 100 end},
    ["Sphere3"] = {x = 43005, y = 49977, z = 27242, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = function() return 100 end},
    ["Sphere4"] = {x = 41971, y = 49978, z = 27058, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = function() return 100 end},
    ["Sphere5"] = {x = 41388, y = 49977, z = 26159, texture = "odysupporticons/icons/squares/squaretwo_red_five.dds", size = function() return 100 end},
    ["Sphere6"] = {x = 41577, y = 49977, z = 25111, texture = "odysupporticons/icons/squares/squaretwo_red_six.dds", size = function() return 100 end},
    ["Sphere7"] = {x = 42475, y = 49977, z = 24515, texture = "odysupporticons/icons/squares/squaretwo_red_seven.dds", size = function() return 100 end},
    ["Sphere8"] = {x = 43506, y = 49977, z = 24719, texture = "odysupporticons/icons/squares/squaretwo_red_eight.dds", size = function() return 100 end},

    ["TripletsSafe"] = {x = 29758, y = 52950, z = 73169, texture = "odysupporticons/icons/emoji-poop.dds", size = GetTripletsIconSize},

    -- Assembly General
    ["AGN"] = {x = 75001, y = 54955, z = 69658, texture = "CrutchAlerts/icons/assets/N.dds", size = GetAGIconsSize},
    ["AGNE"] = {x = 75610, y = 54919, z = 69394, texture = "odysupporticons/icons/squares/squaretwo_green_one.dds", size = GetAGIconsSize},
    ["AGE"] = {x = 75380, y = 54955, z = 69982, texture = "CrutchAlerts/icons/assets/E.dds", size = GetAGIconsSize},
    ["AGSE"] = {x = 75601, y = 54919, z = 70600, texture = "odysupporticons/icons/squares/squaretwo_green_two.dds", size = GetAGIconsSize},
    ["AGS"] = {x = 75006, y = 54956, z = 70319, texture = "CrutchAlerts/icons/assets/S.dds", size = GetAGIconsSize},
    ["AGSW"] = {x = 74410, y = 54918, z = 70614, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetAGIconsSize},
    ["AGW"] = {x = 74630, y = 54956, z = 70005, texture = "CrutchAlerts/icons/assets/W.dds", size = GetAGIconsSize},
    ["AGNW"] = {x = 74405, y = 54919, z = 69422, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetAGIconsSize},
    -- [22:20:28] [Kyzderp's Derps] zoneId=975 {x = 74993, y = 54954, z = 67024} bottom where AG is
    -- [22:20:40] [Kyzderp's Derps] zoneId=975 {x = 76056, y = 55424, z = 67556} top just for Y coord

    -- Sanity's Edge
    ["AnsuulCenter"] = {x = 200093, y = 30199, z = 40023, texture = "odysupporticons/icons/emoji-poop.dds", size = GetAnsuulIconSize},

    ["CavotSpawn"] = {x = 99882, y = 14160, z = 114738, texture = "odysupporticons/icons/emoji-poop.dds", size = GetCavotIconSize},

    -- Mirrors on Orphic Shattered Shard
    ["OrphicN"] = {x = 149348, y = 22880, z = 85334, texture = "CrutchAlerts/icons/assets/N.dds", size = GetOrphicIconSize},
    ["OrphicNE"] = {x = 151041, y = 22880, z = 86169, texture = "CrutchAlerts/icons/assets/NE.dds", size = GetOrphicIconSize},
    ["OrphicE"] = {x = 151956, y = 22880, z = 87950, texture = "CrutchAlerts/icons/assets/E.dds", size = GetOrphicIconSize},
    ["OrphicSE"] = {x = 151169, y = 22880, z = 89708, texture = "CrutchAlerts/icons/assets/SE.dds", size = GetOrphicIconSize},
    ["OrphicS"] = {x = 149272, y = 22880, z = 90657, texture = "CrutchAlerts/icons/assets/S.dds", size = GetOrphicIconSize},
    ["OrphicSW"] = {x = 147477, y = 22880, z = 89756, texture = "CrutchAlerts/icons/assets/SW.dds", size = GetOrphicIconSize},
    ["OrphicW"] = {x = 146628, y = 22880, z = 87851, texture = "CrutchAlerts/icons/assets/W.dds", size = GetOrphicIconSize},
    ["OrphicNW"] = {x = 147488, y = 22880, z = 86178, texture = "CrutchAlerts/icons/assets/NW.dds", size = GetOrphicIconSize},

    ["OrphicNum1"] = {x = 149348, y = 22867, z = 85334, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetOrphicNumIconSize},
    ["OrphicNum2"] = {x = 151041, y = 22864, z = 86169, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetOrphicNumIconSize},
    ["OrphicNum3"] = {x = 151956, y = 22867, z = 87950, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetOrphicNumIconSize},
    ["OrphicNum4"] = {x = 151169, y = 22864, z = 89708, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetOrphicNumIconSize},
    ["OrphicNum5"] = {x = 149272, y = 22868, z = 90657, texture = "odysupporticons/icons/squares/squaretwo_red_five.dds", size = GetOrphicNumIconSize},
    ["OrphicNum6"] = {x = 147477, y = 22869, z = 89756, texture = "odysupporticons/icons/squares/squaretwo_red_six.dds", size = GetOrphicNumIconSize},
    ["OrphicNum7"] = {x = 146628, y = 22867, z = 87851, texture = "odysupporticons/icons/squares/squaretwo_red_seven.dds", size = GetOrphicNumIconSize},
    ["OrphicNum8"] = {x = 147488, y = 22868, z = 86178, texture = "odysupporticons/icons/squares/squaretwo_red_eight.dds", size = GetOrphicNumIconSize},

    -- Xoryn
    ["TempestH1"] = {x = 137157, y = 34975, z = 163631, texture = "odysupporticons/icons/squares/squaretwo_orange_one.dds", size = GetTempestIconsSize},
    ["Tempest1"] = {x = 137785, y = 34975, z = 163175, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetTempestIconsSize},
    ["Tempest2"] = {x = 138493, y = 34975, z = 162911, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetTempestIconsSize},
    ["Tempest3"] = {x = 139205, y = 34975, z = 163189, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetTempestIconsSize},
    ["Tempest4"] = {x = 139845, y = 34975, z = 163657, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetTempestIconsSize},

    ["TempestH2"] = {x = 137061, y = 34975, z = 166466, texture = "odysupporticons/icons/squares/squaretwo_orange_two.dds", size = GetTempestIconsSize},
    ["Tempest5"] = {x = 137678, y = 34975, z = 166834, texture = "odysupporticons/icons/squares/squaretwo_red_five.dds", size = GetTempestIconsSize},
    ["Tempest6"] = {x = 138421, y = 34975, z = 167097, texture = "odysupporticons/icons/squares/squaretwo_red_six.dds", size = GetTempestIconsSize},
    ["Tempest7"] = {x = 139177, y = 34975, z = 166847, texture = "odysupporticons/icons/squares/squaretwo_red_seven.dds", size = GetTempestIconsSize},
    ["Tempest8"] = {x = 139909, y = 34975, z = 166519, texture = "odysupporticons/icons/squares/squaretwo_red_eight.dds", size = GetTempestIconsSize},

    -- Zhaj'hassa
    -- except these are terrible... WIP
    ["ZhajM1"] = {x = 103036, y = 45930, z = 128336, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = GetZhajIconsSize},
    ["ZhajM2"] = {x = 103134, y = 45919, z = 127905, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = GetZhajIconsSize},
    ["ZhajM3"] = {x = 102853, y = 45947, z = 127674, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = GetZhajIconsSize},
    ["ZhajM4"] = {x = 102563, y = 45948, z = 127971, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = GetZhajIconsSize},
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

    local icon = OSI.CreatePositionIcon(iconData.x, iconData.y, iconData.z, iconData.texture, iconData.size(), iconData.color or {1, 1, 1})
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
