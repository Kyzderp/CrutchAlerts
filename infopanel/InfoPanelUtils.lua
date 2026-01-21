local Crutch = CrutchAlerts
local IP = Crutch.InfoPanel


---------------------------------------------------------------------
-- Milliseconds
local function DecorateTimer(timer)
    if (timer > 5000) then
        return string.format("%.0fs", timer / 1000)
    elseif (timer > 3000) then
        return string.format("|cffee00%.1fs|r", timer / 1000)
    else
        return string.format("|cff8c00%.1fs|r", timer / 1000)
    end
end

function IP.CountDownDuration(index, prefix, durationMs)
    local targetTime = GetGameTimeMilliseconds() + durationMs
    Crutch.RegisterUpdateListener("Panel" .. index, function()
        local timer = targetTime - GetGameTimeMilliseconds()
        if (timer > 0) then
            IP.SetLine(index, prefix .. DecorateTimer(timer))
        else
            IP.SetLine(index, prefix .. "|cff8c00Soon™️|r")
        end
    end)
end
-- /script CrutchAlerts.InfoPanel.CountDownDuration(1, "Portal 1: ", 20000)

function IP.StopCount(index)
    Crutch.UnregisterUpdateListener("Panel" .. index)
    IP.RemoveLine(index)
end

function IP.CountDownHardStop(index, prefix, durationMs, showTimer)
    local targetTime = GetGameTimeMilliseconds() + durationMs
    Crutch.RegisterUpdateListener("Panel" .. index, function()
        local timer = targetTime - GetGameTimeMilliseconds()
        if (timer > 0) then
            local text = prefix
            if (showTimer) then
                text = text .. DecorateTimer(timer)
            end
            IP.SetLine(index, text)
        else
            IP.StopCount(index)
        end
    end)
end
