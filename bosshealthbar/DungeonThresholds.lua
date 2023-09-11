CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.BossHealthBar = CrutchAlerts.BossHealthBar or {}
local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

BHB.thresholds = BHB.thresholds or {}
BHB.aliases = BHB.aliases or {}

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
    ["Quintus Verres"] = {
        -- Normal: Quintus Verres (boss1) value: 1204050 max: 1204050 effectiveMax: 1204050
        [60] = "Fires start",
        [20] = "Gargoyle",
        -- Normal: Monstrous Gargoyle (boss1) value: 1262989 max: 1262989 effectiveMax: 1262989
        -- The gargoyle permanently flattens Quintus, replacing him as the boss. Doesn't appear to have anything special
    },

-- Tempest Island
-- Direfrost Keep

-- Blackheart Haven
    ["Atarus"] = {
        -- On normal, has 884093 health. Heals for 294697 (33%)
        [30] = "Monstrous Growth", -- id 29217
    },

-- Selene's Web
-- Blessed Crucible
-- Vaults of Madness

-- Imperial City Prison (Bastion)
    ["Overfiend"] = {
        [50] = "Harvester", -- TODO
    },
    ["Ibomez the Flesh Sculptor"] = {
        [75] = "Prisoners", -- TODO
        [50] = "Prisoners", -- TODO
        [25] = "Prisoners", -- TODO
    },
    ["Lord Warden Dusk"] = {
        [65] = "Shades", -- TODO
        [35] = "Shades", -- TODO
    },

-- White-Gold Tower (Green Emperor Way)
    ["Molag Kena"] = {
        [60] = "Shield", -- TODO
        [30] = "Shield", -- TODO
    }, 

-- Ruins of Mazzatun
    ["Tree-Minder Na-Kesh"] = { -- TODO: 50 or 40?
        [70] = "Chudan", -- TODO
        [50] = "Xal Nur", -- TODO
        [30] = "Execute", -- TODO
    },

-- Cradle of Shadows
    ["Sithera"] = {
        [50] = "Brazier", -- TODO
        [30] = "Brazier", -- TODO
    },
    ["Velidreth"] = {
        [66] = "Banish", -- TODO, some say 65
        [33] = "Banish", -- TODO, some say 30, 31
    },

-- Bloodroot Forge
    ["Caillaoife"] = {
        [75] = "Grove", -- TODO
        [50] = "Grove", -- TODO
        [30] = "Grove", -- TODO
    },
    ["Stoneheart"] = {
        [20] = "Execute!", -- TODO
    },
    ["Earthgore Amalgam"] = {
        [80] = "Split", -- TODO
        -- [40] = "Split", -- TODO -- one guide says it's at 50% overall hp?
    },

-- Falkreath Hold
    ["Domihaus the Bloody-Horned"] = {
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
    ["Thurvokun"] = {
        normHealth = 1683986,
        vetHealth = 3594564, -- TODO, got from log
        hmHealth = 5427792, -- TODO, got from log
        ["Normal"] = {
            [86] = "Crystal",
            [76] = "Crystal",
            [66] = "Crystal",
            [56] = "Crystal",
        },
        ["Veteran"] = {
            [86] = "Crystal",
            [76] = "Crystal",
            [66] = "Crystal",
            [56] = "Crystal",
        },
        ["Hardmode"] = {
            [86] = "Crystal",
            [76] = "Crystal",
            [66] = "Crystal",
            [56] = "Crystal",
            [40] = "Colossus", -- TODO
            [30] = "Colossus", -- TODO
            [20] = "Colossus", -- TODO
            [10] = "Colossus", -- TODO
        },
    },

-- Scalecaller Peak
    ["Doylemish Ironheart"] = {
        [80] = "Stone Orb", -- TODO
        [60] = "Stone Orb", -- TODO
        [40] = "Stone Orb", -- TODO
        [20] = "Stone Orb", -- TODO
    },
    ["Matriarch Aldis"] = {
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
    ["Zaan the Scalecaller"] = {
        [80] = "Winter's Purge",
        [60] = "Winter's Purge",
        [40] = "Winter's Purge",
        [20] = "Winter's Purge",
    },

-- Moon Hunter Keep
    ["Jailer Melitus"] = {
        [80] = "Werewolves", -- TODO
        [50] = "Werewolves", -- TODO
        [30] = "Werewolves", -- TODO
    },
    ["Mylenne Moon-Caller"] = {
        [80] = "Warden", -- TODO
        [60] = "Warden", -- TODO
        [40] = "Warden", -- TODO
        [20] = "Warden", -- TODO
    },
    ["Hedge Maze Guardian"] = {
        [75] = "2 Spriggans", -- TODO
        [55] = "3 Spriggans", -- TODO
        [35] = "5 Spriggans", -- TODO
    },
    ["Archivist Ernarde"] = {
        -- how can the guides be so different??
        -- xynode: 76, 56, 36
        -- esoplanet: 80, 60, 40, 20
        [80] = "Adds", -- TODO
        [60] = "Adds", -- TODO
        [40] = "Adds", -- TODO
        [20] = "Adds", -- TODO
    },
    ["Vykosa the Ascendant"] = {
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
    ["Aghaedh of the Solstice"] = {
        [70] = "Lurcher", -- TODO
        [55] = "Lurcher", -- TODO
        [25] = "Lurcher", -- TODO
    },
    ["Tarcyr"] = {
        [80] = "Hunt", -- TODO
        [50] = "Hunt", -- TODO
        [20] = "Hunt", -- TODO
    },
    ["Balorgh"] = {
        [80] = "Hunt", -- TODO
        [60] = "Hunt", -- TODO
        [40] = "Hunt", -- TODO
        [20] = "Hunt", -- TODO
    },

-- Frostvault
    ["Icestalker"] = {
        -- :shrug: xynode says these, esoplanet says every 10%
        [90] = "Adds", -- TODO
        [50] = "Adds", -- TODO
        [30] = "Adds", -- TODO
    },
    ["Warlord Tzogvin"] = {
        [70] = "Heat Field", -- TODO
        [30] = "Whirlwinds", -- TODO
    },
    ["Vault Protector"] = {
        -- bunch of different %s from different guides again
        [90] = "Lasers", -- TODO
        [75] = "Lasers", -- TODO
        [50] = "Lasers", -- TODO
    },
    ["The Stonekeeper"] = {
        [55] = "Skeevatons", -- TODO different again, 56, 55, 50
        [25] = "Centurion", -- TODO
    },

-- Depths of Malatar
    ["The Scavenging Maw"] = {
        [80] = "Disappear", -- TODO guides 80 or 75
        [50] = "Disappear", -- TODO
        [25] = "Disappear", -- TODO
    },
    ["The Weeping Woman"] = {
        [75] = "Watcher", -- TODO
        [55] = "Watcher", -- TODO
        [35] = "Watcher", -- TODO
    },
    ["Symphony of Blades"] = {
        [10] = "Teleport", -- TODO
    },

-- Moongrave Fane
    ["Dro'zakar"] = {
        [90] = "Shield", -- TODO
        [60] = "Shield", -- TODO
        [30] = "Shield", -- TODO
    },
    ["Kujo Kethba"] = {
        [90] = "Geysers", -- TODO
        [70] = "Geysers", -- TODO
        [50] = "Geysers", -- TODO
        [30] = "Geysers", -- TODO
    },
    ["Grundwulf"] = {
        [70] = "Dire-Maw", -- TODO
        [50] = "Dire-Maw", -- TODO
        [30] = "Dire-Maw", -- TODO
        [20] = "Dire-Maw", -- TODO
        [10] = "Dire-Maw", -- TODO
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
    ["Maarselok"] = {
        [60] = "Perch",
        [55] = "Perch",
        [50] = "Flee",
    },


-- Icereach
    ["Stormborn Revenant"] = {
        [55] = "Atronachs", -- TODO from alcast guide, seems sus
        [40] = "Atronachs", -- TODO from alcast guide, seems sus
    },

-- Unhallowed Grave
    ["Hakgrym the Howler"] = {
        -- Alcast says 60/30, xynode says 70/20, arzyel says 70/30
        -- self tested is 71/31...
        [71] = "Abomination",
        [31] = "Abomination",
        -- On normal, has 2273381 health. Heals for ~1126690 (130728 -> 1267418; 49.5%?) / ~1136690 (130486 -> 1267176; 50%)
        [6] = "Werewolf Form",
    },
    ["Keeper of the Kiln"] = {
        [90] = "Runes", -- TODO
        [60] = "Runes", -- TODO
        [30] = "Runes", -- TODO
    },
    ["Eternal Aegis"] = {
        [90] = "Adds", -- TODO
        [70] = "Adds", -- TODO
        [50] = "Adds", -- TODO
        [30] = "Adds", -- TODO
    },
    ["Ondagore the Mad"] = {
        [80] = "Poison", -- TODO
        [60] = "Pillars", -- TODO
        [40] = "Poison", -- TODO
        [20] = "Pillars", -- TODO
    },
    ["Kjalnar Tombskald"] = {
        [50] = "Summon", -- TODO
    },
    ["Voria the Hearth-Thief"] = {
        [75] = "Teleport", -- TODO
        [40] = "Teleport", -- TODO
    },

-- Stone Garden
    ["Arkasis the Mad Alchemist"] = {
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
    ["Vaduroth"] = {
        [75] = "Scythe", -- TODO
        [50] = "Scythe", -- TODO
        [25] = "Scythe", -- TODO
    },
    ["Lady Thorn"] = {
        [60] = "Batdance", -- TODO
        [60] = "Batdance", -- TODO
    },

-- Black Drake Villa
    -- ["Kinras Ironeye"] = {
        -- TODO: guides have differing %s for ranged phase
        -- aren't the salamanders on % though? maybe?
    -- },
    ["Captain Geminus"] = {
        [70] = "Invulnerable", -- TODO
        [30] = "Invulnerable", -- TODO
    },
    ["Pyroturge Encratis"] = {
        [65] = "Run", -- TODO
    },
    ["Sentinel Aksalaz"] = {
        [85] = "Indrik", -- TODO
        [60] = "Nereid", -- TODO
        [35] = "Atronach", -- TODO
        [25] = "Execute", -- TODO
    },

-- The Cauldron
    ["Taskmaster Viccia"] = {
        [75] = "Adds", -- TODO
        [50] = "Adds", -- TODO
        [25] = "Adds", -- TODO
    },
    -- ["Baron Zaudrus"] = {
    --     -- TODO: % for more flame walls?
    -- },

-- Red Petal Bastion
    ["Eliam Merick"] = {
        [80] = "Liramindrel", -- TODO
        [50] = "Ihudir", -- TODO
        [30] = "Both", -- TODO
    },

-- The Dread Cellar
    ["Scorion Broodlord"] = {
        [80] = "Adds", -- TODO
        [60] = "Adds", -- TODO
        [40] = "Adds", -- TODO
        [20] = "Adds", -- TODO
    },
    ["Magma Incarnate"] = {
        [65] = "Portal", -- TODO
        [35] = "Portal", -- TODO
    },

-- Coral Aerie
    ["Maligalig"] = {
        [70] = "Whirlpool",
        [40] = "Whirlpool",
    },
    ["Sarydil"] = {
        [75] = "Trash", -- Could be 77% instead? kinda weird
        [35] = "Trash",
    },
    ["Varallion"] = {
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
            [95] = "Gryphon", -- TODO
            [80] = "Gryphon", -- TODO
            [55] = "Gryphon", -- TODO
            [30] = "Kargaeda", -- TODO
        },
    },
    ["Z'Baza"] = {
        [60] = "Conduit Tendril",
        [30] = "Conduit Tendril",
    },

-- Shipwright's Regret
    ["Foreman Bradiggan"] = {
        [60] = "Abomination",
        [30] = "Abomination",
    },
    ["Captain Numirril"] = {
        [85] = "Abomination",
        [40] = "Abomination",
    },

-- Earthen Root Enclave
    ["Corruption of Stone"] = {
        -- Health isn't necessary because the stages are the same, this is just for testing
        normHealth = 3367972,
        vetHealth = 5413503,
        hmHealth = 8120255,
        [80] = "Rock Shower",
        [60] = "Rock Shower",
        [30] = "Rock Shower",
    },
    ["Corruption of Root"] = {
        [75] = "Clones", -- Unsure, could be 80?
        [40] = "Clones", -- Unsure, but probably correct
    },
    ["Archdruid Devyric"] = {
        [65] = "Bear Form",
        [45] = "Human Form",
        [20] = "Bear Form",
    },

-- Graven Deep
    ["Zelvraak the Unbreathing"] = {
        [75] = "Clones",
        [50] = "Afterlife",
        [25] = "Clones",
    },

-- Bal Sunnar
    -- %s from alcast guide aren't quite right: 65, 45, 20
    -- normal: Kovan Giryon (boss1) value: 2946975 max: 2946975 effectiveMax: 2946975
    ["Kovan Giryon"] = {
        [71] = "Nix-Ox",
        [46] = "Iron Atronach",
        [21] = "Execute",
    },
    ["Roksa the Warped"] = {
        [70] = "Devour Light",
        [40] = "Devour Light",
    },
    -- %s from 3 guides aren't quite right? they say 70, 35
    ["Matriarch Lladi Telvanni"] = {
        [75] = "Poison Storm",
        [45] = "Poison Storm",
    },

-- Scrivener's Hall
    -- some guides are off, alcast says 80
    ["Riftmaster Naqri"] = {
        [86] = "Book",
        [56] = "Book",
        [36] = "Book",
    },
    ["Ozezan the Inferno"] = { -- TODO: from guides, check. can't check on normal
        normHealth = 4546762,
        vetHealth = 7308229, -- TODO: from uesp
        hmHealth = 13154812,
        ["Normal"] = {
            [75] = "",
            [50] = "",
            [25] = "",
        },
        ["Veteran"] = {
            [40] = "Atronach", -- 35?
            [20] = "Atronach",
        },
        ["Hardmode"] = {
            [40] = "Atronach", -- 35?
            [20] = "Atronach",
        },
    },
    ["Valinna"] = {
        [50] = "Lamikhai leaves",
        [55] = "Valinna leaves",
    }
}

---------------------------------------------------------------------
-- Other language aliases can go here
---------------------------------------------------------------------
local dungeonAliases = {
    ["Steinwahrer"] = "The Stonekeeper",
}

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(dungeonThresholds) do
    BHB.thresholds[k] = v
end

for k, v in pairs(dungeonAliases) do
    BHB.aliases[k] = v
end
