local Crutch = CrutchAlerts
local M = Crutch.Drawing.Model


---------------------------------------------------------------------
-- Track done
---------------------------------------------------------------------
local NUM_TRIAL = 5

-- DO NOT INSERT, always add to end
local trials = {
    636, -- Hel Ra Citadel
    638, -- Aetherian Archive
    639, -- Sanctum Ophidia
    725, -- Maw of Lorkhaj
    975, -- Halls of Fabrication
    1000, -- Asylum Sanctorium
    1051, -- Cloudrest
    1121, -- Sunspire
    1196, -- Kyne's Aegis
    1263, -- Rockgrove
    1344, -- Dreadsail Reef
    1427, -- Sanity's Edge
    1478, -- Lucent Citadel
    1548, -- Ossein Cage
}

local found = {} -- {0x1F, 0x00}

local function TrialsFoundToString()
    local result = ""
    for i = 1, #trials do
        result = string.format("%02x%s", found[trials[i]] or 0, result)
    end
    return result
end
M.TrialsFoundToString = TrialsFoundToString
-- /script d(CrutchAlerts.Drawing.Model.TrialsFoundToString())

local function TrialsStringToFound(str)
    str = str or ""
    ZO_ClearTable(found)
    for i = 1, #str / 2 do
        -- Start at the end of the string and work way up
        local start = #str - i * 2 + 1
        local substr = string.sub(str, start, start + 1)
        local num = tonumber(substr, 16)
        if (not num) then
            Crutch.dbgOther("|cFF0000Couldn't deserialize " .. substr .. "???")
        end
        found[trials[i]] = num
    end
end
M.TrialsStringToFound = TrialsStringToFound

-- put both trials and boxes in order like 4 3 2 1 so that existing ones never change
local function IsCompleted(zoneId, i)
    local val = found[zoneId] or 0
    local mask = BitLShift(1, i - 1)
    return BitAnd(val, mask) ~= 0
end

local function GetNumCompleted(zoneId)
    local num = 0
    for i = 1, NUM_TRIAL do
        num = num + (IsCompleted(zoneId, i) and 1 or 0)
    end
    return num
end

-- TODO: non-trials
local function AreAllPresentsCompleted(zoneId)
    return GetNumCompleted(zoneId) == NUM_TRIAL
end
M.AreAllPresentsCompleted = AreAllPresentsCompleted

local function SetCompleted(zoneId, i, v)
    local newVal = found[zoneId] or 0

    if (v == true) then
        -- if setting to true, set mask to 1, then or
        newVal = BitOr(newVal, BitLShift(1, i - 1))
    elseif (v == false) then
        -- if setting to false, set mask to 1, invert, and
        newVal = BitAnd(newVal, BitNot(BitLShift(1, i - 1), 8))
    end

    found[zoneId] = newVal
    return newVal
end
M.SetCompleted = SetCompleted
-- /script CrutchAlerts.Drawing.Model.SetCompleted(GetZoneId(GetUnitZoneIndex("player")), 5, false)


---------------------------------------------------------------------
-- Solutions
---------------------------------------------------------------------
--[[
ERE
[21:54:48] [Kyzderp's Derps] zoneId=1360 {x = 147724, y = 37560, z = 160802} -- 2nd secret cliff
[22:47:52] [Kyzderp's Derps] zoneId=1360 {x = 129975, y = 36625, z = 56351} -- boss next to banner
]]
local presentCoords = {
    -- [1360] = "", -- ERE
    [ 636] = "HRC|63000,21251,31790,92758,25508,76640,82584,24902,86550,88731,28386,87583,92522,37121,93983", -- Hel Ra Citadel
    [ 638] = "AA|81733,9472,76452,113014,14691,74865,98785,13625,103688,95544,13765,137753,129628,39378,184150", -- Aetherian Archive
    [ 639] = "SO|106847,14627,188222,83234,20092,155520,120587,23780,94093,113491,23790,88746,111631,29312,80472", -- Sanctum Ophidia
    [ 725] = "MoL|111197,42202,139487,101903,45925,129986,89335,44941,140042,55726,61550,188917,32807,61544,190549", -- Maw of Lorkhaj
    [ 975] = "HoF|3120,51089,31569,44242,49976,23616,84458,52514,13094,20781,55663,71547,74996,54915,60551", -- Halls of Fabrication
    [1000] = "AS|74938,60219,101213,92243,65845,107952,96040,65875,100036,101093,65841,88848,100664,61450,96646", -- Asylum Sanctorium
    [1051] = "CR|152670,30523,71288,159398,31423,101037,167669,31445,92713,153329,31587,94847,159141,32851,103606", -- Cloudrest
    [1121] = "SS|107508,52662,47177,175267,47255,174683,101191,49856,105114,105338,53922,70661,105960,54749,114984", -- Sunspire
    [1196] = "KA|127276,25182,114645,115771,25027,115190,119672,29984,92948,94912,24969,51739,26677,7918,11111", -- Kyne's Aegis
    [1263] = "RG|88336,32785,53872,100810,34185,64852,51760,24083,92275,144560,33546,141014,160943,31840,144661", -- Rockgrove
    [1344] = "DSR|28849,15510,175113,155426,38747,162970,116057,37876,98053,47148,36825,29775,117053,40874,28838", -- Dreadsail Reef
    [1427] = "SE|108935,13899,23543,67016,22665,98759,144754,28077,156982,172372,32765,184498,198849,35313,78654", -- Sanity's Edge
    [1478] = "LC|139502,34997,173352,96534,20872,117051,81213,17682,130453,149708,22860,91033,122181,33500,126048", -- Lucent Citadel
    [1548] = "OC|25417,32748,25215,221016,32934,75966,108402,27677,127362,182482,39985,182316,46462,35808,185322", -- Ossein Cage
    -- [ 849] = "VV|218739,11576,508011,218920,11583,504866,218474,11589,505594,218228,11579,505673,218287,11590,505453,218077,11580,505493,218269,11579,505727,218331,11586,505594,218214,11585,505511,218155,11586,505412,218052,11571,505607,218031,11560,505766,217867,11555,505726,217964,11567,505544", -- Vvardenfell testing
    -- [1565] = "OO|", -- Opulent Ordeal (Night Market)
}

local function DoesZoneHavePresents(zoneId)
    return presentCoords[zoneId] ~= nil
end
M.DoesZoneHavePresents = DoesZoneHavePresents

local activePrefix
local activePresents = {} -- {[1] = {}} -- do NOT use ipairs; they are not contiguous


---------------------------------------------------------------------
-- Approach
---------------------------------------------------------------------
local POLLING_NAME = "CrutchAlertsPresentProximity"

local function OpenPresent(index)
    activePresents[index] = nil
    M.PlayPresentAnimation(activePrefix .. index)

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    SetCompleted(zoneId, index, true)
    local num = GetNumCompleted(zoneId)

    if (not next(activePresents)) then
        EVENT_MANAGER:UnregisterForUpdate(POLLING_NAME)
    end

    Crutch.dbgOther(TrialsFoundToString())

    -- shouldn't be possible to have more than 5; that probably means cheating
    if (num == NUM_TRIAL) then
        Crutch.msg(zo_strformat("You found all <<1>> |t100%:100%:CrutchAlerts/assets/poop.dds|t in <<2>>! Happy holidays and enjoy the little snowflakes while in this zone :) Effects can be turned off in CrutchAlerts > Miscellaneous > Enable fun effects", num, GetZoneNameById(zoneId)))
        Crutch.Drawing.Trail.OnPlayerActivated()
    else
        Crutch.msg(zo_strformat("You found a |t100%:100%:CrutchAlerts/assets/poop.dds|t ! <<1>>/<<2>> collected in <<3>>.", num, NUM_TRIAL, GetZoneNameById(zoneId)))
    end
end

local function CheckDistances()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    for index, coords in pairs(activePresents) do
        local dist = Crutch.GetSquaredDistance(x, y, z, coords.x, coords.y, coords.z)
        if (dist < 40000) then
            OpenPresent(index)
            return
        end
    end
end

local function MaybePollProximity()
    EVENT_MANAGER:UnregisterForUpdate(POLLING_NAME)
    if (not next(activePresents)) then return end

    EVENT_MANAGER:RegisterForUpdate(POLLING_NAME, 500, CheckDistances)
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local function ClearPresents()
    for index, _ in pairs(activePresents) do
        M.RemovePresent(activePrefix .. index)
        activePresents[index] = nil
    end
    activePrefix = nil
end

local function PlacePresents()
    ClearPresents()

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if (not presentCoords[zoneId]) then
        return
    end

    local prefix, rest = zo_strsplit("|", presentCoords[zoneId])
    local coords = {zo_strsplit(",", rest)}

    activePrefix = prefix

    for i = 1, #coords / 3 do
        if (IsCompleted(zoneId, i)) then
            Crutch.dbgOther("skipping " .. i .. " since it has already been found")
        else
            local baseIndex = (i - 1) * 3
            local x = tonumber(coords[baseIndex + 1])
            local y = tonumber(coords[baseIndex + 2])
            local z = tonumber(coords[baseIndex + 3])
            activePresents[i] = {x = x, y = y, z = z}
            M.Present(prefix .. i, x, y, z)
        end
    end

    Crutch.dbgOther(NonContiguousCount(activePresents) .. " presents placed")

    MaybePollProximity()
end


---------------------------------------------------------------------
function M.IsPresentSeason()
    local speshulDate = Crutch.GetSpeshulDate()
    return speshulDate >= 1224 and speshulDate <= 1231
end
-- /script CrutchAlerts.Drawing.Model.IsPresentSeason = function() return true end CrutchAlerts.Drawing.Model.InitializePresent() CrutchAlerts.Drawing.Trail.OnPlayerActivated()

-- Enable if it was deliberately turned on; if involuntary, only allow with depth buffers
local function ArePresentsEnabled()
    if (not Crutch.savedOptions.general.showSpeshul) then return false end
    if (Crutch.savedOptions.memes.presents) then return true end
    return M.IsPresentSeason() and M.AreDepthBuffersSupported()
end
M.ArePresentsEnabled = ArePresentsEnabled


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local function Serialize()
    Crutch.savedOptions.general.presents = TrialsFoundToString()
end

local deserialized
local function Deserialize()
    if (deserialized) then return end
    TrialsStringToFound(Crutch.savedOptions.general.presents)
    deserialized = true
end

function M.InitializePresent()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "PresentPlayerActivated", EVENT_PLAYER_ACTIVATED)

    ClearPresents()

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "GuiUnload", EVENT_GUI_UNLOADING, Serialize)

    Deserialize() -- this needs to go before enabled check, because trails could be enabled without presents, and also we need to load it anyway because serialize will always run

    if (not ArePresentsEnabled()) then return end

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "PresentPlayerActivated", EVENT_PLAYER_ACTIVATED, PlacePresents)
    PlacePresents()
end
