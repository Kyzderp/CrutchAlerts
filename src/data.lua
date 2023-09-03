CrutchAlerts = CrutchAlerts or {}
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

-- Enemies
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
    [170830] = function(hitValue) return hitValue == 1000 end, -- Petrify (1 second cast, and the 11 second channel)
}


---------------------------------------------------------------------
-- Some abilities show up as immediately "stopped" even though they're not interruptible
Crutch.uninterruptible = {
    [184540] = true, -- Chain Pull (Exarchanic Yaseyla)
}

---------------------------------------------------------------------
-- Needs testing
Crutch.testing = {
    -- [ 54027] = true, -- Divine Leap (initial hitValue shows 1500 which is the cast)

    -- [ 26770] = true, -- Resurrect

    -- [88887] = true, -- Icy Escape
    -- [88892] = true, -- Icy Escape
    -- [103321] = true, -- Icy Escape

    -- [112889] = true, -- sigil
    -- [112900] = true, -- sigil
    -- [112908] = true, -- sigil
    -- [112871] = true, -- sigil

    -- [52790] = true, -- Taunt Counter
    -- [52788] = true, -- Taunt Immunity
    -- [38541] = true, -- Taunt (self?)

    -- [86774] = true, -- Mudball
    -- [89372] = true, -- Pelted!
    -- [116879] = true, -- Alliance Pie (EP?)
    -- [118833] = true, -- Piessive (EP?)

    -- [40195] = true, -- camo hunter

    -- [163359] = true, -- Aura of Pride (on self when wearing Spaulder)
    -- [163401] = true, -- Aura of Pride (on other person when self wearing Spaulder)

    [133045] = true, -- Dragon Totem
    [133510] = true, -- Harpy Totem
    [133513] = true, -- Gargoyle Totem
    [133515] = true, -- Chaurus Totem

    -- [57470] = true, -- Grip of Lorkhaj projectile?
    -- [57513] = true, -- Grip of Lorkhaj effect?
    -- [57525] = true, -- Jone's Blessing

    [58084] = true, -- Magicka Bomb
    -- [165021] = true, -- Jet (Numirril)
    -- [163676] = true, -- Jet (Numirril)

    [170188] = true, -- Cascading Boot
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
-- Show when the target is anyone
-- TODO: show only when in the zone
-- TODO: check being in a trial but without a group - remove it from others events instead of all?
Crutch.others = {
-- Sunspire
    [121833] = true, [121849] = true, [115587] = true, [123042] = true, --Wing Thrash
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

-- Kyne's Aegis
    [132511] = true, -- Toxic Tide
    [133515] = true, -- Chaurus Totem
    [132468] = true, -- Sanguine Prison
    [135991] = true, -- Toppling Blow (Storm Twin)
    [133936] = true, -- Exploding Spear
    [136965] = true, -- Sanguine Grasp

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

--Sanctum Ophidia
    [56857] = true, -- Emerald Eclipse (Serpent)
    [54125] = true, -- Quake (Mantikora)
    [52442] = true, -- Leaping Crush
    [52447] = true, -- Ground Slam
    [57839] = true, [57861] = true, -- Trapping Bolts (Ozara)
    [56324] = true, -- Spear (Mantikora)
    [53786] = true, -- Poison Mist

--Hel Ra Citadel
    [47975] = true, -- Shield Throw
    [48267] = true, -- Shield Throw

--Aetherian Archive
    --300
    [47898] = true, -- Lightning Storm (Storm Atronach)
    [49583] = true, -- Impending Storm (Storm Atronach)
    [48240] = true, -- Boulder Storm (Stone Atronach)

    --200
    [49506] = true, [49508] = true, [49669] = true, --Conjure Axe (Celestial Mage)

    --100
    [49098]=true,--Big Quake (Stone Atronach)

--Dragonstar Arena
    [52041] = true, -- Blink Strike (Arena 9)
    [55442] = true, -- Heat Wave
    [52773] = true, -- Ice Comet
    [12459] = true, -- Winter's Reach (Regulated Frost mage)
    [54411] = true, -- Celestial Blast (Shadowcaster)
    [91937] = true, -- Burst of Embers (Daedroth)
    [54841] = true, -- Ice Charge (Dwarven Ice Centurion)

--Maelstrom Arena
    --100
    [72057] = true, -- Portal Spawn
    [68011] = true, -- Web Up Artifact
    [70723] = true, -- Rupturing Fog
    [72446] = true, -- Smash Iceberg

--Maw of Lorkhaj
    [ 73700] = true, -- Eclipse Field
    [ 73291] = true, -- Dark Fissure (Zhaj'hassa pillar)
    [ 74035] = true, -- Darkness Falls
    [ 73741] = true, -- Threshing Wings
    [ 74488] = true, -- Unstable Void (Rakkhat)
    [ 74384] = true, -- Dark Barrage (initial)
    [ 74385] = true, -- Dark Barrage (start)

-- Halls of Fabrication
    [ 90499] = true, -- Reclaim the Ruined (Adds spawn)
    [ 90876] = true, -- Direct Current (Pinnacle Factotum interruptible)
    [ 91454] = true, -- Stomp (Assembly General)
    [ 91781] = true, -- Lightning Spear (Pinnacle Factotum conduit)
    [ 94736] = true, -- Overheating Aura (Reducer)
    [ 94757] = true, -- Overloading Aura (Reactor)
    [ 91019] = true, -- Phase 1.1 (Assembly General)

-- Rockgrove
    [149089] = true, -- Astral Shield (Sul-Xan Soulweaver)
    -- [157466] = true, -- Soul Remnant (Sul-Xan Soulweaver) too spammy

    [149316] = true, -- Emblazoned Stomp (Havocrel Butcher)

    [152496] = true, -- Taking Aim on self (Sul-Xan Bloodseeker / Basks-In-Snakes)
    [157248] = true, -- Taking Aim on player (Sul-Xan Bloodseeker)

    [157267] = true, -- Lash (Giant Snake cleave)

    [149414] = true, -- Savage Blitz (Oaxiltso)
    [152688] = true, -- Cinder Cleave (Havocrel Annihilator)

    [152463] = true, -- Skull Salvo (Flame-Herald Bahsei)
    [150008] = true, -- Hemorrhaging Smack (Flesh Abomination)
    [153175] = true, -- Scalding Strike (Fire Behemoth)

    [157482] = true, -- Molten Rain (Ash Titan)
    [152414] = true, -- Meteor Call (Havocrel Torchcaster)

-- Sanity's Edge
    [200544] = true, -- Charge (Wamasu during trash)
    [191133] = true, -- Charge (Wamasu during boss?)
    [183855] = true, -- The Ritual (Ansuul maze)
    [184802] = true, -- True Shot (Contramagis Archer)

---------------------------------------------------------------------
-- Dungeons

-- Fang Lair
    [ 98597] = true, -- Haunting Spectre (Sabina)
    [102615] = true, -- Spectral Chains (Sabina)

-- Wayrest Sewers
    [  5699] = true, -- Shadowstep (Allene Pellingare)

-- Frostvault
    [113465] = true, -- Reckless Charge (Warlord Tzogvin)

-- Elden Hollow
    [  9944] = true, -- Necrotic Burst (Canonreeve Oraneth)

-- The Cauldron
    [146314] = true, -- Execute (Taskmaster Viccia interruptible "oneshot" but is blockable)
    [146179] = true, -- Galvanic Blow (Baron Zaudrus conal that applies Galvanic Burst)

-- Red Petal Bastion
    [157573] = true, -- Dire Gaze (watcher interruptible)
    [154369] = true, -- Opalescent Impale

-- The Dread Cellar
    [156509] = true, -- Deluge of Pain (Scorion Broodlord interruptible)

-- Shipwright's Regret
    [163676] = true, -- Jet (Numirril when he jets to a player)
    [165021] = true, -- Jet (Numirril when he jets away)
    [167906] = true, -- Jet (Numirril when he jets to the edge to go into immune phase)

-- Coral Aerie
    [168947] = true, -- Lingering Current

-- Scrivener's Hall
    [182334] = true, -- Rain of Fire (Valinna)
    [182393] = true, -- Immolation Trap (Valinna)

-- Graven Deep
    [171935] = true, -- Necrotic Rain (Varzunon)

-- Earthen Root Enclave
    [170830] = true, -- Petrify (1 second cast, and the 11 second channel)
    -- [172147] = true, -- Chin Shatter
    -- [171742] = true, -- Boughroot Slash
    -- [170868] = true, -- Crumble (only human form)
    [172410] = true, -- Crumble (Archdruid Devyric rock pillar things)
    [171127] = true, -- Guttural Roar (5 seconds channel of the cone probably)
    [170650] = true, -- Wild Stampede (Static Stampede, GAINED / DURATION tho)
    [116859] = true, -- Crush (Monstrous Bear)

---------------------------------------------------------------------
-- Overland

-- The Deadlands
    [154246] = true, -- Bloodstream (Havocrels)
}
