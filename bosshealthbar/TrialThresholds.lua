CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.BossHealthBar = CrutchAlerts.BossHealthBar or {}
local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

BHB.thresholds = BHB.thresholds or {}
BHB.aliases = BHB.aliases or {}

---------------------------------------------------------------------
-- Add percentage threshold + the mechanic name below
---------------------------------------------------------------------
local trialThresholds = {
    -- Dreadsail Reef
    ["Lylanar"] = {
        [70] = "2nd Teleports",
        [65] = "1st Teleports",
    },
    ["Reef Guardian"] = {
        ["Veteran"] = {
            [50] = "Split",
        },
        ["Hardmode"] = {
            [80] = "Split",
        },
    },

    -- Sanity's Edge
    ["Exarchanic Yaseyla"] = {
        ["Veteran"] = {
            [90] = "Wamasu",
            [70] = "Wamasu",
            [60] = "Portals",
            [50] = "Wamasu",
            [35] = "Portals",
            [30] = "Wamasu",
            [20] = "Wamasu",
            [10] = "Wamasu",
        },
        ["Hardmode"] = {
            [90] = "Wamasu",
            [80] = "Shrapnel",
            [70] = "Wamasu",
            [60] = "Portals",
            [55] = "Shrapnel",
            [50] = "Wamasu",
            [35] = "Portals",
            [30] = "Wamasu",
            [25] = "Shrapnel + on timer",
            [20] = "Wamasu",
            [10] = "Wamasu",
        },
    },
    ["Ansuul the Tormentor"] = {
        [90] = "Manic Phobia",
        [80] = "Maze",
        [70] = "Manic Phobia",
        [60] = "Maze",
        [50] = "Manic Phobia",
        [40] = "Maze",
        [30] = "Manic Phobia",
        [20] = "Split",
        [10] = "Manic Phobia",
    },
}

---------------------------------------------------------------------
-- Other language aliases can go here
---------------------------------------------------------------------
local trialAliases = {
    ["L'exarchanique Yaseyla"] = "Exarchanic Yaseyla",
}

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(trialThresholds) do
    BHB.thresholds[k] = v
end

for k, v in pairs(trialAliases) do
    BHB.aliases[k] = v
end
