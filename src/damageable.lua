CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

local SUBTITLE_CHANNELS = {
    [CHAT_CHANNEL_MONSTER_WHISPER] = true,
    [CHAT_CHANNEL_MONSTER_EMOTE] = true,
    [CHAT_CHANNEL_MONSTER_YELL] = true,
    [CHAT_CHANNEL_MONSTER_SAY] = true,
}

local SUBTITLE_TIMES = {
-- HoF
    ["Assembly General"] = {
        -- Triplets
        ["Reprocessing yard contamination critical. Disassembly status suspended. Mass reactivation initiated."] = 10.2, -- TODO
    },
    ["Divayth Fyr"] = {
        -- Pinnacle
        ["Interesting. These devices have all reset themselves. I didn't do that."] = 16.0,
    },

-- MoL
    ["Mirarro"] = {
        -- Zhaj'hassa
        ["Don't .... It's ... trap."] = 16.8, -- TODO
        ["He's coming!"] = 16.8, -- TODO
    },
    ["Kulan-Dro"] = {
        -- Rakkhat
        ["Have you not heard me? Have I not made your choice plain? You will listen, mortals ... even if it means peeling the ears from your scalps and shouting Namiira's will into whatever's left of your broken skulls!"] = 26.4, -- TODO
        ["Have you not heard me? Have I not made your choice plain? You will listen, mortals"] = 26.4, -- TODO
    },

-- SS
    ["Nahviintaas"] = {
        -- Nahviintaas
        ["To restore the natural order. To reclaim all that was and will be. To correct the mortal mistake."] = 22.2, -- TODO
    },

-- CR

-- VH
    ["Aydolan"] = {
        -- Maebroogha the Void Lich
        ["You made it all the way to the end! Only one final challenge left. Me!"] = 12.7,
    },

-- Castle Thorn
    ["Lady Thorn"] = {
        -- Blood Twilight
        ["Well done, Talfyg. You brought me a daughter of Verandis, as requested. She will complement our lord's army well."] = 19.2,
    },


-- Overland
    ["K'Tora"] = {
        -- Abyssal Geyser
        ["Ruella"] = 5.5,
        ["Churug"] = 5.5,
        ["Sheefar"] = 5.5,
        ["Girawell, K'Tora orders you into the fray!"] = 5.5,
        ["Muustikar"] = 5.5,
        ["Allow me to introduce Reefhammer, the bane of Ul'vor-Kus!"] = 5.5,
        ["Darkstorm"] = 5.5,
        ["Feel the power of Eejoba the Radiant!"] = 5.5,
        ["Tidewrack"] = 5.5,
        ["K'Tora summons Vsskalvor to protect this geyser!"] = 5.5,
    },
}

local spooderPulled = false

local isPolling = false
local pollTime = 0

---------------------------------------------------------------------
-- Milliseconds
local function GetTimerColor(timer)
    if (timer > 5000) then
        return "ffee00"
    elseif (timer > 3000) then
        return "ff8c00"
    else
        return "ff0000"
    end
end

---------------------------------------------------------------------
-- Poll for update
local function UpdateDisplay()
    local currTime = GetGameTimeMilliseconds()
    local millisRemaining = pollTime - currTime
    if (millisRemaining < -1000) then
        isPolling = false
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "PollDamageable")
        CrutchAlertsDamageableLabel:SetHidden(true)
    elseif (millisRemaining < 0) then
        CrutchAlertsDamageableLabel:SetText("|c0fff43Fire the nailguns!|r")
    else
        CrutchAlertsDamageableLabel:SetText(string.format("Boss in |c%s%.1f|r", GetTimerColor(millisRemaining), millisRemaining / 1000))
    end
end

---------------------------------------------------------------------
-- Display the timer
function Crutch.DisplayDamageable(time)
    pollTime = GetGameTimeMilliseconds() + time * 1000
    CrutchAlertsDamageableLabel:SetText(string.format("Boss in |c%s%.1f|r", GetTimerColor(time * 1000), time))
    CrutchAlertsDamageableLabel:SetHidden(false)

    if (not isPolling) then
        isPolling = true
        EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "PollDamageable", 100, UpdateDisplay)
    end
end

---------------------------------------------------------------------
-- EVENT_CHAT_MESSAGE_CHANNEL (number eventCode, MsgChannelType channelType, string fromName, string text, boolean isCustomerService, string fromDisplayName)
local function HandleChat(_, channelType, fromName, text, isCustomerService, fromDisplayName)
    if (not SUBTITLE_CHANNELS[channelType]) then
        return
    end

    local name = zo_strformat("<<1>>", fromName)
    if (Crutch.savedOptions.showSubtitles and not Crutch.savedOptions.subtitlesIgnoredZones[GetZoneId(GetUnitZoneIndex("player"))]) then
        CHAT_SYSTEM:AddMessage(string.format("|c88FFFF%s: |cAAAAAA%s", name, text))
    end

    -- Dialogue NPC matches
    local lines = SUBTITLE_TIMES[name]
    if (not lines) then
        return
    end

    local time = lines[text]
    if (time) then
        -- d("Found time using exact string")
    else
        -- Check each one using string.find
        for line, t in pairs(lines) do
            if (string.find(text, line, 1, true)) then
                time = t
                -- d("Found time using find")
            end
        end

        if (not time) then
            return
        end
    end

    -- Have the number of seconds after which the boss should be damageable
    Crutch.DisplayDamageable(time)

end

---------------------------------------------------------------------
-- EVENT_PLAYER_COMBAT_STATE (number eventCode, boolean inCombat)
local function HandleCombatState(_, inCombat)
    if (not inCombat) then
        -- Reset one-time vars
        spooderPulled = false
    end
end

---------------------------------------------------------------------
local function HandleOverheadRail()
    if (spooderPulled) then
        return
    end

    spooderPulled = true
    Crutch.DisplayDamageable(23.2) -- TODO
end

---------------------------------------------------------------------
function Crutch.InitializeDamageable()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ChatHandler", EVENT_CHAT_MESSAGE_CHANNEL, HandleChat)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DamageableCombatState", EVENT_PLAYER_COMBAT_STATE, HandleCombatState)

    -- TODO: only register this in HoF
    EVENT_MANAGER:RegisterForEvent(Crutch.name.."Spooder", EVENT_COMBAT_EVENT, HandleOverheadRail)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name.."Spooder", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 94805)
end
