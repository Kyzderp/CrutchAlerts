CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.BossHealthBar = CrutchAlerts.BossHealthBar or {}
local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

---------------------------------------------------------------------
-- Add percentage threshold + the mechanic name below
---------------------------------------------------------------------
local endlessArchiveThresholds = {
    ["Councilor Vandacia"] = {
        [50] = "Desperation", -- meteors all over the place
    },
    ["Death's Leviathan"] = {
        [50] = "Immolate", -- TODO; adds fire to its attacks
    },
    -- ["Glemyos Wildhorn"] = {
    --     [50] = "Indriks", -- TODO: may be on a timer, need to check
    -- },
    ["Laatvulon"] = {
        [50] = "Blizzard",
    },
    ["Lady Belain"] = {
        [50] = "Awakening", -- She flies up and summons 2 voidmothers (more in later arcs), and you take constant Awakening damage
        -- Seems like after 50 she also summons blood knights, 3 at once
    },
    ["Sentinel Aksalaz"] = {
        -- Unsure of exact %s. In 2 runs, spawned in order of atro > indrik > nereid
        [75] = "Atronach", -- TODO
        [50] = "Indrik", -- TODO
        [25] = "Nereid", -- TODO
    },
    ["Tho'at Replicanum"] = {
        [70] = "Shard", -- TODO: don't show this for Arc 1
    },
    ["Tho'at Shard"] = {
        -- This is needed because after the Replicanum dies, there is no boss1
        [70] = "Shard", -- TODO: don't show this for Arc 2
    },
    ["Yolnahkriin"] = {
        [50] = "Cataclysm",
    },
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

    -- [""] = "Glemyos Wildhorn",
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
