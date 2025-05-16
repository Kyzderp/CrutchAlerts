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
-- Multiple lines struct
---------------------------------------------------------------------
local lines = {} -- {[1] = control, [2] = control}

local function GetLineControl(num)
    if (not lines[num]) then
        Crutch.dbgSpam("|cFF0000creating new line " .. tostring(num))
        local line = WINDOW_MANAGER:CreateControl("$(parent)CrutchTetherLine" .. tostring(num), OSI.win, CT_CONTROL)
        local backdrop = WINDOW_MANAGER:CreateControl("$(parent)Backdrop", line, CT_BACKDROP)
        backdrop:ClearAnchors()
        backdrop:SetAnchorFill()
        backdrop:SetCenterColor(1, 0, 1, 1)
        backdrop:SetEdgeColor(1, 1, 1, 1)

        local distanceLabel = WINDOW_MANAGER:CreateControl("$(parent)Label", line, CT_LABEL)
        distanceLabel:ClearAnchors()
        distanceLabel:SetAnchor(CENTER, line, CENTER)
        distanceLabel:SetFont("$(BOLD_FONT)|30|outline")
        distanceLabel:SetText("42m")

        lines[num] = line
    end

    return lines[num]
end

---------------------------------------------------------------------
-- Draw a line between 2 arbitrary points on the UI
---------------------------------------------------------------------
local function DrawLineBetween2DPoints(x1, y1, x2, y2, lineNum)
    if (not lineNum) then
        lineNum = 1
    end

    -- Create a line if it doesn't exist
    local line = GetLineControl(lineNum)

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

local function SetLineColor(r, g, b, a, edgeA, showLabel, lineNum)
    if (not lineNum) then
        lineNum = 1
    end

    local line = GetLineControl(lineNum)
    local backdrop = line:GetNamedChild("Backdrop")
    backdrop:SetCenterColor(r, g, b, a or 1)
    backdrop:SetEdgeColor(1, 1, 1, edgeA or 1)

    if (showLabel) then
        line:GetNamedChild("Label"):SetHidden(false)
    else
        line:GetNamedChild("Label"):SetHidden(true)
    end
end
Crutch.SetLineColor = SetLineColor
-- /script CrutchAlerts.SetLineColor(1, 0, 0, 0.5, 0.5) CrutchAlerts.DrawLineBetweenPlayers("group1", "group2")


---------------------------------------------------------------------
-- Polling per frame
---------------------------------------------------------------------
local activeLineFunctions = {}

local function OnUpdate()
    for _, lineFunction in pairs(activeLineFunctions) do
        lineFunction()
    end
end

local function StopPolling()
    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "PollLine")
end

local function StartPolling()
    StopPolling()
    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "PollLine", 10, OnUpdate) -- TODO: interval setting
end


---------------------------------------------------------------------
-- Line-drawing
---------------------------------------------------------------------
-- Returns: whether the line should be visible
local function DrawLineBetween3DPoints(worldX1, worldY1, worldZ1, worldX2, worldY2, worldZ2, lineNum)
    local x1, y1, isInFront1 = GetViewCoordinates(worldX1, worldY1, worldZ1)
    local x2, y2, isInFront2 = GetViewCoordinates(worldX2, worldY2, worldZ2)

    if (not isInFront1 and not isInFront2) then
        return false
    else
        DrawLineBetween2DPoints(x1, y1, x2, y2, lineNum)
        return true
    end
end

-- Draw line between 2 unit tags
local function DrawLineBetweenPlayers(unitTag1, unitTag2, distanceCallback, lineNum)
    Crutch.dbgOther(zo_strformat("drawing line between <<1>> and <<2>>", GetUnitDisplayName(unitTag1), GetUnitDisplayName(unitTag2)))

    if (not lineNum) then
        lineNum = 1
    end
    local line = GetLineControl(lineNum)
    line:SetHidden(false)

    -- Write a function that will be called on every update
    local myLineFunction = function()
        local worldX1, worldY1, worldZ1, worldX2, worldY2, worldZ2
        _, worldX1, worldY1, worldZ1 = GetUnitRawWorldPosition(unitTag1)
        _, worldX2, worldY2, worldZ2 = GetUnitRawWorldPosition(unitTag2)
        -- about waist level to better match real tethers
        local visible = DrawLineBetween3DPoints(worldX1, worldY1 + 100, worldZ1, worldX2, worldY2 + 100, worldZ2, lineNum)
        line:SetHidden(not visible)

        local dist = Crutch.GetUnitTagsDistance(unitTag1, unitTag2)
        line:GetNamedChild("Label"):SetText(string.format("%.02f m", dist))

        -- distanceCallback is a func that takes the distance between the players (since we're using it here anyway)
        if (distanceCallback) then
            distanceCallback(dist)
        end
    end

    activeLineFunctions[lineNum] = myLineFunction
    StartPolling()
end
Crutch.DrawLineBetweenPlayers = DrawLineBetweenPlayers -- /script CrutchAlerts.DrawLineBetweenPlayers("group1", "group2")

-- Draws a line that uses the endpoints provided by a function
local function DrawLineWithProvider(endpointsProvider, lineNum)
    Crutch.dbgOther("drawing line based on callback")
    if (not lineNum) then
        lineNum = 1
    end
    local line = GetLineControl(lineNum)
    line:SetHidden(false)

    -- Write a function that will be called on every update
    local myLineFunction = function()
        local x1, y1, z1, x2, y2, z2 = endpointsProvider()
        local visible = DrawLineBetween3DPoints(x1, y1, z1, x2, y2, z2, lineNum)
        line:SetHidden(not visible)
    end

    activeLineFunctions[lineNum] = myLineFunction
    StartPolling()
end
Crutch.DrawLineWithProvider = DrawLineWithProvider
-- /script _, x, y, z = GetUnitRawWorldPosition("player")
-- /script local _, x2, y2, z2 = GetUnitRawWorldPosition("player") CrutchAlerts.DrawLineWithProvider(function() return x, y, z, x2, y2, z2 end, 3)
-- /script _, x3, y3, z3 = GetUnitRawWorldPosition("player")
-- /script local _, x2, y2, z2 = GetUnitRawWorldPosition("player") CrutchAlerts.DrawLineWithProvider(function() return x3, y3, z3, x2, y2, z2 end, 4)

-- Remove line and possibly stop polling
local function RemoveLine(lineNum)
    if (not lineNum) then
        lineNum = 1
    end

    local line = GetLineControl(lineNum)
    if (line) then
        line:SetHidden(true)
    end

    activeLineFunctions[lineNum] = nil

    -- If there are no more active lines, stop polling
    for _, _ in pairs(activeLineFunctions) do
        return
    end
    StopPolling()
end
Crutch.RemoveLine = RemoveLine -- /script CrutchAlerts.RemoveLine()

