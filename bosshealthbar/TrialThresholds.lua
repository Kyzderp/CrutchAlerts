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
    ["Ra Kotu"] = {
        [35] = "Beyblade",
    },
    ["The Warrior"] = {
        [85] = "Statue Smash",
        [70] = "Statue Smash",
        [35] = "Shockwave",
    },

-- Aetherian Archive
    ["The Mage"] = {
        [15] = "Arcane Vortex",
    },

-- Sanctum Ophidia
    -- Stonebreaker has an enrage, but not sure exact %. The guides for Crag trials
    -- aren't very helpful because they're so early and easy trials... one says 20%

-- Maw of Lorkhaj
    ["Zhaj'hassa the Forgotten"] = {
        [70] = "Shield",
        [30] = "Shield",
    },
    ["Rakkhat"] = {
        [11] = "Execute",
    },

-- Halls of Fabrication
    ["Hunter-Killer Negatrix"] = {
        [15] = "", -- To help know to bring the other boss in, if killing separately
    },
    ["Pinnacle Factotum"] = {
        [80] = "Simulacra",
        [60] = "Conduits",
        [40] = "Spinner",
    },
    ["Reactor"] = {
        [70] = "Reset",
        [40] = "Reset",
        [20] = "Reset",
    },
    ["Assembly General"] = {
        [86] = "Terminals",
        [66] = "Terminals",
        [46] = "Terminals",
        [26] = "Execute",
    },

-- Asylum Sanctorium
    ["Saint Olms the Just"] = {
        [91] = "Big Jump",
        [76] = "Big Jump",
        [51] = "Big Jump",
        [26] = "Big Jump",
    },

-- Cloudrest
    ["Shade of Siroria"] = {
        [60] = "Siroria starts jumping",
    },
    -- I'd add the mini spawns for Z'Maja, but I haven't found a way to detect difficulty easily.
    -- +0, +1, +2, +3 all have the same HP for Z'Maja. Maybe there's a missing buff somewhere?
    -- Otherwise, I'd have to change the mechanic stages once mechs like flare, barswap, frost
    -- start showing up, which would be... a lotta work

-- Sunspire
    ["Lokkestiiz"] = {
        [80] = "Atros + Beam",
        [50] = "Beam + Atros",
        [20] = "Atros + Beam",
    },
    ["Yolnahkriin"] = {
        [75] = "Cataclysm",
        [50] = "Cataclysm",
        [25] = "Cataclysm",
    },
    ["Nahviintaas"] = {
        [90] = "Time Shift",
        [80] = "Takeoff",
        [70] = "Time Shift",
        [60] = "Takeoff",
        [50] = "Time Shift",
        [40] = "Takeoff",
    },

-- Kyne's Aegis
    ["Yandir the Butcher"] = {
        [50] = "Enrage",
    },
    ["Captain Vrol"] = {
        [50] = "Shamans",
    },
    ["Lord Falgravn"] = {
        [95] = "Lieutenant",
        [90] = "Conga Line",
        [80] = "Conga Line",
        [70] = "Floor Shatter",
        [35] = "Floor Shatter",
    },

-- Rockgrove
    ["Oaxiltso"] = {
        [95] = "Mini",
        [75] = "Mini",
        [50] = "Mini",
        [25] = "Mini",
    },
    ["Flame-Herald Bahsei"] = {
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
    ["Xalvakka"] = {
        [70] = "Run!",
        [40] = "Run!",
    },

-- Dreadsail Reef
    ["Lylanar"] = {
        [70] = "2nd Teleports",
        [65] = "1st Teleports",
    },
    ["Reef Guardian"] = {
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
    ["Tideborn Taleria"] = {
        [85] = "Winter Storm",
        [50] = "Bridge",
        [35] = "Bridge",
        [20] = "Bridge",
    },

-- Sanity's Edge
    ["Exarchanic Yaseyla"] = {
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
    ["Ansuul the Tormentor"] = {
        [90] = "Manic Phobia",
        [80] = "Maze",
        [70] = "Manic Phobia",
        [60] = "Maze",
        [50] = "Manic Phobia",
        [40] = "Maze",
        [30] = "Manic Phobia",
        [20] = "Split / Phobia on timer",
    },
}

---------------------------------------------------------------------
-- Other language aliases can go here
---------------------------------------------------------------------
local trialAliases = {
    ["L'exarchanique Yaseyla"] = "Exarchanic Yaseyla",

-- Simplified Chinese aliases from oumu
    ["拉·阔图"] = "Ra Kotu",
    ["武士"] = "The Warrior",
    ["法师"] = "The Mage",
    ["遗忘者扎哈撒"] = "Zhaj'hassa the Forgotten",
    ["拉卡特"] = "Rakkhat",
    ["猎杀者聂佳特里克斯"] = "Hunter-Killer Negatrix",
    ["巅峰机械人"] = "Pinnacle Factotum",
    ["反应器人"] = "Reactor",
    ["组装将军"] = "Assembly General",
    ["公正圣徒奥尔姆斯"] = "Saint Olms the Just",
    ["希罗利亚幽影"] = "Shade of Siroria",
    ["洛克提兹"] = "Lokkestiiz",
    ["尤尔纳克林"] = "Yolnahkriin",
    ["纳温塔丝"] = "Nahviintaas",
    ["屠夫扬迪尔"] = "Yandir the Butcher",
    ["威若船长"] = "Captain Vrol",
    ["法尔格拉文领主"] = "Lord Falgravn",
    ["奥西索"] = "Oaxiltso",
    ["烈焰先驱巴塞"] = "Flame-Herald Bahsei",
    ["夏尔瓦卡"] = "Xalvakka",
    ["莱拉纳尔"] = "Lylanar",
    ["礁石守护者"] = "Reef Guardian",
    ["泰德伯恩·塔勒里亚"] = "Tideborn Taleria",
    ["主教亚塞拉"] = "Exarchanic Yaseyla",
    ["折磨者安苏尔"] = "Ansuul the Tormentor",
}

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(trialThresholds) do
    BHB.thresholds[k] = v
end

for k, v in pairs(trialAliases) do
    BHB.aliases[k] = v
end
