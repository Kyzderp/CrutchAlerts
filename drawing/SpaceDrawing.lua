local Crutch = CrutchAlerts
local Draw = Crutch.Drawing
local C = Crutch.Constants

---------------------------------------------------------------------
local controlPool

local function AcquireControl()
    local control, key = controlPool:AcquireObject()
    control:SetTransformNormalizedOriginPoint(0.5, 0.5)

    control:SetHidden(false)
    control:SetTransformScale(0.01)

    control:SetAnchor(CENTER, GuiRoot, CENTER)

    -- To not clash with RenderSpace keys when put in Draw.activeIcons together
    local spaceKey = "Space" .. key
    return control, spaceKey
end


---------------------------------------------------------------------
-- Core
---------------------------------------------------------------------
local function CreateSpaceControlCommon(x, y, z, orientation)
    local control, key = AcquireControl()

    -- Position is a bit different from RenderSpace
    local oX, oY, oZ = GuiRender3DPositionToWorldPosition(0, 0, 0)
    local tX = (x - oX) / 100
    local tY = y / 100
    local tZ = (z - oZ) / 100
    control:SetTransformOffset(tX, tY, tZ)

    -- pitch, yaw, roll
    control:SetTransformRotation(unpack(orientation))
    return control, key
end

local function ReleaseSpaceControl(key)
    local icon = Draw.activeIcons[key]

    icon.control:SetHidden(true)
    icon.control:GetNamedChild("Backdrop"):SetHidden(true)
    icon.control:GetNamedChild("Backdrop"):SetAlpha(1)
    icon.control:GetNamedChild("Backdrop"):SetScale(1)
    icon.control:GetNamedChild("Texture"):SetHidden(true)
    icon.control:GetNamedChild("Texture"):SetAlpha(1)
    icon.control:GetNamedChild("Texture"):SetScale(1)
    icon.control:GetNamedChild("Composite"):SetHidden(true)
    icon.control:GetNamedChild("Composite"):ClearAllSurfaces()
    icon.control:GetNamedChild("Composite"):SetAlpha(1)
    icon.control:GetNamedChild("Composite"):SetScale(1)
    icon.control:GetNamedChild("Label"):SetHidden(true)
    icon.control:GetNamedChild("Label"):SetAlpha(1)
    icon.control:GetNamedChild("Label"):SetScale(1)

    local realKey = tonumber(string.sub(key, 6))
    controlPool:ReleaseObject(realKey)
end
Draw.ReleaseSpaceControl = ReleaseSpaceControl


---------------------------------------------------------------------
-- Texture, similar to RenderSpace
-- DO NOT CALL THIS DIRECTLY. See Draw.CreateWorldTexture for entry
-- point (except that's not the recommended entry point either...)
---------------------------------------------------------------------
local function CreateSpaceTexture(texture, x, y, z, width, height, color, orientation)
    local control, key = CreateSpaceControlCommon(x, y, z, orientation)

    local textureControl = control:GetNamedChild("Texture")
    textureControl:SetHidden(false)
    textureControl:SetTexture(texture)
    textureControl:SetColor(unpack(color))
    textureControl:SetScale(width)

    return control, key
end
Draw.CreateSpaceTexture = CreateSpaceTexture


---------------------------------------------------------------------
-- Update functions
---------------------------------------------------------------------
local function SetText(icon, text)
    local label = icon.control:GetNamedChild("Label")
    if (label:GetText() ~= text) then
        label:SetText(text)
        label:SetDimensions(2000, 2000)
        label:SetDimensions(label:GetTextWidth(), label:GetTextHeight())
    end
end

local function SetBackdropColors(icon, centerR, centerG, centerB, centerA, edgeR, edgeG, edgeB, edgeA)
    local backdrop = icon.control:GetNamedChild("Backdrop")

    if (centerR or centerG or centerB) then
        backdrop:SetCenterColor(centerR, centerG, centerB, centerA)
    end

    if (edgeR or edgeG or edgeB) then
        backdrop:SetEdgeColor(edgeR, edgeG, edgeB, edgeA)
    end
end

local function SetBackdropRoll(icon, roll)
    icon.control:GetNamedChild("Backdrop"):SetTransformRotation(0, 0, roll)
end

---------------------------------------------------------------------
-- Generic public API
-- @param options: table with options for which elements to enable
--[[
options = {
    label = {
        text = "Hello world",
        size = 100,
        color = {0.5, 1, 0.6, 0.8},
    },
    texture = {
        path = "CrutchAlerts/assets/poop.dds",
        size = 0.8,
        color = {1, 1, 1, 0.7},
    },
    backdrop = {
        width = 100,
        height = 100,
        centerColor = {0, 0, 1, 1},
        edgeColor = {0, 0, 0.2, 1},
        roll = math.pi/4,
    },
    composite = {
        -- Init callback to use the ZOS APIs upon control creation, because it's too complicated to add wrappers
        init = function(composite)
            composite:SetTexture("CrutchAlerts/assets/poop.dds")
            local surfaceIndex = composite:AddSurface(0, 0.5, 0, 1)
            composite:SetInsets(surfaceIndex, 0, 0, 0, 0)
            surfaceIndex = composite:AddSurface(0.5, 1, 0, 1)
            composite:SetInsets(surfaceIndex, 0, 0, 0, 0)
        end,
        size = 0.8,
    },
}
]]
---------------------------------------------------------------------
local function CreateSpaceControl(x, y, z, faceCamera, orientation, options, updateFunc)
    orientation = orientation or C.ZERO_ORIENTATION
    local control, key = CreateSpaceControlCommon(x, y, z, orientation)

    if (options.label and options.label.text) then
        local label = control:GetNamedChild("Label")
        label:SetFont(Crutch.GetStyles().GetMarkerFont(options.label.size))
        label:SetAlpha(1)
        label:SetColor(unpack(options.label.color))
        label:SetText(options.label.text)
        label:SetDimensions(5000, 5000)
        -- Stuff sometimes gets cut off without the 5? But the label is centered, so it's fine I guess
        label:SetDimensions(label:GetTextWidth() + 5, label:GetTextHeight() + 5)
        label:SetHidden(false)
    end

    if (options.composite and options.composite.size) then
        local composite = control:GetNamedChild("Composite")
        composite:SetScale(options.composite.size)
        options.composite.init(composite)
        composite:SetHidden(false)
    end

    if (options.texture and options.texture.path) then
        local textureControl = control:GetNamedChild("Texture")
        textureControl:SetTexture(options.texture.path)

        -- Optional
        if (options.texture.left) then
            textureControl:SetTextureCoords(options.texture.left, options.texture.right, options.texture.top, options.texture.bottom)
        end

        textureControl:SetColor(unpack(options.texture.color))
        textureControl:SetScale(options.texture.size)
        textureControl:SetHidden(false)

    end

    if (options.backdrop and options.backdrop.centerColor) then
        local backdrop = control:GetNamedChild("Backdrop")
        backdrop:SetDimensions(options.backdrop.width or 100, options.backdrop.height or 100)
        backdrop:SetCenterColor(unpack(options.backdrop.centerColor))
        backdrop:SetEdgeColor(unpack(options.backdrop.edgeColor))
        backdrop:SetTransformRotation(0, 0, options.backdrop.roll or 0)
        backdrop:SetHidden(false)
    end

    local pitch, yaw, roll = Draw.ConvertToPitchYawRollIfNeeded(unpack(orientation))

    Draw.CreateControlCommon(
        true, -- isSpace
        control,
        key,
        options.texture and options.texture.path, -- texture
        x, y, z,
        faceCamera,
        pitch, yaw, roll,
        updateFunc,
        Draw.SetPosition,
        Draw.SetOrientation,
        options.texture and Draw.SetColor or nil,
        options.texture and Draw.SetTexture or nil,
        options.texture and Draw.SetTextureHidden or nil,
        options.label and SetText or nil,
        options.label and function(icon, r, g, b, a) Draw.SetColor(icon, r, g, b, a, "Label") end or nil,
        options.backdrop and SetBackdropColors or nil,
        options.backdrop and SetBackdropRoll or nil,
        options.composite and function(icon) return icon.control:GetNamedChild("Composite") end or nil)

    return key
end
Draw.CreateSpaceControl = CreateSpaceControl


---------------------------------------------------------------------
-- Text label
---------------------------------------------------------------------
-- Public API
local function CreateSpaceLabel(text, x, y, z, fontSize, color, faceCamera, orientation, updateFunc)
    local options = {
        label = {
            text = text,
            size = fontSize,
            color = color,
        }
    }
    return CreateSpaceControl(x, y, z, faceCamera, orientation, options, updateFunc)
end
Draw.CreateSpaceLabel = CreateSpaceLabel
--[[
/script local _, x, y, z = GetUnitRawWorldPosition("player") CrutchAlerts.Drawing.CreateSpaceLabel("asdfasdfs fdsfs", x, y, z, 120, {1, 1, 1, 1}, true, {0, 0, 0}, function(icon) local time = GetGameTimeMilliseconds() % 3000 / 3000 icon:SetFontColor(CrutchAlerts.ConvertHSLToRGB(time, 1, 0.5)) icon:SetText(math.floor(GetGameTimeSeconds())) end)
]]


---------------------------------------------------------------------
-- Testing
---------------------------------------------------------------------
local function TestSpacePoop()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    CreateSpaceTexture("CrutchAlerts/assets/poop.dds", x, y, z, 1, 1, C.WHITE, C.ZERO_ORIENTATION)
end
Draw.TestSpacePoop = TestSpacePoop
--[[
/script CrutchAlerts.Drawing.TestSpacePoop()
/tb CrutchAlertsSpaceCrutchAlertsSpaceControl1
]]

local function TestPoopText()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    local options = {
        label = {
            text = "my armory has a mind of its own",
            size = 80,
            color = {1, 1, 1, 1},
        },
        texture = {
            path = "CrutchAlerts/assets/poop.dds",
            size = 1,
            color = {1, 1, 1, 1},
        },
    }

    -- CreateSpaceControl(x, y, z, true, nil, options)
    CreateSpaceControl(x, y, z, true, nil, options, function(icon)
        local time = GetGameTimeMilliseconds() % 3000 / 3000
        icon:SetFontColor(CrutchAlerts.ConvertHSLToRGB(time, 1, 0.5))
        icon:SetText(math.floor(GetGameTimeSeconds()))

        local time2 = (GetGameTimeMilliseconds() + 1500) % 3000 / 3000
        icon:SetColor(CrutchAlerts.ConvertHSLToRGB(time2, 1, 0.5))
    end)
end
Draw.TestPoopText = TestPoopText
--[[
/script CrutchAlerts.Drawing.TestPoopText()
]]

local function TestMarker()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    local options = {
        label = {
            text = "8",
            size = 80,
            color = {1, 1, 1, 1},
        },
        backdrop = {
            width = 100,
            height = 100,
            centerColor = {0, 0, 1, 1},
            edgeColor = {0, 0, 0.2, 1},
        },
    }

    -- CreateSpaceControl(x, y, z, true, nil, options)
    CreateSpaceControl(x, y, z, true, nil, options, function(icon)
        local time = GetGameTimeMilliseconds() % 3000 / 3000
        icon:SetFontColor(Crutch.ConvertHSLToRGB(time, 1, 0.5))
        icon:SetText(math.floor(GetGameTimeSeconds() % 10))

        local time3 = (GetGameTimeMilliseconds() + 2000) % 3000 / 3000
        local centerR, centerG, centerB = Crutch.ConvertHSLToRGB(time3, 1, 0.5)
        local edgeR, edgeG, edgeB = Crutch.ConvertHSLToRGB(time3, 1, 0.06)
        icon:SetBackdropColors(centerR, centerG, centerB, 1, edgeR, edgeG, edgeB, 1)
        icon:SetBackdropRoll(time3 * math.pi * 2 * 2)
    end)
end
Draw.TestMarker = TestMarker
--[[
/script CrutchAlerts.Drawing.TestMarker()
]]


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Draw.InitializeSpace()
    controlPool = ZO_ControlPool:New("CrutchAlertsSpaceControl", CrutchAlertsSpace)
end
