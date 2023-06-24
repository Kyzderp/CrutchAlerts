CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

local SUBTITLE_CHANNELS = {
    [CHAT_CHANNEL_MONSTER_WHISPER] = true,
    [CHAT_CHANNEL_MONSTER_EMOTE] = true,
    [CHAT_CHANNEL_MONSTER_YELL] = true,
    [CHAT_CHANNEL_MONSTER_SAY] = true,
}

local SUBTITLE_TIMES = {
-- DSR
    ["Turlassil"] = {
        -- Lylanar and Turlassil
        ["Fresh challengers more like."] = 16.6,
        ["You pass. Barely"] = 6.4,
        ["You looked a little too eager to kill our hounds for my taste."] = 6.4,
        ["I'll take the first round, Ly."] = 6.4,
        ["That was just a taste of what's to come."] = 6.4,
        ["Don't get up, Ly. This will just be a moment."] = 6.4,
    },
    ["Lylanar"] = {
        -- Lylanar and Turlassil
        ["I'll call first round."] = 6.4,
        ["Had your warm up then?"] = 6.4,
        ["Watch me, Turli. This is how it's done!"] = 6.4,
        ["Made it farther than the thralls do."] = 6.4,
        ["Now the real fight begins."] = 6.4,
    },
    ["Fleet Queen Taleria"] = {
        -- Taleria
        ["Barging into a lady's private chambers. You are bold."] = 23.5,
    },
-- HoF
    ["Assembly General"] = {
        -- Triplets
        ["Reprocessing yard contamination critical. Disassembly status suspended. Mass reactivation initiated."] = 10.2, -- TODO
    },
    ["Montagegeneral"] = {
        -- Triplets
        ["Kritische Kontamination auf dem Wertstoffhof. Ausschlachtung wird ausgesetzt. Massenreaktivierung eingeleitet."] = 10.2, -- TODO
    },
    ["Divayth Fyr"] = {
        -- Pinnacle
        ["Interesting. These devices have all reset themselves. I didn't do that."] = 16.0,
        ["Interessant. Diese Maschinen haben sich alle zurückgesetzt. Das war nicht ich."] = 16.0,
    },

-- MoL
    ["Mirarro"] = {
        -- Zhaj'hassa
        ["Don't .... It's ... trap."] = 16.8,
        ["He's coming!"] = 16.8,
        ["Nicht*… Eine*… Falle."] = 16.8,
        ["Er kommt!"] = 16.8,
    },
    ["Kulan-Dro"] = {
        -- Rakkhat
        ["Have you not heard me? Have I not made your choice plain? You will listen, mortals ... even if it means peeling the ears from your scalps and shouting Namiira's will into whatever's left of your broken skulls!"] = 26.4,
        ["Have you not heard me? Have I not made your choice plain? You will listen, mortals"] = 26.4,
    },
    ["Kulan-dro"] = {
        -- Rakkhat
        ["Habt Ihr mich nicht gehört? Hatte ich mich nicht klar ausgedrückt? Ihr werdet zuhören, Sterbliche"] = 26.4,
    },

-- SS
    ["Nahviintaas"] = {
        -- Nahviintaas
        ["To restore the natural order. To reclaim all that was and will be. To correct the mortal mistake."] = 22.2,
        ["Um die natürliche Ordnung wiederherzustellen. Das, was war und sein wird. Um sterbliche Fehler zu berichtigen."] = 22.2,
    },

-- VH
    ["Aydolan"] = {
        -- Maebroogha the Void Lich
        ["You made it all the way to the end! Only one final challenge left. Me!"] = 12.7,
        ["Ihr habt es ganz bis zum Ende geschafft! Nur noch eine letzte Herausforderung: Ich!"] = 12.7,
    },

-----------
-- Dungeons

-- Castle Thorn
    ["Lady Thorn"] = {
        -- Blood Twilight
        ["Well done, Talfyg. You brought me a daughter of Verandis, as requested. She will complement our lord's army well."] = 19.2,
    },
    ["Fürstin Dorn"] = {
        -- Blood Twilight
        ["Gut gemacht, Talfyg. Ihr habt mir eine Tochter von Verandis gebracht. Wie erbeten. Sie wird die Armee unseres Fürsten gut ergänzen."] = 19.2,
    },

-- Lair of Maarselok
    ["Selene"] = {
        -- Selene fight (bear, spider)
        ["Now for payment in kind. It's my turn to study your insides, warlock!"] = 4.8,
        ["Nun zu meiner Vergeltung. Jetzt studiere ich Eure Eingeweide, Hexer!"] = 4.8,
    },

-- Scrivener’s Hall
    ["Riftmaster Naqri"] = {
        -- Riftmaster Naqri - 1st boss
        ["No need to involve you, Magnastylus. I'll beat anyone who tries to get through here."] = 14.8,
    },
    ["Valinna"] = {
        -- Valinna - Last boss. Last area she has a shield and heals
        ["Let's be done with this. I have important tasks to see to."] = 4.5,
        ["What are you waiting for? Keshargo? Come and get him."] = 4.6,
        ["You live? Let's fix that, shall we?"] = 5,
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

        -- German
        ["Girawell, K'Tora ruft Euch zum Gefecht!"] = 5.5,
        ["Erlaubt mir, Euch Riffhammer, den Fluch Ul'vor-Kus' vorzustellen!"] = 5.5,
        ["Dunkelsturm"] = 5.5,
        ["Spürt die Macht von Eejoba der Strahlenden!"] = 5.5,
        ["Gezeitenbruch"] = 5.5,
        ["K'Tora beschwört Vsskalvor, um diesen Geysir zu beschützen!"] = 5.5,
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
    if (Crutch.savedOptions.showSubtitles) then
        if (not Crutch.savedOptions.subtitlesIgnoredZones[GetZoneId(GetUnitZoneIndex("player"))]) then
            CHAT_SYSTEM:AddMessage(string.format("|c88FFFF%s: |cAAAAAA%s", name, text))
        else
            Crutch.dbgSpam(string.format("|c88FFFF%s: |cAAAAAA%s", name, text))
        end
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
