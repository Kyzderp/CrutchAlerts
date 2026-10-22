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
        ["0"] = {
            [50] = "Adds",
            [30] = "Adds",
        },
        [80] = "Adds", -- +2: no werewolf; +0: nothing?; +1: 1 ww
        [50] = "Adds",
        [30] = "Adds",
    },
    [GetBossName(CRUTCH_BHB_HEDGE_MAZE_GUARDIAN)] = {
        ["0"] = {
            [80] = "Spriggans",
            [45] = "Spriggans",
            [15] = "Spriggans",
        },
        [80] = "Spriggans", -- heals to 75
        [70] = "Adds", -- +2: only senches; +1: 1 senche
        [45] = "Spriggans", -- heals to 49. sometimes spawns 5, bug? +0: 2 spriggans; +2: 3; +1: pushed too fast and it spawned 5...
        [35] = "Adds",
        [15] = "Spriggans + Adds", -- +0: 3 spriggans; +2: 5; TODO: check adds
    },
    [GetBossName(CRUTCH_BHB_MYLENNE_MOONCALLER)] = {
        ["0"] = {
            [80] = "Warden",
            [50] = "Warden",
            [20] = "Wardens",
        },
        ["1"] = {
            [80] = "Warden",
            [50] = "Warden",
            [20] = "Wardens",
        },
        ["2"] = {
            [80] = "Warden",
            [50] = "Wardens", -- TODO
            [20] = "Wardens",
        },
        [80] = "Wardens", -- +0: 1; +1: 1; +2: 1
        [50] = "Wardens", -- +0: 1; +1: 1
        [20] = "Wardens", -- +1: 2; +2: 4??
    },
    [GetBossName(CRUTCH_BHB_ARCHIVIST_ERNARDE)] = {
        [80] = "Symbols", -- +2: adds afterwards; +1: adds afterwards, 75%
        [50] = "Symbols", -- +3: adds; +2: no adds; +1: adds
        [20] = "Symbols", -- +3: adds; +2: adds; +1: 1 add
    },
    [GetBossName(CRUTCH_BHB_VYKOSA_THE_ASCENDANT)] = {
        ["0"] = {
            [80] = "Melee",
            [60] = "Ranged",
            [40] = "Melee",
            [20] = "Ranged",
        },
        [80] = "Melee + Werewolf", -- +1/+2/+3: has ww
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
