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
    ["Glemyos Wildhorn"] = {
        [50] = "Indriks",
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
    ["Yolnahkriin"] = {
        [50] = "Cataclysm",
    },

-- 10/31 solo
    -- 1-1: The Whisperer 792464
    -- 1-2: |c8888FF[BHB]|r Selene (boss1) value: 924541 max: 924541 effectiveMax: 924541
        -- Fang and Claw seem to be on a timer
    -- 1-3: |c8888FF[BHB]|r Lady Belain (boss1) value: 1056619 max: 1056619 effectiveMax: 1056619
    -- 1-4: |c8888FF[BHB]|r Symphony of Blades (boss1) value: 1215111 max: 1215111 effectiveMax: 1215111
        -- south: Scintillating (purple) zoneId=1436 {x = 125148, y = 32248, z = 127218}
        -- east: radiant (yellow)
        -- north: blazing (red)
        -- west: phosphorescent (blue)
    -- 1-5: |c8888FF[BHB]|r Tho'at Replicanum (boss1) value: 2273381 max: 2273381 effectiveMax: 2273381
        -- Aramril (the duelist) is not a "boss" seems to end at ~17% though

    -- 2-1: |c8888FF[BHB]|r Queen of the Reef (boss1) value: 1109450 max: 1109450 effectiveMax: 1109450
    -- 2-2: |c8888FF[BHB]|r The Sable Knight (boss1) value: 1294357 max: 1294357 effectiveMax: 1294357
        -- Maybe only starts doing Dark Burst (aoe centered around itself) after 50%?
    -- 2-3: |c8888FF[BHB]|r Councilor Vandacia (boss1) value: 1479267 max: 1479267 effectiveMax: 1479267
        -- Starts doing meteors all over the place after 50%. "Vandacia's Desperation"
    -- 2-4: |c8888FF[BHB]|r Z'Baza (boss1) value: 1701155 max: 1701155 effectiveMax: 1701155
        -- Tendril seems to be on a timer, no % based mechs
    -- 2-5: |c8888FF[BHB]|r Tho'at Replicanum (boss1) value: 2273381 max: 2273381 effectiveMax: 2273381
        -- |c8888FF[BHB]|r Tho'at Shard (boss3) value: 2273381 max: 2273381 effectiveMax: 2273381
    -- 3-1: |c8888FF[BHB]|r Barbas (boss1) value: 1981160 max: 1981160 effectiveMax: 1981160
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

-- 11/4 T

    -- 2-2: |c8888FF[BHB]|r Voidmother Elgroalif (boss1) value: 1294357 max: 1294357 effectiveMax: 1294357
    -- 4-2: |c8888FF[BHB]|r Glemyos Wildhorn (boss1) value: 2773623 max: 2773623 effectiveMax: 2773623
    -- 4-5: Mantikora spawned at ~65% on atro again

--[[ 11/5 Kujanka
    1-1: |c8888FF[BHB]|r War Chief Ozozai (boss1) value: 792464 max: 792464 effectiveMax: 792464
    1-2: |c8888FF[BHB]|r The Sable Knight (boss1) value: 924541 max: 924541 effectiveMax: 924541
    1-3: |c8888FF[BHB]|r Doylemish Ironheart (boss1) value: 1056619 max: 1056619 effectiveMax: 1056619
    1-4: |c8888FF[BHB]|r Mulaamnir (boss1) value: 1397378 max: 1397378 effectiveMax: 1397378
    1-5: |c8888FF[BHB]|r Tho'at Replicanum (boss1) value: 2273381 max: 2273381 effectiveMax: 2273381

    [12:35:24] [Kyzderp's Derps] zoneId=1436 {x = 165804, y = 39064, z = 86953}

    2-1: |c8888FF[BHB]|r Bittergreen the Wild (boss1) value: 1109450 max: 1109450 effectiveMax: 1109450

    [12:39:04] [Kyzderp's Derps] zoneId=1436 {x = 132643, y = 33349, z = 49862}

    [12:40:22] [Kyzderp's Derps] zoneId=1436 {x = 143643, y = 35269, z = 43404}

    2-2: |c8888FF[BHB]|r Ash Titan (boss1) value: 1294357 max: 1294357 effectiveMax: 1294357

    [12:42:37] [Kyzderp's Derps] zoneId=1436 {x = 74279, y = 36595, z = 80066}

    [12:44:02] [Kyzderp's Derps] zoneId=1436 {x = 70015, y = 36106, z = 72087}

    2-3: |c8888FF[BHB]|r Ghemvas the Harbinger (boss1) value: 1479267 max: 1479267 effectiveMax: 1479267
    50% maybe? Unstable Energy

    [12:47:17] [Kyzderp's Derps] zoneId=1436 {x = 43271, y = 32151, z = 140863}
    wave 2 [12:47:42] [Kyzderp's Derps] zoneId=1436 {x = 44839, y = 32102, z = 139691}

    [12:48:55] [Kyzderp's Derps] zoneId=1436 {x = 51476, y = 32101, z = 139871}
    wave 2 [12:49:13] [Kyzderp's Derps] zoneId=1436 {x = 47678, y = 32146, z = 137915}

    2-4: |c8888FF[BHB]|r Molag Kena (boss1) value: 1701155 max: 1701155 effectiveMax: 1701155

    [12:52:25] [Kyzderp's Derps] zoneId=1436 {x = 81080, y = 35184, z = 76136}
    -- wave 2 somewhere up the ramp idk maybe [12:53:42] [Kyzderp's Derps] zoneId=1436 {x = 78899, y = 35591, z = 76746}

    [12:57:07] [Kyzderp's Derps] zoneId=1436 {x = 74310, y = 36595, z = 80146}
    wave 2 [12:57:24] [Kyzderp's Derps] zoneId=1436 {x = 71809, y = 37128, z = 81992}

    2-5: |c8888FF[BHB]|r Tho'at Replicanum (boss1) value: 1538899 max: 2273381 effectiveMax: 2273381
    |c8888FF[BHB]|r Tho'at Shard (boss3) value: 2273381 max: 2273381 effectiveMax: 2273381

    [13:01:38] [Kyzderp's Derps] zoneId=1436 {x = 121151, y = 44479, z = 170742}
    only one :thonk:

    [13:03:14] [Kyzderp's Derps] zoneId=1436 {x = 134295, y = 47988, z = 168721}

    3-1: |c8888FF[BHB]|r Barbas (boss1) value: 1981160 max: 1981160 effectiveMax: 1981160

    [13:08:01] [Kyzderp's Derps] zoneId=1436 {x = 77965, y = 33200, z = 127826}

    [13:09:31] [Kyzderp's Derps] zoneId=1436 {x = 30528, y = 32387, z = 125860}

    3-2: |c8888FF[BHB]|r Ri'Atahrashi (boss1) value: 2311353 max: 2311353 effectiveMax: 2311353

    [13:13:01] [Kyzderp's Derps] zoneId=1436 {x = 165794, y = 39064, z = 87147}

    [13:14:37] [Kyzderp's Derps] zoneId=1436 {x = 183271, y = 39800, z = 94615}

    3-3: |c8888FF[BHB]|r Kjarg the Tuskscraper (boss1) value: 2641548 max: 2641548 effectiveMax: 2641548

    [13:18:19] [Kyzderp's Derps] zoneId=1436 {x = 28080, y = 32900, z = 147631}
    wave 3 [13:18:52] [Kyzderp's Derps] zoneId=1436 {x = 27934, y = 32900, z = 147387}
    [13:19:10] [Kyzderp's Derps] zoneId=1436 {x = 25710, y = 32900, z = 147704}

    [13:20:33] [Kyzderp's Derps] zoneId=1436 {x = 31476, y = 32900, z = 146153}
    wave 3 [13:21:03] [Kyzderp's Derps] zoneId=1436 {x = 27566, y = 32777, z = 144892}
    [13:21:26] [Kyzderp's Derps] zoneId=1436 {x = 31402, y = 32900, z = 146188}

    3-4: |c8888FF[BHB]|r Rakkhat (boss1) value: 3037778 max: 3037778 effectiveMax: 3037778

    [13:24:33] [Kyzderp's Derps] zoneId=1436 {x = 132689, y = 33348, z = 49823}
    wave 3 [13:25:05] [Kyzderp's Derps] zoneId=1436 {x = 134950, y = 33350, z = 51627}    
    [13:25:10] [Kyzderp's Derps] zoneId=1436 {x = 132117, y = 33344, z = 48987}

    [13:26:23] [Kyzderp's Derps] zoneId=1436 {x = 143893, y = 35269, z = 43538}
    wave 3 [13:27:50] [Kyzderp's Derps] zoneId=1436 {x = 146050, y = 35300, z = 47439}
    [13:28:19] [Kyzderp's Derps] zoneId=1436 {x = 142175, y = 35281, z = 48002}

    3-5: |c8888FF[BHB]|r Tho'at Replicanum (boss1) value: 2273381 max: 2273381 effectiveMax: 2273381
    |c8888FF[BHB]|r Tho'at Shard (boss3) value: 2273381 max: 2273381 effectiveMax: 2273381
    |c8888FF[BHB]|r Tho'at Shard (boss2) value: 2273381 max: 2273381 effectiveMax: 2273381

    [13:34:30] [Kyzderp's Derps] zoneId=1436 {x = 72504, y = 37993, z = 64487}
    wave 3 [13:35:01] [Kyzderp's Derps] zoneId=1436 {x = 75182, y = 38399, z = 65364}
    [13:35:04] [Kyzderp's Derps] zoneId=1436 {x = 75763, y = 38370, z = 68188}

    [13:36:54] [Kyzderp's Derps] zoneId=1436 {x = 80996, y = 35185, z = 76034}
    wave 3 [13:37:27] [Kyzderp's Derps] zoneId=1436 {x = 80209, y = 35988, z = 78410}
    [13:37:53] [Kyzderp's Derps] zoneId=1436 {x = 77474, y = 36312, z = 79936}

    4-1: |c8888FF[BHB]|r Death's Leviathan (boss1) value: 2377392 max: 2377392 effectiveMax: 2377392
    might be Immolate at 50%?

    [13:40:35] [Kyzderp's Derps] zoneId=1436 {x = 49542, y = 31876, z = 145464}
    wave 3 [13:41:23] [Kyzderp's Derps] zoneId=1436 {x = 49902, y = 32062, z = 142723}
    [13:41:27] [Kyzderp's Derps] zoneId=1436 {x = 51050, y = 32103, z = 143920}

    [13:43:44] [Kyzderp's Derps] zoneId=1436 {x = 28003, y = 32900, z = 147772}
    wave 3 [13:44:20] [Kyzderp's Derps] zoneId=1436 {x = 25767, y = 32900, z = 147759}
    [13:44:49] [Kyzderp's Derps] zoneId=1436 {x = 27838, y = 32776, z = 146551} maybe?

    4-2: |c8888FF[BHB]|r Garron the Returned (boss1) value: 2773623 max: 2773623 effectiveMax: 2773623
    maybe Consume Life at 50%?

    [13:47:45] [Kyzderp's Derps] zoneId=1436 {x = 65278, y = 33864, z = 127241}
    wave 3 [13:48:23] [Kyzderp's Derps] zoneId=1436 {x = 66969, y = 34294, z = 128307}
    [13:48:25] [Kyzderp's Derps] zoneId=1436 {x = 67849, y = 34298, z = 126562}

    [13:51:20] [Kyzderp's Derps] zoneId=1436 {x = 61090, y = 32961, z = 125354}
    wave 3 [13:52:48] [Kyzderp's Derps] zoneId=1436 {x = 63252, y = 32975, z = 124472}
    [13:52:54] [Kyzderp's Derps] zoneId=1436 {x = 60778, y = 32650, z = 123705}

    4-3: |c8888FF[BHB]|r Caluurion (boss1) value: 3169857 max: 3169857 effectiveMax: 3169857

    ??
    wave 3[13:57:12] [Kyzderp's Derps] zoneId=1436 {x = 83458, y = 33326, z = 145894}
    [13:57:17] [Kyzderp's Derps] zoneId=1436 {x = 86759, y = 33327, z = 147024}

    [13:58:32] [Kyzderp's Derps] zoneId=1436 {x = 86021, y = 32752, z = 141345}
    wave 3 [13:59:03] [Kyzderp's Derps] zoneId=1436 {x = 88077, y = 33124, z = 139614}
    [13:59:05] [Kyzderp's Derps] zoneId=1436 {x = 86681, y = 33124, z = 138993}

    4-4: |c8888FF[BHB]|r Lady Thorn (boss1) value: 3645333 max: 3645333 effectiveMax: 3645333
    probably batdance at 50%

    [14:05:57] [Kyzderp's Derps] zoneId=1436 {x = 188861, y = 39889, z = 143602}
    wave 3 [14:06:37] [Kyzderp's Derps] zoneId=1436 {x = 190975, y = 39220, z = 146363}
    [14:06:40] [Kyzderp's Derps] zoneId=1436 {x = 191485, y = 39211, z = 144130}

    [14:07:57] [Kyzderp's Derps] zoneId=1436 {x = 189025, y = 38571, z = 138833}
    wave 3 [14:08:30] [Kyzderp's Derps] zoneId=1436 {x = 189514, y = 38672, z = 141525}
    [14:08:37] [Kyzderp's Derps] zoneId=1436 {x = 192554, y = 38623, z = 137927} maybe?

    5-1: |c8888FF[BHB]|r Iceheart (boss1) value: 2773624 max: 2773624 effectiveMax: 2773624

    5-2: 
]]

--[[ 11/5 Eashi

    1-1: |c8888FF[BHB]|r Tremorscale (boss1) value: 792464 max: 792464 effectiveMax: 792464
    1-2: |c8888FF[BHB]|r Ash Titan (boss1) value: 924541 max: 924541 effectiveMax: 924541
    1-3: |c8888FF[BHB]|r Lady Belain (boss1) value: 1056619 max: 1056619 effectiveMax: 1056619
    1-4: |c8888FF[BHB]|r Zhaj'hassa the Forgotten (boss1) value: 1215111 max: 1215111 effectiveMax: 1215111
    1-5: |c8888FF[BHB]|r Tho'at Replicanum (boss1) value: 2273381 max: 2273381 effectiveMax: 2273381

    2-1: |c8888FF[BHB]|r Allene Pellingare (boss1) value: 1109450 max: 1109450 effectiveMax: 1109450
    2-2: |c8888FF[BHB]|r Limenauruus (boss1) value: 1294357 max: 1294357 effectiveMax: 1294357
    2-3: |c8888FF[BHB]|r Sentinel Aksalaz (boss1) value: 1479267 max: 1479267 effectiveMax: 1479267
        atro indrid nereid
    2-4-1: start 1&2 wave with 1 fabled
    2-4: |c8888FF[BHB]|r Baron Zaudrus (boss1) value: 1701155 max: 1701155 effectiveMax: 1701155
    2-5: |c8888FF[BHB]|r Tho'at Replicanum (boss1) value: 2273381 max: 2273381 effectiveMax: 2273381

        3-1-1: back to only wave 1 with 1 fabled
    3-1: |c8888FF[BHB]|r Queen of the Reef (boss1) value: 1981160 max: 1981160 effectiveMax: 1981160
    3-2: |c8888FF[BHB]|r High Kinlord Rilis (boss1) value: 2311353 max: 2311353 effectiveMax: 2311353
    3-3: |c8888FF[BHB]|r Rada al-Saran (boss1) value: 2641548 max: 2641548 effectiveMax: 2641548
        3-4-1: wave 1: 1; wave 3: 2
    3-4: |c8888FF[BHB]|r Yolnahkriin (boss1) value: 3493445 max: 3493445 effectiveMax: 3493445
    3-5: |c8888FF[BHB]|r Tho'at Replicanum (boss1) value: 2273381 max: 2273381 effectiveMax: 2273381
]]
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
}

---------------------------------------------------------------------
-- Separate from the other files
BHB.eaThresholds = endlessArchiveThresholds

---------------------------------------------------------------------
-- Copying into the same struct to allow better file splitting
for k, v in pairs(eaAliases) do
    BHB.aliases[k] = v
end
