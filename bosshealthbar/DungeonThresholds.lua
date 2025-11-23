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
local dungeonThresholds = {
-- Spindleclutch I
-- Spindleclutch II
-- The Banished Cells I
-- The Banished Cells II
-- Fungal Grotto I
-- Fungal Grotto II
-- Wayrest Sewers I
-- Wayrest Sewers II
-- Elden Hollow I
-- Elden Hollow II
-- Darkshade Caverns I
-- Darkshade Caverns II
-- Crypt of Hearts I
-- Crypt of Hearts II
-- City of Ash I
-- City of Ash II (Inner Grove)
-- Arx Corinium

-- Volenfell
    [GetBossName(CRUTCH_BHB_QUINTUS_VERRES)] = {
        -- Normal: Quintus Verres (boss1) value: 1204050 max: 1204050 effectiveMax: 1204050
        [60] = "Fires start",
        [20] = "Gargoyle",
        -- Normal: Monstrous Gargoyle (boss1) value: 1262989 max: 1262989 effectiveMax: 1262989
        -- The gargoyle permanently flattens Quintus, replacing him as the boss. Doesn't appear to have anything special
    },

-- Tempest Island
-- Direfrost Keep

-- Blackheart Haven
    [GetBossName(CRUTCH_BHB_ATARUS)] = {
        -- On normal, has 884093 health. Heals for 294697 (33%)
        [30] = "Monstrous Growth", -- id 29217
    },

-- Selene's Web
-- Blessed Crucible
-- Vaults of Madness

-- Imperial City Prison (Bastion)
    [GetBossName(CRUTCH_BHB_OVERFIEND)] = {
        [50] = "Harvester", -- TODO
    },
    [GetBossName(CRUTCH_BHB_IBOMEZ_THE_FLESH_SCULPTOR)] = {
        [75] = "Prisoners", -- TODO
        [50] = "Prisoners", -- TODO
        [25] = "Prisoners", -- TODO
    },
    [GetBossName(CRUTCH_BHB_LORD_WARDEN_DUSK)] = {
        [65] = "Shades", -- TODO
        [35] = "Shades", -- TODO
    },

-- White-Gold Tower (Green Emperor Way)
    [GetBossName(CRUTCH_BHB_MOLAG_KENA)] = {
        [60] = "Shield",
        [30] = "Shield",
    }, 

-- Ruins of Mazzatun
    [GetBossName(CRUTCH_BHB_TREEMINDER_NAKESH)] = { -- TODO: 50 or 40?
        [70] = "Chudan", -- TODO
        [50] = "Xal Nur", -- TODO
        [30] = "Execute", -- TODO
    },

-- Cradle of Shadows
    [GetBossName(CRUTCH_BHB_SITHERA)] = {
        [50] = "Brazier", -- TODO
        [30] = "Brazier", -- TODO
    },
    [GetBossName(CRUTCH_BHB_VELIDRETH)] = {
        [66] = "Banish", -- TODO, some say 65
        [33] = "Banish", -- TODO, some say 30, 31
    },

-- Bloodroot Forge
    [GetBossName(CRUTCH_BHB_CAILLAOIFE)] = {
        [75] = "Grove", -- TODO
        [50] = "Grove", -- TODO
        [30] = "Grove", -- TODO
    },
    [GetBossName(CRUTCH_BHB_STONEHEART)] = {
        [20] = "Execute!", -- TODO
    },
    [GetBossName(CRUTCH_BHB_EARTHGORE_AMALGAM)] = {
        [80] = "Split", -- TODO
        -- [40] = "Split", -- TODO -- one guide says it's at 50% overall hp?
    },

-- Falkreath Hold
    [GetBossName(CRUTCH_BHB_DOMIHAUS_THE_BLOODYHORNED)] = {
        [80] = "Adds", -- TODO
        [70] = "Grovel", -- TODO
        [60] = "Adds", -- TODO
        [50] = "Grovel", -- TODO
        [40] = "Adds", -- TODO
        [30] = "Grovel", -- TODO
        [20] = "Adds", -- TODO
        [10] = "Grovel", -- TODO
        [ 5] = "Grovel", -- TODO
    },

-- Fang Lair
    -- Lizabet Charnis has 4 hp bars! They're just dummy hp bars to indicate each wave of enemies. All same amount of hp, and her clone dies when the wave is done
    -- normal: Lizabet Charnis (boss1) value: 186642 max: 186642 effectiveMax: 186642
    -- Menagerie doesn't seem hp based, maybe the shield is but idk
    -- normal: Cadaverous Bear (boss1) value: 1683986 max: 1683986 effectiveMax: 1683986
    -- Caluurion relics are on some timer. On normal, they never all activate at the same time? So no execute marker
    -- normal: Caluurion (boss1) value: 2946975 max: 2946975 effectiveMax: 2946975
    -- Ulfnor (boss1) value: 1473488 max: 1473488 effectiveMax: 1473488
    -- Thurvokun turns into Orryn the Black, but the hp bar still works fine
    -- normal: Thurvokun (boss1) value: 1683986 max: 1683986 effectiveMax: 1683986
    [GetBossName(CRUTCH_BHB_THURVOKUN)] = {
        normHealth = 1683986,
        vetHealth = 3594564, -- TODO, got from log
        hmHealth = 5427792, -- TODO, got from log
        ["Normal"] = {
            [85] = "Crystal", -- TODO
            [75] = "Crystal", -- TODO
            [65] = "Crystal", -- TODO
            [55] = "Crystal", -- TODO
        },
        ["Veteran"] = {
            [85] = "Crystal", -- TODO
            [75] = "Crystal", -- TODO
            [65] = "Crystal", -- TODO
            [55] = "Crystal", -- TODO
        },
        ["Hardmode"] = {
            [85] = "Crystal", -- TODO
            [75] = "Crystal", -- TODO
            [65] = "Crystal", -- TODO
            [55] = "Crystal", -- TODO
            [40] = "Colossus", -- TODO
            [30] = "Colossus", -- TODO
            [20] = "Colossus", -- TODO
            [10] = "Colossus", -- TODO
        },
    },

-- Scalecaller Peak
    [GetBossName(CRUTCH_BHB_DOYLEMISH_IRONHEART)] = {
        [80] = "Stone Orb", -- TODO
        [60] = "Stone Orb", -- TODO
        [40] = "Stone Orb", -- TODO
        [20] = "Stone Orb", -- TODO
    },
    [GetBossName(CRUTCH_BHB_MATRIARCH_ALDIS)] = {
        [90] = "Leiminid",
        [80] = "Leiminid",
        [70] = "Leiminid",
        [60] = "Leiminid",
        [50] = "Leiminid",
        [40] = "Leiminid",
        [30] = "Leiminid",
        [20] = "Leiminid",
        [10] = "Leiminid",
    },
    [GetBossName(CRUTCH_BHB_ZAAN_THE_SCALECALLER)] = {
        [80] = "Winter's Purge",
        [60] = "Winter's Purge",
        [40] = "Winter's Purge",
        [20] = "Winter's Purge",
    },

-- Moon Hunter Keep
    [GetBossName(CRUTCH_BHB_JAILER_MELITUS)] = {
        [80] = "Werewolves", -- TODO
        [50] = "Werewolves", -- TODO
        [30] = "Werewolves", -- TODO
    },
    [GetBossName(CRUTCH_BHB_MYLENNE_MOONCALLER)] = {
        [80] = "Warden", -- TODO
        [60] = "Warden", -- TODO
        [40] = "Warden", -- TODO
        [20] = "Warden", -- TODO
    },
    [GetBossName(CRUTCH_BHB_HEDGE_MAZE_GUARDIAN)] = {
        [75] = "2 Spriggans", -- TODO
        [55] = "3 Spriggans", -- TODO
        [35] = "5 Spriggans", -- TODO
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
        [80] = "Hunt", -- TODO
        [60] = "Hunt", -- TODO
        [40] = "Hunt", -- TODO
        [20] = "Hunt", -- TODO
    },

-- Frostvault
    [GetBossName(CRUTCH_BHB_ICESTALKER)] = {
        [90] = "Scuttlers",
        [80] = "Wraiths",
        [70] = "Scuttlers",
        [60] = "Wraiths",
        [50] = "Scuttlers",
        [40] = "Wraiths",
        [30] = "Wraiths",
    },
    [GetBossName(CRUTCH_BHB_WARLORD_TZOGVIN)] = {
        [70] = "Heat Field",
        [35] = "Whirlwinds",
    },
    [GetBossName(CRUTCH_BHB_VAULT_PROTECTOR)] = {
        [80] = "2 Lasers",
        [60] = "3 Lasers",
        [40] = "4 Lasers",
        [20] = "4 Lasers",
    },
    [GetBossName(CRUTCH_BHB_THE_STONEKEEPER)] = {
        [55] = "Skeevatons",
    },

-- Depths of Malatar
    [GetBossName(CRUTCH_BHB_THE_SCAVENGING_MAW)] = {
        [80] = "Disappear", -- TODO guides 80 or 75
        [50] = "Disappear", -- TODO
        [25] = "Disappear", -- TODO
    },
    [GetBossName(CRUTCH_BHB_THE_WEEPING_WOMAN)] = {
        [75] = "Watcher", -- TODO
        [55] = "Watcher", -- TODO
        [35] = "Watcher", -- TODO
    },
    [GetBossName(CRUTCH_BHB_SYMPHONY_OF_BLADES)] = {
        [10] = "Teleport", -- TODO
    },

-- Moongrave Fane
    [GetBossName(CRUTCH_BHB_RISEN_RUINS)] = {
        [90] = "Boulder Storm",
        [70] = "Boulder Storm",
        [50] = "Boulder Storm",
        [30] = "Boulder Storm",
    },
    [GetBossName(CRUTCH_BHB_DROZAKAR)] = {
        [90] = "Shield",
        [60] = "Shield",
        [30] = "Shield",
    },
    [GetBossName(CRUTCH_BHB_KUJO_KETHBA)] = {
        [90] = "Geysers",
        [70] = "Geysers",
        [50] = "Geysers",
        [30] = "Geysers",
    },
    [GetBossName(CRUTCH_BHB_GRUNDWULF)] = {
        [70] = "Dire-Maw",
        [50] = "Dire-Maw",
        [30] = "Dire-Maw",
        [20] = "Dire-Maw",
        [10] = "Dire-Maw",
    },

-- Lair of Maarselok
    -- Normal: Selene's Claws (boss1) value: 926192 max: 926192 effectiveMax: 926192
    -- Normal: Selene's Fangs (boss1) value: 841993 max: 841993 effectiveMax: 841993
    -- Normal: Maarselok (boss1) value: 7409538 max: 7409538 effectiveMax: 7409538
    -- ?? There's some kind of timer for how long the boss is damageable, but it also
    -- cuts short when some % is passed. Not sure of the % though, 40% could be one of them
    -- ["Azureblight Cancroid"] = {
    -- },
    -- Maarselok (boss1) value: 5186676 max: 7409538 effectiveMax: 7409538
    -- Maarselok on his perches lets you dps until 60, 55, 50. It's not particularly interesting though.
    [GetBossName(CRUTCH_BHB_MAARSELOK)] = {
        [60] = "Perch",
        [55] = "Perch",
        [50] = "Flee",
    },


-- Icereach
    [GetBossName(CRUTCH_BHB_STORMBORN_REVENANT)] = {
        [55] = "Atronachs", -- TODO from alcast guide, seems sus
        [40] = "Atronachs", -- TODO from alcast guide, seems sus
    },

-- Unhallowed Grave
    [GetBossName(CRUTCH_BHB_HAKGRYM_THE_HOWLER)] = {
        -- Alcast says 60/30, xynode says 70/20, arzyel says 70/30
        -- self tested is 71/31... (testing done before floor rounding)
        [70] = "Abomination",
        [30] = "Abomination", -- TODO
        -- On normal, has 2273381 health. Heals for ~1126690 (130728 -> 1267418; 49.5%?) / ~1136690 (130486 -> 1267176; 50%)
        [5] = "Werewolf Form", -- TODO
    },
    [GetBossName(CRUTCH_BHB_KEEPER_OF_THE_KILN)] = {
        [90] = "Runes", -- TODO
        [60] = "Runes", -- TODO
        [30] = "Runes", -- TODO
    },
    [GetBossName(CRUTCH_BHB_ETERNAL_AEGIS)] = {
        [90] = "Adds", -- TODO
        [70] = "Adds", -- TODO
        [50] = "Adds", -- TODO
        [30] = "Adds", -- TODO
    },
    [GetBossName(CRUTCH_BHB_ONDAGORE_THE_MAD)] = {
        [80] = "Poison", -- TODO
        [60] = "Pillars", -- TODO
        [40] = "Poison", -- TODO
        [20] = "Pillars", -- TODO
    },
    [GetBossName(CRUTCH_BHB_KJALNAR_TOMBSKALD)] = {
        [50] = "Summon", -- TODO
    },
    [GetBossName(CRUTCH_BHB_VORIA_THE_HEARTTHIEF)] = {
        [75] = "Teleport", -- TODO
        [40] = "Teleport", -- TODO
    },

-- Stone Garden
    [GetBossName(CRUTCH_BHB_ARKASIS_THE_MAD_ALCHEMIST)] = {
        [90] = "Add", -- TODO
        [80] = "Add", -- TODO
        [70] = "Add", -- TODO
        [60] = "Behemoth Phase", -- TODO
        [50] = "Add", -- TODO
        [40] = "Add", -- TODO
        [30] = "Add", -- TODO
        [20] = "Behemoth Phase", -- TODO
        -- [30] = "Add", -- TODO he heals to 40% so this overlaps
        -- [20] = "Add", -- TODO he heals to 40% so this overlaps
        [10] = "Add", -- TODO
    },

-- Castle Thorn
    [GetBossName(CRUTCH_BHB_LADY_THORN)] = {
        [60] = "Batdance",
        [20] = "Batdance",
    },

-- Black Drake Villa
    -- ["Kinras Ironeye"] = {
        -- TODO: guides have differing %s for ranged phase
        -- aren't the salamanders on % though? maybe?
    -- },
    [GetBossName(CRUTCH_BHB_CAPTAIN_GEMINUS)] = {
        [70] = "Invulnerable", -- TODO
        [30] = "Invulnerable", -- TODO
    },
    [GetBossName(CRUTCH_BHB_PYROTURGE_ENCRATIS)] = {
        [65] = "Run", -- TODO
    },
    [GetBossName(CRUTCH_BHB_SENTINEL_AKSALAZ)] = {
        [85] = "Indrik", -- TODO
        [60] = "Nereid", -- TODO
        [35] = "Atronach", -- TODO
        [25] = "Execute", -- TODO
    },

-- The Cauldron
    [GetBossName(CRUTCH_BHB_TASKMASTER_VICCIA)] = {
        [75] = "Adds", -- TODO
        [50] = "Adds", -- TODO
        [25] = "Adds", -- TODO
    },
    -- ["Baron Zaudrus"] = {
    --     -- TODO: % for more flame walls?
    -- },

-- Red Petal Bastion
    [GetBossName(CRUTCH_BHB_ELIAM_MERICK)] = {
        [85] = "Liramindrel", -- prob ok
        [60] = "Ihudir", -- prob ok
        [30] = "Both", -- prob ok
    },

-- The Dread Cellar
    [GetBossName(CRUTCH_BHB_SCORION_BROODLORD)] = {
        [80] = "Adds", -- TODO
        [60] = "Adds", -- TODO
        [40] = "Adds", -- TODO
        [20] = "Adds", -- TODO
    },
    [GetBossName(CRUTCH_BHB_MAGMA_INCARNATE)] = {
        [65] = "Portal", -- TODO
        [35] = "Portal", -- TODO
    },

-- Coral Aerie
    [GetBossName(CRUTCH_BHB_MALIGALIG)] = {
        [70] = "Whirlpool",
        [40] = "Whirlpool",
    },
    [GetBossName(CRUTCH_BHB_SARYDIL)] = {
        [75] = "Trash", -- Could be 77% instead? kinda weird
        [35] = "Trash",
    },
    [GetBossName(CRUTCH_BHB_VARALLION)] = {
        normHealth = 4209965,
        vetHealth = 6766879,
        hmHealth = 13195414,
        ["Normal"] = {
            [95] = "Gryphon",
            [55] = "Gryphon", -- TODO
        },
        ["Veteran"] = {
            [95] = "Gryphon", -- TODO
            [80] = "Gryphon", -- TODO
            [55] = "Gryphon", -- TODO
        },
        ["Hardmode"] = {
            [95] = "Gryphon",
            [80] = "Gryphon",
            [55] = "Gryphon",
            [30] = "Kargaeda",
        },
    },
    [GetBossName(CRUTCH_BHB_ZBAZA)] = {
        [60] = "Conduit Tendril",
        [30] = "Conduit Tendril",
    },

-- Shipwright's Regret
    [GetBossName(CRUTCH_BHB_FOREMAN_BRADIGGAN)] = {
        [60] = "Abomination",
        [30] = "Abomination",
    },
    [GetBossName(CRUTCH_BHB_CAPTAIN_NUMIRRIL)] = {
        [85] = "Abomination",
        [40] = "Abomination",
    },

-- Earthen Root Enclave
    [GetBossName(CRUTCH_BHB_CORRUPTION_OF_STONE)] = {
        -- Health isn't necessary because the stages are the same, this is just for testing
        normHealth = 3367972,
        vetHealth = 5413503,
        hmHealth = 8120255,
        [80] = "Rock Shower",
        [60] = "Rock Shower",
        [30] = "Rock Shower",
    },
    [GetBossName(CRUTCH_BHB_CORRUPTION_OF_ROOT)] = {
        [75] = "Clones", -- Unsure, could be 80?
        [40] = "Clones", -- Unsure, but probably correct
    },
    [GetBossName(CRUTCH_BHB_ARCHDRUID_DEVYRIC)] = {
        [65] = "Bear Form",
        [45] = "Human Form",
        [20] = "Bear Form",
    },

-- Graven Deep
    [GetBossName(CRUTCH_BHB_ZELVRAAK_THE_UNBREATHING)] = {
        [75] = "Clones",
        [50] = "Afterlife",
        [25] = "Clones",
    },

-- Bal Sunnar
    -- %s from alcast guide aren't quite right: 65, 45, 20
    -- normal: Kovan Giryon (boss1) value: 2946975 max: 2946975 effectiveMax: 2946975
    [GetBossName(CRUTCH_BHB_KOVAN_GIRYON)] = {
        [70] = "Nix-Ox", -- TODO
        [45] = "Iron Atronach", -- TODO
        [20] = "Execute", -- TODO
    },
    [GetBossName(CRUTCH_BHB_ROKSA_THE_WARPED)] = {
        [70] = "Devour Light",
        [40] = "Devour Light",
    },
    -- %s from 3 guides aren't quite right? they say 70, 35
    [GetBossName(CRUTCH_BHB_MATRIARCH_LLADI_TELVANNI)] = {
        [75] = "Poison Storm",
        [45] = "Poison Storm",
    },

-- Scrivener's Hall
    -- some guides are off, alcast says 80
    [GetBossName(CRUTCH_BHB_RIFTMASTER_NAQRI)] = {
        [85] = "Book", -- TODO
        [55] = "Book", -- TODO
        [35] = "Book", -- TODO
    },
    [GetBossName(CRUTCH_BHB_OZEZAN_THE_INFERNO)] = {
        normHealth = 4546762,
        vetHealth = 7308229,
        hmHealth = 13154812,
        ["Normal"] = {
            [75] = "",
            [50] = "",
            [25] = "",
        },
        ["Veteran"] = {
            [75] = "",
            [50] = "",
            [25] = "",
        },
        ["Hardmode"] = {
            -- Guides say 40/35 and 20, but I think they're on a "timer" after 40 or 36, namely every time Ozezan tunnels to an edge (NOT the middle), but only if another atro isn't already up
            -- It seems like the atro can also happen during the beam cast...
            -- Side tunnels may be every 40s? Had 43s between two
            -- It may also be 75% for the first burrowing to the middle succ. Most fights only have 2 Charge Boss, but one has 3?
            [40] = "Atronachs start", -- TODO: 36?
        },
    },
    [GetBossName(CRUTCH_BHB_VALINNA)] = {
        -- TODO: after the 2nd room, Lamikhai's death removes her unit, so only Valinna is left, triggering
        -- a bosses changed event. It resets the threshold highlighting because the stages are redrawn
        [50] = "Lamikhai leaves",
        [55] = "Valinna leaves",
    },

-- Oathsworn Pit
    [GetBossName(CRUTCH_BHB_ANTHELMIRS_CONSTRUCT)] = {
        [70] = "b o n k",
    },
    [GetBossName(CRUTCH_BHB_ARADROS_THE_AWAKENED)] = {
        [50] = "Furnace",
    },

-- Bedlam Veil
    [GetBossName(CRUTCH_BHB_SHATTERED_CHAMPION)] = {
        [70] = "Shard Bash",
        [50] = "Shard Bash",
    },

    [GetBossName(CRUTCH_BHB_DARKSHARD)] = {
        [80] = "Maxus",
        [60] = "Atrocity",
        [40] = "Argonian",
    },

    [GetBossName(CRUTCH_BHB_THE_BLIND)] = {
        [80] = "Blind Shards",
        [60] = "Glass Remnants",
        [40] = "Glass Remnants",
        [20] = "Gleaming Deluge",
    },

-- Exiled Redoubt -- TODO: jp, pl
    [GetBossName(CRUTCH_BHB_JERENSI)] = {
        [80] = "Condemn + Adds",
        [50] = "Condemn + Adds",
        [30] = "Condemn + Execute on timer", -- prob a 15 or 14s timer
    },
    [GetBossName(CRUTCH_BHB_VANDORALLEN)] = {
        normHealth = 3169856,
        vetHealth = 7200895,
        hmHealth = 12601566,
        ["Normal"] = {
            [90] = "Spiders", -- Actual Ability name is "Iron Charge (ID: 224446)"
            [70] = "Spiders",
            [50] = "Spiders",
            [30] = "Spiders",
        },
        ["Veteran"] = {
            [90] = "Spiders",
            [70] = "Spiders",
            [50] = "Spiders", -- TODO: does vet have simulacra?
            [30] = "Spiders",
        },
        ["Hardmode"] = {
            [90] = "Spiders", -- Actual Ability name is "Iron Charge (ID: 224446)"
            [70] = "Spiders",
            [50] = "Spiders + Simulacra on timer", -- I think simulacrums are only on hm. HM Health = 12601566
            [30] = "Spiders",
        },
    },
    [GetBossName(CRUTCH_BHB_SQUALL_OF_RETRIBUTION)] = { -- Boss gains one of 3 buffs depending on what type it currently is
        normHealth = 3367972,
        vetHealth = 10263990,
        hmHealth = 15395986,
        ["Normal"] = {
            [95] = "Fire Atro", -- Buff: Fire Only (ID: 224495)
            [86] = "Fire Atro", -- 86.6?
            [78] = "Fire Atro", -- 78.9?
            [70] = "Fire Atro", -- 70.6?
            [63] = "Ice Atro", -- Buff: Color Swap Fire Frost (ID: 224497) - M0R: I believe this is actually like 63.3 (2/3 of 95), but I am not fully sure | Kyz: procced at ~63.9?
            [47] = "Ice Atro", -- 47.1? could be earlier
            [31] = "Storm Atro", -- Buff: Color Swap (ID: 224493) - M0R: I believe this is actually 31.6 (1/3 of 95), but am not fully sure | Kyz: procced at ~31.9?
            [23] = "Storm Atro", -- 22.7 or above?
        },
        ["Veteran"] = {
            [95] = "Fire Atro", -- Buff: Fire Only (ID: 224495)
            [86] = "Fire Atro", -- 86.6?
            [78] = "Fire Atro", -- 78.9?
            [70] = "Fire Atro", -- 70.6?
            [63] = "Ice Atro", -- Buff: Color Swap Fire Frost (ID: 224497) - M0R: I believe this is actually like 63.3 (2/3 of 95), but I am not fully sure | Kyz: procced at ~63.9?
            [47] = "Ice Atro", -- 47.1? could be earlier
            [31] = "Storm Atro", -- Buff: Color Swap (ID: 224493) - M0R: I believe this is actually 31.6 (1/3 of 95), but am not fully sure | Kyz: procced at ~31.9?
            [23] = "Storm Atro", -- 22.7 or above?
        },
        ["Hardmode"] = {
            [95] = "Fire Atro", -- Buff: Fire Only (ID: 224495)
            [86] = "Fire Atro", -- 86.6?
            [78] = "Fire Atro", -- 78.9?
            [70] = "Fire Atro", -- 70.6?
            [63] = "Ice Atro", -- Buff: Color Swap Fire Frost (ID: 224497) - M0R: I believe this is actually like 63.3 (2/3 of 95), but I am not fully sure | Kyz: procced at ~63.9?
            [53] = "Ice Atro", -- 53.4? HM ONLY
            [47] = "Ice Atro x2", -- 47.3? could be earlier; second one HM only
            [31] = "Storm Atro", -- Buff: Color Swap (ID: 224493) - M0R: I believe this is actually 31.6 (1/3 of 95), but am not fully sure | Kyz: procced at ~31.9?
            [23] = "Storm Atro", -- 23.8 or above?
            [15] = "Storm Atro", -- 15.7 or above? HM only
            [ 7] = "Storm Atro", -- 7.3 or above? HM only
        },
    },

-- Lep Seculsa -- TODO: jp, pl
    [GetBossName(CRUTCH_BHB_GARVIN_THE_TRACKER)] = {
        normHealth = 3367972,
        vetHealth = 5954854, -- Still need to find
        hmHealth = 8932282,
        ["Hardmode"] = {
            [80] = "Hunt Duneripper", -- Might be 85, need to double check
            [50] = "Hunt Duneripper", -- Boss casts ability: Hunt (ID: 227863) to spawn dunerippers
            [40] = "Hunt Duneripper",

            [95] = "Storm Mage", -- Boss casts ability: Summon Storm Mage (ID: 226220)
            [85] = "Flame Archer", -- Boss casts ability: Flame Archer (ID: 227480)
            [75] = "Infuser", -- Boss casts ability: Summon Infuser (ID: 227481)

            [65] = "Storm Mage",
            [55] = "Flame Archer",
            [45] = "Infuser",

            [35] = "Storm Mage",
            [30] = "Flame Archer",
            [25] = "Infuser",
        },
        ["Normal"] = { -- Verified
            [75] = "Storm Mage",
            [50] = "Duneripper + Archer",
            [25] = "Infuser",
        },
        ["Veteran"] = {
            [95] = "Storm Mage",
            [80] = "Flame Archer",
            [70] = "Hunt Duneripper",
            [60] = "Infuser", -- Not sure about this percent, might be 65

            [50] = "Storm Mage",
            [40] = "Hunt Duneripper",
            [35] = "Flame Archer",
            [20] = "Infuser", -- Not sure about this percent
        },
    },
    [GetBossName(CRUTCH_BHB_SIEGE_MASTER_MALTHORAS)] = {
        [50] = "Adds",
    },
    [GetBossName(CRUTCH_BHB_NORIWEN)] = {
        [70] = "Middle",
        [50] = "Gryphons",
        [40] = "Gryphons",
        [20] = "Middle",
    },
    [GetBossName(CRUTCH_BHB_ORPHEON_THE_TACTICIAN)] = {
        [85] = "Alcunar",
        [60] = "Alcunar",
        [40] = "Alcunar",
        [20] = "Alcunar",
    },

-- Black Gem Foundry
    [GetBossName(CRUTCH_BHB_PROSPECTOR_LYRAKTA)] = {
        [75] = "Adds",
        [50] = "Adds",
        [25] = "Adds",
    },
    [GetBossName(CRUTCH_BHB_QUARRYMASTER_SALDEZAAR)] = {
        normHealth = 4209965,
        hmHealth = 13533758,
        ["Normal"] = {
            [60] = "Rupture",
            [20] = "Rupture",
        },
        -- TODO: don't know vet
        ["Hardmode"] = {
            [65] = "Rupture",
            [30] = "Rupture",
        },
    },
    [GetBossName(CRUTCH_BHB_GEMCARVER_HYNAX)] = {
        [75] = "Teleport",
        [50] = "Teleport",
        [25] = "Teleport",
    },
    -- Not sure about all these, they seem really inconsistent. Not sure if bug or intentional
    -- ["Black Gem Monstrosity"] = {
    --     [80] = "Fire", -- 83??
    --     [50] = "Fire", -- 53?
    --     [35] = "Fire", -- 33?
    -- },
    [GetBossName(CRUTCH_BHB_MISURA_ASSISTANT_TO_THE_HIGH_SOULBINDER)] = {
        [75] = "Adds",
        [50] = "Adds",
        [25] = "Adds",
    },
    [GetBossName(CRUTCH_BHB_HIGH_SOULBINDER_VYKAND)] = {
        normHealth = 6314947,
        vetHealth = 12829988,
        hmHealth = 25659976,
        ["Normal"] = {
            [75] = "",
            [50] = "",
            [25] = "",
        },
        ["Veteran"] = {
            [75] = "",
            [50] = "",
            [25] = "",
        },
        ["Hardmode"] = {
            [60] = "Annihilation",
        },
    },

-- Naj-Caldeesh
    [GetBossName(CRUTCH_BHB_VOSKRONA_STONEHULK_POXITO)] = {
        [90] = "Adds",
        [80] = "Adds",
        [70] = "Totem",
        [60] = "Adds",
        [50] = "Totem",
        [40] = "Adds",
        [30] = "Totem",
    },
    [GetBossName(CRUTCH_BHB_TALENLAH)] = {
        [70] = "Bar-Sakka",
        [55] = "Talen-Lah",
        [30] = "Bar-Sakka",
        [5] = "Together", -- TODO
    },
}

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(dungeonThresholds) do
    BHB.thresholds[k] = v
end
