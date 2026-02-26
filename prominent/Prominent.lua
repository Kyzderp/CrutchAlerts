local Crutch = CrutchAlerts
local C = Crutch.Constants

local childNames = {"LeftMid", "LeftTop", "LeftBottom", "RightMid", "RightTop", "RightBottom"}

-- TODO: make these user vars
-- TODO: interrupted
local preMillis = 1000
local postMillis = 200

-- Data for prominent display of notifications
Crutch.prominent = {
-- Custom "IDs"
    [C.ID.DAMAGE_TAKEN] = {text = "BAD", color = C.RED, slot = 2, playSound = false, millis = 1000}, -- Called from damageTaken.lua
    [C.ID.COLOR_SWAP] = {text = "COLOR SWAP", color = C.RED, slot = 1, playSound = true, millis = 1000}, -- vMol color swap
    [C.ID.STATIC] = {text = "STATIC", color = {0.5, 1, 1}, slot = 1, playSound = true, millis = 1000}, -- vDSR static stacks
    [C.ID.POISON] = {text = "POISON", color = {0.5, 1, 0.5}, slot = 2, playSound = true, millis = 1000}, -- vDSR poison stacks
    [C.ID.DROP_FROST] = {text = "DROP FROST", color = {0, 0.7, 1}, slot = 2, playSound = true, millis = 1000}, -- vCR drop hoarfrost
}

Crutch.prominentDisplaying = {} -- {[12459] = 1,}

-------------------------------------------------------------------------------
local function Display(abilityId, text, color, slot, millis)
    Crutch.prominentDisplaying[abilityId] = slot

    local styles = Crutch.GetStyles()

    local control = GetControl("CrutchAlertsProminent" .. tostring(slot))
    for _, name in ipairs(childNames) do
        local label = control:GetNamedChild(name)
        if (label) then
            label:SetFont(styles.prominentFont)
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

local soundsSize = 0
local function GetRandomSound()
    -- First time, get the size
    if (soundsSize == 0) then
        for _, _ in pairs(SOUNDS) do
            soundsSize = soundsSize + 1
        end
    end

    local i = 1
    local random = math.floor(math.random() * soundsSize + 1)
    for _, sound in pairs(SOUNDS) do
        if (i == random) then
            return sound
        end
        i = i + 1
    end

    return SOUNDS.DUEL_START
end

function Crutch.DisplayProminentSpin(text, color, slot)
    color = color or {1, 0.6, 0}
    slot = slot or 1
    Display(888888, text, color, slot, 5000)
    local stop = false
    zo_callLater(function()
        stop = true
    end, 5000)

    local angle = 0
    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "Spinny" .. tostring(slot), 30, function()
        PlaySound(GetRandomSound())
        angle = angle + 10 * ((slot % 2 == 0) and 1 or -1) * slot
        if (stop) then
            EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "Spinny" .. tostring(slot))
            angle = 0
        end

        local control = GetControl("CrutchAlertsProminent" .. tostring(slot))
        for _, name in ipairs(childNames) do
            local label = control:GetNamedChild(name)
            if (label) then
                label:SetTransformRotationZ(math.rad(angle))
            end
        end
    end)
end
-- /script CrutchAlerts.DisplayProminentSpin("POLY", nil, 1) CrutchAlerts.DisplayProminentSpin("POLY POLY", {0, 1, 0}, 2) CrutchAlerts.DisplayProminentSpin("POLY POLY POLY", {1, 0, 1}, 3)

-------------------------------------------------------------------------------
function Crutch.DisplayProminent(abilityId)
    local data = Crutch.prominent[abilityId]
    if (not data) then
        Crutch.dbgOther(string.format("|cFF5555WARNING: tried to DisplayProminent without abilityId (%d) in data|r", abilityId))
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
        Crutch.dbgOther("|cFF5555WARNING: tried to DisplayProminent2 without data|r")
        return
    end

    Crutch.dbgSpam(string.format("|cFF8888[P] DisplayProminent2 %d|r", abilityId))
    if (data.playSound) then
        PlaySound(SOUNDS.DUEL_START)
    end
    Display(abilityId, data.text, data.color, data.slot, data.millis or (preMillis + postMillis))
end
