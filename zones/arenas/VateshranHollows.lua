local Crutch = CrutchAlerts

local GREEN = "Hunter's Grotto"
local BLUE = "The Wounding"
local RED = "The Brimstone Den"

local currentWing -- Hunter's Grotto, Wounding, Brimstone Den
local gateIndex = 0

---------------------------------------------------------------------
-- Data for how many of each add is in each wing
---------------------------------------------------------------------
local REASON_POINTS = {
    [RAID_POINT_REASON_SOLO_ARENA_PICKUP_ONE] = 750, -- 4x given on rahdgarak for whatev reason
    [RAID_POINT_REASON_SOLO_ARENA_PICKUP_TWO] = 1500,
    [RAID_POINT_REASON_SOLO_ARENA_PICKUP_THREE] = 2250,
    [RAID_POINT_REASON_SOLO_ARENA_PICKUP_FOUR] = 3000,
    [RAID_POINT_REASON_KILL_NORMAL_MONSTER] = 100,
    [RAID_POINT_REASON_KILL_BANNERMEN] = 500,
    [RAID_POINT_REASON_KILL_CHAMPION] = 750,
    [RAID_POINT_REASON_KILL_BOSS] = 15000,
}

local ADDS = {
    [GREEN] = {
        [1] = { -- 3 spriggans, 2 alits, 4 fire shalks, troll gatekeeper
            normal = 4, -- shalks
            bannermen = 3, -- spriggans
            champion = 2, -- alits
            normalName = "shalks",
            bannermenName = "spriggans",
            championName = "alits",
        },
        [2] = { -- 2 fetcherfly hives, 3 fire shalks, 1 spriggan, 2 alits, 1 blessed spriggan, bristleback gatekeeper
            normal = 5, -- shalks + hives
            bannermen = 1, -- spriggan
            champion = 1, -- probably the blessed spriggan? these alits are worth 0 score
            normalName = "shalks/fetcherfly hives",
            bannermenName = "spriggan",
            championName = "blessed spriggan?",
        },
        [3] = { -- boss, pickup_four
            boss = true,
        },
        [4] = { -- 3 cliff striders, 3 salamanders, 2 direwolves, ogre gatekeeper
            normal = 5, -- direwolves + cliff striders
            bannermen = 3, -- salamanders
            champion = 0,
            normalName = "direwolves/cliff striders",
            bannermenName = "spriggans",
            championName = "",
        },
        [5] = { -- 4 cliff striders, 2 terror birds, haj mota gatekeeper
            normal = 4, -- cliff striders
            bannermen = 2, -- terror birds
            champion = 0,
            normalName = "cliff striders",
            bannermenName = "terror birds",
            championName = "",
        },
        [6] = { -- boss, pickup_four + 4x pickup_one
            boss = true,
        },
    },
    [BLUE] = {
        [1] = { -- 3 twilights, 5 banekin, dire warden
            normal = 4, -- the 4th banekin does not give score
            bannermen = 3, -- 3 twilights
            champion = 0,
            normalName = "banekin",
            bannermenName = "twilights",
            championName = "",
        },
        [2] = { -- 2 ogrims, 3 twilights, 5 banekin, dire warden
            normal = 5, -- banekin
            bannermen = 3, -- twilights
            champion = 2, -- ogrims
        },
        [3] = { -- boss, kill_boss + pickup_four
            boss = true,
        },
        [4] = { -- 2 watchers, 5 banekin
            normal = 5, -- banekin
            bannermen = 2, -- watchers
            champion = 0,
            normalName = "banekin",
            bannermenName = "watchers",
            championName = "",
        },
        [5] = { -- 5 banekin, 1 twilight, 1 xivkyn hammerfist, 1 xivkyn chillfiend, sentinel of enfeeblement, ogrim behemoth (gatekeeper)
            normal = 5, -- banekin
            bannermen = 1, -- twilight
            champion = 3, -- hammerfist, chillfiend, sentinel
            normalName = "banekin",
            bannermenName = "twilight",
            championName = "xivkyn/sentinel",
        },
        [6] = { -- 1 xivkyn kynlurker, 1 watcher, 1 sentinel of debilitation, 2 banekin, 1 dire warden
            normal = 2, -- banekin
            bannermen = 1, -- watcher
            champion = 3, -- kynlurker, sentinel, dire warden
            normalName = "banekin",
            bannermenName = "watcher",
            championName = "xivkyn/sentinel/dire warden",
        },
        [7] = { -- (side portal) 9 banekin, 1 sentinel of enfeeblement
            normal = 9, -- banekin
            bannermen = 0,
            champion = 1, -- sentinel
            normalName = "banekin",
            bannermenName = "",
            championName = "sentinel",
        },
        [8] = { -- 4 banekin, 1 sentinel of vulnerability, 1 xivkyn hammerfist
            normal = 4, -- banekin
            bannermen = 0,
            champion = 2, -- sentinel, hammerfist
            normalName = "banekin",
            bannermenName = "",
            championName = "sentinel/xivkyn",
        },
        [9] = { -- boss, 2x kill_boss + pickup_four
            boss = true,
        },
    },
    [RED] = {
        [1] = { -- 5 scamps, 3 clannfears, 2 flame atros, daedroth (gatekeeper)
            normal = 5, -- scamps
            bannermen = 5, -- clannfears + flame atros
            champion = 0,
            normalName = "scamps",
            bannermenName = "clannfears/flame atros",
            championName = "",
        },
        [2] = { -- 2 flame atros, 3 scamps, 1 clannfear, brimstone warden
            normal = 3, -- scamps
            bannermen = 3, -- flame atros + clannfear
            champion = 0,
            normalName = "scamps",
            bannermenName = "clannfears/flame atros",
            championName = "",
        },
        [3] = { -- boss, kill_boss + pickup_four
            boss = true,
        },
        [4] = { -- 1 flame atro, 5 scamps, daedroth (gatekeeper)
            normal = 5, -- scamps
            bannermen = 1, -- flame atro
            champion = 0,
            normalName = "scamps",
            bannermenName = "flame atros",
            championName = "",
        },
        [5] = { -- brimstone caretaker, kill_boss
            brimstone = true,
        },
        [6] = { -- 1 flame atro, 4 dremora kyngald, 3 scamps, brimstone warden
            -- brimstone caretaker is also in this gate, for 15k points (kill_boss), score is given immediately upon kill. but it's part of the score after killing gatekeeper too, as a champion
            normal = 3, -- scamps
            bannermen = 5, -- kyngalds + flame atro
            champion = 1, -- brimstone caretaker
            normalName = "scamps",
            bannermenName = "dremora/flame atros",
            championName = "colossus",
        },
        [7] = { -- boss, 2x kill_boss + pickup_four
            boss = true,
        },
    },
}

-- final boss: kill_boss + solo_wing_complete <short delay> solo_wing_complete

---------------------------------------------------------------------
---------------------------------------------------------------------
--[[
/script d(GetMapTileTexture())
lobby: Art/maps/reach/VateshransRites01_0.dds
choosing: [20:05:43] Art/maps/reach/VateshransRites01a_0.dds
the wounding: [01:06:59] [CO] Art/maps/reach/VateshransRitesMap02_0.dds
hunter's grotto: [20:06:36] Art/maps/reach/VateshransRitesMAP03_0.dds
the brimstone den: [00:17:08] Art/maps/reach/VateshransRitesMAP04_0.dds
champion's circle: [01:20:34] [CO] Art/maps/reach/VateshransRitesMAP05_0.dds
]]
local function GetWing()
    local mapTileTexture = string.lower(GetMapTileTexture())

    if (string.find(mapTileTexture, "map02")) then
        return BLUE
    elseif (string.find(mapTileTexture, "map03")) then
        return GREEN
    elseif (string.find(mapTileTexture, "map04")) then
        return RED
    elseif (string.find(mapTileTexture, "map05")) then
        return nil -- champion's circle
    else
        return nil -- lobby or others?
    end
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local scoreBatch = {}

local function OnScoreBatch()
    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "VHScoreTimeout")

    local wing = GetWing()

    if (wing) then
        if (wing ~= currentWing) then
            Crutch.dbgOther(string.format("|cFF7777Starting new wing %s|r", wing))
            currentWing = wing
            gateIndex = 0
        end

        local isBoss = false
        if (scoreBatch[RAID_POINT_REASON_SOLO_ARENA_PICKUP_ONE] or
            scoreBatch[RAID_POINT_REASON_SOLO_ARENA_PICKUP_TWO] or
            scoreBatch[RAID_POINT_REASON_SOLO_ARENA_PICKUP_THREE] or
            scoreBatch[RAID_POINT_REASON_SOLO_ARENA_PICKUP_FOUR]) then
            isBoss = true
        end

        gateIndex = gateIndex + 1
        local baselineData = ADDS[wing][gateIndex]
        if (not baselineData) then
            Crutch.dbgOther(string.format("|cFF0000No baseline data found for %s gate %d|r", wing, gateIndex))
        else
            Crutch.dbgSpam(string.format("checking wing %s gateIndex %d", wing, gateIndex))
            if (isBoss and baselineData.normal ~= nil) then
                -- This means we skipped entire trash pulls, so increment gate until we get to a boss baseline
                local missedNormal = 0
                local missedBannermen = 0
                local missedChampion = 0

                while (not baselineData.boss) do
                    missedNormal = missedNormal + (baselineData.normal or 0)
                    missedBannermen = missedBannermen + (baselineData.bannermen or 0)
                    missedChampion = missedChampion + (baselineData.champion or 0)
                    gateIndex = gateIndex + 1
                    baselineData = ADDS[wing][gateIndex]
                end

                local message = ""
                if (missedNormal ~= 0) then
                    message = string.format("%s; |cFF5555%d|r normal adds", message, missedNormal)
                end
                if (missedBannermen ~= 0) then
                    message = string.format("%s; |cFF5555%d|r bannermen", message, missedBannermen)
                end
                if (missedChampion ~= 0) then
                    message = string.format("%s; |cFF5555%d|r champions", message, missedChampion)
                end
                if (message ~= "") then
                    CHAT_ROUTER:AddSystemMessage("Missed adds (lots of skipping)" .. message)
                end
            elseif (isBoss) then
                Crutch.dbgOther("this is a boss")
            elseif (scoreBatch[RAID_POINT_REASON_KILL_BOSS]) then
                -- Killed Brimstone Caretaker
                Crutch.dbgOther("moar score")
            else
                if (baselineData.normal == nil) then
                    -- This means we skipped the brimstone caretaker, which is a "boss"
                    gateIndex = gateIndex + 1
                    baselineData = ADDS[wing][gateIndex]
                    CHAT_ROUTER:AddSystemMessage("|cFF5555You skipped the Brimstone Caretaker?! It's worth 15k points!|r")
                end

                -- Compare the scores we got vs the baseline
                local missedNormal = baselineData.normal - (scoreBatch[RAID_POINT_REASON_KILL_NORMAL_MONSTER] or 0)
                local missedBannermen = baselineData.bannermen - (scoreBatch[RAID_POINT_REASON_KILL_BANNERMEN] or 0)
                local missedChampion = baselineData.champion - (scoreBatch[RAID_POINT_REASON_KILL_CHAMPION] or 0)

                local message = ""
                if (missedNormal ~= 0) then
                    message = string.format("%s; |cFF5555%d|r normal adds (%s)", message, missedNormal, baselineData.normalName)
                end
                if (missedBannermen ~= 0) then
                    message = string.format("%s; |cFF5555%d|r bannermen (%s)", message, missedBannermen, baselineData.bannermenName)
                end
                if (missedChampion ~= 0) then
                    message = string.format("%s; |cFF5555%d|r champions (%s)", message, missedChampion, baselineData.championName)
                end
                if (message ~= "") then
                    CHAT_ROUTER:AddSystemMessage("Missed adds" .. message)
                end
            end
        end
    end

    scoreBatch = {}
end

-- EVENT_RAID_TRIAL_SCORE_UPDATE (number eventCode, RaidPointReason scoreUpdateReason, number scoreAmount, number totalScore)
local function OnScoreUpdate(_, scoreUpdateReason, scoreAmount, totalScore)
    if (scoreUpdateReason == RAID_POINT_REASON_LIFE_REMAINING) then return end

    -- We should collect them into batches because killing a gatekeeper gives you all the score at once
    if (not scoreBatch[scoreUpdateReason]) then
        scoreBatch[scoreUpdateReason] = 0
    end
    scoreBatch[scoreUpdateReason] = scoreBatch[scoreUpdateReason] + 1

    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "VHScoreTimeout", 100, OnScoreBatch)
end


---------------------------------------------------------------------
-- Reset everything when starting score
---------------------------------------------------------------------
-- EVENT_RAID_TRIAL_STARTED (number eventCode, string trialName, boolean weekly)
local function OnStarted()
    scoreBatch = {}
    currentWing = nil
    gateIndex = 0
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterVateshran()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Vateshran Hollows")

    if (Crutch.savedOptions.vateshran.showMissedAdds) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "VHStarted", EVENT_RAID_TRIAL_STARTED, OnStarted)

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "VHScore", EVENT_RAID_TRIAL_SCORE_UPDATE, OnScoreUpdate)
    end
end

function Crutch.UnregisterVateshran()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "VHStarted", EVENT_RAID_TRIAL_STARTED)

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "VHScore", EVENT_RAID_TRIAL_SCORE_UPDATE)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Vateshran Hollows")
end
