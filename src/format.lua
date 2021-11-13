CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Result   Type  HideTimer  Color  Timer
-- 0        0     1          1      07.5
-- 001107.5
-- 
-- Result: 0 = any, 1 = BEGIN only, 2 = GAINED only, 3 = NOT DURATION
-- Type: 0 = normal alert, 1 = secondary, 2 = prevent overwrite, 3 = always display even if already displaying
-- HideTimer: 0 = false, 1 = true
-- Color: 0 = white, 1 = ...
-- Timer: actual number, or 0

Crutch.format = {
-- Testing The Abomination
    -- [  8244] =  10, -- Devastate
    [  8247] = 20202.5, -- Vomit

-- Sunspire
    [122012] = 130402.5, -- Storm Crush (Gale-Claw)
    [120890] = 130302.5, -- Crush (Fire-Fang)
    [121722] =      6.3, -- Focus Fire (Yolnahkriin)
    [120783] = 330000.0, -- Hail of Stone (Vigil Statue)

-- Asylum Sanctorium
    [ 95545] =  20206.2, -- Defiling Dye Blast (Saint Llothis)

-- Cloudrest
    [103531] = 100107, -- Roaring Flare
    [110431] = 100107, -- Roaring Flare
    [105239] = 200010, -- Crushing Darkness
    [103555] =     3, -- Voltaic Current
    [ 87346] =    10, -- Voltaic Overload
    [104019] = 31003, -- Olorime Spears

-- Blackrose Prison
    [111283] = 2, -- Tremors (Imperial Cleaver)

-- Sanctum Ophidia
    [ 56857] = 205, -- Emerald Eclipse (The Serpent)

-- Aetherian Archive
    [ 47898] = 10, -- Lightning Storm (Storm Atronach)
    [ 48240] = 10, -- Boulder Storm (Stone Atronach)
    [ 49098] = 10, -- Big Quake (Stone Atronach)

-- Maelstrom Arena
    [ 72057] = 20003, -- Portal Spawn
    [ 70723] =  1203, -- Rupturing Fog

-- Rockgrove
    [152688] = 2.5, -- Cinder Cleave (Havocrel Annihilator)
    [157860] = 1000, -- Noxious Sludge (hide because of sides)
}


---------------------------------------------------------------------
--[[
from LUI, not gonna use exactly the same though
damage = {
    [DAMAGE_TYPE_NONE]      = { 1, 1, 1, 1 },
    [DAMAGE_TYPE_GENERIC]   = { 1, 1, 1, 1 },
    [DAMAGE_TYPE_PHYSICAL]  = { 200/255, 200/255, 160/255, 1 },
    [DAMAGE_TYPE_FIRE]      = { 1, 100/255, 20/255, 1 },
    [DAMAGE_TYPE_SHOCK]     = { 0, 1, 1, 1 },
    [DAMAGE_TYPE_OBLIVION]  = { 75/255, 0, 150/255, 1 },
    [DAMAGE_TYPE_COLD]      = { 35/255, 70/255, 1, 1 },
    [DAMAGE_TYPE_EARTH]     = { 100/255, 75/255, 50/255, 1 },
    [DAMAGE_TYPE_MAGIC]     = { 1, 1, 0, 1 },
    [DAMAGE_TYPE_DROWN]     = { 35/255, 70/255, 255/255, 1 },
    [DAMAGE_TYPE_DISEASE]   = { 25/255, 85/255, 0, 1 },
    [DAMAGE_TYPE_POISON]    = { 0, 1, 127/255, 1 },
    [DAMAGE_TYPE_BLEED]     = { 1, 45/255, 45/255, 1 },
},
from improved death recap
IDR.dmgcolors={ 
    [DAMAGE_TYPE_NONE]      = "|cE6E6E6", 
    [DAMAGE_TYPE_GENERIC]   = "|cE6E6E6", 
    [DAMAGE_TYPE_PHYSICAL]  = "|cf4f2e8", 
    [DAMAGE_TYPE_FIRE]      = "|cff6600", 
    [DAMAGE_TYPE_SHOCK]     = "|cffff66", 
    [DAMAGE_TYPE_OBLIVION]  = "|cd580ff", 
    [DAMAGE_TYPE_COLD]      = "|cb3daff", 
    [DAMAGE_TYPE_EARTH]     = "|cbfa57d", 
    [DAMAGE_TYPE_MAGIC]     = "|c9999ff", 
    [DAMAGE_TYPE_DROWN]     = "|ccccccc", 
    [DAMAGE_TYPE_DISEASE]   = "|cc48a9f", 
    [DAMAGE_TYPE_POISON]    = "|c9fb121", 
    [DAMAGE_TYPE_BLEED]     = "|cc20a38", 
}
]]
local colors = {
    [1] = "ff6600", -- Orange, fire
    [2] = "64c200", -- Green, poison
    [3] = "f4f2e8", -- Tan, physical
    [4] = "8ef5f5", -- Light blue, shock
    [5] = "ff00ff", -- Magenta
}


---------------------------------------------------------------------
-- Unpack the format info
---------------------------------------------------------------------
function Crutch.GetFormatInfo(abilityId)
    local remainder = Crutch.format[abilityId]
    if (not remainder) then
        remainder = 0
    end

    local resultFilter = math.floor(remainder / 100000)
    remainder = remainder - resultFilter * 100000

    local alertType = math.floor(remainder / 10000)
    remainder = remainder - alertType * 10000

    local hideTimer = math.floor(remainder / 1000)
    remainder = remainder - hideTimer * 1000

    local color = math.floor(remainder / 100)
    remainder = remainder - color * 100

    return remainder * 1000, colors[color], hideTimer, alertType, resultFilter
end