local Crutch = CrutchAlerts
local M = Crutch.Drawing.Model


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
    -- [1565] = "OO|",  -- Opulent Ordeal (Night Market)
}

local activePresents = {}


---------------------------------------------------------------------
-- Approach
---------------------------------------------------------------------
local POLLING_NAME = "CrutchAlertsPresentProximity"
local function OpenPresent(name)
    activePresents[name] = nil
    M.PlayPresentAnimation(name)

    if (not next(activePresents)) then
        EVENT_MANAGER:UnregisterForUpdate(POLLING_NAME)
    end
end

local function CheckDistances()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    for name, coords in pairs(activePresents) do
        local dist = Crutch.GetSquaredDistance(x, y, z, coords.x, coords.y, coords.z)
        if (dist < 10000) then
            OpenPresent(name)
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
    for name, _ in pairs(activePresents) do
        M.RemovePresent(name)
        activePresents[name] = nil
    end
end

local function PlacePresents()
    ClearPresents()

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if (not presentCoords[zoneId]) then
        return
    end

    local prefix, rest = zo_strsplit("|", presentCoords[zoneId])
    local coords = zo_strsplit(",", rest)

    for i = 1, #coords / 3 do
        local name = prefix .. i
        local baseIndex = (i - 1) * 3
        activePresents[name] = {x = coords[baseIndex + 1], y = coords[baseIndex + 2], z = coords[baseIndex + 3]}
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