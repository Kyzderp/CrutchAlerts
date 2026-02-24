local Crutch = CrutchAlerts


---------------------------------------------------------------------
local DURATION = 6000
local function OnHardCCed(abilityId)
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
    CrutchAlertsCCJetRight:SetAnchor(RIGHT, CrutchAlertsCC, LEFT, -200, -yOffset)
    CrutchAlertsCCJetRightLabel:SetText(text)
    CrutchAlertsCCJetRight:SetHidden(false)
    CrutchAlertsCCJetRight.slide:SetDuration(DURATION)
    CrutchAlertsCCJetRight.slide:SetDeltaOffsetX(GuiRoot:GetWidth() + 800)
    CrutchAlertsCCJetRight.slideAnimation:PlayFromStart()

    CrutchAlertsCCJetLeft:ClearAnchors()
    CrutchAlertsCCJetLeft:SetAnchor(LEFT, CrutchAlertsCC, RIGHT, 200, yOffset)
    CrutchAlertsCCJetLeftLabel:SetText(text)
    CrutchAlertsCCJetLeft:SetHidden(false)
    CrutchAlertsCCJetLeft.slide:SetDuration(DURATION)
    CrutchAlertsCCJetLeft.slide:SetDeltaOffsetX(-GuiRoot:GetWidth() - 800)
    CrutchAlertsCCJetLeft.slideAnimation:PlayFromStart()

end
Crutch.OnHardCCed = OnHardCCed
-- /script CrutchAlerts.OnHardCCed()
