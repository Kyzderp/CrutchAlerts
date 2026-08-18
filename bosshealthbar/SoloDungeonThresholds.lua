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
        [80] = "Werewolves", -- TODO
        [50] = "Werewolves", -- TODO
        [30] = "Werewolves", -- TODO
    },
    [GetBossName(CRUTCH_BHB_HEDGE_MAZE_GUARDIAN)] = {
        [80] = "2 Spriggans", -- maybe? heals to 75
        [70] = "Adds",
        [45] = "3-5 Spriggans", -- maybe? heals to 49. 5? might be because pushed farther?
        [35] = "Adds",
        [15] = "Adds + 5 Spriggans?",
    },
    [GetBossName(CRUTCH_BHB_MYLENNE_MOONCALLER)] = {
        [80] = "Warden", -- TODO
        [60] = "Warden", -- TODO
        [40] = "Warden", -- TODO
        [20] = "Warden", -- TODO
    },
    [GetBossName(CRUTCH_BHB_ARCHIVIST_ERNARDE)] = {
        -- how can the guides be so different??
        -- xynode: 76, 56, 36
        -- esoplanet: 80, 60, 40, 20
        [80] = "Adds", -- TODO
        [60] = "Adds", -- TODO
        [40] = "Adds", -- TODO
        [20] = "Adds", -- TODO
    },
    [GetBossName(CRUTCH_BHB_VYKOSA_THE_ASCENDANT)] = {
        normHealth = 1515587, -- TODO
        vetHealth = 4233356, -- TODO
        hmHealth = 5503363, -- TODO
        ["Normal"] = {
            [90] = "Werewolves", -- TODO
            [80] = "Wolves", -- TODO
            [70] = "Werewolves", -- TODO
            [60] = "Wolves", -- TODO
            [50] = "Werewolves", -- TODO
            [40] = "Wolves", -- TODO
            [30] = "Werewolves", -- TODO
            [20] = "Wolves", -- TODO
        },
        ["Veteran"] = {
            [90] = "Werewolves", -- TODO
            [80] = "Wolves", -- TODO
            [70] = "Werewolves", -- TODO
            [60] = "Wolves", -- TODO
            [50] = "Werewolves", -- TODO
            [40] = "Wolves", -- TODO
            [30] = "Werewolves", -- TODO
            [20] = "Wolves", -- TODO
        },
        ["Hardmode"] = {
            [90] = "Werewolves", -- TODO
            [85] = "Werewolves", -- TODO
            [80] = "Wolves", -- TODO
            [70] = "Werewolves", -- TODO
            [65] = "Werewolves", -- TODO
            [60] = "Wolves", -- TODO
            [50] = "Werewolves + Warden", -- TODO
            [45] = "Werewolves", -- TODO
            [40] = "Wolves", -- TODO
            [30] = "Werewolves + Rune", -- TODO
            [25] = "Werewolves", -- TODO
            [20] = "Wolves", -- TODO
        },
    },

-- March of Sacrifices (Bloodscent Pass)
    [GetBossName(CRUTCH_BHB_AGHAEDH_OF_THE_SOLSTICE)] = {
        [70] = "Lurcher", -- TODO
        [55] = "Lurcher", -- TODO
        [25] = "Lurcher", -- TODO
    },
    [GetBossName(CRUTCH_BHB_TARCYR)] = {
        [80] = "Hunt", -- TODO
        [50] = "Hunt", -- TODO
        [20] = "Hunt", -- TODO
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
