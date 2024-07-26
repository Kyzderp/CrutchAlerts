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

function Crutch.SetMechanicIconForUnit(atName, iconPath, size, color)
    OSI.SetMechanicIconForUnit(atName, iconPath, size, color)

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

---------------------------------------------------------------------
-- Is the player or their group in combat? Assume player is already
-- not in combat.
---------------------------------------------------------------------
local function IsInEncounter()
    if (not IsUnitGrouped("player")) then
        return false
    end

    for i = 1, GetGroupSize() do
        local groupTag = "group" .. i
        if (IsUnitInCombat(groupTag) and IsUnitOnline(groupTag)) then
            return groupTag
        end
    end
    return false
end

---------------------------------------------------------------------
-- OSI.ResetMechanicIcons
-- The problem with this function is that it's called every time on
-- OSI update. If the player is not personally in combat, then the
-- mechanic icons get completely reset. We don't want this, because
-- dying during a group encounter (sometimes?) triggers this. So, 
-- override OSI to not reset if anyone in the group is in combat.
--
-- /script OSI.SetMechanicIconForUnit("@TheClawlessConqueror", "odysupporticons/icons/squares/squaretwo_blue.dds")
---------------------------------------------------------------------
local origOSIResetMechanicIcons
local function OnCombatStateChanged(_, inCombat)
    if (inCombat) then
        -- Entered combat, could be from entering a fight or from rezzing, anything else?
        Crutch.dbgSpam("entered combat")
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "CombatStateUpdate")
        if (not origOSIResetMechanicIcons) then
            -- Sub out OSI to not reset mech icons
            origOSIResetMechanicIcons = OSI.ResetMechanicIcons
            OSI.ResetMechanicIcons = function() end
        end
    else
        -- Exited combat, could be from dying though, or stepping through cloudrest portal too
        local inCombatUnit = IsInEncounter()
        if (inCombatUnit) then
            Crutch.dbgSpam(string.format("personally exited combat but %s(%s) is in combat", GetUnitDisplayName(inCombatUnit), inCombatUnit))
            -- Check again in a few seconds
            EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "CombatStateUpdate", 1000, function() OnCombatStateChanged(_, IsUnitInCombat("player")) end)
        else
            Crutch.dbgSpam("exited combat")
            EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "CombatStateUpdate")
            if (origOSIResetMechanicIcons) then
                -- Restore OSI
                OSI.ResetMechanicIcons = origOSIResetMechanicIcons
            end
        end
    end
end

---------------------------------------------------------------------
-- Override OSI.OnUpdate to draw an extra line
---------------------------------------------------------------------
local line
local function DrawLineBetweenControls(first, second)
    -- Create a line if it doesn't exist
    if (line == nil) then
        Crutch.dbgSpam("|cFF0000creating new line")
        line = WINDOW_MANAGER:CreateControl("$(parent)Line", OSI.win, CT_CONTROL)
        local backdrop = WINDOW_MANAGER:CreateControl("$(parent)Backdrop", line, CT_BACKDROP)
        backdrop:SetAnchorFill()
        backdrop:SetCenterColor(1, 0, 1, 1)
        backdrop:SetEdgeColor(1, 1, 1, 1)
    end

    -- Use the BOTTOM of the controls as the "anchor" points
    local x1, _ = first:GetCenter()
    local y1 = first:GetBottom()
    local x2, _ = second:GetCenter()
    local y2 = second:GetBottom()
    
    -- The midpoint between the two icons
    local centerX = (x1 + x2) / 2
    local centerY = (y1 + y2) / 2
    line:ClearAnchors()
    line:SetAnchor(CENTER, GuiRoot, TOPLEFT, centerX, centerY)

    -- Set the length of the line and rotate it
    local x = x2 - x1
    local y = y2 - y1
    local length = math.sqrt(x*x + y*y)
    line:SetDimensions(length, 10)
    local angle = math.atan(y/x)
    line:SetTransformRotationZ(-angle)
end

-- Override OSI.OnUpdate to draw the line after the normal update is done
local origOSIUpdate
local function DrawLineBetweenPlayers(atName1, atName2)
    Crutch.dbgOther(zo_strformat("drawing line between <<1>> and <<2>>", atName1, atName2))
    if (line) then
        line:SetHidden(false)
    end

    -- In case this is called twice in a row without a RemoveLine in between
    if (not origOSIUpdate) then
        origOSIUpdate = OSI.OnUpdate

        OSI.OnUpdate = function(...)
            origOSIUpdate(...)
            DrawLineBetweenControls(OSI.GetIconForPlayer(atName1).ctrl, OSI.GetIconForPlayer(atName2).ctrl)
        end

        -- Since the function is registered directly for polling, we need to restart the polling with the replaced func
        OSI.StartPolling()
    end
end
Crutch.DrawLineBetweenPlayers = DrawLineBetweenPlayers -- /script CrutchAlerts.DrawLineBetweenPlayers("@", "@")

-- Remove line by restoring the original OSI.OnUpdate
local function RemoveLine()
    if (origOSIUpdate) then
        OSI.OnUpdate = origOSIUpdate
        origOSIUpdate = nil
        OSI.StartPolling()
    end
    if (line) then
        line:SetHidden(true)
    end
end
Crutch.RemoveLine = RemoveLine -- /script CrutchAlerts.RemoveLine()


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Crutch.InitializeHooks()
    if (OSI) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "OSIHookCombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    end
end
