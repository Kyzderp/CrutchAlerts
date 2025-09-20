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
            -- Callback to set position, keeping old if nil
            local function SetPosition(x, y, z)
                if (icon.x ~= x or icon.z ~= z or icon.y ~= y) then
                    icon.x = x or icon.x
                    icon.y = y or icon.y
                    icon.z = z or icon.z
                    icon.control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(icon.x, icon.y, icon.z))
                end
            end

            -- Callback to set color, keeping old if nil
            local function SetColor(r, g, b, a)
                -- Not sure if doing this is actually more efficient
                local changed = false
                if (r and icon.color.r ~= r) then
                    icon.color.r = r
                    changed = true
                end
                if (g and icon.color.g ~= g) then
                    icon.color.g = g
                    changed = true
                end
                if (b and icon.color.b ~= b) then
                    icon.color.b = b
                    changed = true
                end
                if (a and icon.color.a ~= a) then
                    icon.color.a = a
                    changed = true
                end
                if (changed) then
                    icon.control:SetColor(icon.color.r, icon.color.g, icon.color.b, icon.color.a)
                end
            end

            -- Callback to set orientation, keeping old if nil
            -- Either ({fX, fY, fZ}, {rX, rY, rZ}, {uX, uY, uZ}) or (pitch, yaw, roll)
            local function SetOrientation(first, second, third)
                local function IsDOF(value)
                    return type(value) == "number"
                end
                local value = first or second or third
                local isDOF = IsDOF(value)
                if (isDOF == IsDOF(icon.orientation)) then
                    first = first or icon.orientation.first
                    second = second or icon.orientation.second
                    third = third or icon.orientation.third
                else
                    -- New orientation type is different from old
                    if (not first and not second and not third) then
                        return -- It's fine if it's all nil, but why is it being called...?
                    end

                    if (not first or not second or not third) then
                        CrutchAlerts.msg("|cFF0000Caller attempted to set different orientation axis system but not all values are specified!")
                        return
                    end
                end

                if (isDOF) then
                    -- Pitch, Yaw, Roll
                    if (icon.orientation.first ~= first or icon.orientation.second ~= second or icon.orientation.third ~= third) then
                        icon.orientation.first = first
                        icon.orientation.second = second
                        icon.orientation.third = third
                        icon.control:Set3DRenderSpaceOrientation(first, second, third)
                    end
                else
                    -- Forward, Right, Up
                    if (icon.orientation.first ~= first) then
                        icon.orientation.first = first
                        icon.control:Set3DRenderSpaceForward(unpack(first))
                    end
                    if (icon.orientation.second ~= second) then
                        icon.orientation.second = second
                        icon.control:Set3DRenderSpaceRight(unpack(second))
                    end
                    if (icon.orientation.third ~= third) then
                        icon.orientation.third = third
                        icon.control:Set3DRenderSpaceUp(unpack(third))
                    end
                end
            end

            -- Callback to set texture, keeping old if nil
            local function SetTexture(path)
                if (path and icon.texture ~= path) then
                    icon.texture = path
                    icon.control:SetTexture(path)
                end
            end

            icon.updateFunc(icon.control, SetPosition, SetColor, SetOrientation, SetTexture)
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
        -- Things can still appear off if a small texture overlaps a large texture, because the
        -- center of the large texture is closer, but the small should be above. Oh well.
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
    if (not next(Draw.activeIcons)) then
        return
    end

    -- Has icons, can start polling
    EVENT_MANAGER:RegisterForUpdate(CrutchAlerts.name .. "DrawingUpdate", Crutch.savedOptions.drawing.interval, DoUpdate)
    polling = true

    -- Also run once immediately
    DoUpdate()
end

function Draw.MaybeStopPolling()
    if (not polling) then return end

    -- Only stop polling if there are no more icons
    if (next(Draw.activeIcons)) then
        return
    end

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
