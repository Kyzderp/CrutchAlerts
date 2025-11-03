local Crutch = CrutchAlerts
local C = Crutch.Constants

--[[
gryphon room HM

[20:03:38] [Kyzderp's Derps] zoneId=1427 {x = 172091, y = 40350, z = 238068}
[20:03:44] [Kyzderp's Derps] zoneId=1427 {x = 172123, y = 40350, z = 242163}
[20:03:48] [Kyzderp's Derps] zoneId=1427 {x = 170049, y = 40350, z = 242334}
[20:03:51] [Kyzderp's Derps] zoneId=1427 {x = 168007, y = 40350, z = 242182}
[20:03:57] [Kyzderp's Derps] zoneId=1427 {x = 168000, y = 40350, z = 238103}

[20:07:12] [Kyzderp's Derps] zoneId=1427 {x = 172096, y = 40350, z = 238073}
[20:07:18] [Kyzderp's Derps] zoneId=1427 {x = 172115, y = 40350, z = 242170}
[20:07:22] [Kyzderp's Derps] zoneId=1427 {x = 170021, y = 40350, z = 242334}
[20:07:25] [Kyzderp's Derps] zoneId=1427 {x = 168001, y = 40350, z = 242177}


wamasu room nonHM

[03:20:16] [Kyzderp's Derps] zoneId=1427 {x = 192112, y = 40350, z = 240132}
[03:20:21] [Kyzderp's Derps] zoneId=1427 {x = 189867, y = 40350, z = 242334}
[03:20:24] [Kyzderp's Derps] zoneId=1427 {x = 187670, y = 40350, z = 240136}
[03:20:28] [Kyzderp's Derps] zoneId=1427 {x = 189892, y = 40350, z = 237901}
]]

local chimeraPositions = {
    -- TODO: coords from wondernuts' SE helper for now, but I want them up against the pedestal, and oriented
    {
        -- Gryphon
        [1] = {171984, 40350, 238116},
        [2] = {172026, 40350, 242013},
        [3] = {170048, 40350, 242200},
        [4] = {168148, 40350, 242050},
        [5] = {168147, 40350, 238168},
    },
    {
        -- Lion
        [1] = {181899, 40350, 238230},
        [2] = {181903, 40350, 242085},
        [3] = {179948, 40350, 242203},
        [4] = {178072, 40350, 242011},
        [5] = {178065, 40350, 238175},
    },
    {
        -- Wamasu
        [1] = {191735, 40350, 238150},
        [2] = {191874, 40350, 242064},
        [3] = {189859, 40350, 242154},
        [4] = {187935, 40350, 242088},
        [5] = {187954, 40350, 238224},
    }
}
Crutch.chimeraPositions = chimeraPositions

---------------------------------------------------------------------
---------------------------------------------------------------------
local icons = {}
local function RemoveIcons()
    for _, key in ipairs(icons) do
        Crutch.Drawing.RemoveWorldTexture(key)
    end
    icons = {}
end
Crutch.RemoveChimIcons = RemoveIcons

local function AddIcons() -- TODO: name
    RemoveIcons()

    for room, roomData in ipairs(chimeraPositions) do
        for i, coords in ipairs(roomData) do
            local text = string.format("%d-%d", room, i)
            local key = Crutch.Drawing.CreateSpaceLabel(text, coords[1], coords[2], coords[3], 80, C.WHITE, false, {0, math.pi, 0})
            table.insert(icons, key)
        end
    end
end
Crutch.AddChimIcons = AddIcons


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterSanitysEdge()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Sanity's Edge")

    -- Ansuul icon
    if (Crutch.savedOptions.sanitysedge.showAnsuulIcon) then
        Crutch.EnableIcon("AnsuulCenter")
    end

    -- AddIcons()
end

function Crutch.UnregisterSanitysEdge()
    -- Ansuul icon
    Crutch.DisableIcon("AnsuulCenter")

    -- RemoveIcons()

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Sanity's Edge")
end
