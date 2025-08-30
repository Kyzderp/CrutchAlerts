CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.Drawing = CrutchAlerts.Drawing or {}
local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

---------------------------------------------------------------------
-- wow, using a pool for the first time instead of making my own janky version
local controlPool
Draw.activeIcons = {} -- {[key] = {control = control, faceCamera = true, x = x, y = y, z = z, updateFunc = function() end}}

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
local function Create3DControl(texture, x, y, z, width, height, color, useDepthBuffer)
    local control, key = AcquireTexture()
    control:SetTexture(texture)
    control:SetColor(unpack(color))
    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y, z))
    control:Set3DLocalDimensions(width, height)
    control:Set3DRenderSpaceUsesDepthBuffer(useDepthBuffer)
    return control, key
end

---------------------------------------------------------------------
-- Creating and removing icons
---------------------------------------------------------------------
local function CreateWorldIcon(texture, x, y, z, width, height, color, useDepthBuffer, faceCamera, updateFunc)
    local control, key = Create3DControl(texture, x, y, z, width, height, color, useDepthBuffer)
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
    return CreateWorldIcon(texture, x, y, z, size / 150, size / 150, color, true, true)
end
Draw.CreatePlacedIcon = CreatePlacedIcon

local function RemovePlacedIcon(key)
    RemoveWorldIcon(key)
end
Draw.RemovePlacedIcon = RemovePlacedIcon

---------------------------------------------------------------------
-- Testing for now
---------------------------------------------------------------------
local num = 1

local function TestBooger(faceCamera, color)
    color = color or {1, 1, 1, 1}

    local _, x, y, z = GetUnitWorldPosition("player")

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


---------------------------------------------------------------------
-- Init 3D render space and stuff idk
---------------------------------------------------------------------
function Draw.Initialize()
    CrutchAlertsDrawingCamera:Create3DRenderSpace()
    controlPool = ZO_ControlPool:New("CrutchAlertsDrawingTexture", CrutchAlertsDrawing)
    Draw.InitializeAttachedIcons()
end
