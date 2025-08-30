CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.Drawing = CrutchAlerts.Drawing or {}
local Crutch = CrutchAlerts
local Draw = Crutch.Drawing


---------------------------------------------------------------------
-- Update
-- This is run continuously to update icons if needed
---------------------------------------------------------------------
local function DoUpdate()
    -- Get the camera matrix once per update; the same values are applied to each control
    local fX, fY, fZ
    local rX, rY, rZ
    local uX, uY, uZ

    for _, icon in pairs(Draw.activeIcons) do
        if (icon.faceCamera) then
            if (not fX) then
                Set3DRenderSpaceToCurrentCamera("CrutchAlertsDrawingCamera")
                fX, fY, fZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceForward()
                rX, rY, rZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceRight()
                uX, uY, uZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceUp()
            end

            icon.control:Set3DRenderSpaceForward(fX, fY, fZ)
            icon.control:Set3DRenderSpaceRight(rX, rY, rZ)
            icon.control:Set3DRenderSpaceUp(uX, uY, uZ)
        end
    end
end

---------------------------------------------------------------------
-- Starting/stopping updates based on whether there are icons
---------------------------------------------------------------------
local polling = false
function Draw.MaybeStartPolling()
    if (polling) then return end

    -- Only start polling if there are icons
    local hasIcons = false
    for _, _ in pairs(Draw.activeIcons) do
        hasIcons = true
        break
    end

    if (not hasIcons) then return end

    -- Has icons, can start polling
    EVENT_MANAGER:RegisterForUpdate(CrutchAlerts.name .. "DrawingUpdate", 10, DoUpdate)
    polling = true
end

function Draw.MaybeStopPolling()
    if (not polling) then return end

    -- Only stop polling if there are no more icons
    local hasIcons = false
    for _, _ in pairs(Draw.activeIcons) do
        hasIcons = true
        break
    end

    if (hasIcons) then return end

    -- No more icons, can stop polling
    EVENT_MANAGER:UnregisterForUpdate(CrutchAlerts.name .. "DrawingUpdate")
    polling = false
end
