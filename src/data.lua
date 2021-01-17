CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

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
    [ 26792] = true, -- Biting Jabs
    [ 26797] = true, -- Puncturing Sweep
    [ 31816] = true, -- Stone Giant

-- Other player-sourced
    [107579] = true, -- Mend Wounds
    [107630] = true, -- Mend Spirit
    [107637] = true, -- Symbiosis

-- Enemies
    [ 45508] = true, -- Passing Through (assassin jumpflip)
    [ 25926] = true, -- Flare (Flame Atronach) TODO: tank mode?
    [113195] = true, -- Ice Bolt (Ghost) in BRP
}


---------------------------------------------------------------------
-- Needs testing
Crutch.testing = {
    -- [ 54027] = true, -- Divine Leap (initial hitValue shows 1500 which is the cast)
    -- [102027] = true, -- Caluurion Fire
    -- [102032] = true, -- Caluurion Frost
    -- [102033] = true, -- Caluurion Disease
    -- [102034] = true, -- Caluurion Shock

    -- [ 26770] = true, -- Resurrect

    -- [142318] = true, -- Sanguine Burst (Lady Thorn Synergy)
    -- [88887] = true, -- Icy Escape
    -- [88892] = true, -- Icy Escape
    -- [103321] = true, -- Icy Escape

    -- [112889] = true, -- sigil
    -- [112900] = true, -- sigil
    -- [112908] = true, -- sigil
    -- [112871] = true, -- sigil
}


---------------------------------------------------------------------
-- Don't display chat spam in these zones
Crutch.noSpamZone = {
    [1000] = true, -- Asylum Sanctorium
    [1082] = true, -- Blackrose Prison
}


---------------------------------------------------------------------
-- Show when the target is other people too
-- TODO: show only when in the zone
-- TODO: check being in a trial but without a group - remove it from others events instead of all?
Crutch.others = {
-- Sunspire
    [121833] = true, [121849] = true, [115587] = true, [123042] = true,--Wing Thrash
    [122012] = true, -- Storm Crush (Gale-Claw)
    [120890] = true, -- Crush (Fire-Fang)
    [122309] = true, -- Flaming Bat
    [119549] = true, -- Emberstorm
    [121723] = true, -- Fire Breath
    [121722] = true, -- Focus Fire
    [120505] = true,--Meteor
    [122216] = true,--Blast Furnace
    [119283] = true, -- Frost Breath
    [121980] = true, -- Searing Breath
    [121676] = true,--Time Shift
    [121271] = true,--Lightning Storm
    [121411] = true, -- Negate Field
    [121436] = true, -- Translation Apocalypse

    --200
    [114085] = true,--Frost Atro Init

    --300
    [115702] = true,--Storm Fury   Effect:115858
    [119632] = true,--Frozen Tomb
    [118562] = true,--Thrash
    [118743] = true, [120188] = true,--Sweeping Breath

-- Kyne's Aegis
    [132468] = true, -- Sanguine Prison
    [135991] = true, -- Toppling Blow (Storm Twin)

-- Asylum Sanctorium
    --300
    [ 15954] = true,--Ordinated Protector
    [ 95545] = true,--Defiling Dye Blast (Saint Llothis) -- TODO: add the extra pulses
    [ 99027] = true,--Manifest Wrath (Saint Felms the Bold)

    --100
    -- [ 95585] = true,--Soul Stained Corruption
    [ 98582] = true,--Trial by Fire

-- Cloudrest
    --300
    [103531]=true,[110431]=true,--Roaring Flare

    --200
    [105890]=true,--Set Start CD of SRealm
    [105016]=true,--SUM Lrg Tentacle
    [106023]=true,--ZMaja Break Amulet

    --100
    [103946]=true,--Shadow Realm Cast
    [105291]=true,--SUM Shadow Beads

    --true
    [106374]=true,--Chilling Comet
    [105120]=true,--SotDead Proj to Corpse
    [105673]=true,--Talon Slice
    -- [107082]=true,--Baneful Mark
    -- [107196]=true,--Shade Baneful Mark

-- Blackrose Prison
    [111283] = true, -- Tremors (Imperial Cleaver) TODO: timer?
    [114629] = true, -- Void (Drakeeh)
    --300
    [114453]=true,--Chill Spear  [114455]=true,
    --100
    [111659]=true,--Bat Swarm
    [114578]=true,--Portal Spawn
    [ 71787]=true,--Impending Storm
    [113208]=true,--Shockwave
    [110181]=true,--Bug Bomb
    [114443]=true,--Stone Totem
    [114803]=true,--Defiling Eruption
    [111315]=true,--Summon Troll
    [111329]=true,--Summon Wamasu
    [111332]=true,--Summon Haj Mota
    [114213]=true,--Summon Infuser
    [114223]=true,[114230]=true,[114236]=true,--Summon Colossus

--Sanctum Ophidia
    --300
    [56857]=true,--Emerald Eclipse (Serpent)
    [54125]=true,--Quake (Mantikora)
    [52442]=true,--Leaping Crush
    [52447]=true,--Ground Slam
    [57839]=true,[57861]=true,--Trapping Bolts (Ozara)

    --100
    [56324]=true,--Spear (Mantikora)
    [53786]=true,--Poison Mist

    --Custom true
    -- [58218]=14,--Overcharge (Overcharger) TODO
    -- [79390]=10,--Call Lightning (Overcharger) TODO

--Hel Ra
    --300
    [47975]=true,[48267]=true,--Shield Throw

--Aetherian Archive
    --300
    [47898]=true,--Lightning Storm (Storm Atronach)
    [48240]=true,--Boulder Storm (Stone Atronach)
    [49583]=true,--Impending Storm (Storm Atronach)

    --200
    [49506]=true,[49508]=true,[49669]=true,--Conjure Axe (Celestial Mage)

    --100
    [49098]=true,--Big Quake (Stone Atronach)

--Dragonstar Arena
    --300
    [52041]=true,--Blink Strike (Arena 9)
    [55442]=true,--Heat Wave
    [52773]=true,--Ice Comet
    [ 12459] = true, -- Winter's Reach (Regulated Frost mage)

--Maelstrom Arena
    --100
    [72057]=true,--Portal Spawn
    --[15954]=100,--Boss (Clockwork Sentry)
    [68011]=true,--Web Up Artifact
    [70723]=true,--Rupturing Fog

--Maw of Lorkhaj
    [ 73700] = true, -- Eclipse Field
    --300
    [74035]=true,--Darkness Falls
    [73741]=true,--Threshing Wings

    --Custom true
    [74488]=true,--Unstable Void (Rakkhat)
    [74384]=true,[74385]=true,[74388]=true,[74390]=true,[74391]=true,[74392]=true,[75965]=true,[75966]=true,[75967]=true,[75968]=true,[78015]=true,[74389]=true,--Dark Barrage

--Halls of Fabrication
    [ 90499] = true, -- Fabricant Spawn
    [ 90876] = true, -- Direct Current (Pinnacle Factotum interruptible)
    [ 91454] = true, -- Stomp (Assembly General)
    --300
    [91781]=true,--Conduit Spawn

    --200
    [90715]=true,--Reclaimer Overcharge
}