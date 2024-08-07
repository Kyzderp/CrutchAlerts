CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.BossHealthBar = CrutchAlerts.BossHealthBar or {}
local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

BHB.thresholds = BHB.thresholds or {}
---------------------------------------------------------------------
local function GetBossName(id)
    return Crutch.GetCapitalizedString(id)
end

---------------------------------------------------------------------
-- Add percentage threshold + the mechanic name below
---------------------------------------------------------------------
local trialThresholds = {
-- Testing
    -- ["Loremaster Trigon"] = {
    --     [90] = "Test",
    --     [80] = "Thingo",
    --     [70] = "Blah",
    --     [60] = "Yeeeeet",
    --     [55] = "More mechanics",
    --     [50] = "AAAAAAAAAA",
    --     [35] = "Stuff",
    --     [30] = "Text",
    --     [25] = "Longer mechanic name",
    --     [20] = "Testing",
    --     [10] = "BURN IT",
    -- },

-- For unlock UI settings
    ["Example Boss 1"] = {
        [85] = "Some mechanic",
        [70] = "Another mechanic",
        [35] = "A mechanic",
    },

-- Hel Ra Citadel
    [GetBossName(CRUTCH_BHB_RA_KOTU)] = {
        [35] = "Beyblade",
    },
    [GetBossName(CRUTCH_BHB_THE_WARRIOR)] = {
        [85] = "Statue Smash",
        [70] = "Statue Smash",
        [35] = "Shockwave",
    },

-- Aetherian Archive
    [GetBossName(CRUTCH_BHB_THE_MAGE)] = {
        [16] = "Knockdown", -- Not sure of the exact %, but it seems to be between 16 and 18
    },

-- Sanctum Ophidia
    -- Stonebreaker has an enrage, but not sure exact %. The guides for Crag trials
    -- aren't very helpful because they're so early and easy trials... one says 20%

-- Maw of Lorkhaj
    [GetBossName(CRUTCH_BHB_ZHAJHASSA_THE_FORGOTTEN)] = {
        [70] = "Shield",
        [30] = "Shield",
    },
    [GetBossName(CRUTCH_BHB_RAKKHAT)] = {
        [11] = "Execute",
    },

-- Halls of Fabrication
    [GetBossName(CRUTCH_BHB_HUNTERKILLER_NEGATRIX)] = {
        [15] = "", -- To help know to bring the other boss in, if killing separately
    },
    [GetBossName(CRUTCH_BHB_PINNACLE_FACTOTUM)] = {
        [80] = "Simulacra",
        [60] = "Conduits",
        [40] = "Spinner",
    },
    [GetBossName(CRUTCH_BHB_REACTOR)] = {
        [70] = "Reset",
        [40] = "Reset",
        [20] = "Reset",
    },
    [GetBossName(CRUTCH_BHB_ASSEMBLY_GENERAL)] = {
        [86] = "Terminals", -- TODO: check it after the floor rounding change
        [66] = "Terminals", -- TODO: check it after the floor rounding change
        [46] = "Terminals", -- TODO: check it after the floor rounding change
        [26] = "Execute", -- TODO: check it after the floor rounding change
    },

-- Asylum Sanctorium
    [GetBossName(CRUTCH_BHB_SAINT_OLMS_THE_JUST)] = {
        [90] = "Big Jump", -- it seems to actually be 91.04%...
        [75] = "Big Jump",
        [50] = "Big Jump",
        [25] = "Big Jump",
    },

-- Cloudrest
    [GetBossName(CRUTCH_BHB_SHADE_OF_SIRORIA)] = {
        [60] = "Siroria starts jumping",
    },
    -- I'd add the mini spawns for Z'Maja, but I haven't found a way to detect difficulty easily.
    -- +0, +1, +2, +3 all have the same HP for Z'Maja. Maybe there's a missing buff somewhere?
    -- Otherwise, I'd have to change the mechanic stages once mechs like flare, barswap, frost
    -- start showing up, which would be... a lotta work
    -- On vet, it could be possible to check the score to see how many side bosses were killed
    -- ... but also a lotta work

-- Sunspire
    [GetBossName(CRUTCH_BHB_LOKKESTIIZ)] = {
        [80] = "Atros + Beam",
        [50] = "Beam + Atros",
        [20] = "Atros + Beam",
    },
    [GetBossName(CRUTCH_BHB_YOLNAHKRIIN)] = {
        [75] = "Cataclysm",
        [50] = "Cataclysm",
        [25] = "Cataclysm",
    },
    [GetBossName(CRUTCH_BHB_NAHVIINTAAS)] = {
        [90] = "Time Shift",
        [80] = "Takeoff",
        [70] = "Time Shift",
        [60] = "Takeoff",
        [50] = "Time Shift",
        [40] = "Takeoff",
    },

-- Kyne's Aegis
    [GetBossName(CRUTCH_BHB_YANDIR_THE_BUTCHER)] = {
        [50] = "Enrage",
    },
    [GetBossName(CRUTCH_BHB_CAPTAIN_VROL)] = {
        [50] = "Shamans",
    },
    [GetBossName(CRUTCH_BHB_LORD_FALGRAVN)] = {
        [95] = "Lieutenant",
        [90] = "Conga Line",
        [80] = "Conga Line",
        [70] = "Floor Shatter",
        [35] = "Floor Shatter",
    },

-- Rockgrove
    [GetBossName(CRUTCH_BHB_OAXILTSO)] = {
        [95] = "Mini",
        [75] = "Mini",
        [50] = "Mini",
        [20] = "Mini",
    },
    [GetBossName(CRUTCH_BHB_FLAMEHERALD_BAHSEI)] = {
        [90] = "Abomination",
        [85] = "Abomination",
        [80] = "Abomination",
        [75] = "Abomination",
        [70] = "Abomination",
        [65] = "Abomination",
        [60] = "Abomination",
        [50] = "Behemoth",
        [40] = "Behemoth",
        [30] = "Meteor",
        [25] = "Behemoth",
        [20] = "Behemoth",
        [10] = "Behemoth",
    },
    [GetBossName(CRUTCH_BHB_XALVAKKA)] = {
        [70] = "Run!",
        [40] = "Run!",
    },

-- Dreadsail Reef
    [GetBossName(CRUTCH_BHB_LYLANAR)] = {
        [70] = "2nd Teleports",
        [65] = "1st Teleports",
    },
    [GetBossName(CRUTCH_BHB_REEF_GUARDIAN)] = {
        vetHealth = 27943440,
        hmHealth = 41915160,
        ["Veteran"] = {
            [80] = "Big Split",
            [50] = "Split",
        },
        ["Hardmode"] = {
            [100] = "Big Split",
            [80] = "Split",
        },
    },
    [GetBossName(CRUTCH_BHB_TIDEBORN_TALERIA)] = {
        [85] = "Winter Storm",
        [50] = "Bridge",
        [35] = "Bridge",
        [20] = "Bridge",
    },

-- Sanity's Edge
    [GetBossName(CRUTCH_BHB_EXARCHANIC_YASEYLA)] = {
        -- |cFF0000[BHB] boss 1 MAX INCREASE|r 65201356 -> 97802032
        vetHealth = 65201356,
        hmHealth = 97802032,
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
    [GetBossName(CRUTCH_BHB_ANSUUL_THE_TORMENTOR)] = {
        [90] = "Manic Phobia",
        [80] = "Maze",
        [70] = "Manic Phobia",
        [60] = "Maze",
        [50] = "Manic Phobia",
        [40] = "Maze",
        [30] = "Manic Phobia",
        [20] = "Split / Phobia on timer",
    },

-- Lucent Citadel
    [GetBossName(CRUTCH_BHB_ORPHIC_SHATTERED_SHARD)] = {
        [90] = "Color Change",
        [60] = "Color Change",
        [40] = "Color Change",
        [25] = "Adds",
        [15] = "Color Change",
    },
}

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(trialThresholds) do
    BHB.thresholds[k] = v
end
