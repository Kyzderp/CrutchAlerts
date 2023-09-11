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
}

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(arenaThresholds) do
    BHB.thresholds[k] = v
end

for k, v in pairs(arenaAliases) do
    BHB.aliases[k] = v
end
