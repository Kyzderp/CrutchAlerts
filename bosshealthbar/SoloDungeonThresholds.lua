local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar


---------------------------------------------------------------------
local function GetBossName(id)
    return Crutch.GetCapitalizedString(id)
end

---------------------------------------------------------------------
-- Add percentage threshold + the mechanic name below
---------------------------------------------------------------------
local soloDungeonThresholds = {
-- Moon Hunter Keep
    [GetBossName(CRUTCH_BHB_JAILER_MELITUS)] = {
        [80] = "Werewolves",
        [50] = "Werewolves",
        [30] = "Werewolves",
    },
    [GetBossName(CRUTCH_BHB_HEDGE_MAZE_GUARDIAN)] = {
        [80] = "2 Spriggans", -- heals to 75
        [70] = "Adds",
        [45] = "3-5 Spriggans", -- heals to 49. sometimes spawns 5, bug?
        [35] = "Adds",
        [15] = "Adds + 5 Spriggans",
    },
    [GetBossName(CRUTCH_BHB_MYLENNE_MOONCALLER)] = {
        [80] = "Wardens", 
        [65] = "Wolves", -- does it also require being after wardens?
        [50] = "Wardens",
        [27] = "Wolves", -- TODO: 27? 30? didn't spawn on one, maybe because warden still up?
        [20] = "Wardens", -- TODO: 21.015 (maybe from healing mm)
    },
    [GetBossName(CRUTCH_BHB_ARCHIVIST_ERNARDE)] = {
        [80] = "Symbols",
        [62] = "Adds", -- TODO: delayed by symbols cast 60 62
        [50] = "Symbols", -- probably right
        [40] = "Adds", -- TODO: no idea, burned too fast
        [30] = "Symbols", -- TODO: no idea, burned too fast
    },
    [GetBossName(CRUTCH_BHB_VYKOSA_THE_ASCENDANT)] = {
        [80] = "Melee + Werewolf",
        [60] = "Ranged",
        [40] = "Melee + Werewolf",
        [20] = "Ranged",
    },

-- March of Sacrifices (Bloodscent Pass)
    [GetBossName(CRUTCH_BHB_TARCYR)] = {
        [80] = "Hunt",
        [55] = "Hunt",
        [20] = "Hunt",
    },
    [GetBossName(CRUTCH_BHB_BALORGH)] = {
        [80] = "Hunt",
        [60] = "Hunt",
        [40] = "Hunt",
        [20] = "Hunt",
    },
}

---------------------------------------------------------------------
-- Separate from the other files
BHB.soloDungeonThresholds = soloDungeonThresholds
