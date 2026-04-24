local Crutch = CrutchAlerts
local C = Crutch.Constants

---------------------------------------------------------------------
-- Quarrymaster Saldezaar
---------------------------------------------------------------------
local CENTER_X = 175064
local CENTER_Y = 32820
local CENTER_Z = 75194
local RADIUS = 3100

local function GetLineEndpoint()
    local _, x, _, z = GetUnitRawWorldPosition("player")
    -- Get the angle of player, then extend it to radius
    local theta = math.atan2(z - CENTER_Z, x - CENTER_X)
    return CENTER_X + math.cos(theta) * RADIUS, CENTER_Y, CENTER_Z + math.sin(theta) * RADIUS
end

local key
local function DrawSlamLine()
    local x1, y1, z1 = GetLineEndpoint()
    key = Crutch.Drawing.CreateLine(x1, y1, z1, CENTER_X, CENTER_Y, CENTER_Z, 0.3, C.RED, nil, nil, function()
        local x1, y1, z1 = GetLineEndpoint()
        return x1, y1, z1, CENTER_X, CENTER_Y, CENTER_Z
    end)
end

local function OnRupture()
    if (key) then
        Crutch.Drawing.RemoveLine(key)
        key = nil
    end
end

local function OnRuptureHide()
    DrawSlamLine()
    zo_callLater(OnRupture, 20000) -- Just in case it doesn't clear for some reason
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterBlackGemFoundry()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Black Gem Foundry")

    if (Crutch.savedOptions.blackGemFoundry.showRuptureLine) then
        Crutch.RegisterForCombatEvent("BGFRuptureHide", OnRuptureHide, nil, 240244)
        Crutch.RegisterForCombatEvent("BGFRupture", OnRupture, nil, 240240)

        Crutch.RegisterExitedGroupCombatListener("BGFRupture", OnRupture)
    end
end

function Crutch.UnregisterBlackGemFoundry()
    Crutch.UnregisterForCombatEvent("BGFRuptureHide")
    Crutch.UnregisterForCombatEvent("BGFRupture")

    Crutch.UnregisterExitedGroupCombatListener("BGFRupture")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Black Gem Foundry")
end