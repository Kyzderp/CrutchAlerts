CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

local childNames = {"LeftMid", "LeftTop", "LeftBottom", "RightMid", "RightTop", "RightBottom"}

-- TODO: make these user vars
-- TODO: interrupted
local preMillis = 1000
local postMillis = 200

-- Data for prominent display of notifications
Crutch.prominent = {
-- Screw these
    -- [ 12459] = {text = "WINTER'S REACH", color = {0.5, 1, 1}, slot = 1, preMillis = 1500,
    --     zoneIds = {
    --         -- [1227] = true, -- Vateshran Hollows
    --         [ 635] = true, -- Dragonstar Arena
    --     }}, -- Winter's Reach (Regulated Frost Mage, Xivkyn Chillfiend, etc.)
    -- [ 15164] = {text = "HEAT WAVE", color = {1, 0.3, 0.1}, slot = 1,
    --     zoneIds = {
    --         -- [1227] = true, -- Vateshran Hollows
    --         -- [ 677] = true, -- Maelstrom Arena
    --         [ 635] = true, -- Dragonstar Arena
    --     }}, -- Heat Wave (Dremora Kyngald, etc.)

-- HoF
    -- [ 90499] = {text = "ADDS", color = {1, 0.2, 0.2}, slot = 1, millis = 6000}, -- Reclaim the Ruined (Adds spawn)
    -- [ 90876] = {text = "INTERRUPT", color = {0.5, 1, 1}, slot = 1, playSound = true}, -- Direct Current (Pinnacle interruptible)
    -- [ 91454] = {text = "BLOCK", color = {1, 0.2, 0.2}, slot = 1, playSound = true}, -- Stomp (Assembly General)

-- SS
    -- [117075] = {text = "SHIELD CHARGE", color = {0.5, 1, 1}, slot = 1, playSound = true}, -- Shield Charge (Ruin of Alkosh)
    -- [121422] = {text = "CONE", color = {0.5, 1, 1}, slot = 1, playSound = true, preMillis = 1000}, -- Sundering Gale (Eternal Servant)

-- MoL
    -- [ 73721] = {text = "VOID RUSH", color = {0.5, 1, 1}, slot = 1, playSound = true}, -- Void Rush (Dro-m'Athra Shadowguard)
    -- [ 73741] = {text = "BLOCK", color = {1, 0.9, 170/255}, slot = 1, playSound = true}, -- Threshing Wings (Rakkhat)
    -- [ 57517] = {text = "CURSE", color = {0.5, 0, 1}, slot = 1, playSound = true, millis = 1000}, -- Grip of Lorkhaj (Zhaj'hassa) called manually from MawOfLorkhaj.lua

-- CR
    -- [105380] = {text = "INTERRUPT", color = {0.5, 1, 1}, slot = 2, playSound = true, preMillis = 6000, millis = 6000}, -- Direct Current (Relequen interruptible)
    -- [106405] = {text = "INTERRUPT", color = {0.5, 1, 1}, slot = 2, playSound = true, preMillis = 6000, millis = 6000}, -- Glacial Spikes (Galenwe interruptible)
    -- [105016] = {text = "CREEPER", color = {0.5, 1, 0.5}, slot = 1, playSound = true, preMillis = 6000, millis = 6000}, -- Creeper spawn
    -- [104646] = {text = "STOP REZZING", color = {0.6, 0, 1}, slot = 2, playSound = true, preMillis = 6000, millis = 2000}, -- Grievous Retaliation

-- RG
    -- [149414] = {text = "BLITZ", color = {1, 1, 0.5}, slot = 1, playSound = true}, -- Savage Blitz (Oaxiltso)

-- BRP
    -- [111161] = {text = "LAVA WHIP", color = {1, 0.6, 0}, slot = 1, playSound = true}, -- Lava Whip (Imperial Dread Knight)

-- DSA
    -- [54608] = {text = "DODGE", color = {0, 0.6, 0}, slot = 1, playSound = true}, -- Draining Poison (Pacthunter Ranger)

-------------------
-- BDV
    -- TODO: I didn't move this V2 mostly because code's already has it... but also because I'm lazy. And there are a lot of trial/arena things that need testing already
    -- [150380] = {text = "DODGE", color = {0.5, 1, 1}, slot = 1, playSound = true}, -- Glacial Gash (Sentinel Aksalaz)

-------------------
-- MA
    -- [75277] = {text = "AMBUSH", color = {223/255, 71/255, 237/255}, slot = 1, playSound = true}, -- Teleport Strike (Dremora Kynlurker) TODO: zoneId maybe?
    -- [75281] = {text = "TETHER", color = {223/255, 71/255, 237/255}, slot = 1, playSound = true}, -- Soul Tether (Dremora Kynlurker) TODO: zoneId maybe?

-------------------
-- DSR
    -- [170188] = {text = "BOOT", color = {223/255, 71/255, 237/255}, slot = 1, playSound = true}, -- Cascading Boot (Dreadsail Overseer)

-------------------
-- SE
    -- [184540] = {text = "CHAIN", color = {1, 0, 0}, slot = 1, playSound = true, millis = 1000}, -- Chain Pull (Exarchanic Yaseyla)

-------------------
-- EA
    -- [197418] = {text = "CURSE", color = {0.5, 0, 1}, slot = 1, playSound = true, millis = 1000}, -- Grasp of Lorkhaj (Zhaj'hassa)

-------------------
-- Custom
    -- [888001] = {text = "BOOGER", color = {1, 0, 0}, slot = 1, playSound = true, millis = 2000}, -- Booger phase ended in Falgravn 2nd floor
    [888002] = {text = "BAD", color = {1, 0, 0}, slot = 2, playSound = false, millis = 1000}, -- Called from damageTaken.lua
    [888003] = {text = "COLOR SWAP", color = {1, 0, 0}, slot = 1, playSound = true, millis = 1000}, -- vMol color swap
    [888004] = {text = "STATIC", color = {0.5, 1, 1}, slot = 1, playSound = true, millis = 1000}, -- vDSR static stacks
    -- [888005] = {text = "UNSTABLE", color = {1, 0, 0}, slot = 1, playSound = true, millis = 1500}, -- vMoL Unstable Void
    [888006] = {text = "POISON", color = {0.5, 1, 0.5}, slot = 2, playSound = true, millis = 1000}, -- vDSR poison stacks
    -- [888007] = {text = "DARK", color = {0.5, 0, 1}, slot = 1, playSound = true, millis = 1000}, -- vLC Darkness Inflicted
    -- [888008] = {text = "CLEANSE", color = {0.5, 1, 0.5}, slot = 1, playSound = true, millis = 1000}, -- vMA poison round
}

Crutch.prominentDisplaying = {} -- {[12459] = 1,}

-------------------------------------------------------------------------------
local function Display(abilityId, text, color, slot, millis)
    Crutch.prominentDisplaying[abilityId] = slot

    local control = GetControl("CrutchAlertsProminent" .. tostring(slot))
    for _, name in ipairs(childNames) do
        local label = control:GetNamedChild(name)
        if (label) then
            label:SetText(text)
            label:SetColor(unpack(color))
        end
    end
    control:SetHidden(false)

    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "Prominent" .. tostring(slot), millis, function()
        control:SetHidden(true)
        Crutch.prominentDisplaying[abilityId] = nil
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "Prominent" .. tostring(slot))
    end)
end

-------------------------------------------------------------------------------
function Crutch.DisplayProminent(abilityId)
    local data = Crutch.prominent[abilityId]
    if (not data) then
        d("|cFF5555WARNING: tried to DisplayProminent without abilityId in data|r")
        return
    end

    if (data.zoneIds ~= nil and not data.zoneIds[GetZoneId(GetUnitZoneIndex("player"))]) then
        return
    end

    Crutch.dbgSpam(string.format("|cFF8888[P] DisplayProminent %d|r", abilityId))
    if (data.playSound) then
        PlaySound(SOUNDS.DUEL_START)
    end
    Display(abilityId, data.text, data.color, data.slot, data.millis or (preMillis + postMillis))
end

-------------------------------------------------------------------------------
function Crutch.DisplayProminent2(abilityId, data)
    if (not data) then
        d("|cFF5555WARNING: tried to DisplayProminent2 without data|r")
        return
    end

    Crutch.dbgSpam(string.format("|cFF8888[P] DisplayProminent2 %d|r", abilityId))
    if (data.playSound) then
        PlaySound(SOUNDS.DUEL_START)
    end
    Display(abilityId, data.text, data.color, data.slot, data.millis or (preMillis + postMillis))
end
