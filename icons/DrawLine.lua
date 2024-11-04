CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Convert in-world coordinates to view via fancy linear algebra.
-- This is ripped almost entirely from OSI, with only minor changes
-- to not modify icons, and instead only return coordinates
-- Credit: OdySupportIcons (@Lamierina7)
--
-- I'm doing this because OSI icons do not show/update when the
-- position is far enough behind the camera, and therefore I can't
-- naively draw a line between 2 player icons, because one or both
-- could be hidden or have outdated coords.
--
-- Returns: x, y, isInFront (of camera)
---------------------------------------------------------------------
local function GetViewCoordinates(wX, wY, wZ)
    -- prepare render space
    Set3DRenderSpaceToCurrentCamera( OSI.ctrl:GetName() )
    
    -- retrieve camera world position and orientation vectors
    local cX, cY, cZ = GuiRender3DPositionToWorldPosition( OSI.ctrl:Get3DRenderSpaceOrigin() )
    local fX, fY, fZ = OSI.ctrl:Get3DRenderSpaceForward()
    local rX, rY, rZ = OSI.ctrl:Get3DRenderSpaceRight()
    local uX, uY, uZ = OSI.ctrl:Get3DRenderSpaceUp()

    -- https://semath.info/src/inverse-cofactor-ex4.html
    -- calculate determinant for camera matrix
    -- local det = rX * uY * fZ - rX * uZ * fY - rY * uX * fZ + rZ * uX * fY + rY * uZ * fX - rZ * uY * fX
    -- local mul = 1 / det
    -- determinant should always be -1
    -- instead of multiplying simply negate
    -- calculate inverse camera matrix
    local i11 = -( uY * fZ - uZ * fY )
    local i12 = -( rZ * fY - rY * fZ )
    local i13 = -( rY * uZ - rZ * uY )
    local i21 = -( uZ * fX - uX * fZ )
    local i22 = -( rX * fZ - rZ * fX )
    local i23 = -( rZ * uX - rX * uZ )
    local i31 = -( uX * fY - uY * fX )
    local i32 = -( rY * fX - rX * fY )
    local i33 = -( rX * uY - rY * uX )
    local i41 = -( uZ * fY * cX + uY * fX * cZ + uX * fZ * cY - uX * fY * cZ - uY * fZ * cX - uZ * fX * cY )
    local i42 = -( rX * fY * cZ + rY * fZ * cX + rZ * fX * cY - rZ * fY * cX - rY * fX * cZ - rX * fZ * cY )
    local i43 = -( rZ * uY * cX + rY * uX * cZ + rX * uZ * cY - rX * uY * cZ - rY * uZ * cX - rZ * uX * cY )

    -- screen dimensions
    local uiW, uiH = GuiRoot:GetDimensions()

    -- calculate unit view position
    local pX = wX * i11 + wY * i21 + wZ * i31 + i41
    local pY = wX * i12 + wY * i22 + wZ * i32 + i42
    local pZ = wX * i13 + wY * i23 + wZ * i33 + i43

    -- calculate unit screen position
    -- Kyz: this is the only thing I did, really. Taking the absolute value of pZ allows the conversion
    -- to still work; the line doesn't draw particularly well, but the idea of it being behind the
    -- camera object is still conveyed. I don't claim to know anything about this math though...
    local w, h = GetWorldDimensionsOfViewFrustumAtDepth(math.abs(pZ))

    return pX * uiW / w, -pY * uiH / h, pZ > 0
end


---------------------------------------------------------------------
-- Draw a hot pink line between 2 arbitrary points on the UI
---------------------------------------------------------------------
local line
local function DrawLineBetweenControls(x1, y1, x2, y2)
    -- Create a line if it doesn't exist
    if (line == nil) then
        Crutch.dbgSpam("|cFF0000creating new line")
        line = WINDOW_MANAGER:CreateControl("$(parent)CrutchLemondsLine", OSI.win, CT_CONTROL)
        local backdrop = WINDOW_MANAGER:CreateControl("$(parent)Backdrop", line, CT_BACKDROP)
        backdrop:SetAnchorFill()
        backdrop:SetCenterColor(1, 0, 1, 1)
        backdrop:SetEdgeColor(1, 1, 1, 1)
    end

    -- The midpoint between the two icons
    local centerX = (x1 + x2) / 2
    local centerY = (y1 + y2) / 2
    line:ClearAnchors()
    line:SetAnchor(CENTER, GuiRoot, CENTER, centerX, centerY)

    -- Set the length of the line and rotate it
    local x = x2 - x1
    local y = y2 - y1
    local length = math.sqrt(x*x + y*y)
    line:SetDimensions(length, 10)
    local angle = math.atan(y/x)
    line:SetTransformRotationZ(-angle)
end


---------------------------------------------------------------------
-- Override OSI.OnUpdate to draw the line after the normal update is done
---------------------------------------------------------------------
local origOSIUpdate
local function DrawLineBetweenPlayers(unitTag1, unitTag2)
    Crutch.dbgOther(zo_strformat("drawing line between <<1>> and <<2>>", GetUnitDisplayName(unitTag1), GetUnitDisplayName(unitTag2)))
    if (line) then
        line:SetHidden(false)
    end

    -- In case this is called twice in a row without a RemoveLine in between
    if (not origOSIUpdate) then
        origOSIUpdate = OSI.OnUpdate

        OSI.OnUpdate = function(...)
            origOSIUpdate(...)
            local x, y, z
            _, x, y, z = GetUnitRawWorldPosition(unitTag1)
            local x1, y1, isInFront1 = GetViewCoordinates(x, y + 100, z) -- about waist level to better match real tethers
            _, x, y, z = GetUnitRawWorldPosition(unitTag2)
            local x2, y2, isInFront2 = GetViewCoordinates(x, y + 100, z)

            if (not isInFront1 and not isInFront2) then
                if (line) then
                    line:SetHidden(true) -- If both players are behind, it just makes a weird line
                end
            else
                if (line) then
                    line:SetHidden(false)
                end
                DrawLineBetweenControls(x1, y1, x2, y2)
            end
        end

        -- Since the function is registered directly for polling, we need to restart the polling with the replaced func
        OSI.StartPolling()
    end
end
Crutch.DrawLineBetweenPlayers = DrawLineBetweenPlayers -- /script CrutchAlerts.DrawLineBetweenPlayers("group1", "group2")

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

