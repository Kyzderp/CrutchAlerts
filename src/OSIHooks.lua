CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Override UnitErrorCheck
---------------------------------------------------------------------
local origOSIUnitErrorCheck

-- Show icon for self
local function SelfMechanicUnitErrorCheck(...)
    local error = origOSIUnitErrorCheck(...)
    if (error == 2) then
        return 0
    end
    return error
end

function Crutch.SetMechanicIconForUnit(atName, iconPath)
    OSI.SetMechanicIconForUnit(atName, iconPath)

    if (not origOSIUnitErrorCheck and atName == GetUnitDisplayName("player")) then
        Crutch.dbgSpam("Overriding OSI.UnitErrorCheck to show mechanic for self")
        origOSIUnitErrorCheck = OSI.UnitErrorCheck

        OSI.UnitErrorCheck = SelfMechanicUnitErrorCheck
    end
end

function Crutch.RemoveMechanicIconForUnit(atName)
    OSI.RemoveMechanicIconForUnit(atName)

    if (origOSIUnitErrorCheck and atName == GetUnitDisplayName("player")) then
        Crutch.dbgSpam("Restoring OSI.UnitErrorCheck to normal")
        OSI.UnitErrorCheck = origOSIUnitErrorCheck
    end
end
