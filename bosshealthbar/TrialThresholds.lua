CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.BossHealthBar = CrutchAlerts.BossHealthBar or {}
local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

BHB.thresholds = BHB.thresholds or {}
BHB.aliases = BHB.aliases or {}
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
        [15] = "Arcane Vortex",
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
        [86] = "Terminals",
        [66] = "Terminals",
        [46] = "Terminals",
        [26] = "Execute",
    },

-- Asylum Sanctorium
    [GetBossName(CRUTCH_BHB_SAINT_OLMS_THE_JUST)] = {
        [91] = "Big Jump",
        [76] = "Big Jump",
        [51] = "Big Jump",
        [26] = "Big Jump",
    },

-- Cloudrest
    [GetBossName(CRUTCH_BHB_SHADE_OF_SIRORIA)] = {
        [60] = "Siroria starts jumping",
    },
    -- I'd add the mini spawns for Z'Maja, but I haven't found a way to detect difficulty easily.
    -- +0, +1, +2, +3 all have the same HP for Z'Maja. Maybe there's a missing buff somewhere?
    -- Otherwise, I'd have to change the mechanic stages once mechs like flare, barswap, frost
    -- start showing up, which would be... a lotta work

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
        [25] = "Mini",
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

-- German aliases from Keldorem
    -- ["Ra Kotu"] = Same in german
    ["Krieger"] = "The Warrior",
    ["Magierin"] = "The Mage",
    ["Zhaj'hassa der Vergessene"] = "Zhaj'hassa the Forgotten",
    -- ["Rakkhat"] = Same in german
    ["Abfänger Negatrix"] = "Hunter-Killer Negatrix",
    ["Perfektioniertes Faktotum"] = "Pinnacle Factotum",
    ["Reaktor"] = "Reactor",
    ["Montagegeneral"] = "Assembly General",
    ["Heiliger Olms der Gerechte"] = "Saint Olms the Just",
    ["Schatten von Siroria"] = "Shade of Siroria",
    -- ["Lokkestiiz"] = Same in german
    -- ["Yolnahkriin"] = Same in german
    -- ["Nahviintaas"] = Same in german
    ["Yandir der Ausweider"] = "Yandir the Butcher",
    ["Kapitän Vrol"] = "Captain Vrol",
    ["Fürst Falgravn"] = "Lord Falgravn",
    -- ["Oaxiltso"] = Same in german
    ["Flammenheroldin Bahsei"] = "Flame-Herald Bahsei",
    -- ["Xalvakka"] = Same in german
    -- ["Lylanar"] = Same in german
    ["Riffwächter"] = "Reef Guardian",
    ["Gezeitengeborene Taleria"] = "Tideborn Taleria",
    ["Exarchanikerin Yaseyla"] = "Exarchanic Yaseyla",
    ["Ansuul die Quälende"] = "Ansuul the Tormentor",

-- Japanese aliases from nikepiko
    ["ラ・コツ"] = "Ra Kotu",
    ["戦士"] = "The Warrior",
    ["魔術師"] = "The Mage",
    ["忘れ去られたザジュハッサ"] = "Zhaj'hassa the Forgotten",
    ["ラカート"] = "Rakkhat",
    ["ハンターキラー・ネガトリクス"] = "Hunter-Killer Negatrix",
    ["ピナクル・ファクトタム"] = "Pinnacle Factotum",
    ["リアクター"] = "Reactor",
    ["アセンブリ・ジェネラル"] = "Assembly General",
    ["公正なる聖オルムス"] = "Saint Olms the Just",
    ["シロリアの影"] = "Shade of Siroria",
    ["ロクケスティーズ"] = "Lokkestiiz",
    ["ヨルナークリン"] = "Yolnahkriin",
    ["ナーヴィンタース"] = "Nahviintaas",
    ["肉削ぎヤンディル"] = "Yandir the Butcher",
    ["ヴロル隊長"] = "Captain Vrol",
    ["ファルグラヴン卿"] = "Lord Falgravn",
    ["オアジルツォ"] = "Oaxiltso",
    ["炎の使者バーセイ"] = "Flame-Herald Bahsei",
    ["ザルヴァッカ"] = "Xalvakka",
    ["リラナー"] = "Lylanar",
    ["サンゴのガーディアン"] = "Reef Guardian",
    ["タイドボーン・タレリア"] = "Tideborn Taleria",
    ["エグザーカニック・ヤセイラ"] = "Exarchanic Yaseyla",
    ["拷問者アンスール"] = "Ansuul the Tormentor",
}

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(trialThresholds) do
    BHB.thresholds[k] = v
end

for k, v in pairs(trialAliases) do
    BHB.aliases[k] = v
end
