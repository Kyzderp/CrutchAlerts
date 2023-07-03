CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.BossHealthBar = CrutchAlerts.BossHealthBar or {}
local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

BHB.thresholds = BHB.thresholds or {}
BHB.aliases = BHB.aliases or {}

---------------------------------------------------------------------
-- Add percentage threshold + the mechanic name below
---------------------------------------------------------------------
local dungeonThresholds = {
    -- Frostvault
    ["The Stonekeeper"] = {
        [55] = "Skeevatons",
    },

    -- Coral Aerie
    ["Maligalig"] = {
        [70] = "Whirlpool",
        [40] = "Whirlpool",
    },
    ["Sarydil"] = {
        [75] = "Trash", -- Could be 77% instead? kinda weird
        [35] = "Trash",
    },
    ["Varallion"] = {
        ["Normal"] = {
            [95] = "Gryphon",
            [50] = "Gryphon",
        },
    },
    ["Z'Baza"] = {
        [60] = "Conduit Tendril",
        [30] = "Conduit Tendril",
    },

    -- Earthen Root Enclave
    ["Corruption of Stone"] = {
        [80] = "Rock Shower",
        [60] = "Rock Shower",
        [30] = "Rock Shower",
    },
    ["Corruption of Root"] = {
        [75] = "Clones", -- Unsure, could be 80?
        [40] = "Clones", -- Unsure, but probably correct
    },
    ["Archdruid Devyric"] = {
        [65] = "Bear Form",
        [45] = "Human Form",
        [20] = "Bear Form",
    },
}

---------------------------------------------------------------------
-- Other language aliases can go here
---------------------------------------------------------------------
local dungeonAliases = {
    ["Steinwahrer"] = "The Stonekeeper",
}

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(dungeonThresholds) do
    BHB.thresholds[k] = v
end

for k, v in pairs(dungeonAliases) do
    BHB.aliases[k] = v
end
