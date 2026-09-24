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
-- virtuals
local X_OFFSET = GuiRoot:GetWidth() / 2 * 0.8
local SLOT_COORDS = {
    [1] = {
        {-X_OFFSET,    0, LEFT},
        {-X_OFFSET,  300, LEFT},
        {-X_OFFSET, -300, LEFT},
        { X_OFFSET,    0, RIGHT},
        { X_OFFSET,  300, RIGHT},
        { X_OFFSET, -300, RIGHT},
    },
    [2] = {
        {-X_OFFSET,  150, LEFT},
        {-X_OFFSET, -150, LEFT},
        { X_OFFSET,  150, RIGHT},
        { X_OFFSET, -150, RIGHT},
    },
    [3] = {
        {-X_OFFSET,  225, LEFT},
        {-X_OFFSET, -225, LEFT},
        { X_OFFSET,  225, RIGHT},
        { X_OFFSET, -225, RIGHT},
    },
    [4] = {
        {        0,    0, CENTER},
        {-X_OFFSET,  225, LEFT},
        {-X_OFFSET, -225, LEFT},
        {        0,  450, CENTER},
        { X_OFFSET,  225, RIGHT},
        { X_OFFSET, -225, RIGHT},
    },
}

local prominentControls = {}

local function CreateProminents(slot)
    local control = WINDOW_MANAGER:CreateTopLevelWindow("CrutchAlertsProminent" .. slot)
    for i, coords in ipairs(SLOT_COORDS[slot]) do
        local line = CreateControlFromVirtual(
            "$(parent)Line" .. i,
            control,
            "CrutchAlertsProminentLineTemplate",
            "")
        line:SetAnchor(coords[3], GuiRoot, CENTER, coords[1], coords[2])
    end
    return control
end


-------------------------------------------------------------------------------
local function Display(abilityId, text, color, slot, millis)
    Crutch.prominentDisplaying[abilityId] = slot

    -- Get or create
    local control = GetControl("CrutchAlertsProminent" .. slot)
    if (not control) then
        local creationStartTime = GetGameTimeMilliseconds()
        control = CreateProminents(slot)
        Crutch.dbgOther("Creating prominents took " .. GetGameTimeMilliseconds() - creationStartTime)
    end

    -- Individual lines
    local font = Crutch.GetStyles().GetProminentFont(Crutch.savedOptions.general.prominentSize)
    for i = 1, control:GetNumChildren() do
        local label = control:GetChild(i)
        label:SetFont(font)
        label:SetText(text)
        label:SetColor(unpack(color))
        label:SetDimensions(1000, 1000)
        label:SetWidth(label:GetTextWidth())
        label:SetHeight(label:GetTextHeight())
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

function Crutch.DisplayProminentSpin(text, color, slot, mute)
    color = color or {1, 0.6, 0}
    slot = slot or 1
    Display(888888, text, color, slot, 5000)
    local stop = false
    zo_callLater(function()
        stop = true
    end, 5000)

    local angle = 0
    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "Spinny" .. tostring(slot), 30, function()
        if (not mute) then
            PlaySound(GetRandomSound())
        end
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
    local sound = data.playSound
    if (sound) then
        if (sound == true) then
            PlaySound(SOUNDS.DUEL_START)
        elseif (type(sound) == "function") then
            sound()
        else
            PlaySound(sound)
        end
    end
    Display(abilityId, data.text, data.color, data.slot, data.millis or (preMillis + postMillis))
end
