local Crutch = CrutchAlerts

-- Also see format.lua for formatting, damageable.lua for boss timer data, and prominent.lua for prominent alerts data

-- true = ignore
-- false = needs testing
---------------------------------------------------------------------
-- Blacklist
-- TODO: separate into self-sourced and enemy blacklists
-- TODO: wtf is this??? [17:00:09] Interrupted (0): Off-Balance Exploit(44364) on (15536) HitValue 0 Type NONE Result STUNNED
Crutch.blacklist = {
-- Self-sourced
    [ 37059] = true, -- Mount Up
    [103706] = true, -- Channeled Acceleration
    [ 23316] = true, -- Summon Volatile Familiar
    [ 23319] = true, -- Summon Unstable Clannfear
    [ 24636] = true, -- Summon Twilight Tormentor
    [ 87875] = true, -- Betty Netch
    [ 86103] = true, -- Bull Netch
    [ 26114] = true, -- Puncturing Strikes
    [ 26792] = true, -- Biting Jabs
    [ 26797] = true, -- Puncturing Sweep
    [ 31816] = true, -- Stone Giant
    [ 59525] = true, -- Arcane Engine Guardian
    [ 59539] = true, -- Robust Engine Guardian
    [ 59541] = true, -- Healthy Engine Guardian
    [ 32986] = true, -- Mist Form
    [ 38965] = true, -- Blood Mist
    [ 38963] = true, -- Elusive Mist
    [103492] = true, -- Meditate
    [103652] = true, -- Deep Thoughts
    [103665] = true, -- Introspection
    [115721] = true, -- Spirit Mender Reconstitute
    [118914] = true, -- Spirit Guardian Reconstitute
    [118851] = true, -- Intensive Mender Reconstitute

    [185805] = true, -- Fatecarver (cost mag)
    [193331] = true, -- Fatecarver (cost stam)
    [183122] = true, -- Exhausting Fatecarver (cost mag)
    [193397] = true, -- Exhausting Fatecarver (cost stam)
    [186366] = true, -- Pragmatic Fatecarver (cost mag)
    [193398] = true, -- Pragmatic Fatecarver (cost stam)
    [183537] = true, -- Remedy Cascade (cost mag)
    [198309] = true, -- Remedy Cascade (cost stam)
    [186193] = true, -- Cascading Fortune (cost mag)
    [198330] = true, -- Cascading Fortune (cost stam)
    [186200] = true, -- Curative Surge (cost mag)
    [198537] = true, -- Curative Surge (cost stam)

-- Other player-sourced
    [107579] = true, -- Mend Wounds
    [107630] = true, -- Mend Spirit
    [107637] = true, -- Symbiosis

-- Enemies general
    [ 10845] = true, -- Run Away!
    [ 45508] = true, -- Passing Through (assassin jumpflip)
    [ 25926] = true, -- Flare (Flame Atronach) TODO: tank mode?
    [113195] = true, -- Ice Bolt (Ghost) in BRP
    [163335] = true, -- Soul Draining (Harrowing Haunter) in SR
    [158363] = true, -- Roll (Ascendant Pursuer / Sarydil) in CA
    [158365] = true, -- Dodge (Ascendant Pursuer / Sarydil) in CA

    [ 74388] = true, -- Dark Barrage
    [ 74389] = true, -- Dark Barrage
    [ 74390] = true, -- Dark Barrage
    [ 74391] = true, -- Dark Barrage
    [ 74392] = true, -- Dark Barrage
    [ 75965] = true, -- Dark Barrage
    [ 75966] = true, -- Dark Barrage
    [ 75967] = true, -- Dark Barrage
    [ 75968] = true, -- Dark Barrage
    [ 78015] = true, -- Dark Barrage

-- Trials
    [116584] = true, -- Frigid Cold (Lokk)
    -- [123660] = true, -- Storm Bound

-- Dungeons
    [229256] = true, -- Forbidden Knowledge (GAINED)
    [241678] = true, -- Fluctuating Esseence YEL [sic]
}


---------------------------------------------------------------------
-- For specific abilities, some filters are required. Return true to show, false to skip
Crutch.filter = {
    [ 73741] = function(hitValue, targetUnitTag) return hitValue >= 1900 and Crutch.GetUnitTagsDistance("player", targetUnitTag) <= 30 end, -- Threshing Wings (only get the initial cast, not the weird other parts that are cast on everyone)
    [ 74488] = function(hitValue, targetUnitTag) return Crutch.GetUnitTagsDistance("player", targetUnitTag) <= 30 end, -- Unstable Void (Rakkhat)
    [ 74384] = function(hitValue, targetUnitTag) return Crutch.GetUnitTagsDistance("player", targetUnitTag) <= 30 end, -- Dark Barrage (initial)
    [ 74385] = function(hitValue, targetUnitTag) return Crutch.GetUnitTagsDistance("player", targetUnitTag) <= 30 end, -- Dark Barrage (start)
    [103946] = function(hitValue) return hitValue >= 2500 end, -- Shadow Realm Cast (only initial cast)
    [105291] = function(hitValue) return hitValue >= 1250 end, -- SUM Shadow Beads (only initial cast)
    [105380] = function(hitValue) return hitValue >= 2000 and not Crutch.IsInShadowWorld() end, -- Direct Current (Relequen, only after he actually starts channeling, not the 250ms cast time)
    [106405] = function(hitValue) return not Crutch.IsInShadowWorld() end, -- Glacial Spikes (Galenwe)
    [121422] = function(hitValue) return hitValue >= 1800 and Crutch.IsInNahvPortal() end, -- Sundering Gale (Eternal Servant, only display if self is in portal)
    [133936] = function(hitValue) return hitValue > 1 end, -- Exploding Spear
    [168947] = function(hitValue) return hitValue == 1300 end, -- Coral Aerie Ofallo Lingering Current
    [170830] = function(hitValue) return hitValue == 1000 end, -- Petrify (ERE; 1 second cast, and the 11 second channel)
    [192013] = function(hitValue) return hitValue <= 5000 end, -- Splintering Mirror (Tho'at) otherwise there's a really long one
    [196251] = function(hitValue) return hitValue == 3000 end, -- Enervating Sheen (EA; Nerien'eth) there's a BEGIN cast, and then an 8000 DURATION when it hits
    [192024] = function(hitValue) return hitValue > 2400 end, -- Glass Sky (Tho'at Shard (Mantikora))
    [192641] = function(hitValue) return hitValue > 1900 end, -- Paralyzing STomp [sic] (Death's Leviathan) 2000 for initial, extra 1900 after
    [202374] = function(hitValue) return hitValue > 1500 end, -- Pound (Bone Colossus) 2300 for initial, then does an extra 1500 after
    [215107] = function(hitValue) return hitValue == 1200 end, -- Tempest (Xoryn) want it as soon as he casts, not after the cast when gained duration
    [227461] = function(hitValue) return hitValue == 1233 end, -- Ram (Marauder Zulfimbul) -- BEGIN timer is 1233, but DUR 10000. Only use BEGIN
    [ 56857] = function(hitValue) return hitValue == 4000 end, -- Emerald Eclipse (Serpent) -- BEGIN is 1400 before 4000 DUR
    [246168] = function(hitValue) return hitValue == 500 end, -- Acute Enervation (initial targeting of first, for some reason is 500 then 2800, but then not another ~1s until the real cast)
}


---------------------------------------------------------------------
-- Some abilities show up as immediately "stopped" even though they're not interruptible
-- Or sometimes get "interrupted" for some reason?
Crutch.uninterruptible = {
    [184540] = true, -- Chain Pull (Exarchanic Yaseyla)
    [ 94736] = true, -- Overheating Aura (Reducer)
    [ 94757] = true, -- Overloading Aura (Reactor)
    [ 91019] = true, -- Phase 1.1 (Assembly General)
    [192024] = true, -- Glass Sky (Tho'at Shard (Mantikora)) this could be interrupted when it dies, but I'd rather not have the timer disappear
    -- [ 73250] = true, -- Shattered in MoL -- idr why I made this uninterruptible?
    [203989] = true, -- Hurl Axe (Anthelmir's Construct)
    [ 96826] = true, -- Impaling Shards (Thurvokun)
    [226600] = true, -- Noxious Boulder (Garvin the Tracker)
    [231801] = true, -- Spring (Noriwen)
    [233598] = true, -- Spark Smash (Jynorah)
    [233610] = true, -- Blazing Smash (Skorkhif)
    [157466] = true, -- Soul Remnant
}

---------------------------------------------------------------------
-- Needs testing
Crutch.testing = {
    [133045] = true, -- Dragon Totem
    [133510] = true, -- Harpy Totem
    [133513] = true, -- Gargoyle Totem
    [133515] = true, -- Chaurus Totem

    [58084] = true, -- Magicka Bomb
    [56782] = true, -- Magicka Bomb, the 11 seconds, not 58084

    [97022] = true, -- Wraith Speed

    [152525] = true, -- Fire Behemoth?

    [155184] = true, -- Catastrophe (Magma Incarnate)

    -- [63029] = true, -- Radiant Destruction
    -- [63044] = true, -- Radiant Glory
    -- [63046] = true, -- Radiant Oppression

    [140606] = true, -- Meteor
    [134023] = true, -- Meteor

    [241685] = true, -- Fluctuating Esseence GRN [sic] (buff Refracted Soul Essence when it turns green maybe)

    [232460] = true, -- Titanic Clash on Valneer
    [232465] = true, -- Titanic Clash on Myrinax

    [119596] = true, -- Storm Breath (80%)
    [122794] = true, -- Storm Breath 2 (50%)
    [122961] = true, -- Storm Breath (20%)

    [240244] = true, -- Rupture 2 Hide (Quarrymaster Saldezaar)
    [240240] = true, -- Rupture
}

---------------------------------------------------------------------
-- Testing stacks of effects
Crutch.stacks = {
    [111783] = true, -- Spirit Energy (Drakeeh absorbed ghosts)
    -- [ 61905] = true, -- Grim Focus
    -- [ 61920] = true, -- Grim Focus
    -- [ 61928] = true, -- Grim Focus
    -- [52790] = true, -- Taunt Counter
}

---------------------------------------------------------------------
-- Don't display chat spam in these zones, self testing purposes
Crutch.noSpamZone = {
    -- [1000] = true, -- Asylum Sanctorium
    -- [1082] = true, -- Blackrose Prison
    -- [1121] = true, -- Sunspire
    -- [1196] = true, -- Kyne's Aegis
}


---------------------------------------------------------------------
-- Normally we don't listen for ACTION_RESULT_GAINED_DURATION, but timers can be useful in some cases
Crutch.gainedDuration = {
-- Cloudrest
    [103555] = true, -- Voltaic Current (initial of barswap)

-- Kyne's Aegis
    [140941] = true, -- Instability
    [140944] = true, -- Instability HM

-- Lucent Citadel
    [218285] = true, -- Gloomy Impact (first one)
    [223331] = true, -- Gloomy Impact (second one)
    [222609] = true, -- Gloomy Impact (Knot)

-- Ossein Cage
    [232773] = true, -- Dominator's Chains (initial cast, 4100)
    [232779] = true, -- Dominator's Chains (after it's gained, 16100)
    [232780] = true, -- Dominator's Chains (after it's gained, 16100)
    -- [237121] = true, -- Daedric Bombardment (Channeler / Pain Channeler) doesn't seem to work right, and doesn't cover all of them
    -- [237163] = true, -- Agonizing Burden (6000)

-- Sanctum Ophidia
    [56782] = true, -- Magicka Bomb, the 11 seconds, not 58084

-- Sunspire
    [116636] = true, -- Chilling Comet (Alkosh's Fate)

-- Frostvault
    [117324] = true, -- Ice Comet (2000) Coldsnap Skysplitter might be the ones on the ledge?
    [117326] = true, -- Ice Comet (3750) Coldsnap Skysplitter

-- Infinite Archive
    -- [222161] = true, -- Meteor (Butcher's Fire Shaman (Yandir))

-- Black Gem Foundry
    -- [241229] = true, -- Imminent Annihilation (Vykand) -- might not show on dead players
    [241224] = true, -- Ominous Vision
}


---------------------------------------------------------------------
-- Show when the target is anyone
-- TODO: show only when in the zone
-- TODO: check being in a trial but without a group - remove it from others events instead of all?
Crutch.others = {
---------------------------------------------------------------------
-- Trials

-- Aetherian Archive
    [47898] = true, -- Lightning Storm (Storm Atronach)
    [49583] = true, -- Impending Storm (Storm Atronach)
    [48240] = true, -- Boulder Storm (Stone Atronach)
    [49506] = true, [49508] = true, [49669] = true, -- Conjure Axe (Celestial Mage)
    [49098] = true, -- Big Quake (Stone Atronach)

-- Asylum Sanctorium
    [ 95545] = true, -- Defiling Dye Blast (Saint Llothis) -- TODO: add the extra pulses
    [ 99027] = true, -- Manifest Wrath
    [ 98582] = true, -- Trial by Fire
    [ 95482] = true, -- Exhaustive Charges

-- Cloudrest
    [103531] = true, -- Roaring Flare
    [110431] = true, -- Roaring Flare (execute 2nd flare)
    [103946] = true, -- Shadow Realm Cast
    [105291] = true, -- SUM Shadow Beads
    [105890] = true, -- Set Start CD of SRealm
    [105016] = true, -- SUM Lrg Tentacle
    [106023] = true, -- ZMaja Break Amulet
    [105673] = true, -- Talon Slice
    [105239] = true, -- Crushing Darkness
    [105380] = true, -- Direct Current (Relequen interruptible)
    [106405] = true, -- Glacial Spikes (Galenwe interruptible)
    [104036] = true, -- Welkynar's Light (synergized with spear)
    [103980] = true, -- Grant Malevolent Core
    [104047] = true, -- Shadow Piercer Exit

-- Halls of Fabrication
    [ 90499] = true, -- Reclaim the Ruined (Adds spawn)
    [ 90876] = true, -- Direct Current (Pinnacle Factotum interruptible)
    [ 91454] = true, -- Stomp (Assembly General)
    [ 91781] = true, -- Lightning Spear (Pinnacle Factotum conduit)
    [ 94736] = true, -- Overheating Aura (Reducer)
    [ 94757] = true, -- Overloading Aura (Reactor)
    [ 91019] = true, -- Phase 1.1 (Assembly General)

-- Hel Ra Citadel
    [47975] = true, -- Shield Throw
    [48267] = true, -- Shield Throw

-- Kyne's Aegis
    [132511] = true, -- Toxic Tide
    [134196] = true, -- Crashing Wave
    [133515] = true, -- Chaurus Totem
    [132468] = true, -- Sanguine Prison
    [135991] = true, -- Toppling Blow (Storm Twin)
    [133936] = true, -- Exploding Spear
    [136965] = true, -- Sanguine Grasp
    [134050] = true, -- Wrath of Tides

-- Lucent Citadel
    [214203] = true, -- Bleak Annihilation
    [214187] = true, -- Brilliant Annihilation
    [214136] = true, -- Fate Sealer
    -- [214311] = true, -- Fate Sealer (first one gained by pillar?)
    -- [214344] = true, -- Fate Sealer (second one gained by pillar?)
    -- [214138] = true, -- Fate Sealer (from logs, maybe full duration?)
    [215107] = true, -- Tempest
    [214355] = true, -- Lightning Flood (Xoryn cone)

-- Maw of Lorkhaj
    [ 73700] = true, -- Eclipse Field
    [ 73291] = true, -- Dark Fissure (Zhaj'hassa pillar)
    [ 74035] = true, -- Darkness Falls
    [ 73741] = true, -- Threshing Wings
    [ 74488] = true, -- Unstable Void (Rakkhat)
    [ 74384] = true, -- Dark Barrage (initial)
    [ 74385] = true, -- Dark Barrage (start)

-- Ossein Cage
    [238800] = true, -- Phantasmal Barrage
    [235201] = true, -- Storm Slam (Molag Kena)
    [232516] = true, -- Jynorah Titanic Clash
    [232517] = true, -- Skorikhif Titanic Clash
    [232397] = true, -- Effluvial Expellant (Shaper of Flesh)
    [233762] = true, -- Abduct

-- Rockgrove
    [149089] = true, -- Astral Shield (Sul-Xan Soulweaver)
    [149316] = true, -- Emblazoned Stomp (Havocrel Butcher)
    [152496] = true, -- Taking Aim on self (Sul-Xan Bloodseeker / Basks-In-Snakes)
    [157248] = true, -- Taking Aim on player (Sul-Xan Bloodseeker)
    [157267] = true, -- Lash (Giant Snake cleave)
    [149414] = true, -- Savage Blitz (Oaxiltso)
    [152688] = true, -- Cinder Cleave (Havocrel Annihilator)
    [152463] = true, -- Skull Salvo (Flame-Herald Bahsei)
    -- [150008] = true, -- Hemorrhaging Smack (Flesh Abomination)
    [153175] = true, -- Scalding Strike (Fire Behemoth)
    [157482] = true, -- Molten Rain (Ash Titan)
    [152414] = true, -- Meteor Call (Havocrel Torchcaster)
    [153517] = true, -- Portal CW
    [153518] = true, -- Portal CCW

-- Sanctum Ophidia
    [56857] = true, -- Emerald Eclipse (Serpent)
    [54125] = true, -- Quake (Mantikora)
    [52987] = true, -- Slam (Mantikora)
    [52442] = true, -- Leaping Crush
    [52447] = true, -- Ground Slam
    [57839] = true, [57861] = true, -- Trapping Bolts (Ozara)
    [56324] = true, -- Spear (Mantikora)
    [53786] = true, -- Poison Mist

-- Sanity's Edge
    [200544] = true, -- Charge (Wamasu during trash)
    [191133] = true, -- Charge (Wamasu during boss?)
    [183855] = true, -- The Ritual (Ansuul maze)
    [184802] = true, -- True Shot (Contramagis Archer)
    [199344] = true, -- Sunburst (Ansuul)
    -- [183778] = true, -- Inferno (Enraged Fragment) TODO: see if I can receive the interrupts, otherwise it's not useful

-- Sunspire
    [121833] = true, [121849] = true, [115587] = true, [123042] = true, -- Wing Thrash
    [122012] = true, -- Storm Crush (Gale-Claw)
    [120890] = true, -- Crush (Fire-Fang)
    [122309] = true, -- Flaming Bat
    [116836] = true, -- Storm Leap
    [119549] = true, -- Emberstorm
    [121723] = true, -- Fire Breath
    [121722] = true, -- Focus Fire
    [122216] = true, -- Blast Furnace
    [119283] = true, -- Frost Breath
    [121980] = true, -- Searing Breath
    [121676] = true, -- Time Shift
    [121271] = true, -- Lightning Storm
    [121411] = true, -- Negate Field
    [121436] = true, -- Translation Apocalypse
    [120359] = true, -- Relentless Gale (Lokkestiiz)
    [120783] = true, -- Hail of Stone (Vigil Statue) - starts with a 3 second cast and then becomes 17 seconds
    [115702] = true, -- Storm Fury
    [118562] = true, -- Thrash
    [121422] = true, -- Sundering Gale
    [122598] = true, -- Cataclysm


---------------------------------------------------------------------
-- Arenas

-- Blackrose Prison
    [111283] = true, -- Tremors (Imperial Cleaver)
    [114629] = true, -- Void (Drakeeh)
    [114447] = true, -- Haunting Spectre (Soul of Void)
    [114453] = true, -- Chill Spear
    [111659] = true, -- Bat Swarm
    [ 71787] = true, -- Impending Storm
    [113208] = true, -- Shockwave
    [110181] = true, -- Bug Bomb
    [114443] = true, -- Stone Totem (short timer)
    [114803] = true, -- Defiling Eruption
    [111315] = true, -- Summon Troll
    [111329] = true, -- Summon Wamasu
    [111332] = true, -- Summon Haj Mota
    [114213] = true, -- Summon Infuser
    [114223] = true, [114230] = true, [114236] = true, -- Summon Colossus

-- Dragonstar Arena
    [52041] = true, -- Blink Strike (Arena 9)
    [55442] = true, -- Heat Wave
    [52773] = true, -- Ice Comet
    [12459] = true, -- Winter's Reach (Regulated Frost mage)
    [54411] = true, -- Celestial Blast (Shadowcaster)
    [91937] = true, -- Burst of Embers (Daedroth)
    [54841] = true, -- Ice Charge (Dwarven Ice Centurion)

-- Infinite Archive
    [192013] = true, -- Splintering Mirror (Tho'at Replicanum)
    [192024] = true, -- Glass Sky (Tho'at Shard (Mantikora))
    [210841] = true, -- Crashing Wave (Marauder Ulmor)
    [210830] = true, -- Fulmination II (Marauder Ulmor)
    [195816] = true, -- Poison Bolt (Selene) TODO
    [192641] = true, -- Paralyzing STomp [sic] (Death's Leviathan)
    [196848] = true, -- Mundus Breach (Silver Rose Realmshaper) it hurts a LOT in later arcs
    [202374] = true, -- Pound (Bone Colossus) really need to block in later arcs
    [193530] = true, -- Befouled Air (Old Snagara) poison aoe
    [196251] = true, -- Enervating Sheen (Nerien'eth) does it need to be shielded?
    [197002] = true, -- Stormfront (Storm Atronach)
    [196959] = true, -- Crush (Iron Atronach)
    [195448] = true, -- Wing Burst (Ash Titan)
    [203006] = true, -- Thrash (Bristleback)
    [227772] = true, -- Scaling (Meteor) -- Scaling is just the buff that it gets, so use it to detect the spawn
    [227461] = true, -- Ram (Marauder Zulfimbul) -- BEGIN timer is 1233, but DUR 10000. Only use BEGIN
    [192517] = true, -- Seeking Spheres (Tho'at Shard)
    [223685] = true, -- Hoarfrost Fist (Frost Atronach)
    [223378] = true, -- Rending Leap (Clannfear)
    [198099] = true, -- Blood Dive (Lady Thorn)
    [222156] = true, -- Meteor (Butcher's Fire Shaman (Yandir))

-- Maelstrom Arena
    [72057] = true, -- Portal Spawn
    [68011] = true, -- Web Up Artifact
    [70723] = true, -- Rupturing Fog
    [72446] = true, -- Smash Iceberg
    [68194] = true, -- Necrotic Orb (timer for followy-thingy)
    [75281] = true, -- Soul Tether (Dremora Kynlurker)


---------------------------------------------------------------------
-- Dungeons

-- Bedlam Veil
    [206488] = true, -- Glass Stomp (Shattered Champion)
    [207005] = true, -- Malediction (The Blind)

-- Black Gem Foundry
    [240426] = true, -- Seismic Splinters
    [240363] = true, -- Soul Focus (Black Gem Monstrosity, initial 2750 begin, then 7000 begin)
    [241854] = true, -- Soulbinding Slam (High Soulbinder Vykand)
    [241863] = true, -- Soul Cascade (Vykand)
    [241685] = true, -- Fluctuating Esseence GRN [sic] (3000 when the fountains become green)
    [241326] = true, -- Annihilation
    [241327] = true, -- Annihilation
    [241328] = true, -- Annihilation
    [241329] = true, -- Annihilation
    [240665] = true, -- Charged Lightning?
    [246168] = true, -- Acute Enervation (initial targeting of first, for some reason is 500 then 2800, but then not another ~1s until the real cast)

-- Coral Aerie
    [168947] = true, -- Lingering Current

-- Earthen Root Enclave
    [170830] = true, -- Petrify (1 second cast, and the 11 second channel)
    [172410] = true, -- Crumble (Archdruid Devyric rock pillar things)
    [171127] = true, -- Guttural Roar (5 seconds channel of the cone probably)
    [170650] = true, -- Wild Stampede (Static Stampede, GAINED / DURATION tho)
    [116859] = true, -- Crush (Monstrous Bear)

-- Elden Hollow
    [  9944] = true, -- Necrotic Burst (Canonreeve Oraneth)

-- Exiled Redoubt
    [224463] = true, -- Summon Fire Atro (Squall, first one)
    [230349] = true, -- Summon Fire Atro (Squall, next 3)
    [224473] = true, -- Summon Ice Atro (Squall, first)
    [230383] = true, -- Summon Ice Atro (Squall, second)
    [224476] = true, -- Summon Shock Atro (Squall, first)
    [230386] = true, -- Summon Shock Atro (Squall, second)
    [223935] = true, -- Six Sword Assault (Squall)

-- Fang Lair
    [ 98597] = true, -- Haunting Spectre (Sabina)
    [102615] = true, -- Spectral Chains (Sabina)
    [ 97022] = true, -- Wraith Speed
    [ 96826] = true, -- Impaling Shards (Thurvokun)

-- Frostvault
    [113465] = true, -- Reckless Charge (Warlord Tzogvin)

-- Graven Deep
    [171935] = true, -- Necrotic Rain (Varzunon)

-- Lep Seclusa
    [226181] = true, -- Venom Eruption (Garvin the Tracker)
    [229247] = true, -- Forbidden Knowledge (Orpheon the Tactician)
    [233821] = true, -- Cyclone (Flame Gryphon)
    [109231] = true, -- Bog Slam (Argonian Behemoth)
    [224822] = true, -- Blast Powder (Noriwen)

-- Oathsworn Pit
    [203989] = true, -- Hurl Axe (Anthelmir's Construct)

-- Red Petal Bastion
    [157573] = true, -- Dire Gaze (watcher interruptible)
    [154369] = true, -- Opalescent Impale

-- Scrivener's Hall
    [182334] = true, -- Rain of Fire (Valinna)
    [182393] = true, -- Immolation Trap (Valinna)

-- Shipwright's Regret
    [163676] = true, -- Jet (Numirril when he jets to a player)
    [165021] = true, -- Jet (Numirril when he jets away)
    [167906] = true, -- Jet (Numirril when he jets to the edge to go into immune phase)

-- The Cauldron
    [146314] = true, -- Execute (Taskmaster Viccia interruptible "oneshot" but is blockable)
    [146179] = true, -- Galvanic Blow (Baron Zaudrus conal that applies Galvanic Burst)

-- The Dread Cellar
    [156509] = true, -- Deluge of Pain (Scorion Broodlord interruptible)
    [155184] = true, -- Catastrophe (Magma Incarnate)

-- Wayrest Sewers
    [  5699] = true, -- Shadowstep (Allene Pellingare)


---------------------------------------------------------------------
-- Overland

-- The Deadlands
    [154246] = true, -- Bloodstream (Havocrels)
}
