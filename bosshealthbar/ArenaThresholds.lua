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
local arenaThresholds = {
-- Blackrose Prison
    -- TODO: localization
    ["Tames-the-Beast"] = {
        [60] = "Mini", -- TODO: 2nd arena: haj/wamasu; 4th arena: wamasu/haj
        [40] = "Mini",
    },
    ["Lady Minara"] = { -- TODO: only on 3rd arena. does boss tag take care of this?
        [80] = "Infuser",
        [60] = "Colossus",
        [40] = "Colossus + Infuser",
        [20] = "Colossus + Infusers",
    },

-- Dragonstar Arena
    [GetBossName(CRUTCH_BHB_CHAMPION_MARCAULD)] = {
        [75] = "Adds", -- TODO: alcast 70
        [40] = "Adds", -- TODO
    },
    -- Stage 2 and 3 are based on combined health, skip for now
    [GetBossName(CRUTCH_BHB_EARTHEN_HEART_KNIGHT)] = {
        [70] = "Adds", -- TODO
        [30] = "Adds", -- TODO
    },
    [GetBossName(CRUTCH_BHB_ANALA_TUWHA)] = {
        [78] = "Adds", -- TODO
        [40] = "Adds", -- TODO
    },
    [GetBossName(CRUTCH_BHB_PISHNA_LONGSHOT)] = {
        [70] = "Adds", -- TODO
        [40] = "Adds", -- TODO
    },
    -- Stage 7 is combined health
    [GetBossName(CRUTCH_BHB_MAVUS_TALNARITH)] = {
        [80] = "Adds", -- TODO
        [40] = "Adds", -- TODO
    },
    [GetBossName(CRUTCH_BHB_VAMPIRE_LORD_THISA)] = {
        [80] = "Portal", -- TODO
        [40] = "Adds", -- TODO
    },
    [GetBossName(CRUTCH_BHB_HIATH_THE_BATTLEMASTER)] = {
        [75] = "Adds", -- TODO
        [50] = "Pull + Adds", -- TODO
        [25] = "Pull", -- TODO
    },

-- Maelstrom Arena

-- Vateshran Hollows
    [GetBossName(CRUTCH_BHB_THE_PYRELORD)] = {
        [70] = "Colossus",
        [30] = "Colossus",
    },
}

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(arenaThresholds) do
    BHB.thresholds[k] = v
end
