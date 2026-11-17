local Crutch = CrutchAlerts
Crutch.Drawing.Trail = {}
local T = Crutch.Drawing.Trail
local C = Crutch.Constants

local particles = {}

local function ParticleFunc(icon)
    local elapsed = GetGameTimeMilliseconds() - icon.extraData
    if (elapsed >= 3000) then
        Crutch.Drawing.RemoveWorldTexture(icon.key, true)
    end
    local progress = elapsed % 3000 / 3000

    icon:SetColor(nil, nil, nil, 1 - ZO_EaseOutCubic(progress))
    icon:SetPosition(icon.x, icon.y - progress * 2, icon.z)

    local rotation = particles[icon.key]
    local pitch, yaw, roll
    if (rotation == 1) then
        pitch = icon.orientation.pitch + progress
    elseif (rotation == 2) then
        yaw = icon.orientation.yaw + progress
    elseif (rotation == 3) then
        roll = icon.orientation.roll + progress
    end
    icon:SetOrientation(pitch, yaw, roll)
end

local orientation = {-math.pi / 2, 0, 0}
local function CreateParticle(x, y, z)
    orientation[1] = math.random() * math.pi * 2
    orientation[2] = math.random() * math.pi * 2
    orientation[3] = math.random() * math.pi * 2
    local key = Crutch.Drawing.CreateWorldTexture(
        "esoui/art/icons/heraldrycrests_misc_snowflake_01.dds",
        x, y + 150, z,
        0.25, 0.25,
        C.WHITE,
        false,
        false,
        orientation,
        ParticleFunc,
        GetGameTimeMilliseconds(),
        true)
    particles[key] = math.random(1, 3)
end

local function OnUpdate()
    if (not IsPlayerMoving()) then return end

    local _, x, y, z = GetUnitRawWorldPosition("player")
    CreateParticle(x, y, z)
end

local function AreTrailsEnabled()
    if (not Crutch.savedOptions.general.showSpeshulEffects) then return false end

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if (not Crutch.Drawing.Model.DoesZoneHavePresents(zoneId)) then
        return false
        -- return Crutch.savedOptions.experimental
    end

    if (not Crutch.Drawing.Model.IsPresentSeason() and not Crutch.savedOptions.general.showEffectsOutOfSeason) then return false end
    return Crutch.Drawing.Model.AreAllPresentsCompleted(zoneId)
end

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "TrailUpdate")
    if (AreTrailsEnabled()) then
        EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "TrailUpdate", 150, OnUpdate)
    end
end
T.OnPlayerActivated = OnPlayerActivated

function T.Initialize()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TrailPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end
