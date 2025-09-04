CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.Drawing = CrutchAlerts.Drawing or {}
local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

---------------------------------------------------------------------
-- wow, using a pool for the first time instead of making my own janky version
local controlPool
Draw.activeIcons = {} -- {[key] = {control = control, faceCamera = true, x = x, y = y, z = z, updateFunc = function() end}}
-- /script d(CrutchAlerts.Drawing.activeIcons)

local function AcquireTexture()
    local control, key = controlPool:AcquireObject()

    control:SetHidden(false)
    control:Create3DRenderSpace()
    control:SetColor(1, 1, 1, 1)

    return control, key
end

---------------------------------------------------------------------
-- The core 3D code, at its simplest... or close to it
---------------------------------------------------------------------
-- forwardRightUp = {{fX}}
local function Create3DControl(texture, x, y, z, width, height, color, useDepthBuffer, forwardRightUp)
    local control, key = AcquireTexture()
    control:SetTexture(texture)
    control:SetColor(unpack(color))
    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y, z))
    control:Set3DLocalDimensions(width, height)
    control:Set3DRenderSpaceUsesDepthBuffer(useDepthBuffer)

    if (forwardRightUp) then
        control:Set3DRenderSpaceForward(unpack(forwardRightUp[1]))
        control:Set3DRenderSpaceRight(unpack(forwardRightUp[2]))
        control:Set3DRenderSpaceUp(unpack(forwardRightUp[3]))
    end
    return control, key
end

---------------------------------------------------------------------
-- Creating and removing icons
---------------------------------------------------------------------
local function CreateWorldIcon(texture, x, y, z, width, height, color, useDepthBuffer, faceCamera, forwardRightUp, updateFunc)
    local control, key = Create3DControl(texture, x, y, z, width, height, color, useDepthBuffer, forwardRightUp)
    Draw.activeIcons[key] = {
        control = control,
        faceCamera = faceCamera,
        x = x,
        y = y,
        z = z,
        updateFunc = updateFunc,
    }
    Draw.MaybeStartPolling()

    CrutchAlerts.dbgSpam("Created icon |t100%:100%:" .. texture .. "|t key " .. tostring(key))
    return key
end
Draw.CreateWorldIcon = CreateWorldIcon

local function RemoveWorldIcon(key)
    if (not Draw.activeIcons[key]) then
        CrutchAlerts.dbgOther("|cFF0000Icon \"" .. tostring(key) .. "\" does not exist")
        return
    end
    CrutchAlerts.dbgSpam("Removing icon " .. tostring(key))

    local icon = Draw.activeIcons[key]
    icon.control:Destroy3DRenderSpace()
    icon.control:SetHidden(true)
    controlPool:ReleaseObject(key)
    Draw.activeIcons[key] = nil
    Draw.MaybeStopPolling()
end
Draw.RemoveWorldIcon = RemoveWorldIcon

---------------------------------------------------------------------
-- For calling from WorldIcons, migration from OSI
---------------------------------------------------------------------
local function CreatePlacedIcon(texture, x, y, z, size, color)
    color = color or {1, 1, 1, 1}
    return CreateWorldIcon(texture, x, y, z, size / 150, size / 150, color, false, true)
end
Draw.CreatePlacedIcon = CreatePlacedIcon

local function RemovePlacedIcon(key)
    RemoveWorldIcon(key)
end
Draw.RemovePlacedIcon = RemovePlacedIcon

---------------------------------------------------------------------
---------------------------------------------------------------------
local function CreateGroundCircle(x, y, z, radius, color, useDepthBuffer, forwardRightUp)
    if (not x) then
        _, x, y, z = GetUnitRawWorldPosition("player")
    end

    forwardRightUp = forwardRightUp or {
        {0, -1, 0},
        {-1, 0, 0},
        {0, 0, 1},
    }
    radius = radius or 12
    local size = radius * 2

    color = color or {1, 0, 0, 1}

    return CreateWorldIcon("CrutchAlerts/assets/floor/circle.dds", x, y, z, size, size, color, useDepthBuffer, false, forwardRightUp)
end
Draw.CreateGroundCircle = CreateGroundCircle

---------------------------------------------------------------------
-- Testing for now
---------------------------------------------------------------------
local num = 1

local function TestBooger(faceCamera, color)
    color = color or {1, 1, 1, 1}

    local _, x, y, z = GetUnitRawWorldPosition("player")

    CreateWorldIcon("esoui/art/icons/targetdummy_voriplasm_01.dds", x, y + 50, z, 1, 1, color, true, faceCamera)
end
Draw.TestBooger = TestBooger
-- /script CrutchAlerts.Drawing.TestBooger(true)
-- /script CrutchAlerts.Drawing.TestBooger(false)
--[[
/script local a = CrutchAlerts.Drawing.activeIcons
d(a[1].control:GetDrawLevel())
d(a[2].control:GetDrawLevel())
a[1].control:SetDrawLevel(10)
]]

local function TestJet(size)
    local start = 90000
    local forwardRightUp = {
        {0, 0, 1},
        {-1, 0, 0},
        {0, 1, 0},
    }
    local width = size or 20
    local height = width / 600 * 128
    local key = CreateWorldIcon("CrutchAlerts/assets/jet.dds", 98000, 44000, 101500, width, height, {1, 1, 1, 1}, true, false, forwardRightUp, function(control, setPositionFunc)
        start = start + 15
        setPositionFunc(start, 44000, 106000)
    end)

    zo_callLater(function() RemoveWorldIcon(key) end, 30000)
end
Draw.TestJet = TestJet
-- /script CrutchAlerts.Drawing.TestJet()
-- /script d("|t100%:100%:CrutchAlerts/assets/jet.dds|t")
-- /script d("|t100%:100%:CrutchAlerts/assets/directional/N.dds|t")

local lastKey
local function TestCircle(radius, x, y, z, useDepthBuffer)
    if (lastKey) then
        RemoveWorldIcon(lastKey)
    end
    if (not x) then
        _, x, y, z = GetUnitRawWorldPosition("player")
    end

    local forwardRightUp = {
        {0, -1, 0},
        {-1, 0, 0},
        {0, 0, 1},
    }
    radius = radius or 12
    local size = radius * 2

    lastKey = CreateWorldIcon("CrutchAlerts/assets/floor/circle.dds", x, y, z, size, size, {1, 0, 0, 1}, useDepthBuffer, false, forwardRightUp)
end
Draw.TestCircle = TestCircle
--[[
/script CrutchAlerts.Drawing.TestCircle()
/script
Set3DRenderSpaceToCurrentCamera("CrutchAlertsDrawingCamera")
d(CrutchAlertsDrawingCamera:Get3DRenderSpaceForward())
d(CrutchAlertsDrawingCamera:Get3DRenderSpaceRight())
d(CrutchAlertsDrawingCamera:Get3DRenderSpaceUp())
]]


---------------------------------------------------------------------
-- Init 3D render space and stuff idk
---------------------------------------------------------------------
function Draw.Initialize()
    CrutchAlertsDrawingCamera:Create3DRenderSpace()
    controlPool = ZO_ControlPool:New("CrutchAlertsDrawingTexture", CrutchAlertsDrawing)
    Draw.InitializeAttachedIcons()
end
