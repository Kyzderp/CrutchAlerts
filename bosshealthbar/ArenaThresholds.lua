CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.BossHealthBar = CrutchAlerts.BossHealthBar or {}
local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

BHB.thresholds = BHB.thresholds or {}
BHB.aliases = BHB.aliases or {}

---------------------------------------------------------------------
-- Add percentage threshold + the mechanic name below
---------------------------------------------------------------------
local arenaThresholds = {
-- Blackrose Prison

-- Dragonstar Arena
    ["Champion Marcauld"] = {
        [75] = "Adds", -- TODO: alcast 70
        [40] = "Adds", -- TODO
    },
    -- Stage 2 and 3 are based on combined health, skip for now
    ["Earthen Heart Knight"] = {
        [70] = "Adds", -- TODO
        [30] = "Adds", -- TODO
    },
    ["Anal'a Tu'wha"] = {
        [78] = "Adds", -- TODO
        [40] = "Adds", -- TODO
    },
    ["Pishna Longshot"] = {
        [70] = "Adds", -- TODO
        [40] = "Adds", -- TODO
    },
    -- Stage 7 is combined health
    ["Mavus Talnarith"] = {
        [80] = "Adds", -- TODO
        [40] = "Adds", -- TODO
    },
    ["Vampire Lord Thisa"] = {
        [80] = "Portal", -- TODO
        [40] = "Adds", -- TODO
    },
    ["Hiath the Battlemaster"] = {
        [75] = "Adds", -- TODO
        [50] = "Pull + Adds", -- TODO
        [25] = "Pull", -- TODO
    },

-- Maelstrom Arena

-- Vateshran Hollows
    ["The Pyrelord"] = {
        [70] = "Colossus",
        [30] = "Colossus",
    },
}

---------------------------------------------------------------------
-- Other language aliases can go here
---------------------------------------------------------------------
local arenaAliases = {
    ["Der Schürfürst"] = "The Pyrelord",

-- Simplified Chinese aliases from oumu
    ["勇士马卡尔德"] = "Champion Marcauld",
    ["大地之心骑士"] = "Earthen Heart Knight",
    ["阿那拉·图哈"] = "Anal'a Tu'wha",
    ["远射手皮斯娜"] = "Pishna Longshot",
    ["马维斯·泰尔纳里斯"] = "Mavus Talnarith",
    ["吸血鬼大君斯萨"] = "Vampire Lord Thisa",
    ["战斗大师西亚斯"] = "Hiath the Battlemaster",
    ["柴堆领主"] = "The Pyrelord",

-- German aliases from Keldorem
    ["Der Schürfürst"] = "The Pyrelord",
}

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(arenaThresholds) do
    BHB.thresholds[k] = v
end

for k, v in pairs(arenaAliases) do
    BHB.aliases[k] = v
end
