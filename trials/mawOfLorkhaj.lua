CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------

---------------------------------------------------------------------
-- ZHAJ'HASSA
---------------------------------------------------------------------
-- {
--     {x=0.55496829748154, y=0.29175475239754},
--     {x=0.56342494487762, y=0.25405216217041},
--     {x=0.60077518224716, y=0.24876673519611},
--     {x=0.62297391891479, y=0.26250880956650},
--     {x=0.64059197902679, y=0.29774489998817},
--     {x=0.62508809566498, y=0.32699084281921},
-- }


---------------------------------------------------------------------
-- TWINS
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Register/Unregister
function Crutch.RegisterMawOfLorkhaj()
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CT]|r Registered Maw of Lorkhaj") end
end

function Crutch.UnregisterMawOfLorkhaj()
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CT]|r Unregistered Maw of Lorkhaj") end
end
