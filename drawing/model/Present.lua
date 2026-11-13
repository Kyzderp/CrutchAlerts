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

local function IndexOf(tab, item)
    for i, v in ipairs(tab) do
        if (v == item) then
            return i
        end
    end
    return nil
end

local found = {} -- {0x1F, 0x00}
M.found = found

local function TrialsFoundToString()
    local result = ""
    for i = 1, #trials do
        result = string.format("%s%02x", result, found[trials[i]] or 0)
    end
    return result
end
M.TrialsFoundToString = TrialsFoundToString

local function TrialsStringToFound(str)
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

local function InitFound(index)
    if (not found[index]) then
        found[index] = 0
    end
end

-- found 1111 1111
-- put both trials and boxes in order like 4 3 2 1 so that existing ones never change
local function GetCompleted(zoneId)
    local index = IndexOf(trials, zoneId)
    if (not index) then return end
    InitFound(index)

    return found[index]
end
M.GetCompleted = GetCompleted

local function SetCompleted(zoneId, i, v)
    local index = IndexOf(trials, zoneId)
    if (not index) then return end
    InitFound(index)

    local newVal = found[index]

    if (v == true) then
        -- if setting to true, set mask to 1, then or
        newVal = BitOr(newVal, BitLShift(1, i - 1))
    elseif (v == false) then
        -- if setting to false, set mask to 1, invert, and
        newVal = BitAnd(newVal, BitNot(BitLShift(1, i - 1), 8))
    end

    found[index] = newVal
    return newVal
end
M.SetCompleted = SetCompleted


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
    [ 636] = "HRC|",  -- Hel Ra Citadel
    [ 638] = "AA|",  -- Aetherian Archive
    [ 639] = "SO|",  -- Sanctum Ophidia
    [ 725] = "MoL|",  -- Maw of Lorkhaj
    [ 975] = "HoF|",  -- Halls of Fabrication
    [1000] = "AS|",  -- Asylum Sanctorium
    [1051] = "CR|",  -- Cloudrest
    [1121] = "SS|",  -- Sunspire
    [1196] = "KA|",  -- Kyne's Aegis
    [1263] = "RG|",  -- Rockgrove
    [1344] = "DSR|",  -- Dreadsail Reef
    [1427] = "SE|",  -- Sanity's Edge
    [1478] = "LC|",  -- Lucent Citadel
    [1548] = "OC|",  -- Ossein Cage
    [ 849] = "VV|218739,11576,508011,218920,11583,504866",  -- Vvardenfell testing
    -- [1565] = "OO|",  -- Opulent Ordeal (Night Market)
}

local activePrefix
local activePresents = {} -- {[1] = {}} -- do NOT use ipairs; they can be removed when opened


---------------------------------------------------------------------
-- Approach
---------------------------------------------------------------------
local POLLING_NAME = "CrutchAlertsPresentProximity"
local function OpenPresent(index)
    activePresents[index] = nil
    M.PlayPresentAnimation(activePrefix .. index)

    SetCompleted(GetZoneId(GetUnitZoneIndex("player")), index, true)

    if (not next(activePresents)) then
        EVENT_MANAGER:UnregisterForUpdate(POLLING_NAME)
    end

    Crutch.dbgOther(TrialsFoundToString())
end

local function CheckDistances()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    for index, coords in pairs(activePresents) do
        local dist = Crutch.GetSquaredDistance(x, y, z, coords.x, coords.y, coords.z)
        if (dist < 40000) then
            OpenPresent(activePrefix .. index)
            return
        end
    end
end

local function MaybePollProximity()
    EVENT_MANAGER:UnregisterForUpdate(POLLING_NAME)
    if (not next(activePresents)) then return end

    EVENT_MANAGER:RegisterForUpdate(POLLING_NAME, 1000, CheckDistances)
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
        local baseIndex = (i - 1) * 3
        Crutch.dbgOther(coords[baseIndex + 1])
        local x = tonumber(coords[baseIndex + 1])
        local y = tonumber(coords[baseIndex + 2])
        local z = tonumber(coords[baseIndex + 3])
        activePresents[i] = {x = x, y = y, z = z}
        M.Present(prefix .. i, x, y, z)
    end

    Crutch.dbgOther(NonContiguousCount(activePresents) .. " presents placed")

    MaybePollProximity()
end


---------------------------------------------------------------------
-- Enable if it was deliberately turned on; if involuntary, only allow with depth buffers
local function ArePresentsEnabled()
    if (not Crutch.savedOptions.general.showSpeshul) then return false end
    if (Crutch.savedOptions.experimental or Crutch.savedOptions.memes.presents) then return true end
    local speshulDate = Crutch.GetSpeshulDate()
    return speshulDate >= 1224 and speshulDate <= 1231 and M.AreDepthBuffersSupported()
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function M.InitializePresent()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "PresentPlayerActivated", EVENT_PLAYER_ACTIVATED)

    ClearPresents()

    if (not ArePresentsEnabled()) then return end

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "PresentPlayerActivated", EVENT_PLAYER_ACTIVATED, PlacePresents)
    PlacePresents()
end
-- /script CrutchAlerts.Drawing.Model.InitializePresent()
