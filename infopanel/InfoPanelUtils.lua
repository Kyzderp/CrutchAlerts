local Crutch = CrutchAlerts
local IP = Crutch.InfoPanel

local PANEL_DAMAGEABLE_INDEX = 1

---------------------------------------------------------------------
-- Inherit, yellow, orange
local function DecorateTimer(timer)
    if (timer > 5000) then
        return string.format("%.0fs", timer / 1000)
    elseif (timer > 3000) then
        return string.format("|cffee00%.1fs|r", timer / 1000)
    else
        return string.format("|cff8c00%.1fs|r", timer / 1000)
    end
end

-- Yellow, orange, red
local function DecorateTimerDamageable(timer)
    if (timer > 5000) then
        return string.format("|cffee00%.1fs|r", timer / 1000)
    elseif (timer > 3000) then
        return string.format("|cff8c00%.1fs|r", timer / 1000)
    else
        return string.format("|cff0000%.1fs|r", timer / 1000)
    end
end

-- prefix: should include a space at the end to not be squished with the timer
-- doneText: the whole text to show after timer is <= 0 (is not prefixed)
-- doneMs: milliseconds after timer <= 0 to persist the line. nil to not auto remove
local function CountDown(index, prefix, doneText, durationMs, doneMs, showTimer, decorateTimerFunc)
    local targetTime = GetGameTimeMilliseconds() + durationMs
    if (not decorateTimerFunc) then
        decorateTimerFunc = DecorateTimer
    end

    Crutch.RegisterUpdateListener("Panel" .. index, function()
        local timer = targetTime - GetGameTimeMilliseconds()
        if (timer > 0) then
            local text = prefix
            if (showTimer) then
                text = text .. decorateTimerFunc(timer)
            end
            IP.SetLine(index, text)
        elseif (doneMs == nil) then
            -- If doneMs is nil, do not auto remove timer, just set the text
            IP.SetLine(index, doneText)
        elseif (timer < -doneMs) then
            -- If timer is past doneMs, remove timer
            IP.StopCount(index)
        else
            -- Timer is <= 0, but not ending yet
            IP.SetLine(index, doneText)
        end
    end)
end

function IP.CountDownDuration(index, prefix, durationMs)
    CountDown(index, prefix, prefix .. "|cff8c00Soon™️|r", durationMs, nil, true)
end
-- /script CrutchAlerts.InfoPanel.CountDownDuration(1, "Portal 1: ", 20000)

function IP.StopCount(index)
    Crutch.UnregisterUpdateListener("Panel" .. index)
    IP.RemoveLine(index)
end

function IP.CountDownHardStop(index, prefix, durationMs, showTimer)
    CountDown(index, prefix, "", durationMs, 0, showTimer)
end

---------------------------------------------------------------------
-- Damageable consolidated
function IP.CountDownDamageable(durationSeconds, prefix)
    CountDown(
        PANEL_DAMAGEABLE_INDEX,
        prefix or "Boss in ",
        "|c0fff43Fire the nailguns!|r",
        durationSeconds * 1000,
        1000,
        true,
        DecorateTimerDamageable)
end

function IP.StopDamageable()
    IP.StopCount(PANEL_DAMAGEABLE_INDEX)
end
