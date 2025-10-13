local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

---------------------------------------------------------------------
local controlPool

local function AcquireControl()
    local control, key = controlPool:AcquireObject()

    control:SetHidden(false)
    control:SetScale(0.01)

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
    control:SetTransformNormalizedOriginPoint(0.5, 0.5)

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
    icon.control:GetNamedChild("Texture"):SetHidden(true)
    icon.control:GetNamedChild("Label"):SetHidden(true)

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

    -- TODO: width and height?
    control:SetTransformScale(width)

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
    end
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
}
]]
---------------------------------------------------------------------
local function CreateSpaceControl(x, y, z, faceCamera, orientation, options, updateFunc)
    orientation = orientation or {0, 0, 0}
    local control, key = CreateSpaceControlCommon(x, y, z, orientation)

    if (options.label) then
        local label = control:GetNamedChild("Label")
        label:SetHidden(false)
        label:SetFont(Crutch.GetStyles().GetMarkerFont(options.label.size))
        label:SetAlpha(1) -- In case it's not specified by color
        label:SetColor(unpack(options.label.color))
        label:SetText(options.label.text)
        label:SetDimensions(2000, 2000)
        label:SetDimensions(label:GetTextWidth(), label:GetTextHeight())
    end

    if (options.texture) then
        local textureControl = control:GetNamedChild("Texture")
        textureControl:SetHidden(false)
        textureControl:SetTexture(options.texture.path)
        textureControl:SetColor(unpack(options.texture.color))
        textureControl:SetTransformScale(options.texture.size)
    end

    -- TODO?
    control:SetTransformScale(1)

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
        options.label and SetText or nil,
        options.label and function(icon, r, g, b, a) Draw.SetColor(icon, r, g, b, a, "Label") end or nil)

    return control, key
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
    CreateSpaceTexture("CrutchAlerts/assets/poop.dds", x, y, z, 1, 1, {1, 1, 1}, {0, 0, 0})
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


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Draw.InitializeSpace()
    controlPool = ZO_ControlPool:New("CrutchAlertsSpaceControl", CrutchAlertsSpace)

    -- TODO: fragment?
end
