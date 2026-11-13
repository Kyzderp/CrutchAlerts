local Crutch = CrutchAlerts
local T = Crutch.Drawing.Trail
local C = Crutch.Constants

local particles = {}
local particleKeys = {} -- {[key] = 12355}

local function ParticleFunc(icon)
end

local function CreateParticle(x, y, z)
    local key = Crutch.Drawing.CreateOrientedTexture(
        "CrutchAlerts/assets/poop.dds",
        x, y, z,
        10,
        C.WHITE,
        C.FLAT_ORIENTATION,
        ParticleFunc,
        true)
    particles[key] = GetGameTimeMilliseconds()
end

local function OnUpdate()
    if (not IsPlayerMoving()) then return end

    local _, x, y, z = GetUnitRawWorldPosition("player")
    CreateParticle(x, y, z)
end

function T.Initialize()
end
