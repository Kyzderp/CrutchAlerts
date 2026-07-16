local Crutch = CrutchAlerts
local C = Crutch.Constants

---------------------------------------------------------------------
---------------------------------------------------------------------
local circleKeys = {}
local function OnStoned(_, changeType, _, _, unitTag)
end

local function CleanUp()
    for key, _ in pairs(circleKeys) do
        -- TODO: remove
    end
    ZO_ClearTable(circleKeys)
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterHelRaCitadel()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Hel Ra Citadel")
end

function Crutch.UnregisterHelRaCitadel()
    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Hel Ra Citadel")
end
