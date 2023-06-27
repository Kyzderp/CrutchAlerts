CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.BossHealthBar = CrutchAlerts.BossHealthBar or {}
local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

BHB.thresholds = BHB.thresholds or {}
BHB.aliases = BHB.aliases or {}

---------------------------------------------------------------------
-- Add percentage threshold + the mechanic name below
---------------------------------------------------------------------
local arenaThresholds = {
    -- Vateshran Hollows
    ["The Pyrelord"] = {
        [70] = "Colossus",
        [30] = "Colossus",
    },
}

---------------------------------------------------------------------
-- Other language aliases can go here
---------------------------------------------------------------------
local arenaAliases = {
    ["Der Schürfürst"] = "The Pyrelord",
}

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(arenaThresholds) do
    BHB.thresholds[k] = v
end

for k, v in pairs(arenaAliases) do
    BHB.aliases[k] = v
end
