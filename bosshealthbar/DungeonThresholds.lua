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
-- White-Gold Tower (Green Emperor Way)
-- Ruins of Mazzatun
-- Cradle of Shadows
-- Bloodroot Forge
-- Falkreath Hold
-- Fang Lair
-- Scalecaller Peak
-- Moon Hunter Keep
-- March of Sacrifices (Bloodscent Pass)

-- Frostvault
    ["The Stonekeeper"] = {
        [55] = "Skeevatons",
    },

-- Depths of Malatar
-- Moongrave Fane

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

-- Unhallowed Grave
    ["Hakgrym the Howler"] = {
        [71] = "Abomination",
        [31] = "Abomination",
        -- On normal, has 2273381 health. Heals for ~1126690 (130728 -> 1267418; 49.5%?) / ~1136690 (130486 -> 1267176; 50%)
        [6] = "Werewolf Form",
    },

-- Stone Garden
-- Castle Thorn
-- Black Drake Villa
-- The Cauldron
-- Red Petal Bastion
-- The Dread Cellar

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
        ["Normal"] = {
            [95] = "Gryphon",
            [50] = "Gryphon",
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
        [40] = "Atronach",
        [20] = "Atronach",
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
