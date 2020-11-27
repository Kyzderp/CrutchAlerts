CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Type  HideTimer  Color  Timer
-- 0     1          1      07.5
-- 01107.5
-- 
-- Type: 0 = normal alert, 1 = secondary, 2 = prevent overwrite
-- HideTimer: 0 = false, 1 = true
-- Color: 0 = white, 1 = ?
-- Timer: actual number

Crutch.format = {
-- Testing The Abomination
    [  8244] =  10, -- Devastate
    [  8247] = 20005, -- Vomit

-- Sunspire
    [122012] = 2.5, -- Storm Crush (Gale-Claw)
    [120890] = 2.5, -- Crush (Fire-Fang)
    [121722] = 6.3, -- Focus Fire (Yolnahkriin)

-- Asylum Sanctorium
    [ 95545] = 20006.2, -- Defiling Dye Blast (Saint Llothis)

-- Cloudrest
    [103946] =   2, -- Shadow Realm Cast (Z'Maja)
    [103760] =   7, -- Hoarfrost
    [103531] =   7, -- Roaring Flare
    [110431] =   7, -- Roaring Flare
    [105239] =  10, -- Crushing Darkness
    [103555] =   3, -- Voltaic Current
    [ 87346] =  10, -- Voltaic Overload

-- Blackrose Prison
    [111283] =   2, -- Tremors (Imperial Cleaver) TODO: check

-- Sanctum Ophidia
    [ 56857] =   5, -- Emerald Eclipse (The Serpent)

-- Aetherian Archive
    [ 47898] =  10, -- Lightning Storm (Storm Atronach)
    [ 48240] =  10, -- Boulder Storm (Stone Atronach)
    [ 49098] =  10, -- Big Quake (Stone Atronach)

-- Maw of Lorkhaj
    [ 74035] =   2, -- Darkness Falls
    [ 74384] =   5, -- Dark Barrage
    [ 74385] =   5, -- Dark Barrage
    [ 74388] =   5, -- Dark Barrage
    [ 74389] =   5, -- Dark Barrage
    [ 74390] =   5, -- Dark Barrage
    [ 74391] =   5, -- Dark Barrage
    [ 74392] =   5, -- Dark Barrage
    [ 75965] =   5, -- Dark Barrage
    [ 75966] =   5, -- Dark Barrage
    [ 75967] =   5, -- Dark Barrage
    [ 75968] =   5, -- Dark Barrage
    [ 78015] =   5, -- Dark Barrage

-- Maelstrom Arena
    [ 72057] =   20003, -- Portal Spawn
}

function Crutch.GetFormatInfo(abilityId)
    local remainder = Crutch.format[abilityId]
    if (not remainder) then
        remainder = 0
    end

    local alertType = math.floor(remainder / 10000)
    remainder = remainder - alertType * 10000

    local hideTimer = math.floor(remainder / 1000)
    remainder = remainder - hideTimer * 1000

    local color = math.floor(remainder / 100)
    remainder = remainder - color * 100

    return remainder * 1000, color, hideTimer, alertType
end