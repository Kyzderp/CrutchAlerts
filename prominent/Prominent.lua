CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

local childNames = {"LeftMid", "LeftTop", "LeftBottom", "RightMid", "RightTop", "RightBottom"}

-- TODO: make these user vars
-- TODO: interrupted
local preMillis = 1000
local postMillis = 200

-- Data for prominent display of notifications
Crutch.prominent = {
-- Custom "IDs"
    [888002] = {text = "BAD", color = {1, 0, 0}, slot = 2, playSound = false, millis = 1000}, -- Called from damageTaken.lua
    [888003] = {text = "COLOR SWAP", color = {1, 0, 0}, slot = 1, playSound = true, millis = 1000}, -- vMol color swap
    [888004] = {text = "STATIC", color = {0.5, 1, 1}, slot = 1, playSound = true, millis = 1000}, -- vDSR static stacks
    [888006] = {text = "POISON", color = {0.5, 1, 0.5}, slot = 2, playSound = true, millis = 1000}, -- vDSR poison stacks
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
