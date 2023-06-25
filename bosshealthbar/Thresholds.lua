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
}

BHB.aliases = {
    ["L'exarchanique Yaseyla"] = "Exarchanic Yaseyla",
}
