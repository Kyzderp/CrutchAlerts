CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.BossHealthBar = CrutchAlerts.BossHealthBar or {}
local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

BHB.thresholds = {
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
    ["Corruption of Stone"] = {
        [80] = "Rock Shower",
        [60] = "Rock Shower",
        [30] = "Rock Shower",
    },
    ["Corruption of Root"] = {
        [70] = "Distributary", -- Unsure
        [40] = "Distributary", -- Unsure
    },
    ["Archdruid Devyric"] = {
        [65] = "Bear Form",
        [45] = "Human Form",
        [20] = "Bear Form",
    },
}

BHB.aliases = {
    ["L'exarchanique Yaseyla"] = "Exarchanic Yaseyla",
}
