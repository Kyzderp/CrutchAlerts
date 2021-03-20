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
    [ 12459] = {text = "WINTER'S REACH", color = {0.5, 1, 1}, slot = 1,
        zoneIds = {
            [1227] = true, -- Vateshran Hollows
            [ 635] = true, -- Dragonstar Arena
        }}, -- Winter's Reach (Regulated Frost Mage, Xivkyn Chillfiend, etc.)
    [ 15164] = {text = "HEAT WAVE", color = {1, 0.3, 0.1}, slot = 1,
        zoneIds = {
            [1227] = true, -- Vateshran Hollows
            [ 635] = true, -- Dragonstar Arena
        }}, -- Heat Wave (Dremora Kyngald, etc.)

-- HoF
    [ 90499] = {text = "ADDS", color = {1, 0.2, 0.2}, slot = 1, millis = 6000}, -- Reclaim the Ruined (Adds spawn)
    [ 91454] = {text = "BLOCK", color = {1, 0.2, 0.2}, slot = 1, playSound = true}, -- Stomp (Assembly General)

-- SS    
    [117075] = {text = "SHIELD CHARGE", color = {0.5, 1, 1}, slot = 1, playSound = true}, -- Shield Charge (Ruin of Alkosh)

-- MoL
    [ 73721] = {text = "VOID RUSH", color = {0.5, 1, 1}, slot = 1, playSound = true}, -- Void Rush (Dro-m'Athra Shadowguard)

-- CR
    [105380] = {text = "INTERRUPT", color = {0.5, 1, 1}, slot = 1, playSound = true}, -- Direct Current (Relequen interruptible)

-- BDV
    [150380] = {text = "DODGE", color = {0.5, 1, 1}, slot = 1, playSound = true}, -- Glacial Gash (Sentinel Aksalaz)
}
-- /script CrutchAlerts.DisplayProminent(117075)

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
        if (Crutch.savedOptions.debugChatSpam) then
            d(string.format("|cCEFA8C[P] Skipped displaying %s because not in zoneIds|r", data.text))
        end
        return
    end

    if (data.playSound) then
        PlaySound(SOUNDS.DUEL_START)
    end
    Display(abilityId, data.text, data.color, data.slot, data.millis or (preMillis + postMillis))
end
