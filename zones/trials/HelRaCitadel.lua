local Crutch = CrutchAlerts
local C = Crutch.Constants

---------------------------------------------------------------------
-- Stone Form circle
---------------------------------------------------------------------
Crutch.stonedRadius = 8 -- TODO: /script CrutchAlerts.stonedRadius = 8
local circleKeys = {} -- [atName] = key -- store using @name because of potential tag changes
local function OnStoned(_, changeType, _, _, unitTag)
    if (changeType == EFFECT_RESULT_UPDATED) then return end

    -- We'll need to remove it anyway even if gaining, so this already handles faded
    local atName = GetUnitDisplayName(unitTag)
    local key = circleKeys[atName]
    if (key) then
        Crutch.Drawing.RemoveGroundCircle(key)
        circleKeys[key] = nil
    end

    if (changeType == EFFECT_RESULT_GAINED) then
        local _, x, y, z = GetUnitRawWorldPosition(unitTag)
        key = Crutch.Drawing.CreateGroundCircle(x, y + 5, z, Crutch.stonedRadius, C.RED_3, nil, nil, false)
        circleKeys[atName] = key
    end
end

local function CleanUp()
    for _, key in pairs(circleKeys) do
        Crutch.Drawing.RemoveGroundCircle(key)
    end
    ZO_ClearTable(circleKeys)
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterHelRaCitadel()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Hel Ra Citadel")

    Crutch.RegisterExitedGroupCombatListener("CrutchHRCStonedExitedCombat", CleanUp)
    Crutch.RegisterForEffectChanged("HRCStoned", OnStoned, 56577, "group")
end

function Crutch.UnregisterHelRaCitadel()
    Crutch.UnregisterExitedGroupCombatListener("CrutchHRCStonedExitedCombat")
    Crutch.UnregisterForEffectChanged("HRCStoned")
    CleanUp()

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Hel Ra Citadel")
end
