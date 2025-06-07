CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Convert in-world coordinates to view via fancy linear algebra.
-- This is ripped almost entirely from OSI, with only minor changes
-- to not modify icons, and instead only return coordinates
-- Credit: OdySupportIcons (@Lamierina7)
--
-- This is required because one of the points can be behind the
-- camera, so we need to find the intersection of where the line
-- would go off screen and draw that instead.
---------------------------------------------------------------------
local i11, i12, i13, i21, i22, i23, i31, i32, i33, i41, i42, i43
local function CalculateMatrix()
    -- prepare render space
    Set3DRenderSpaceToCurrentCamera(OSI.ctrl:GetName())
    
    -- retrieve camera world position and orientation vectors
    local cX, cY, cZ = GuiRender3DPositionToWorldPosition(OSI.ctrl:Get3DRenderSpaceOrigin())
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
    i11 = -( uY * fZ - uZ * fY )
    i12 = -( rZ * fY - rY * fZ )
    i13 = -( rY * uZ - rZ * uY )
    i21 = -( uZ * fX - uX * fZ )
    i22 = -( rX * fZ - rZ * fX )
    i23 = -( rZ * uX - rX * uZ )
    i31 = -( uX * fY - uY * fX )
    i32 = -( rY * fX - rX * fY )
    i33 = -( rX * uY - rY * uX )
    i41 = -( uZ * fY * cX + uY * fX * cZ + uX * fZ * cY - uX * fY * cZ - uY * fZ * cX - uZ * fX * cY )
    i42 = -( rX * fY * cZ + rY * fZ * cX + rZ * fX * cY - rZ * fY * cX - rY * fX * cZ - rX * fZ * cY )
    i43 = -( rZ * uY * cX + rY * uX * cZ + rX * uZ * cY - rX * uY * cZ - rY * uZ * cX - rZ * uX * cY )
end

local function GetViewCoordinates(wX, wY, wZ)
    -- calculate unit view position
    local pX = wX * i11 + wY * i21 + wZ * i31 + i41
    local pY = wX * i12 + wY * i22 + wZ * i32 + i42
    local pZ = wX * i13 + wY * i23 + wZ * i33 + i43
    return pX, pY, pZ
end

local function GetLineViewCoordinates(worldX1, worldY1, worldZ1, worldX2, worldY2, worldZ2)
    local pX1, pY1, pZ1 = GetViewCoordinates(worldX1, worldY1, worldZ1)
    local pX2, pY2, pZ2 = GetViewCoordinates(worldX2, worldY2, worldZ2)

    -- near clip plane code from Breadcrumbs (@TheMrPancake)
    local nearZ = 0.1
    if pZ1 < nearZ and pZ2 < nearZ then
        return nil -- Both behind, don't draw line
    end
    if pZ1 < 0 or pZ2 < 0 then -- find point on plane
        local t = (nearZ - pZ1) / (pZ2 - pZ1)
        local clipX = pX1 + t * (pX2 - pX1)
        local clipY = pY1 + t * (pY2 - pY1)
        if pZ1 < 0 then
            pX1, pY1, pZ1 = clipX, clipY, nearZ
        else 
            pX2, pY2, pZ2 = clipX, clipY, nearZ
        end
    end

    -- calculate unit screen position
    local w1, h1 = GetWorldDimensionsOfViewFrustumAtDepth(pZ1)
    local w2, h2 = GetWorldDimensionsOfViewFrustumAtDepth(pZ2)

    -- screen dimensions
    local uiW, uiH = GuiRoot:GetDimensions()

    return pX1 * uiW / w1, -pY1 * uiH / h1, pX2 * uiW / w2, -pY2 * uiH / h2
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
    CalculateMatrix()
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
    local x1, y1, x2, y2 = GetLineViewCoordinates(worldX1, worldY1, worldZ1, worldX2, worldY2, worldZ2)

    if (not x1) then
        return false
    end

    DrawLineBetween2DPoints(x1, y1, x2, y2, lineNum)
    return true
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
        local _, worldX1, worldY1, worldZ1, worldX2, worldY2, worldZ2
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

