local Crutch = CrutchAlerts


---------------------------------------------------------------------
local jetsDisplaying = false
local function HideJets()
    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "HideJets")
    jetsDisplaying = false
    CrutchAlertsCCJetRight:SetHidden(true)
    CrutchAlertsCCJetLeft:SetHidden(true)
end

local DURATION = 6000
local function LeaveOnAJetPlane(abilityId)
    local binds = {}
    local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName("SPECIAL_MOVE_INTERRUPT")
    local foundFirstBind = false
    for i = 1, 4 do
        local keyCode, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, i)
        if (keyCode and keyCode ~= KEY_INVALID) then
            local keybindString = ZO_Keybindings_GetBindingStringFromKeys(keyCode, mod1, mod2, mod3, mod4, nil, KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP)
            table.insert(binds, keybindString)
            if (foundFirstBind) then break end -- Only show first 2 found binds
            foundFirstBind = true
        end
    end
    local text = table.concat(binds, "   ")

    local yOffset = GuiRoot:GetHeight() / 3

    CrutchAlertsCCJetRight:ClearAnchors()
    CrutchAlertsCCJetRight:SetTransformRotationZ(0)
    CrutchAlertsCCJetRight:SetAnchor(RIGHT, CrutchAlertsCC, LEFT, -100, -yOffset)
    CrutchAlertsCCJetRightLabel:SetText(text)
    CrutchAlertsCCJetRight:SetHidden(false)
    CrutchAlertsCCJetRight.slide:SetDuration(DURATION)
    CrutchAlertsCCJetRight.slide:SetDeltaOffsetX(GuiRoot:GetWidth() + 800)
    CrutchAlertsCCJetRight.slide:SetDeltaOffsetY(0)
    CrutchAlertsCCJetRight.slideAnimation:PlayFromStart()

    CrutchAlertsCCJetLeft:ClearAnchors()
    CrutchAlertsCCJetLeft:SetTransformRotationZ(0)
    CrutchAlertsCCJetLeft:SetAnchor(LEFT, CrutchAlertsCC, RIGHT, 100, yOffset)
    CrutchAlertsCCJetLeftLabel:SetText(text)
    CrutchAlertsCCJetLeft:SetHidden(false)
    CrutchAlertsCCJetLeft.slide:SetDuration(DURATION)
    CrutchAlertsCCJetLeft.slide:SetDeltaOffsetX(-GuiRoot:GetWidth() - 800)
    CrutchAlertsCCJetLeft.slide:SetDeltaOffsetY(0)
    CrutchAlertsCCJetLeft.slideAnimation:PlayFromStart()

    jetsDisplaying = true

    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "HideJets", DURATION, HideJets)
end

local YEET_DURATION = 1000
local function Jettison()
    if (not jetsDisplaying) then return end

    CrutchAlertsCCJetRight:SetTransformRotationZ(math.rad(30))
    CrutchAlertsCCJetRight.slide:SetDuration(YEET_DURATION)
    CrutchAlertsCCJetRight.slide:SetDeltaOffsetX(GuiRoot:GetWidth() / 4)
    CrutchAlertsCCJetRight.slide:SetDeltaOffsetY(-GuiRoot:GetWidth() / 2)
    CrutchAlertsCCJetRight.slideAnimation:PlayFromStart()

    CrutchAlertsCCJetLeft:SetTransformRotationZ(math.rad(30))
    CrutchAlertsCCJetLeft.slide:SetDuration(YEET_DURATION)
    CrutchAlertsCCJetLeft.slide:SetDeltaOffsetX(-GuiRoot:GetWidth() / 4)
    CrutchAlertsCCJetLeft.slide:SetDeltaOffsetY(GuiRoot:GetWidth() / 2)
    CrutchAlertsCCJetLeft.slideAnimation:PlayFromStart()

    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "HideJets", YEET_DURATION, HideJets)
end

---------------------------------------------------------------------
---------------------------------------------------------------------
local function OnHardCCed()
    if (Crutch.savedOptions.experimental) then
        LeaveOnAJetPlane()
    end
end
Crutch.OnHardCCed = OnHardCCed
-- /script CrutchAlerts.OnHardCCed()

local function OnStunned()
end
Crutch.OnStunned = OnStunned

local function OnNotStunned()
    if (Crutch.savedOptions.experimental) then
        Jettison()
    end
end
Crutch.OnNotStunned = OnNotStunned
-- /script CrutchAlerts.OnNotStunned()
