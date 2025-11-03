local Crutch = CrutchAlerts
local C = Crutch.Constants

---------------------------------------------------------------------
local function GetFalgravnIconsSize()
    return Crutch.savedOptions.kynesaegis.falgravnIconsSize * 0.9
end

local function GetLokkIconsSize()
    return Crutch.savedOptions.sunspire.lokkIconsSize * 0.9
end

local function GetYolIconsSize()
    return Crutch.savedOptions.sunspire.yolIconsSize * 0.9
end

local function GetTripletsIconSize()
    return Crutch.savedOptions.hallsoffabrication.tripletsIconSize * 0.9
end

local function GetAGIconsSize()
    return Crutch.savedOptions.hallsoffabrication.agIconsSize * 0.8
end

local function GetAnsuulIconSize()
    return Crutch.savedOptions.sanitysedge.ansuulIconSize * 0.9
end

local function GetCavotIconSize()
    return Crutch.savedOptions.lucentcitadel.cavotIconSize * 0.9
end

local function GetOrphicIconSize()
    return Crutch.savedOptions.lucentcitadel.orphicIconSize * 0.8 -- Round icons from code take up the full texture but appear smaller
    -- 0.7 for my old full square icons
end

local function GetOrphicNumIconSize()
    return Crutch.savedOptions.lucentcitadel.orphicIconSize * 0.9
end

local function GetTempestIconsSize()
    return Crutch.savedOptions.lucentcitadel.tempestIconsSize * 0.9
end

local function GetZhajIconsSize()
    return Crutch.savedOptions.mawoflorkhaj.zhajIconSize * 0.9
end

local function GetOCIconsSize()
    return Crutch.savedOptions.osseincage.twinsIconsSize * 0.9
end

---------------------------------------------------------------------
local icons = {}

local data = {
    ["Falgravn2ndFloor1"] = {x = 24668, y = 14569, z = 9631, texture = "CrutchAlerts/assets/shape/diamond_blue_1.dds", size = GetFalgravnIconsSize},
    ["Falgravn2ndFloor2"] = {x = 24654, y = 14569, z = 10398, texture = "CrutchAlerts/assets/shape/diamond_blue_2.dds", size = GetFalgravnIconsSize},
    ["Falgravn2ndFloor3"] = {x = 25441, y = 14569, z = 10370, texture = "CrutchAlerts/assets/shape/diamond_blue_3.dds", size = GetFalgravnIconsSize},
    ["Falgravn2ndFloor4"] = {x = 25468, y = 14569, z = 9620, texture = "CrutchAlerts/assets/shape/diamond_blue_4.dds", size = GetFalgravnIconsSize},
    ["Falgravn2ndFloorH1"] = {x = 24268, y = 14569, z = 10000, texture = "CrutchAlerts/assets/shape/diamond_orange_1.dds", size = GetFalgravnIconsSize},
    ["Falgravn2ndFloorH2"] = {x = 25838, y = 14569, z = 10000, texture = "CrutchAlerts/assets/shape/diamond_orange_2.dds", size = GetFalgravnIconsSize},

    -- Traditional Lokkestiiz
    ["LokkBeam1"] = {x = 115110, y = 56100, z = 107060, texture = "CrutchAlerts/assets/shape/diamond_red_1.dds", size = GetLokkIconsSize},
    ["LokkBeam2"] = {x = 114320, y = 56100, z = 107060, texture = "CrutchAlerts/assets/shape/diamond_red_2.dds", size = GetLokkIconsSize},
    ["LokkBeam3"] = {x = 114320, y = 56100, z = 106390, texture = "CrutchAlerts/assets/shape/diamond_red_3.dds", size = GetLokkIconsSize},
    ["LokkBeam4"] = {x = 115110, y = 56100, z = 106390, texture = "CrutchAlerts/assets/shape/diamond_red_4.dds", size = GetLokkIconsSize},
    ["LokkBeam5"] = {x = 115110, y = 56100, z = 105760, texture = "CrutchAlerts/assets/shape/diamond_red_5.dds", size = GetLokkIconsSize},
    ["LokkBeam6"] = {x = 114320, y = 56100, z = 105760, texture = "CrutchAlerts/assets/shape/diamond_red_6.dds", size = GetLokkIconsSize},
    ["LokkBeam7"] = {x = 114320, y = 56100, z = 105090, texture = "CrutchAlerts/assets/shape/diamond_red_7.dds", size = GetLokkIconsSize},
    ["LokkBeam8"] = {x = 115110, y = 56100, z = 105090, texture = "CrutchAlerts/assets/shape/diamond_red_8.dds", size = GetLokkIconsSize},
    ["LokkBeamLH"] = {x = 115500, y = 56100, z = 106725, texture = "CrutchAlerts/assets/shape/diamond_orange_1.dds", size = GetLokkIconsSize},
    ["LokkBeamRH"] = {x = 115500, y = 56100, z = 105425, texture = "CrutchAlerts/assets/shape/diamond_orange_2.dds", size = GetLokkIconsSize},

    -- Solo Healer Lokkestiiz from Floliroy
    ["SHLokkBeam1"] = {x = 113880, y = 56100, z = 106880, texture = "CrutchAlerts/assets/shape/diamond_red_1.dds", size = GetLokkIconsSize},
    ["SHLokkBeam2"] = {x = 114080, y = 56100, z = 106360, texture = "CrutchAlerts/assets/shape/diamond_red_2.dds", size = GetLokkIconsSize},
    ["SHLokkBeam3"] = {x = 114080, y = 56100, z = 105640, texture = "CrutchAlerts/assets/shape/diamond_red_3.dds", size = GetLokkIconsSize},
    ["SHLokkBeam4"] = {x = 113880, y = 56100, z = 105120, texture = "CrutchAlerts/assets/shape/diamond_red_4.dds", size = GetLokkIconsSize},
    ["SHLokkBeam5"] = {x = 114480, y = 56100, z = 107200, texture = "CrutchAlerts/assets/shape/diamond_red_5.dds", size = GetLokkIconsSize},
    ["SHLokkBeam6"] = {x = 114650, y = 56100, z = 106570, texture = "CrutchAlerts/assets/shape/diamond_red_6.dds", size = GetLokkIconsSize},
    ["SHLokkBeam7"] = {x = 114650, y = 56100, z = 105460, texture = "CrutchAlerts/assets/shape/diamond_red_7.dds", size = GetLokkIconsSize},
    ["SHLokkBeam8"] = {x = 114480, y = 56100, z = 104880, texture = "CrutchAlerts/assets/shape/diamond_red_8.dds", size = GetLokkIconsSize},
    ["SHLokkBeam9"] = {x = 114730, y = 56100, z = 106050, texture = "CrutchAlerts/assets/shape/diamond_red.dds", size = GetLokkIconsSize},
    ["SHLokkBeamH"] = {x = 116400, y = 56100, z = 106050, texture = "CrutchAlerts/assets/shape/diamond_orange.dds", size = GetLokkIconsSize},

    -- ["YolWing1"] = {x = 96021, y = 49697, z = 108422, texture = "CrutchAlerts/assets/shape/diamond_red_1.dds", size = GetYolIconsSize},
    ["YolWing2"] = {x = 97803, y = 49685, z = 108988, texture = "CrutchAlerts/assets/shape/diamond_red_2.dds", size = GetYolIconsSize},
    ["YolWing3"] = {x = 97121, y = 49722, z = 110613, texture = "CrutchAlerts/assets/shape/diamond_red_3.dds", size = GetYolIconsSize},
    ["YolWing4"] = {x = 95580, y = 49669, z = 110308, texture = "CrutchAlerts/assets/shape/diamond_red_4.dds", size = GetYolIconsSize},
    -- ["YolHead1"] = {x = 96004, y = 49690, z = 109008, texture = "CrutchAlerts/assets/shape/diamond_blue_1.dds", size = GetYolIconsSize},
    ["YolHead2"] = {x = 97188, y = 49703, z = 109064, texture = "CrutchAlerts/assets/shape/diamond_blue_2.dds", size = GetYolIconsSize},
    ["YolHead3"] = {x = 97196, y = 49689, z = 110024, texture = "CrutchAlerts/assets/shape/diamond_blue_3.dds", size = GetYolIconsSize},
    ["YolHead4"] = {x = 96109, y = 49669, z = 110270, texture = "CrutchAlerts/assets/shape/diamond_blue_4.dds", size = GetYolIconsSize},
    -- Left Yolnahkriin from B7TxSpeed
    ["YolLeftWing2"] = {x = 96409, y = 49689, z = 108324, texture = "CrutchAlerts/assets/shape/diamond_red_2.dds", size = GetYolIconsSize},
    ["YolLeftWing3"] = {x = 97863, y = 49695, z = 109303, texture = "CrutchAlerts/assets/shape/diamond_red_3.dds", size = GetYolIconsSize},
    ["YolLeftWing4"] = {x = 96867, y = 49700, z = 110960, texture = "CrutchAlerts/assets/shape/diamond_red_4.dds", size = GetYolIconsSize},
    ["YolLeftHead2"] = {x = 96827, y = 49689, z = 108889, texture = "CrutchAlerts/assets/shape/diamond_blue_2.dds", size = GetYolIconsSize},
    ["YolLeftHead3"] = {x = 97502, y = 49704, z = 109702, texture = "CrutchAlerts/assets/shape/diamond_blue_3.dds", size = GetYolIconsSize},
    ["YolLeftHead4"] = {x = 96498, y = 49694, z = 110533, texture = "CrutchAlerts/assets/shape/diamond_blue_4.dds", size = GetYolIconsSize},

    -- Halls of Fabrication
    ["Sphere1"] = {x = 44087, y = 49977, z = 25581, texture = "CrutchAlerts/assets/shape/diamond_red_1.dds", size = function() return 100 end},
    ["Sphere2"] = {x = 43885, y = 49978, z = 26656, texture = "CrutchAlerts/assets/shape/diamond_red_2.dds", size = function() return 100 end},
    ["Sphere3"] = {x = 43005, y = 49977, z = 27242, texture = "CrutchAlerts/assets/shape/diamond_red_3.dds", size = function() return 100 end},
    ["Sphere4"] = {x = 41971, y = 49978, z = 27058, texture = "CrutchAlerts/assets/shape/diamond_red_4.dds", size = function() return 100 end},
    ["Sphere5"] = {x = 41388, y = 49977, z = 26159, texture = "CrutchAlerts/assets/shape/diamond_red_5.dds", size = function() return 100 end},
    ["Sphere6"] = {x = 41577, y = 49977, z = 25111, texture = "CrutchAlerts/assets/shape/diamond_red_6.dds", size = function() return 100 end},
    ["Sphere7"] = {x = 42475, y = 49977, z = 24515, texture = "CrutchAlerts/assets/shape/diamond_red_7.dds", size = function() return 100 end},
    ["Sphere8"] = {x = 43506, y = 49977, z = 24719, texture = "CrutchAlerts/assets/shape/diamond_red_8.dds", size = function() return 100 end},

    ["TripletsSafe"] = {x = 29758, y = 52950, z = 73169, texture = "CrutchAlerts/assets/poop.dds", size = GetTripletsIconSize},

    -- Assembly General
    ["AGN"] = {x = 75001, y = 54955, z = 69658, texture = "CrutchAlerts/assets/directional/N.dds", size = GetAGIconsSize},
    ["AGNE"] = {x = 75610, y = 54919, z = 69394, texture = "CrutchAlerts/assets/shape/diamond_orange_1.dds", size = GetAGIconsSize},
    ["AGE"] = {x = 75380, y = 54955, z = 69982, texture = "CrutchAlerts/assets/directional/E.dds", size = GetAGIconsSize},
    ["AGSE"] = {x = 75601, y = 54919, z = 70600, texture = "CrutchAlerts/assets/shape/diamond_orange_2.dds", size = GetAGIconsSize},
    ["AGS"] = {x = 75006, y = 54956, z = 70319, texture = "CrutchAlerts/assets/directional/S.dds", size = GetAGIconsSize},
    ["AGSW"] = {x = 74410, y = 54918, z = 70614, texture = "CrutchAlerts/assets/shape/diamond_red_2.dds", size = GetAGIconsSize},
    ["AGW"] = {x = 74630, y = 54956, z = 70005, texture = "CrutchAlerts/assets/directional/W.dds", size = GetAGIconsSize},
    ["AGNW"] = {x = 74405, y = 54919, z = 69422, texture = "CrutchAlerts/assets/shape/diamond_red_1.dds", size = GetAGIconsSize},
    -- [22:20:28] [Kyzderp's Derps] zoneId=975 {x = 74993, y = 54954, z = 67024} bottom where AG is
    -- [22:20:40] [Kyzderp's Derps] zoneId=975 {x = 76056, y = 55424, z = 67556} top just for Y coord

    -- Sanity's Edge
    ["AnsuulCenter"] = {x = 200093, y = 30199, z = 40023, texture = "CrutchAlerts/assets/poop.dds", size = GetAnsuulIconSize},

    ["CavotSpawn"] = {x = 99882, y = 14160, z = 114738, texture = "CrutchAlerts/assets/poop.dds", size = GetCavotIconSize},

    -- Mirrors on Orphic Shattered Shard
    ["OrphicN"] = {x = 149348, y = 22880, z = 85334, texture = "CrutchAlerts/assets/directional/N.dds", size = GetOrphicIconSize},
    ["OrphicNE"] = {x = 151041, y = 22880, z = 86169, texture = "CrutchAlerts/assets/directional/NE.dds", size = GetOrphicIconSize},
    ["OrphicE"] = {x = 151956, y = 22880, z = 87950, texture = "CrutchAlerts/assets/directional/E.dds", size = GetOrphicIconSize},
    ["OrphicSE"] = {x = 151169, y = 22880, z = 89708, texture = "CrutchAlerts/assets/directional/SE.dds", size = GetOrphicIconSize},
    ["OrphicS"] = {x = 149272, y = 22880, z = 90657, texture = "CrutchAlerts/assets/directional/S.dds", size = GetOrphicIconSize},
    ["OrphicSW"] = {x = 147477, y = 22880, z = 89756, texture = "CrutchAlerts/assets/directional/SW.dds", size = GetOrphicIconSize},
    ["OrphicW"] = {x = 146628, y = 22880, z = 87851, texture = "CrutchAlerts/assets/directional/W.dds", size = GetOrphicIconSize},
    ["OrphicNW"] = {x = 147488, y = 22880, z = 86178, texture = "CrutchAlerts/assets/directional/NW.dds", size = GetOrphicIconSize},

    ["OrphicNum1"] = {x = 149348, y = 22867, z = 85334, texture = "CrutchAlerts/assets/shape/diamond_red_1.dds", size = GetOrphicNumIconSize},
    ["OrphicNum2"] = {x = 151041, y = 22864, z = 86169, texture = "CrutchAlerts/assets/shape/diamond_red_2.dds", size = GetOrphicNumIconSize},
    ["OrphicNum3"] = {x = 151956, y = 22867, z = 87950, texture = "CrutchAlerts/assets/shape/diamond_red_3.dds", size = GetOrphicNumIconSize},
    ["OrphicNum4"] = {x = 151169, y = 22864, z = 89708, texture = "CrutchAlerts/assets/shape/diamond_red_4.dds", size = GetOrphicNumIconSize},
    ["OrphicNum5"] = {x = 149272, y = 22868, z = 90657, texture = "CrutchAlerts/assets/shape/diamond_red_5.dds", size = GetOrphicNumIconSize},
    ["OrphicNum6"] = {x = 147477, y = 22869, z = 89756, texture = "CrutchAlerts/assets/shape/diamond_red_6.dds", size = GetOrphicNumIconSize},
    ["OrphicNum7"] = {x = 146628, y = 22867, z = 87851, texture = "CrutchAlerts/assets/shape/diamond_red_7.dds", size = GetOrphicNumIconSize},
    ["OrphicNum8"] = {x = 147488, y = 22868, z = 86178, texture = "CrutchAlerts/assets/shape/diamond_red_8.dds", size = GetOrphicNumIconSize},

    -- Xoryn
    ["TempestH1"] = {x = 137157, y = 34975, z = 163631, texture = "CrutchAlerts/assets/shape/diamond_orange_1.dds", size = GetTempestIconsSize},
    ["Tempest1"] = {x = 137785, y = 34975, z = 163175, texture = "CrutchAlerts/assets/shape/diamond_red_1.dds", size = GetTempestIconsSize},
    ["Tempest2"] = {x = 138493, y = 34975, z = 162911, texture = "CrutchAlerts/assets/shape/diamond_red_2.dds", size = GetTempestIconsSize},
    ["Tempest3"] = {x = 139205, y = 34975, z = 163189, texture = "CrutchAlerts/assets/shape/diamond_red_3.dds", size = GetTempestIconsSize},
    ["Tempest4"] = {x = 139845, y = 34975, z = 163657, texture = "CrutchAlerts/assets/shape/diamond_red_4.dds", size = GetTempestIconsSize},

    ["TempestH2"] = {x = 137061, y = 34975, z = 166466, texture = "CrutchAlerts/assets/shape/diamond_orange_2.dds", size = GetTempestIconsSize},
    ["Tempest5"] = {x = 137678, y = 34975, z = 166834, texture = "CrutchAlerts/assets/shape/diamond_red_5.dds", size = GetTempestIconsSize},
    ["Tempest6"] = {x = 138421, y = 34975, z = 167097, texture = "CrutchAlerts/assets/shape/diamond_red_6.dds", size = GetTempestIconsSize},
    ["Tempest7"] = {x = 139177, y = 34975, z = 166847, texture = "CrutchAlerts/assets/shape/diamond_red_7.dds", size = GetTempestIconsSize},
    ["Tempest8"] = {x = 139909, y = 34975, z = 166519, texture = "CrutchAlerts/assets/shape/diamond_red_8.dds", size = GetTempestIconsSize},

    -- Zhaj'hassa
    -- except these are terrible... WIP
    ["ZhajM1"] = {x = 103036, y = 45930, z = 128336, texture = "CrutchAlerts/assets/shape/diamond_red_1.dds", size = GetZhajIconsSize},
    ["ZhajM2"] = {x = 103134, y = 45919, z = 127905, texture = "CrutchAlerts/assets/shape/diamond_red_2.dds", size = GetZhajIconsSize},
    ["ZhajM3"] = {x = 102853, y = 45947, z = 127674, texture = "CrutchAlerts/assets/shape/diamond_red_3.dds", size = GetZhajIconsSize},
    ["ZhajM4"] = {x = 102563, y = 45948, z = 127971, texture = "CrutchAlerts/assets/shape/diamond_red_4.dds", size = GetZhajIconsSize},
}

-- New more organized data
local iconGroups = {
    -- Jynorah + Skorkhif, matching Asquart's OCH
    ["OCAOCH"] = {
        size = GetOCIconsSize,
        icons = {
            {x = 104556, y = 26157, z = 129135, texture = "CrutchAlerts/assets/shape/diamond_magenta.dds"}, -- OCBlueBossEntrance
            {x = 104863, y = 26157, z = 128405, texture = "CrutchAlerts/assets/shape/diamond_blue.dds"}, -- OCBlueHealEntrance
            {x = 104110, y = 26157, z = 128614, texture = "CrutchAlerts/assets/shape/diamond_blue_1.dds"}, -- OCBlue1Entrance
            {x = 104137, y = 26157, z = 128115, texture = "CrutchAlerts/assets/shape/diamond_blue_2.dds"}, -- OCBlue2Entrance
            {x = 104536, y = 26157, z = 128677, texture = "CrutchAlerts/assets/shape/diamond_blue_3.dds"}, -- OCBlue3Entrance
            {x = 104557, y = 26157, z = 128107, texture = "CrutchAlerts/assets/shape/diamond_blue_4.dds"}, -- OCBlue4Entrance
            {x = 105634, y = 26157, z = 129199, texture = "CrutchAlerts/assets/shape/diamond_magenta.dds"}, -- OCRedBossEntrance
            {x = 105330, y = 26157, z = 128446, texture = "CrutchAlerts/assets/shape/diamond_orange.dds"}, -- OCRedHealEntrance
            {x = 106063, y = 26157, z = 128701, texture = "CrutchAlerts/assets/shape/diamond_orange_1.dds"}, -- OCRed1Entrance
            {x = 106069, y = 26157, z = 128253, texture = "CrutchAlerts/assets/shape/diamond_orange_2.dds"}, -- OCRed2Entrance
            {x = 105652, y = 26157, z = 128729, texture = "CrutchAlerts/assets/shape/diamond_orange_3.dds"}, -- OCRed3Entrance
            {x = 105661, y = 26157, z = 128177, texture = "CrutchAlerts/assets/shape/diamond_orange_4.dds"}, -- OCRed4Entrance

            {x = 104560, y = 26157, z = 131493, texture = "CrutchAlerts/assets/shape/diamond_red.dds"}, -- OCBlueBossExit
            {x = 104860, y = 26157, z = 132259, texture = "CrutchAlerts/assets/shape/diamond_blue.dds"}, -- OCBlueHealExit
            {x = 104137, y = 26157, z = 131962, texture = "CrutchAlerts/assets/shape/diamond_blue_1.dds"}, -- OCBlue1Exit
            {x = 104106, y = 26157, z = 132462, texture = "CrutchAlerts/assets/shape/diamond_blue_2.dds"}, -- OCBlue2Exit
            {x = 104568, y = 26157, z = 131949, texture = "CrutchAlerts/assets/shape/diamond_blue_3.dds"}, -- OCBlue3Exit
            {x = 104522, y = 26157, z = 132518, texture = "CrutchAlerts/assets/shape/diamond_blue_4.dds"}, -- OCBlue4Exit
            {x = 105638, y = 26157, z = 131557, texture = "CrutchAlerts/assets/shape/diamond_red.dds"}, -- OCRedBossExit
            {x = 105330, y = 26157, z = 132273, texture = "CrutchAlerts/assets/shape/diamond_orange.dds"}, -- OCRedHealExit
            {x = 106087, y = 26157, z = 132105, texture = "CrutchAlerts/assets/shape/diamond_orange_1.dds"}, -- OCRed1Exit
            {x = 106040, y = 26157, z = 132551, texture = "CrutchAlerts/assets/shape/diamond_orange_2.dds"}, -- OCRed2Exit
            {x = 105682, y = 26157, z = 132030, texture = "CrutchAlerts/assets/shape/diamond_orange_3.dds"}, -- OCRed3Exit
            {x = 105626, y = 26157, z = 132579, texture = "CrutchAlerts/assets/shape/diamond_orange_4.dds"}, -- OCRed4Exit
        },
    },
    -- Jynorah + Skorkhif, matching... someone's Elm's (Minervyr via M0R via Plonk)
    ["OCAlt"] = {
        size = GetOCIconsSize,
        icons = {
            {x = 105750, y = 26157, z = 128100, texture = "CrutchAlerts/assets/shape/diamond_magenta.dds"}, -- RedBossEntrance
            {x = 105400, y = 26157, z = 128100, texture = "CrutchAlerts/assets/shape/diamond_orange.dds"}, -- RedHealEntrance
            {x = 105750, y = 26157, z = 128350, texture = "CrutchAlerts/assets/shape/diamond_orange_1.dds"}, -- Red1Entrance
            {x = 105750, y = 26157, z = 127850, texture = "CrutchAlerts/assets/shape/diamond_orange_2.dds"}, -- Red2Entrance
            {x = 106250, y = 26157, z = 128350, texture = "CrutchAlerts/assets/shape/diamond_orange_3.dds"}, -- Red3Entrance
            {x = 106250, y = 26157, z = 127850, texture = "CrutchAlerts/assets/shape/diamond_orange_4.dds"}, -- Red4Entrance
            {x = 104450, y = 26157, z = 128100, texture = "CrutchAlerts/assets/shape/diamond_magenta.dds"}, -- BlueBossEntrance
            {x = 104800, y = 26157, z = 128100, texture = "CrutchAlerts/assets/shape/diamond_blue.dds"}, -- BlueHealEntrance
            {x = 104450, y = 26157, z = 128350, texture = "CrutchAlerts/assets/shape/diamond_blue_1.dds"}, -- Blue1Entrance
            {x = 104450, y = 26157, z = 127850, texture = "CrutchAlerts/assets/shape/diamond_blue_2.dds"}, -- Blue2Entrance
            {x = 103950, y = 26157, z = 128350, texture = "CrutchAlerts/assets/shape/diamond_blue_3.dds"}, -- Blue3Entrance
            {x = 103950, y = 26160, z = 127850, texture = "CrutchAlerts/assets/shape/diamond_blue_4.dds"}, -- Blue4Entrance

            {x = 105750, y = 26157, z = 132700, texture = "CrutchAlerts/assets/shape/diamond_red.dds"}, -- RedBossExit
            {x = 105400, y = 26161, z = 132700, texture = "CrutchAlerts/assets/shape/diamond_orange.dds"}, -- RedHealExit
            {x = 105750, y = 26157, z = 132450, texture = "CrutchAlerts/assets/shape/diamond_orange_1.dds"}, -- Red1Exit
            {x = 105750, y = 26157, z = 132950, texture = "CrutchAlerts/assets/shape/diamond_orange_2.dds"}, -- Red2Exit
            {x = 106250, y = 26157, z = 132450, texture = "CrutchAlerts/assets/shape/diamond_orange_3.dds"}, -- Red3Exit
            {x = 106250, y = 26157, z = 132950, texture = "CrutchAlerts/assets/shape/diamond_orange_4.dds"}, -- Red4Exit
            {x = 104450, y = 26157, z = 132700, texture = "CrutchAlerts/assets/shape/diamond_red.dds"}, -- BlueBossExit
            {x = 104800, y = 26161, z = 132700, texture = "CrutchAlerts/assets/shape/diamond_blue.dds"}, -- BlueHealExit
            {x = 104450, y = 26157, z = 132450, texture = "CrutchAlerts/assets/shape/diamond_blue_1.dds"}, -- Blue1Exit
            {x = 104450, y = 26157, z = 132950, texture = "CrutchAlerts/assets/shape/diamond_blue_2.dds"}, -- Blue2Exit
            {x = 103950, y = 26157, z = 132450, texture = "CrutchAlerts/assets/shape/diamond_blue_3.dds"}, -- Blue3Exit
            {x = 103950, y = 26157, z = 132950, texture = "CrutchAlerts/assets/shape/diamond_blue_4.dds"}, -- Blue4Exit
        },
    },

    -- Jynorah + Skorkhif middle
    ["OCMiddle"] = {
        size = GetOCIconsSize,
        icons = {
            {x = 105400, y = 26157, z = 130300, texture = "CrutchAlerts/assets/shape/diamond_orange.dds"}, -- RedHealMiddle
            {x = 105750, y = 26157, z = 130050, texture = "CrutchAlerts/assets/shape/diamond_orange_1.dds"}, -- Red1Middle
            {x = 105750, y = 26157, z = 130550, texture = "CrutchAlerts/assets/shape/diamond_orange_2.dds"}, -- Red2Middle
            {x = 106250, y = 26157, z = 130050, texture = "CrutchAlerts/assets/shape/diamond_orange_3.dds"}, -- Red3Middle
            {x = 106250, y = 26157, z = 130550, texture = "CrutchAlerts/assets/shape/diamond_orange_4.dds"}, -- Red4Middle
            {x = 104800, y = 26157, z = 130300, texture = "CrutchAlerts/assets/shape/diamond_blue.dds"}, -- BlueHealMiddle
            {x = 104450, y = 26157, z = 130050, texture = "CrutchAlerts/assets/shape/diamond_blue_1.dds"}, -- Blue1Middle
            {x = 104450, y = 26157, z = 130550, texture = "CrutchAlerts/assets/shape/diamond_blue_2.dds"}, -- Blue2Middle
            {x = 103950, y = 26157, z = 130050, texture = "CrutchAlerts/assets/shape/diamond_blue_3.dds"}, -- Blue3Middle
            {x = 103950, y = 26157, z = 130550, texture = "CrutchAlerts/assets/shape/diamond_blue_4.dds"}, -- Blue4Middle
        },
    },

    -- Orphic Shattered Shard mirror with directions
    ["OrphicDirections"] = {
        size = GetOrphicIconSize,
        icons = {
            {x = 149348, y = 22880, z = 85334, texture = "CrutchAlerts/assets/shape/diamond.dds", color = C.BLUE, text = "N", orientation = {0, math.pi, 0}}, -- TODO orientation
            {x = 151041, y = 22880, z = 86169, texture = "CrutchAlerts/assets/shape/diamond.dds", color = C.RED, text = "NE", orientation = {0, math.pi, 0}}, -- TODO orientation
            {x = 151956, y = 22880, z = 87950, texture = "CrutchAlerts/assets/shape/diamond.dds", color = C.BLUE, text = "E", orientation = {0, math.pi, 0}}, -- TODO orientation
            {x = 151169, y = 22880, z = 89708, texture = "CrutchAlerts/assets/shape/diamond.dds", color = C.RED, text = "SE", orientation = {0, math.pi, 0}}, -- TODO orientation
            {x = 149272, y = 22880, z = 90657, texture = "CrutchAlerts/assets/shape/diamond.dds", color = C.BLUE, text = "S", orientation = {0, math.pi, 0}}, -- TODO orientation
            {x = 147477, y = 22880, z = 89756, texture = "CrutchAlerts/assets/shape/diamond.dds", color = C.RED, text = "SW", orientation = {0, math.pi, 0}}, -- TODO orientation
            {x = 146628, y = 22880, z = 87851, texture = "CrutchAlerts/assets/shape/diamond.dds", color = C.BLUE, text = "W", orientation = {0, math.pi, 0}}, -- TODO orientation
            {x = 147488, y = 22880, z = 86178, texture = "CrutchAlerts/assets/shape/diamond.dds", color = C.RED, text = "NW", orientation = {0, math.pi, 0}}, -- TODO orientation
        },
    },
}


---------------------------------------------------------------------
function Crutch.EnableIcon(name)
    if (icons[name]) then
        Crutch.dbgOther("|cFF0000Icon already enabled " .. name .. "|r")
        return
    end

    local iconData = data[name]
    if (not iconData) then
        Crutch.dbgOther("|cFF0000Invalid icon name " .. name .. "|r")
        return
    end

    local size = iconData.size() / 1.5
    local key = Crutch.Drawing.CreatePlacedPositionMarker(iconData.texture, iconData.x, iconData.y, iconData.z, size)
    icons[name] = key
end

function Crutch.DisableIcon(name)
    if (not icons[name]) then
        return
    end

    Crutch.Drawing.RemovePlacedPositionMarker(icons[name])
    icons[name] = nil
end


---------------------------------------------------------------------
-- Icon groups
function Crutch.EnableIconGroup(iconGroupName)
    local iconGroup = iconGroups[iconGroupName]
    if (not iconGroup) then
        Crutch.dbgOther("|cFF0000Invalid icon group name " .. iconGroupName .. "|r")
        return
    end

    -- Enable individual icons, using the same size throughout
    local size = iconGroup.size() / 1.5
    for i, iconData in ipairs(iconGroup.icons) do
        local name = iconGroupName .. "_" .. tostring(i)

        if (icons[name]) then
            Crutch.dbgOther("|cFF0000Icon already enabled " .. name .. "|r")
        else
            local key
            if (iconData.text) then
                -- Use fancy space
                local options = {}
                if (iconData.texture) then
                    options.texture = {
                        path = iconData.texture,
                        size = size / 100, -- TODO
                        color = iconData.color,
                    }
                end

                if (iconData.text) then
                    options.label = {
                        text = iconData.text,
                        size = size, -- TODO
                        color = C.WHITE,
                    }
                end

                key = Crutch.Drawing.CreateSpaceControl(
                    iconData.x,
                    iconData.y,
                    iconData.z,
                    iconData.orientation == nil, -- face camera if orientation not specified
                    iconData.orientation,
                    options,
                    nil) -- updateFunc
            else
                -- Use only texture
                key = Crutch.Drawing.CreatePlacedPositionMarker(iconData.texture, iconData.x, iconData.y, iconData.z, size)
            end
            icons[name] = key
        end
    end
end

function Crutch.DisableIconGroup(iconGroupName)
    local iconGroup = iconGroups[iconGroupName]
    if (not iconGroup) then
        Crutch.dbgOther("|cFF0000Invalid icon group name " .. iconGroupName .. "|r")
        return
    end

    -- Disable individual icons
    local size = iconGroup.size()
    for i, _ in ipairs(iconGroup.icons) do
        local name = iconGroupName .. "_" .. tostring(i)
        if (icons[name]) then
            Crutch.Drawing.RemovePlacedPositionMarker(icons[name])
            icons[name] = nil
        end
    end
end

