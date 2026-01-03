local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- DingIA Result   Type  HideTimer  Color  Timer
-- 0      0        0     1          1      07.5
-- 0001107.5
-- 
-- DingIA: 0 = no ding, 1 = Uppercut/Power Bash ding in IA only, 2 = ding in IA only
-- Result: 0 = any, 1 = BEGIN only, 2 = GAINED only, 3 = NOT DURATION
-- Type: 0 = normal alert, 1 = secondary, 2 = prevent overwrite, 3 = always display even if already displaying (show multiple)
-- HideTimer: 0 = false, 1 = true
-- Color: 0 = white, 1 = ...
-- Timer: actual number, or 0 for auto detect

Crutch.format = {
-- Arcanist
    [185805] = 700, -- Fatecarver (cost mag)
    [193331] = 700, -- Fatecarver (cost stam)
    [183122] = 700, -- Exhausting Fatecarver (cost mag)
    [193397] = 700, -- Exhausting Fatecarver (cost stam)
    [186366] = 700, -- Pragmatic Fatecarver (cost mag)
    [193398] = 700, -- Pragmatic Fatecarver (cost stam)
    [183537] = 700, -- Remedy Cascade (cost mag)
    [198309] = 700, -- Remedy Cascade (cost stam)
    [186193] = 700, -- Cascading Fortune (cost mag)
    [198330] = 700, -- Cascading Fortune (cost stam)
    [186200] = 700, -- Curative Surge (cost mag)
    [198537] = 700, -- Curative Surge (cost stam)

-- Templar
    [63029] = 900, -- Radiant Destruction
    [63044] = 900, -- Radiant Glory
    [63046] = 900, -- Radiant Oppression

---------------------------------------------------------------------
-- Trials

-- Aetherian Archive
    [ 47898] = 10, -- Lightning Storm (Storm Atronach)
    [ 48240] = 10, -- Boulder Storm (Stone Atronach)
    [ 49098] = 10, -- Big Quake (Stone Atronach)

-- Asylum Sanctorium
    [ 95545] =  20206.2, -- Defiling Dye Blast (Saint Llothis)

-- Cloudrest
    [103531] = 100107, -- Roaring Flare
    [110431] = 100107, -- Roaring Flare
    [105239] = 200010, -- Crushing Darkness
    [103555] =    400, -- Voltaic Current (initial of barswap)
    [104019] =  31003, -- Olorime Spears
    [103946] =    500, -- Shadow Realm Cast
    [105291] =    600, -- SUM Shadow Beads

-- Dreadsail Reef
    [163987] = 500, -- Coral Slam

-- Halls of Fabrication
    [ 91019] = 430, -- Phase 1.1 (Assembly General)
    [ 94736] = 500, -- Overheating Aura (Reducer)
    [ 94757] = 500, -- Overloading Aura (Reactor)

-- Kyne's Aegis
    [133515] = 100204.5, -- Chaurus Totem seems to send out first projectile ~4.5 seconds after spawn
    [134050] =  30400, -- Wrath of Tides
    [134196] =    500, -- Crashing Wave
    [140606] =    100, -- Meteor (Yandir)
    [134023] =    100, -- Meteor (Vrol)
    [140941] =    400, -- Instability
    [140944] =    400, -- Instability (HM)

-- Lucent Citadel
    [214203] = 500, -- Bleak Annihilation
    [214187] = 500, -- Brilliant Annihilation
    [214136] = 500, -- Fate Sealer
    [219420] = 300, -- Smite (Cavot Agnan)
    [222071] = 400, -- Heavy Shock
    [214138] = 520.1, -- Fate Sealer (very long gained duration, but it seems to explode at 20.1s)
    [218285] = 800, -- Gloomy Impact (first one)
    [223331] = 800, -- Gloomy Impact (second one)
    [222609] = 800, -- Gloomy Impact (Knot)
    [215107] = 408.8, -- Tempest
    [214355] = 400, -- Lightning Flood (Xoryn cone)

-- Maw of Lorkhaj
    [ 75507] = 001601.1, -- Void Shackle (Rakkhat tethers)
    [ 73250] = 000315, -- Shattered (Savage)

-- Ossein Cage
    [237149] = 500, -- Agonizer Bombs (Overfiend Kazpian)
    [235201] = 500, -- Storm Slam (Molag Kena)
    [232773] = 500, -- Dominator's Chains (initial cast, 4100)
    [232779] = 400, -- Dominator's Chains (after it's gained, 16100)
    [232780] = 400, -- Dominator's Chains (after it's gained, 16100)
    [233598] = 300, -- Spark Smash (Jynorah)
    [233610] = 300, -- Blazing Smash (Skorkhif)
    [232397] = 500, -- Effluvial Expellant (Shaper of Flesh)
    [236569] = 500, -- Spectral Revenge (Osteon Spectral Revenant)
    [238800] = 800, -- Phantasmal Barrage
    [234276] = 1105, -- Blazing Curse (Skorkhif)
    [234000] = 1405, -- Sparking Curse (Jynorah)
    [236381] = 30500, -- True Shot (Coldharbour Sinewshot)
    -- [236383] = 30500, -- True Shot (Coldharbour Sinewshot) (the effect?)
    [234683] = {info = 31103, text = "Blazing Flame Atronach"}, -- Radiance (Blazing Flame Atronach)
    [234680] = {info = 31403, text = "Sparking Cold-Flame Atronach"}, -- Radiance (Sparking Cold-Flame Atronach)

-- Rockgrove
    [152688] = 2.5, -- Cinder Cleave (Havocrel Annihilator)
    [157860] = 1000, -- Noxious Sludge (hide because of sides)
    [150008] = 30000, -- Hemorrhaging Smack (Flesh Abomination)
    [149089] = 500, -- Astral Shield
    [157466] = 30800, -- Soul Remnant
    [153517] = {info = 1110, text = "Clockwise |t100%:100%:esoui/art/housing/rotation_arrow_reverse.dds:inheritcolor|t"}, -- CW
    [153518] = {info = 1210, text = "Counter-Clockwise|t100%:100%:esoui/art/housing/rotation_arrow.dds:inheritcolor|t"}, -- CCW

-- Sanctum Ophidia
    [ 56857] = 200, -- Emerald Eclipse (The Serpent)
    [ 54125] = 100205.7, -- Quake (Mantikora)
    [ 56782] = 800, -- Magicka Bomb, the 11 seconds, not 58084

-- Sanity's Edge
    [183855] = 45, -- The Ritual (Ansuul maze)
    [199344] = 100, -- Sunburst (Ansuul)
    [184802] = 30500, -- True Shot (Contramagis Archer)

-- Sunspire
    [122012] = 130402.5, -- Storm Crush (Gale-Claw)
    [120890] = 130302.5, -- Crush (Fire-Fang)
    [120359] =  20403.1, -- Relentless Gale (Lokkestiiz)
    [121722] =      6.3, -- Focus Fire (Yolnahkriin)
    [120783] = 330000.0, -- Hail of Stone (Vigil Statue)
    [118884] =    100.0, -- Fire Storm (Nahv)
    [117251] =    100.0, -- Meteor (Nahviintaas)

---------------------------------------------------------------------
-- Dungeons

-- Bedlam Veil
    [207005] = 200001.4, -- Malediction (The Blind) game only sends 200 for some reason

-- Black Gem Foundry
    [240426] = 800, -- Seismic Splinters
    [240363] = 500, -- Soul Focus (Black Gem Monstrosity, initial 2750 begin, then 7000 begin)
    [241689] = 30200, -- Soul Essence Bombardment
    [241662] = 100, -- Fluctuating Essence (red shooting out)
    [241685] = 20200, -- Fluctuating Esseence GRN [sic] (3000 when the fountains become green)
    [241854] = 500, -- Soulbinding Slam (High Soulbinder Vykand)
    [241863] = 500, -- Soul Cascade (Vykand)
    -- [241229] = 500, -- Imminent Annihilation (Vykand)
    [241326] = 500, -- Annihilation
    [241327] = 500, -- Annihilation
    [241328] = 500, -- Annihilation
    [241329] = 500, -- Annihilation
    [241224] = 500, -- Ominous Vision
    [240665] = 400, -- Charged Lightning?
    [246168] = 204.3, -- Acute Enervation (initial targeting of first, for some reason is 500 then 2800, but then not another ~1s until the real cast)

-- Coral Aerie
    [163153] = 600, -- Coalescing Shadows

-- Earthen Root Enclave
    [172410] = 200003.3, -- Crumble (Archdruid Devyric rock pillar things)
    [171742] = 500, -- Boughroot Slash

-- Exiled Redoubt
    [224463] = 1102, -- Summon Fire Atro (Squall, first one)
    [230349] = 1102, -- Summon Fire Atro (Squall, next 3)
    [224473] = 1402, -- Summon Ice Atro (Squall, first)
    [230383] = 1402, -- Summon Ice Atro (Squall, second)
    [224476] = 1402, -- Summon Shock Atro (Squall, first)
    [230386] = 1402, -- Summon Shock Atro (Squall, second)
    [223935] =  500, -- Six Sword Assault (Squall)

-- Fang Lair
    [ 98809] = 500, -- Draconic Smash
    [ 97022] = 500, -- Wraith Speed
    [ 96826] = 100400, -- Impaling Shards (Thurvokun)

-- Lep Seclusa
    [226181] = 200, -- Venom Eruption (Garvin the Tracker)
    [229247] = 800, -- Forbidden Knowledge (Orpheon the Tactician)
    [233821] = 100, -- Cyclone (Flame Gryphon)
    [224822] = 100, -- Blast Powder (Noriwen)

-- Naj-Caldeesh
    [242063] = 100, -- Ancient Blaze (Voskrona Stonehulk Poxito)

-- Shipwright's Regret
    [168314] = 1505, -- Soul Bomb
    [163654] =  500, -- Dark Blast
    [164480] =  300, -- Smash (Drowned Hulk)

-- Scrivener's Hall
    [182334] = 105.3, -- Rain of Fire (Valinna)
    [182393] = 14.5, -- Immolation Trap (Valinna)

---------------------------------------------------------------------
-- Arenas

-- Blackrose Prison
    [111283] = 2, -- Tremors (Imperial Cleaver)

-- Endless Archive
    [195448] = 501.1, -- Wing Burst (Ash Titan) for some reason game sends 3000, but it hits much before then

    [192013] = 500, -- Splintering Mirror (Tho'at Replicanum)
    [192024] = 500, -- Glass Sky (Tho'at Shard (Mantikora))
    [210841] = 500, -- Crashing Wave (Marauder Ulmor)
    [210830] = 500, -- Fulmination II (Marauder Ulmor)
    [195816] = 500, -- Poison Bolt (Selene)
    [196848] = 500, -- Mundus Breach (Silver Rose Realmshaper)
    [202374] = 500, -- Pound (Bone Colossus)
    [193530] = 500, -- Befouled Air (Old Snagara) poison aoe
    [196251] = 500, -- Enervating Sheen (Nerien'eth) does it need to be shielded?
    [198099] = 500, -- Blood Dive (Lady Thorn)
    [197002] = 500, -- Stormfront (Storm Atronach)
    [196959] = 500, -- Crush (Iron Atronach)
    [196875] = 500, -- Earthen Blast (Lurcher)
    [220298] = 500, -- Clobber (Marauder Zulfimbul)
    [227461] = 500, -- Ram (Marauder Zulfimbul)
    [223378] = 500, -- Rending Leap (Clannfear)
    [209981] = 100, -- Fireball (Tho'at Shard (dragon))
    [209963] = 100, -- Fireball (Tho'at Shard (dragon))
    [192517] = 1500, -- Seeking Spheres (Tho'at Shard)
    [ 47481] = 2000500, -- Obliterate (Anka-Ra Destroyer)
    [196235] = 2000500, -- Heavy Slash (Nerien'eth)
    [221792] = 2001503, -- Elixir of Diminishing (Fabled Brewmaster)

    [227772] = {info = 110, text = GetAbilityName(211987)}, -- Scaling (Meteor) -- seems to be 10 seconds before meteor blows up
    [196689] = 200, -- Venomous Arrow (Ascendant Archer) dot hurts if pre-debuffed. chance to dodge
    [221745] = 100, -- Sunburst (Fabled Lightbringer)

    [194984] = 1000300, -- Uppercut (Ascendant Vanguard, Dremora Blademaster, Dremora Ravager, Dro-m'Athra Blademaster)
    [196715] = 1000300, -- Power Bash (Dro-m'Athra Sentinel, Dremora Bulwark, Dremora Vigilant, Goblin Warbruiser, Grovebound Bruiser)
    [211594] = 1000300, -- Power Bash (Ascendant Bulwark)
    [221216] = 1000300, -- Power Bash (Dugan the Red)
    [ 47488] = 300, -- Uppercut (Anka-Ra Destroyer)
    [203006] = 300, -- Thrash (Bristleback)
    [201727] = 300, -- Shield Charge (Dremora Vigilant)
    [203492] = 300, -- Diving Strike (Dremora Ironclad)
    [199608] = 300, -- Heinous Highkick (Prior Thierric Sarazen)
    [202383] = 300, -- Charge (Ogrim)
    [191702] = 300, -- Lunging Strike (Kra'gh the Dreugh King)
    [223685] = 300, -- Hoarfrost Fist (Frost Atronach)
    [193534] = 300, -- Spinning Blades (Barbas)
    [209645] = 300, -- Venomous Fangs (Selene's Fangs)


-- Maelstrom Arena
    [ 72057] = 20003, -- Portal Spawn
    [ 70723] =  1203, -- Rupturing Fog
    [ 72446] =   400, -- Smash Iceberg
    [ 68194] =    14, -- Necrotic Orb (timer for followy-thingy)
    [  9674] =   300, -- Resonate (Lamia Domina)
    [ 29378] =   300, -- Uppercut (Queen's Champion, Kartheid, etc.)
    [ 17867] =   400, -- Shock Aura (Queen's Champion)
    -- [ 72180] =   400, -- Electric Wave (Dwarven Sphere) I think it's obvious enough
    [  4817] =   300, -- Unyielding Mace (Flesh Atronach)
    [ 70955] =   200, -- Blight Bomb (Xivilai Toxicoli)
    [ 35164] =   800, -- Agony (Argonian Berserker)
    [ 70695] =   500, -- Taking Aim (Argonian Venomshot)
    [ 68994] =   500, -- Staggering Stomp (Argonian Behemoth)
    [ 69029] =   500, -- Wrecking Bite (Argonian Behemoth)
    [ 69083] =   500, -- Enraged Scream (Argonian Behemoth)
    -- [ 69083] =   512.5, -- Enraged Scream (Argonian Behemoth)
    [ 71849] =   100, -- Inferno (Dremora Kyngald)
    [ 67411] =   300, -- Uppercut (Dremora Caitiff)
    [ 67420] =   500, -- Necrotic Blast (Voriak Solkyn)
    [ 69001] =   500, -- Necrotic Blast (Voriak Solkyn while he's upstairs)
    [ 68011] =   500, -- Web Up Artifact
}


---------------------------------------------------------------------
local colors = {
    [1] = "ff6600", -- Orange, fire
    [2] = "64c200", -- Green, poison
    [3] = "fff1ab", -- Tan, physical
    [4] = "8ef5f5", -- Light blue, shock/ice
    [5] = "ff00ff", -- Magenta
    [6] = "9447ff", -- The color of rrrrregality
    [7] = "3fe02a", -- Green for Arcanist
    [8] = "9999ff", -- Light indigo, magic
    [9] = "ffe736", -- Yellow for Templar
}


---------------------------------------------------------------------
-- Unpack the format info
---------------------------------------------------------------------
function Crutch.GetFormatInfo(abilityId)
    local remainder = Crutch.format[abilityId]
    local customText
    if (type(remainder) == "table") then
        customText = remainder.text
        remainder = remainder.info
    end

    if (not remainder) then
        remainder = 0
    end

    local dingInIA = math.floor(remainder / 1000000)
    remainder = remainder - dingInIA * 1000000

    local resultFilter = math.floor(remainder / 100000)
    remainder = remainder - resultFilter * 100000

    local alertType = math.floor(remainder / 10000)
    remainder = remainder - alertType * 10000

    local hideTimer = math.floor(remainder / 1000)
    remainder = remainder - hideTimer * 1000

    local color = math.floor(remainder / 100)
    remainder = remainder - color * 100

    return remainder * 1000, colors[color], hideTimer, alertType, resultFilter, dingInIA, customText
end