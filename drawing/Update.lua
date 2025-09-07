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

    -- Camera position for z levels
    local cX, cY, cZ
    Set3DRenderSpaceToCurrentCamera("CrutchAlertsDrawingCamera")

    for key, icon in pairs(Draw.activeIcons) do
        -- Update function, mostly for attached icons
        if (icon.updateFunc) then
            local function SetPosition(x, y, z)
                if (icon.x ~= x or icon.z ~= z or icon.y ~= y) then
                    icon.x = x
                    icon.y = y
                    icon.z = z
                    icon.control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y, z))
                end
            end
            icon.updateFunc(icon.control, SetPosition)
        end

        -- Facing camera instead of fixed
        if (icon.faceCamera) then
            if (not fX) then
                fX, fY, fZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceForward()
                rX, rY, rZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceRight()
                uX, uY, uZ = CrutchAlertsDrawingCamera:Get3DRenderSpaceUp()
            end

            icon.control:Set3DRenderSpaceForward(fX, fY, fZ)
            icon.control:Set3DRenderSpaceRight(rX, rY, rZ)
            icon.control:Set3DRenderSpaceUp(uX, uY, uZ)
        end

        -- All controls have the same draw level, so farther away icons might display in front
        -- of closer icons. With depth buffers off, this just draws them on top, and with depth
        -- buffers on, they end up clipping weirdly with the transparent parts of the texture.
        -- So, set the draw level manually based on the distance to the camera.
        if (Crutch.savedOptions.drawing.useLevels) then
            if (not cX) then
                cX, cY, cZ = GuiRender3DPositionToWorldPosition(CrutchAlertsDrawingCamera:Get3DRenderSpaceOrigin())
            end

            local distanceToCamera = math.floor(Crutch.GetSquaredDistance(icon.x, icon.y, icon.z, cX, cY, cZ))
            icon.control:SetDrawLevel(-distanceToCamera)
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
    EVENT_MANAGER:RegisterForUpdate(CrutchAlerts.name .. "DrawingUpdate", Crutch.savedOptions.drawing.interval, DoUpdate)
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

-- To be called from settings only, to update interval
function Draw.ForceRestartPolling()
    EVENT_MANAGER:UnregisterForUpdate(CrutchAlerts.name .. "DrawingUpdate")
    polling = false
    Draw.MaybeStartPolling()
end
