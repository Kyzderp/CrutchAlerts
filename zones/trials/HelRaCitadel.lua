local Crutch = CrutchAlerts
local C = Crutch.Constants

---------------------------------------------------------------------
-- Stone Form circle
---------------------------------------------------------------------
local circleKeys = {} -- [atName] = key -- store using @name because of potential tag changes
local function OnStoned(_, changeType, _, _, unitTag)
    if (changeType == EFFECT_RESULT_UPDATED) then return end

    -- We'll need to remove it anyway even if gaining, so this already handles faded
    local atName = GetUnitDisplayName(unitTag)
    local key = circleKeys[atName]
    if (key) then
        Crutch.Drawing.RemoveGroundCircle(key)
        circleKeys[atName] = nil
    end

    if (changeType == EFFECT_RESULT_GAINED) then
        local _, x, y, z = GetUnitRawWorldPosition(unitTag)

        -- Make circle follow the player because the player could be in motion as they gain Stone Form
        local function CircleFunc(icon)
            local _, x, y, z = GetUnitRawWorldPosition(unitTag)
            icon:SetPosition(x, y, z)
        end

        key = Crutch.Drawing.CreateGroundCircle(x, y, z, 8, C.RED_2, nil, CircleFunc, false)
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

    if (Crutch.savedOptions.helracitadel.showStoneFormCircle) then
        Crutch.RegisterForEffectChanged("HRCStoned", OnStoned, 56577, "group")
    end
end

function Crutch.UnregisterHelRaCitadel()
    Crutch.UnregisterExitedGroupCombatListener("CrutchHRCStonedExitedCombat")
    Crutch.UnregisterForEffectChanged("HRCStoned")
    CleanUp()

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Hel Ra Citadel")
end
