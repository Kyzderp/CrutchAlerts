local Crutch = CrutchAlerts


---------------------------------------------------------------------
---------------------------------------------------------------------
local CC_DISPLAY = {
    [ACTION_RESULT_DISORIENTED] = "Disoriented",
    [ACTION_RESULT_LEVITATED] = "Levitated",
    [ACTION_RESULT_CHARMED] = "Charmed",
    [ACTION_RESULT_FEARED] = "Feared",
    [ACTION_RESULT_STUNNED] = "Stunned",
}


---------------------------------------------------------------------
-- Jets
---------------------------------------------------------------------
local jetsDisplaying = 0 -- 0: not displaying, 1: horizontal, 2: diagonal
local function HideJets()
    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "HideJets")
    jetsDisplaying = 0
    CrutchAlertsCCJetRight:SetHidden(true)
    CrutchAlertsCCJetLeft:SetHidden(true)
end

local FLIGHT_DURATION = 6000
local function LeaveOnAJetPlane(abilityId, result, duration, sourceName)
    if (jetsDisplaying ~= 1) then -- If already in horizontal, don't restart it (but do extend the hide)
        local text = zo_strformat("<<1>> by <<2>>!", string.upper(CC_DISPLAY[result]), GetAbilityName(abilityId))

        local yOffset = GuiRoot:GetHeight() / 3

        CrutchAlertsCCJetRight:ClearAnchors()
        CrutchAlertsCCJetRight:SetTransformRotationZ(0)
        CrutchAlertsCCJetRight:SetAnchor(RIGHT, CrutchAlertsCC, LEFT, -100, -yOffset)
        CrutchAlertsCCJetRightLabel:SetText(text)
        CrutchAlertsCCJetRight:SetHidden(false)
        CrutchAlertsCCJetRight.slide:SetDuration(FLIGHT_DURATION)
        CrutchAlertsCCJetRight.slide:SetDeltaOffsetX(GuiRoot:GetWidth() + 800)
        CrutchAlertsCCJetRight.slide:SetDeltaOffsetY(0)
        CrutchAlertsCCJetRight.slideAnimation:PlayFromStart()

        CrutchAlertsCCJetLeft:ClearAnchors()
        CrutchAlertsCCJetLeft:SetTransformRotationZ(0)
        CrutchAlertsCCJetLeft:SetAnchor(LEFT, CrutchAlertsCC, RIGHT, 100, yOffset)
        CrutchAlertsCCJetLeftLabel:SetText(text)
        CrutchAlertsCCJetLeft:SetHidden(false)
        CrutchAlertsCCJetLeft.slide:SetDuration(FLIGHT_DURATION)
        CrutchAlertsCCJetLeft.slide:SetDeltaOffsetX(-GuiRoot:GetWidth() - 800)
        CrutchAlertsCCJetLeft.slide:SetDeltaOffsetY(0)
        CrutchAlertsCCJetLeft.slideAnimation:PlayFromStart()

        jetsDisplaying = 1
    end

    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "HideJets", FLIGHT_DURATION, HideJets)
end

local YEET_DURATION = 1000
local function Jettison()
    if (jetsDisplaying ~= 1) then return end

    jetsDisplaying = 2

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
-- UI for Normies
---------------------------------------------------------------------
--[[
progress and number for stun duration
icon and name of ability
stun type?
]]
local function HideCCProgress()
    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "HideCC")
    CrutchAlertsCCUIMin:SetHidden(true)
    CrutchAlertsCCUIObnoxious:SetHidden(true)
    Crutch.UnregisterUpdateListener("CCDuration")
end

local function ShowCCProgress(control, abilityId, result, duration, sourceName)
    control:GetNamedChild("Type"):SetText(string.upper(CC_DISPLAY[result]))
    control:GetNamedChild("Ability"):SetText(zo_strformat("<<1>>", GetAbilityName(abilityId)))
    control:GetNamedChild("Icon"):SetTexture(GetAbilityIcon(abilityId))
    local source = control:GetNamedChild("Source")
    if (source) then
        source:SetText(zo_strformat("<<1>>", sourceName))
    end

    control:SetHidden(false)
    control:GetNamedChild("Radial"):StartCooldown(duration, duration, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false)
end

local function ShowCCProgressAll(abilityId, result, duration, sourceName)
    local enabled = false
    if (Crutch.savedOptions.cc.showVisual) then
        enabled = true
        ShowCCProgress(CrutchAlertsCCUIMin, abilityId, result, duration, sourceName)
    end
    if (Crutch.savedOptions.cc.showObnoxious) then
        enabled = true
        ShowCCProgress(CrutchAlertsCCUIObnoxious, abilityId, result, duration, sourceName)
    end

    if (not enabled) then return end

    local targetTime = GetGameTimeMilliseconds() + duration
    Crutch.RegisterUpdateListener("CCDuration", function()
        local remaining = targetTime - GetGameTimeMilliseconds()
        if (remaining < 0) then remaining = 0 end
        local timeString = string.format("%.1f", remaining / 1000)
        CrutchAlertsCCUIMinNumber:SetText(timeString)
        CrutchAlertsCCUIObnoxiousNumber:SetText(timeString)
    end)

    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "HideCC", duration, HideCCProgress)
end
Crutch.ShowCCProgressAll = ShowCCProgressAll
-- /script CrutchAlerts.ShowCCProgressAll(85214, ACTION_RESULT_STUNNED, 6000, "Kimbrudhil the Songbird")
-- /script CrutchAlerts.ShowCCProgressAll(121444, ACTION_RESULT_STUNNED, 30000, "Eternal Servant")
-- /script CrutchAlerts.ShowCCProgressAll(122013, ACTION_RESULT_STUNNED, 1800, "Jone's Gale-Claw")


---------------------------------------------------------------------
-- Common
---------------------------------------------------------------------
local function OnHardCCed(abilityId, result, duration, sourceName)
    if (Crutch.savedOptions.cc.showChat) then
        Crutch.msg(zo_strformat("|c00FFFF<<1>> |cAAAAAAby |c00FFFF<<2>>|r|cAAAAAA's |c00FFFF<<3>> |cAAAAAA(<<4>>) for <<5>>ms",
            CC_DISPLAY[result],
            sourceName,
            GetAbilityName(abilityId),
            abilityId,
            duration))
    end

    if (Crutch.savedOptions.experimental) then
        LeaveOnAJetPlane(abilityId, result, duration, sourceName)
    end

    ShowCCProgressAll(abilityId, result, duration, sourceName)
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

    HideCCProgress()
end
Crutch.OnNotStunned = OnNotStunned
-- /script CrutchAlerts.OnNotStunned()


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Crutch.InitializeCCUI()
    CrutchAlertsCCUIMin:ClearAnchors()
    CrutchAlertsCCUIMin:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.cc.visualPositionX, Crutch.savedOptions.cc.visualPositionY)

    CrutchAlertsCCUIObnoxious:ClearAnchors()
    CrutchAlertsCCUIObnoxious:SetAnchor(CENTER, GuiRoot, CENTER, Crutch.savedOptions.cc.obnoxiousPositionX, Crutch.savedOptions.cc.obnoxiousPositionY)
end
