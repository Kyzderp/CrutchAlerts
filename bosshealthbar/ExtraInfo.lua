local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

local function SetExtraInfo(index, text)
    local statusBar = CrutchAlertsBossHealthBarContainer:GetNamedChild("Bar" .. index)
    if (not statusBar) then return end
    local infoLabel = statusBar:GetNamedChild("ExtraInfo")
    infoLabel:SetText(text)
    infoLabel:SetHidden(false)
end

local function RemoveExtraInfo(index)
    local statusBar = CrutchAlertsBossHealthBarContainer:GetNamedChild("Bar" .. index)
    if (not statusBar) then return end
    local infoLabel = statusBar:GetNamedChild("ExtraInfo")
    infoLabel:SetHidden(true)
end


---------------------------------------------------------------------
-- Utils
---------------------------------------------------------------------
local function DecorateTimer(timer)
    if (timer > 60000) then
        return FormatTimeSeconds(timer / 1000, TIME_FORMAT_STYLE_COLONS)
    elseif (timer > 5000) then
        return string.format("%.0fs", timer / 1000)
    elseif (timer > 3000) then
        return string.format("|cffee00%.1fs|r", timer / 1000)
    else
        return string.format("|cff8c00%.1fs|r", timer / 1000)
    end
end

local function CountDownTarget(index, targetTime)
    Crutch.RegisterUpdateListener("BHBExtraInfo" .. index, function()
        local timer = targetTime - GetGameTimeMilliseconds()
        if (timer > 0) then
            local text = DecorateTimer(timer)
            SetExtraInfo(index, text)
        else
            SetExtraInfo(index, "|cff8c00|t90%:90%:esoui/art/miscellaneous/gamepad/gp_icon_new.dds:inheritcolor|t|r")
        end
    end)
end

function BHB.CountDownExtraInfoDuration(index, durationMs)
    CountDownTarget(index, GetGameTimeMilliseconds() + durationMs)
end
-- /script CrutchAlerts.BossHealthBar.CountDownExtraInfoDuration(1, 20000)

function BHB.StopExtraInfoCount(index)
    Crutch.UnregisterUpdateListener("BHBExtraInfo" .. index)
    RemoveExtraInfo(index)
end
