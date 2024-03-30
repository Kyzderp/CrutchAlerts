CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.BossHealthBar = CrutchAlerts.BossHealthBar or {}
local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

---------------------------------------------------------------------
local function GetBossName(id)
    return Crutch.GetCapitalizedString(id)
end

---------------------------------------------------------------------
-- Add percentage threshold + the mechanic name below
---------------------------------------------------------------------
local endlessArchiveThresholds = {
    -- Allene Pellingare -- nothing interesting
    -- Ash Titan

    -- Barbas -- nothing interesting
    -- Baron Zaudrus
    -- Bittergreen the Wild

    -- Caluurion -- nothing interesting
    -- Canonreeve Oraneth
    -- Captain Blackheart
    -- Councilor Vandacia
    [GetBossName(CRUTCH_BHB_COUNCILOR_VANDACIA)] = {
        [50] = "Desperation", -- meteors all over the place
    },
    -- Cynhamoth

    -- Death's Leviathan
    [GetBossName(CRUTCH_BHB_DEATHS_LEVIATHAN)] = {
        [50] = "Immolate", -- TODO; adds fire to its attacks
    },
    -- Doylemish Ironheart
    [GetBossName(CRUTCH_BHB_DOYLEMISH_IRONHEART)] = {
        [50] = "Stone Orb", -- They seem to spawn on a timer after 50%, but don't... do anything?
    },

    -- Exarch Kraglen

    -- Garron the Returned -- Consume Life is timer based
    -- Ghemvas the Harbinger
    [GetBossName(CRUTCH_BHB_GHEMVAS_THE_HARBINGER)] = {
        [50] = "Unstable Energy",
    },
    -- Glemyos Wildhorn
    -- ["Glemyos Wildhorn"] = {
    --     [50] = "Indriks", -- TODO: may be on a timer, need to check
    -- },
    -- Grothdarr -- nothing interesting

    -- High Kinlord Rilis -- nothing interesting

    -- Iceheart -- nothing interesting

    -- Kjarg the Tuskscraper -- nothing interesting
    -- Kra'gh the Dreugh King

    -- Laatvulon
    [GetBossName(CRUTCH_BHB_LAATVULON)] = {
        [50] = "Blizzard",
    },
    -- Lady Belain
    [GetBossName(CRUTCH_BHB_LADY_BELAIN)] = {
        [50] = "Awakening", -- She flies up and summons 2 voidmothers (more in later arcs), and you take constant Awakening damage
        -- Seems like after 50 she also summons blood knights, 3 at once
    },
    -- Lady Thorn
    [GetBossName(CRUTCH_BHB_LADY_THORN)] = {
        [50] = "Batdance",
    },
    -- Limenauruus
    -- Lord Warden Dusk

    -- Marauder Gothmau -- no hp gates
    -- Marauder Hilkarax -- no hp gates
    -- Marauder Ulmor -- no hp gates

    -- Molag Kena
    -- Mulaamnir
    [GetBossName(CRUTCH_BHB_MULAAMNIR)] = {
        [50] = "Storm",
    },
    -- Murklight

    -- Nazaray
    -- Nerien'eth
    [GetBossName(CRUTCH_BHB_NERIENETH)] = {
        [50] = "Ebony Blade",
    },

    -- Old Snagara -- no hp gates

    -- Queen of the Reef

    -- Ra'khajin -- no hp gates
    -- Rada al-Saran -- no hp gates
    -- Rakkhat -- no hp gates I think
    -- Razor Master Erthas
    -- Ri'Atahrashi

    -- Selene -- the Claw and Fang seem to be on both timer and hp gate
    -- Sentinel Aksalaz
    [GetBossName(CRUTCH_BHB_SENTINEL_AKSALAZ)] = {
        -- Unsure of exact %s. In 2 runs, spawned in order of atro > indrik > nereid
        -- Different order: indrik > nereid > atro
        -- solo run: atro > indrid > nereid
        [75] = "Add", -- TODO: still not sure. He seems to have a lot of priority skills
        [50] = "Add",
        [25] = "Add",
    },
    -- Shadowrend -- no hp gates
    -- Sonolia the Matriarch -- no hp gates
    -- Symphony of Blades -- no hp gates?

    -- Taupezu Azzida -- no hp gates
    -- The Ascendant Lord -- no hp gates?
    -- The Endling
    -- The Imperfect -- no hp gates
    -- The Lava Queen -- no hp gates?
    -- The Mage
    [GetBossName(CRUTCH_BHB_THE_MAGE)] = {
        [50] = "Arcane Vortex",
    },
    -- The Sable Knight -- no hp gates
    -- The Serpent
    -- The Warrior
    -- The Weeping Woman
    -- The Whisperer
    -- Tho'at Replicanum
    [GetBossName(CRUTCH_BHB_THOAT_REPLICANUM)] = {
        [70] = "Shard", -- TODO: don't show this for Arc 1
    },
    [GetBossName(CRUTCH_BHB_THOAT_SHARD)] = {
        -- This is needed because after the Replicanum dies, there is no boss1
        [70] = "Shard", -- TODO: don't show this for Arc 2
    },
    -- Tremorscale

    -- Valkynaz Nokvroz
    -- Vila Theran
    -- Voidmother Elgroalif
    -- Vorenor Winterbourne

    -- War Chief Ozozai -- no hp gates

    -- Xeemhok the Trophy-Taker

    -- Yolnahkriin
    [GetBossName(CRUTCH_BHB_YOLNAHKRIIN)] = {
        [50] = "Cataclysm",
    },
    -- Ysmgar

    -- Z'Baza -- no hp gates
    -- Zhaj'hassa the Forgotten -- no hp gates?
}
Crutch.test = endlessArchiveThresholds

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
