CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.BossHealthBar = CrutchAlerts.BossHealthBar or {}
local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

---------------------------------------------------------------------
-- Add percentage threshold + the mechanic name below
---------------------------------------------------------------------
local endlessArchiveThresholds = {
-- Sunspire
    ["Yolnahkriin"] = {
        [50] = "Takeoff", -- TODO: figure out actual name for the subsequent attack. Is it still cataclysm?
    },
}

---------------------------------------------------------------------
-- Other language aliases can go here
---------------------------------------------------------------------
local endlessArchiveAliases = {
-- Simplified Chinese aliases from oumu
    ["尤尔纳克林"] = "Yolnahkriin",

-- German aliases from Keldorem
    -- ["Yolnahkriin"] = Same in german
}

---------------------------------------------------------------------
-- Separate from the other files
BHB.eaThresholds = endlessArchiveThresholds
BHB.eaAliases = endlessArchiveAliases
