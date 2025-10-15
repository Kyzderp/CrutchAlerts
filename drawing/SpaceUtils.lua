local Crutch = CrutchAlerts
local Draw = Crutch.Drawing
local Anim = Draw.Animation

---------------------------------------------------------------------
-- Pulsing animation
-- initialSize: 0~1 fraction of the full composite size
-- t: 0~1 fraction of the time of the full cycle
-- color: nil (no change) or color of all surfaces
---------------------------------------------------------------------
local function PulseUpdate(composite, t, color)
    -- Surface 1 expanding outwards
    local inset = (1 - t) / 2
    local surface1 = 1
    composite:SetInsets(surface1, inset, -inset, inset, -inset)
    composite:SetSurfaceAlpha(surface1, zo_clamp(zo_lerp(2, 0, t), 0, 1))

    -- Surface 2 expanding outwards, slightly after surface 1
    local t2 = t - 0.3
    if (t2 < 0) then t2 = t2 + 1 end
    local inset2 = (1 - t2) / 2
    local surface2 = 2
    composite:SetInsets(surface2, inset2, -inset2, inset2, -inset2)
    composite:SetSurfaceAlpha(surface2, zo_clamp(zo_lerp(2, 0, t2), 0, 1))

    -- Set color for all surfaces
    if (color) then
        for i = 1, composite:GetNumSurfaces() do
            local a = composite:GetSurfaceAlpha(i)
            composite:SetColor(i, color[1], color[2], color[3], a)
        end
    end
end
Anim.PulseUpdate = PulseUpdate

local function PulseInitial(composite, texturePath, initialSize, color)
    composite:SetTexture(texturePath)

    -- AddSurface(*number* _left_, *number* _right_, *number* _top_, *number* _bottom_)
    local surface1 = composite:AddSurface(0, 1, 0, 1)
    composite:SetInsets(surface1, 0, 0, 0, 0)
    composite:SetColor(surface1, color[1], color[2], color[3], 0)

    local surface2 = composite:AddSurface(0, 1, 0, 1)
    composite:SetInsets(surface2, 0, 0, 0, 0)
    composite:SetSurfaceAlpha(surface2, 0)
    composite:SetColor(surface2, color[1], color[2], color[3], 0)

    -- Actual texture goes last
    -- SetInsets(*luaindex* _surfaceIndex_, *number* _left_, *number* _right_, *number* _top_, *number* _bottom_)
    local inset = (1 - initialSize) / 2
    local surfaceOrig = composite:AddSurface(0, 1, 0, 1)
    composite:SetInsets(surfaceOrig, inset, -inset, inset, -inset)
    composite:SetColor(surfaceOrig, color[1], color[2], color[3], color[4])
end
Anim.PulseInitial = PulseInitial

local function TestPulse()
    local cycleTime = 700
    Crutch.SetAttachedIconForUnit(
        "player",
        "CrutchAlertsTestPulse",
        500,
        nil,
        120,
        nil,
        false,
        function(icon)
            local time = GetGameTimeMilliseconds() % cycleTime
            local t = time / cycleTime
            PulseUpdate(icon:GetCompositeTexture(), t)
        end,
        {
            label = {
                text = "9",
                size = 60,
                color = {1, 1, 1, 0.8},
            },
            composite = {
                size = 1.7,
                init = function(composite)
                    PulseInitial(composite, "CrutchAlerts/assets/shape/diamond.dds", 0.5, {1, 1, 1, 0.8})
                end,
            },
        })
end
Draw.TestPulse = TestPulse
-- /script CrutchAlerts.Drawing.TestPulse()
-- /script CrutchAlerts.RemoveAttachedIconForUnit("player", "CrutchAlertsTestPulse")
-- /script CrutchAlertsSpaceCrutchAlertsSpaceControl1Composite:SetInsets(2, 0.25, -.25, .25, -0.25)



---------------------------------------------------------------------
-- Chevron "boost" animation
-- t: 0~1 fraction of the time of the full cycle
---------------------------------------------------------------------
local function BoostUpdate(composite, t)
end
Anim.BoostUpdate = BoostUpdate

local chevronHeight = 0.4
local function BoostInitial(composite, colorFrom, colorTo)
    composite:SetTexture("CrutchAlerts/assets/shape/chevronthin.dds")

    local from = ZO_ColorDef:New(colorFrom[1], colorFrom[2], colorFrom[3])
    local to = ZO_ColorDef:New(colorTo[1], colorTo[2], colorTo[3])
    for i = 1, 4 do
        composite:AddSurface(0, 1, 0, 1)

        -- SetInsets(*luaindex* _surfaceIndex_, *number* _left_, *number* _right_, *number* _top_, *number* _bottom_)
        local offset = i * chevronHeight
        composite:SetInsets(i, 0, 0, -offset, -offset)

        composite:SetColor(i, ZO_ColorDef.LerpRGB(from, to, (i - 1) / 3))
    end
end
Anim.BoostInitial = BoostInitial

local function TestBoost()
    local cycleTime = 700
    Crutch.SetAttachedIconForUnit(
        "player",
        "CrutchAlertsTestBoost",
        500,
        nil,
        120,
        nil,
        false,
        function(icon)
            local time = GetGameTimeMilliseconds() % cycleTime
            local t = time / cycleTime
            BoostUpdate(icon:GetCompositeTexture(), t)
        end,
        {
            composite = {
                size = 1,
                init = function(composite)
                    BoostInitial(composite, {1, 1, 0}, {1, 0, 0})
                end,
            },
        })
end
Draw.TestBoost = TestBoost
-- /script CrutchAlerts.Drawing.TestBoost()
-- /script CrutchAlerts.RemoveAttachedIconForUnit("player", "CrutchAlertsTestBoost")
