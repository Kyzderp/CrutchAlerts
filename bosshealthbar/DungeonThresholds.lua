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
    ["Lady Thorn"] = {
        [60] = "Batdance", -- TODO
        [20] = "Batdance", -- TODO
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
    ["Ozezan the Inferno"] = {
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
    ["Valinna"] = {
        -- TODO: after the 2nd room, Lamikhai's death removes her unit, so only Valinna is left, triggering
        -- a bosses changed event. It resets the threshold highlighting because the stages are redrawn
        [50] = "Lamikhai leaves",
        [55] = "Valinna leaves",
    }
}

---------------------------------------------------------------------
-- Other language aliases can go here
---------------------------------------------------------------------
local dungeonAliases = {
    ["Steinwahrer"] = "The Stonekeeper",

-- Simplified Chinese aliases from oumu
    ["奎因图斯·韦雷斯"] = "Quintus Verres",
    ["阿塔鲁斯"] = "Atarus",
    ["魂摄魔灵"] = "Overfiend",
    ["血肉雕刻者伊波梅兹"] = "Ibomez the Flesh Sculptor",
    ["黄昏典狱长"] = "Lord Warden Dusk",
    ["莫拉格·科娜"] = "Molag Kena",
    ["树之牧者纳-凯石"] = "Tree-Minder Na-Kesh",
    ["希瑟拉"] = "Sithera",
    ["薇利德雷斯"] = "Velidreth",
    ["凯拉奥菲"] = "Caillaoife",
    ["波敦恩石心"] = "Stoneheart",
    ["地血混合体"] = "Earthgore Amalgam",
    ["“血角”多米豪斯"] = "Domihaus the Bloody-Horned",
    ["图尔佛昆"] = "Thurvokun",
    ["“铁心”多来米什"] = "Doylemish Ironheart",
    ["首领阿尔蒂斯"] = "Matriarch Aldis",
    ["唤鳞者赞恩"] = "Zaan the Scalecaller",
    ["狱卒梅利图斯"] = "Jailer Melitus",
    ["米伦尼·唤月者"] = "Mylenne Moon-Caller",
    ["树篱迷宫守护者"] = "Hedge Maze Guardian",
    ["档案管理员厄纳尔德"] = "Archivist Ernarde",
    ["崛起的维科萨"] = "Vykosa the Ascendant",
    ["至日的阿格海德"] = "Aghaedh of the Solstice",
    ["塔赛尔"] = "Tarcyr",
    ["巴洛格"] = "Balorgh",
    ["寒冰追猎者"] = "Icestalker",
    ["督军佐格文"] = "Warlord Tzogvin",
    ["宝库守护者"] = "Vault Protector",
    ["石之看守"] = "The Stonekeeper",
    ["拾荒饿鬼"] = "The Scavenging Maw",
    ["悲泣之女"] = "The Weeping Woman",
    ["利刃交响曲"] = "Symphony of Blades",
    ["多罗扎卡"] = "Dro'zakar",
    ["库乔·科斯巴"] = "Kujo Kethba",
    ["格伦德伍尔夫"] = "Grundwulf",
    ["马塞洛克"] = "Maarselok",
    ["冰铸亡魂"] = "Stormborn Revenant",
    ["嚎叫者哈克格里姆"] = "Hakgrym the Howler",
    ["炉窑守护者"] = "Keeper of the Kiln",
    ["永恒盾灵"] = "Eternal Aegis",
    ["疯狂的昂达戈尔"] = "Ondagore the Mad",
    ["卡尔纳尔·墓歌"] = "Kjalnar Tombskald",
    ["偷心者沃瑞亚"] = "Voria the Hearth-Thief",
    ["疯炼金术士阿卡西斯"] = "Arkasis the Mad Alchemist",
    ["瓦杜罗斯"] = "Vaduroth",
    ["荆棘夫人"] = "Lady Thorn",
    ["杰米诺斯队长"] = "Captain Geminus",
    ["派罗图格·恩克拉迪斯"] = "Pyroturge Encratis",
    ["哨兵阿克萨拉兹"] = "Sentinel Aksalaz",
    ["使命之主维希娅"] = "Taskmaster Viccia",
    ["于连·梅里克"] = "Eliam Merick",
    ["斯克里昂巢穴领主"] = "Scorion Broodlord",
    ["岩浆化身"] = "Magma Incarnate",
    ["马里伽利格"] = "Maligalig",
    ["萨利迪尔"] = "Sarydil",
    ["瓦拉利昂"] = "Varallion",
    ["泽巴萨"] = "Z'Baza",
    ["工头布拉迪干"] = "Foreman Bradiggan",
    ["队长努米利尔"] = "Captain Numirril",
    ["腐化之石"] = "Corruption of Stone",
    ["腐化之根"] = "Corruption of Root",
    ["大德鲁伊德维里克"] = "Archdruid Devyric",
    ["无息泽尔拉克"] = "Zelvraak the Unbreathing",
    ["科万·吉里恩"] = "Kovan Giryon",
    ["扭曲者洛科萨"] = "Roksa the Warped",
    ["女族长雷拉蒂·泰尔瓦尼"] = "Matriarch Lladi Telvanni",
    ["裂隙御侍纳克里"] = "Riftmaster Naqri",
    ["炼狱奥泽赞"] = "Ozezan the Inferno",
    ["瓦琳娜"] = "Valinna",

-- German aliases from Keldorem
    -- ["Quintus Verres"] = Same in german
    -- ["Atarus"] = Same in german
    ["Der Oberunhold"] = "Overfiend",
    ["Ibomez den Fleischbildner"] = "Ibomez the Flesh Sculptor",
    ["Hochwärter Dämmer"] = "Lord Warden Dusk",
    -- ["Molag Kena"] = Same in german
    ["Baumhirtin Na-Kesh"] = "Tree-Minder Na-Kesh",
    -- ["Sithera"] = Same in german
    -- ["Velidreth"] = Same in german
    -- ["Caillaoife"] = Same in german
    ["Steinherz"] = "Stoneheart",
    ["Erdbluter-Amalgam"] = "Earthgore Amalgam",
    ["Domihaus der Blutgehörnte"] = "Domihaus the Bloody-Horned",
    -- ["Thurvokun"] = Same in german
    ["Doylemish Eisenherz"] = "Doylemish Ironheart",
    ["Matriarchin Aldis"] = "Matriarch Aldis",
    ["Zaan die Schuppenruferin"] = "Zaan the Scalecaller",
    ["Kerkermeister Melitus"] = "Jailer Melitus",
    ["Mylenne Mondruferin"] = "Mylenne Moon-Caller",
    ["Wirrrankenwächter"] = "Hedge Maze Guardian",
    ["Mondjäger-Stürmer"] = "Archivist Ernarde",
    ["Vykosa die Aufgestiegene"] = "Vykosa the Ascendant",
    ["Aghaedh von der Sonnenwende"] = "Aghaedh of the Solstice",
    -- ["Tarcyr"] = Same in german
    -- ["Balorgh"] = Same in german
    ["Eispirscher"] = "Icestalker",
    ["Kriegsfürst Tzogvin"] = "Warlord Tzogvin",
    ["Gewölbebeschützer"] = "Vault Protector",
    ["Steinwahrer"] = "The Stonekeeper",
    ["Der Raubschlund"] = "The Scavenging Maw",
    ["Die Trauernde"] = "The Weeping Woman",
    ["Die Sinfonie der Klingen"] = "Symphony of Blades",
    -- ["Dro'zakar"] = Same in german
    -- ["Kujo Kethba"] = Same in german
    -- ["Grundwulf"] = Same in german
    -- ["Maarselok"] = Same in german
    ["Sturmgeborener Wiedergänger"] = "Stormborn Revenant",
    ["Hakgrym der Heuler"] = "Hakgrym the Howler",
    ["Bewahrein der Feuerkammer"] = "Keeper of the Kiln",
    ["Ewige Ägis"] = "Eternal Aegis",
    ["Ondagore der Verrückte"] = "Ondagore the Mad",
    ["Kjalnar Grabskalde"] = "Kjalnar Tombskald",
    ["Voria die Herzdiebin"] = "Voria the Hearth-Thief",
    ["Arkasis der irre Alchemist"] = "Arkasis the Mad Alchemist",
    -- ["Vaduroth"] = Same in german
    ["Fürstin Dorn"] = "Lady Thorn",
    -- ["Kinras Einauge"] = "Kinras Ironeye", -- Not supported yet
    ["Hauptmann Geminus"] = "Captain Geminus",
    ["Pyroturg Encratis"] = "Pyroturge Encratis",
    ["Wächter Aksalaz"] = "Sentinel Aksalaz",
    ["Zuchtmeisterin Viccia"] = "Taskmaster Viccia",
    -- ["Baron Zaudrus"] = Same in german
    ["Reliktträgern"] = "Eliam Merric",
    ["Skorionbrutfürst"] = "Scorion Broodlord",
    ["Magmaverkörperung"] = "Magma Incarnate",
    -- ["Maligalig"] = Same in german
    -- ["Sarydil"] = Same in german
    -- ["Varallion"] = Same in german
    -- ["Z'Baza"] = Same in german
    ["Vorarbeiter Bradiggan"] = "Foreman Bradiggan",
    ["Kapitän Numirril"] = "Captain Numirril",
    ["Verderbnis des Steins"] = "Corruption of Stone",
    ["Die Verderbnis der Wurzel"] = "Corruption of Root",
    ["Erzdruide Devyric"] = "Archdruid Devyric",
    ["Zelvraak der Atemlose"] = "Zelvraak the Unbreathing",
    -- ["Kovan Giryon"] = Same in german
    ["Roksa die Verkrümmte"] = "Roksa the Warped",
    ["Matriarchin Lladi Telvanni"] = "Matriarch Lladi Telvanni",
    ["Rissmeister Naqri"] = "Riftmaster Naqri",
    ["Ozezan das Inferno"] = "Ozezan the Inferno",
    -- ["Valinna"] = Same in german

-- Japanese aliases from nikepiko
    ["クインタス・ヴェレス"] = "Quintus Verres",
    ["アタルス"] = "Atarus",
    ["オーバーフィーンド"] = "Overfiend",
    ["肉の彫刻家イボメズ"] = "Ibomez the Flesh Sculptor",
    ["ダスク看守長"] = "Lord Warden Dusk",
    ["モラグ・キーナ"] = "Molag Kena",
    ["木の番人ナ・ケッシュ"] = "Tree-Minder Na-Kesh",
    ["シセラ"] = "Sithera",
    ["ヴェリドレス"] = "Velidreth",
    ["カイラオイフェ"] = "Caillaoife",
    ["ストーンハート"] = "Stoneheart",
    ["アースゴア・アマルガム"] = "Earthgore Amalgam",
    ["血塗られた角ドミーハウス"] = "Domihaus the Bloody-Horned",
    ["サーヴォクン"] = "Thurvokun",
    ["ドイルミッシュ・アイアンハート"] = "Doylemish Ironheart",
    ["ルラディ・テルヴァンニ女族長"] = "Matriarch Aldis",
    ["ザーン・スケイルコーラー"] = "Zaan the Scalecaller",
    ["看守メリトゥス"] = "Jailer Melitus",
    ["月呼びミレンヌ"] = "Mylenne Moon-Caller",
    ["生垣の迷宮のガーディアン"] = "Hedge Maze Guardian",
    ["公文書保管人アーナルデ"] = "Archivist Ernarde",
    ["超越者ヴィコサ"] = "Vykosa the Ascendant",
    ["極点のアガエド"] = "Aghaedh of the Solstice",
    ["タルシル"] = "Tarcyr",
    ["バローグ"] = "Balorgh",
    ["アイスストーカー"] = "Icestalker",
    ["ツォグヴィン戦士長"] = "Warlord Tzogvin",
    ["ヴォルトの守護者"] = "Vault Protector",
    ["石の番人"] = "The Stonekeeper",
    ["スカベンジング・モー"] = "The Scavenging Maw",
    ["嘆きの淑女"] = "The Weeping Woman",
    ["シンフォニー・オブ・ブレイズ"] = "Symphony of Blades",
    ["ドロザカール"] = "Dro'zakar",
    ["クジョー・ケスバ"] = "Kujo Kethba",
    ["グランドウルフ"] = "Grundwulf",
    ["マーセロク"] = "Maarselok",
    ["ストームボーン・レブナント"] = "Stormborn Revenant",
    ["吠えるハクグリム"] = "Hakgrym the Howler",
    ["窯の番人"] = "Keeper of the Kiln",
    ["エターナル・アイギス"] = "Eternal Aegis",
    ["狂乱のオンダゴア"] = "Ondagore the Mad",
    ["クジャルナル・トゥームスカルド"] = "Kjalnar Tombskald",
    ["心盗賊ヴォリア"] = "Voria the Hearth-Thief",
    ["狂った錬金術師アルカシス"] = "Arkasis the Mad Alchemist",
    ["ヴァドゥロス"] = "Vaduroth",
    ["レディ・ソーン"] = "Lady Thorn",
    ["ゲミナス隊長"] = "Captain Geminus",
    ["火炎魔術師エンクラティス"] = "Pyroturge Encratis",
    ["衛士アクサラズ"] = "Sentinel Aksalaz",
    ["タスクマスター・ヴィッシア"] = "Taskmaster Viccia",
    ["エリアム・メリック"] = "Eliam Merick",
    ["スコーリオン・ブルードロード"] = "Scorion Broodlord",
    ["マグマの転生者"] = "Magma Incarnate",
    ["マリガリグ"] = "Maligalig",
    ["サリディル"] = "Sarydil",
    ["ヴァラリオン"] = "Varallion",
    ["ズバザ"] = "Z'Baza",
    ["ブラディガン作業長"] = "Foreman Bradiggan",
    ["ヌミリル船長"] = "Captain Numirril",
    ["腐敗の石"] = "Corruption of Stone",
    ["腐敗の根"] = "Corruption of Root",
    ["アークドルイド・デヴィリック"] = "Archdruid Devyric",
    ["息要らずのゼルヴラーク"] = "Zelvraak the Unbreathing",
    ["コヴァン・ジリョン"] = "Kovan Giryon",
    ["歪められたロクサ"] = "Roksa the Warped",
    ["ルラディ・テルヴァンニ女族長"] = "Matriarch Lladi Telvanni",
    ["リフトマスター・ナクリ"] = "Riftmaster Naqri",
    ["業火のオゼザン"] = "Ozezan the Inferno",
    ["ヴァリナ"] = "Valinna",
}

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(dungeonThresholds) do
    BHB.thresholds[k] = v
end

for k, v in pairs(dungeonAliases) do
    BHB.aliases[k] = v
end
