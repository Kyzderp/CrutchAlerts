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
        [50] = "Cataclysm",
    },

    -- Don't know %s yet. In one run, spawned in order of atro > indrik > nereid
    -- ["Sentinel Aksalaz"] = {
    --     [] = "Atronach", -- TODO
    --     [] = "Indrik", -- TODO
    --     [] = "Nereid", -- TODO
    -- },

-- Run 10/31 solo
    -- The Whisperer
    -- 1-1: 792464

    -- Selene: Fang and Claw seem to be on a timer
    -- 1-2: |c8888FF[BHB]|r Selene (boss1) value: 924541 max: 924541 effectiveMax: 924541

    ["Lady Belain"] = {
    -- 1-3: |c8888FF[BHB]|r Lady Belain (boss1) value: 1056619 max: 1056619 effectiveMax: 1056619
        [50] = "Awakening", -- She flies up and summons 2? voidmothers, and you take constant Awakening damage
        -- Seems like after 50 she also summons blood knights, 3 at once
    },

    -- 1-4: |c8888FF[BHB]|r Symphony of Blades (boss1) value: 1215111 max: 1215111 effectiveMax: 1215111
    -- south: Scintillating

    -- 1-5: |c8888FF[BHB]|r Tho'at Replicanum (boss1) value: 2273381 max: 2273381 effectiveMax: 2273381

    -- Aramril (the duelist) is not a "boss" seems to end at ~17% though

    -- 2-1: |c8888FF[BHB]|r Queen of the Reef (boss1) value: 1109450 max: 1109450 effectiveMax: 1109450
    -- Doesn't appear to have a % based mechanic

    -- 2-2: |c8888FF[BHB]|r The Sable Knight (boss1) value: 1294357 max: 1294357 effectiveMax: 1294357
    -- Maybe only starts doing Dark Burst (aoe centered around itself) after 50%?

    -- 2-3: |c8888FF[BHB]|r Councilor Vandacia (boss1) value: 1479267 max: 1479267 effectiveMax: 1479267
    -- Starts doing meteors all over the place after 50%. "Vandacia's Desperation"

    -- 2-4: |c8888FF[BHB]|r Z'Baza (boss1) value: 1701155 max: 1701155 effectiveMax: 1701155
    -- Tendril seems to be on a timer, no % based mechs

    -- 2-5:
    -- |c8888FF[BHB]|r Tho'at Replicanum (boss1) value: 2273381 max: 2273381 effectiveMax: 2273381
    -- |c8888FF[BHB]|r Tho'at Shard (boss3) value: 2273381 max: 2273381 effectiveMax: 2273381
    -- spawned at ~70%?

    -- 3-1: |c8888FF[BHB]|r Barbas (boss1) value: 1981160 max: 1981160 effectiveMax: 1981160
    -- boring mechs

    -- 3-2: |c8888FF[BHB]|r Ash Titan (boss1) value: 2311353 max: 2311353 effectiveMax: 2311353
    -- No % mechanics. TODO: fix Wing Burst (and probably add it to OTHERS)

    -- 3-3: |c8888FF[BHB]|r Prior Thierric Sarazen (boss1) value: 2641548 max: 2641548 effectiveMax: 2641548
    -- No % mechanics? TODO: see if the aoe cast can be an alert

    -- 3-4-1: |c8888FF[BHB]|r Marauder Gothmau (boss1) value: 1215111 max: 1215111 effectiveMax: 1215111

    -- 3-4: |c8888FF[BHB]|r Nazaray (boss1) value: 3037778 max: 3037778 effectiveMax: 3037778

    -- 3-5:
    -- |c8888FF[BHB]|r Tho'at Replicanum (boss1) value: 2273381 max: 2273381 effectiveMax: 2273381
    -- |c8888FF[BHB]|r Tho'at Shard (boss3) value: 2273381 max: 2273381 effectiveMax: 2273381
    -- |c8888FF[BHB]|r Tho'at Shard (boss2) value: 2273381 max: 2273381 effectiveMax: 2273381

    -- 4-1-1: |c8888FF[BHB]|r Marauder Gothmau (boss1) value: 1215111 max: 1215111 effectiveMax: 1215111
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
