CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.BossHealthBar = CrutchAlerts.BossHealthBar or {}
local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

---------------------------------------------------------------------
-- Add percentage threshold + the mechanic name below
---------------------------------------------------------------------
local endlessArchiveThresholds = {
    -- Allene Pellingare
    -- Ash Titan

    -- Barbas -- nothing interesting
    -- Baron Zaudrus
    -- Bittergreen the Wild

    -- Caluurion -- nothing interesting
    -- Canonreeve Oraneth
    -- Captain Blackheart
    -- Councilor Vandacia
    ["Councilor Vandacia"] = {
        [50] = "Desperation", -- meteors all over the place
    },
    -- Cynhamoth

    -- Death's Leviathan
    ["Death's Leviathan"] = {
        [50] = "Immolate", -- TODO; adds fire to its attacks
    },
    -- Doylemish Ironheart

    -- Exarch Kraglen

    -- Garron the Returned -- Consume Life is timer based
    -- Ghemvas the Harbinger
    -- Glemyos Wildhorn
    -- ["Glemyos Wildhorn"] = {
    --     [50] = "Indriks", -- TODO: may be on a timer, need to check
    -- },
    -- Grothdarr

    -- High Kinlord Rilis

    -- Iceheart

    -- Kjarg the Tuskscraper
    -- Kra'gh the Dreugh King

    -- Laatvulon
    ["Laatvulon"] = {
        [50] = "Blizzard",
    },
    -- Lady Belain
    ["Lady Belain"] = {
        [50] = "Awakening", -- She flies up and summons 2 voidmothers (more in later arcs), and you take constant Awakening damage
        -- Seems like after 50 she also summons blood knights, 3 at once
    },
    -- Lady Thorn
    ["Lady Thorn"] = {
        [50] = "Batdance",
    },
    -- Limenauruus
    -- Lord Warden Dusk

    -- Marauder Gothmau
    -- Marauder Hilkarax
    -- Marauder Ulmor

    -- Molag Kena
    -- Mulaamnir
    -- Murklight

    -- Nazaray
    -- Nerien'eth
    ["Nerien'eth"] = {
        [50] = "Ebony Blade",
    },

    -- Old Snagara

    -- Queen of the Reef

    -- Ra'khajin
    -- Rada al-Saran
    -- Rakkhat
    -- Razor Master Erthas
    -- Ri'Atahrashi

    -- Selene
    -- Sentinel Aksalaz
    ["Sentinel Aksalaz"] = {
        -- Unsure of exact %s. In 2 runs, spawned in order of atro > indrik > nereid
        -- Different order: indrik > nereid > atro
        [75] = "Add", -- TODO
        [50] = "Add", -- TODO
        [25] = "Add", -- TODO
    },
    -- Shadowrend
    -- Sonolia the Matriarch
    -- Symphony of Blades

    -- Taupezu Azzida
    -- The Ascendant Lord
    -- The Endling
    -- The Imperfect
    -- The Lava Queen
    -- The Mage
    ["The Mage"] = {
        [50] = "Arcane Vortex",
    },
    -- The Sable Knight
    -- The Serpent
    -- The Warrior
    -- The Weeping Woman
    -- The Whisperer
    -- Tho'at Replicanum
    ["Tho'at Replicanum"] = {
        [70] = "Shard", -- TODO: don't show this for Arc 1
    },
    ["Tho'at Shard"] = {
        -- This is needed because after the Replicanum dies, there is no boss1
        [70] = "Shard", -- TODO: don't show this for Arc 2
    },
    -- Tremorscale

    -- Valkynaz Nokvroz
    -- Vila Theran
    -- Voidmother Elgroalif
    -- Vorenor Winterbourne

    -- War Chief Ozozai

    -- Xeemhok the Trophy-Taker

    -- Yolnahkriin
    ["Yolnahkriin"] = {
        [50] = "Cataclysm",
    },
    -- Ysmgar

    -- Z'Baza
    -- Zhaj'hassa the Forgotten
}

---------------------------------------------------------------------
-- Other language aliases can go here. Unlike the thresholds, this is
-- combined with the other content's aliases, so the translations
-- from e.g. TrialThresholds for Yolnahkriin will apply automatically
--
-- Therefore, this struct should only be used for overland or quest
-- bosses, or obviously EA-exclusive Tho'at Replicanum
---------------------------------------------------------------------
local eaAliases = {
    ["格莱米奥斯·野角"] = "Glemyos Wildhorn",
    ["拉特伏龙"] = "Laatvulon",
    ["索特复影体"] = "Tho'at Replicanum",
    ["索特碎片"] = "Tho'at Shard",

    -- "Laatvulon", same
    ["Replicanum de Tho'at"] = "Tho'at Replicanum",
    ["Fragment de Tho'at"] = "Tho'at Shard",

    -- "Glemyos Wildhorn", same
    -- "Laatvulon", same
    ["Ratsherr Vandacia"] = "Councilor Vandacia",
    -- "Tho'at Replicanum", same
    ["Tho'at-Scherbe"] = "Tho'at Shard",
}

---------------------------------------------------------------------
-- Separate from the other files
BHB.eaThresholds = endlessArchiveThresholds

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(eaAliases) do
    BHB.aliases[k] = v
end
