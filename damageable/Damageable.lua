CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

local SUBTITLE_CHANNELS = {
    [CHAT_CHANNEL_MONSTER_WHISPER] = true,
    [CHAT_CHANNEL_MONSTER_EMOTE] = true,
    [CHAT_CHANNEL_MONSTER_YELL] = true,
    [CHAT_CHANNEL_MONSTER_SAY] = true,
}

-- TODO: migrate these to lang files
local SUBTITLE_TIMES = {
-- CR
    ["Z'Maja"] = {
        ["I won't be beaten! I'll smash this amulet if that's what it takes."] = 14.4,

        -- These are unfortunately also idle voice lines, so to work around this, only display them once ("singleZoneId") in an instance
        ["You challenge the power of the Sea Sload? It shall be your last mistake."] = {time = 7.5, singleZoneId = 1051},
        ["You dare fight against darkness itself? Foolish."] = {time = 7.5, singleZoneId = 1051},
        ["Darkness shall reign across Summerset!"] = {time = 7.5, singleZoneId = 1051},
        ["Cloudrest has already fallen. And so too shall you."] = {time = 7.5, singleZoneId = 1051},
        ["Soon, my shadows shall spread to all of Summerset!"] = {time = 7.5, singleZoneId = 1051},
        ["The shadows answer to me now."] = {time = 7.5, singleZoneId = 1051},
        ["Do you truly think you can stand against my shadows?"] = {time = 7.5, singleZoneId = 1051},
        ["I can wait. After all, your deaths are inevitable."] = {time = 7.5, singleZoneId = 1051},
    },
-- DSR
    ["Turlassil"] = {
        -- Lylanar and Turlassil
        ["Fresh challengers more like."] = 16.6,

        ["Eher neue Herausforderer."] = 16.6,

        -- First
        ["Don't get up, Ly. This will just be a moment."] = 6.4,
        ["I'll take the first round, Ly."] = 6.4,
        ["That was just a taste of what's to come."] = 6.4,
        ["You looked a little too eager to kill our hounds for my taste."] = 6.4,
        ["You pass. Barely"] = 6.4,

        ["Steht nicht auf, Ly. Das wird nur einen Augenblick dauern."] = 6.4,
        ["Ich übernehme die erste Runde, Ly."] = 6.4,
        ["Das war nur ein Vorgeschmack auf das, was kommt."] = 6.4,
        ["Für meinen Geschmack wirktet Ihr ein bisschen zu versessen darauf, unsere Hunde zu töten."] = 6.4,
        ["Das reicht. Gerade so."] = 6.4,

        -- Second to come down
        ["I don't want to finish them off before you get a crack at them, Ly."] = 7.5,
        ["Not your finest hour, Ly. Let me show you how it's done."] = 7.5,

        ["Ich will sie nicht besiegen, bevor Ihr ihnen nicht auch ein paar verpasst habt, Ly."] = 7.5,
        ["Nicht Eure beste Leistung, Ly. Lasst es mich vormachen."] = 7.5,

        -- Double: Ly second
        ["If you're done sulking, Ly, some assistance would be welcome."] = 8,

        ["Wenn Ihr mit dem Schmollen fertig seid, Ly, wäre etwas Hilfe willkommen."] = 8,

        -- Double: Turli second
        ["It would seem my bad luck has rubbed off on you, Ly."] = 8,

        ["Anscheinend hat mein Pech auf Euch abgefärbt, Ly."] = 8,
    },
    ["Lylanar"] = {
        -- First
        ["Had your warm up then?"] = 6.4,
        ["I'll call first round."] = 6.4,
        ["Made it farther than the thralls do."] = 6.4,
        ["Now the real fight begins."] = 6.4,
        ["Watch me, Turli. This is how it's done!"] = 6.4,

        ["Seid Ihr jetzt aufgewärmt?"] = 6.4,
        ["Ich nehme die erste Runde."] = 6.4,
        ["Das war weiter, als es die Sklaven schaffen."] = 6.4,
        ["Jetzt beginnt der richtige Kampf."] = 6.4,
        ["Seht gut her, Turli. So wird's gemacht!"] = 6.4,

        -- Second to come down
        ["I don't wish to hog all the excitement. Turli, why don't you get in on the action?"] = 7.5,
        ["That was a limp performance, Turli. I'll show them what true power is."] = 7.5,

        ["Ich will den ganzen Spaß nicht für mich allein. Turli, warum steigt Ihr nicht ein?"] = 7.5,
        ["Das war eine schwache Darbietung, Turli. Ich werde ihnen zeigen, was wahre Macht ist."] = 7.5,

        -- Double: Ly second
        ["You don't look to be fairing any better than I did, Turli."] = 8, -- [sic]

        ["Es sieht nicht so aus, als ob es Euch besser ergeht als mir, Turli."] = 8,
    },
    ["Fleet Queen Taleria"] = {
        -- Taleria
        ["Barging into a lady's private chambers. You are bold."] = 23.5,
    },
    ["Flottenkönigin Taleria"] = {
        -- Taleria de
        ["Ihr stürmt einfach in die Privatgemächer einer Dame. Dreist."] = 23.5,
    },
    ["Турлассил"] = {
        -- Turlassil ru
        ["Скорее, новые претенденты."] = 16.6,

        ["Не вставай, Ли. Скоро все закончится."] = 6.4,
        ["Ли, первый раунд мой."] = 6.4,
        ["Это лишь малая часть того, что тебя ждет."] = 6.4,
        ["Мне не нравится, что ты так хочешь убить наших псов."] = 6.4,
        ["Ты проходишь в следующий раунд. С огромным трудом."] = 6.4,

        -- Second to come down
        ["Ли, я бы их уже прикончил, но ты же тогда совсем не поучаствуешь в бою."] = 7.5,
        ["Не лучший твой бой, Ли. Посмотри, как надо."] = 7.5,

        -- Double: Ly second
        ["Ли, если тебе надоело дуться — можешь помочь."] = 8,

        -- Double: Turli second
        ["Кажется, мое невезение заразило и тебя, Ли."] = 8,
    },
    ["Лиланар"] = {
        -- Lylanar ru
        ["У вас было время размяться?"] = 6.4,
        ["Первый раунд — мой."] = 6.4,
        ["Вам удалось пройти дальше, чем рабам."] = 6.4,
        ["Вот теперь начнется настоящий бой."] = 6.4,
        ["Турли, смотри и учись!"] = 6.4,

        -- Second to come down
        ["Как-то слабовато, Турли. Давай я покажу им настоящую мощь."] = 7.5,
        ["Обидно будет, если все удовольствие достанется мне. Турли, может, присоединишься?"] = 7.5,

        -- Double: Ly second
        ["Кажется, у тебя получается не лучше моего, Турли."] = 8,
    },
    ["Повелительница флота Талерия"] = {
        -- Taleria ru
        ["Вламываться в личные покои дамы? Какая наглость!"] = 23.5,
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
        -- Assembly General
        ["Well, well. Now that's the second largest construct I've ever seen. Inactive, at the moment."] = 26.4,  -- TODO: I was given 19.2, but I think it's 26.4... need testing
    },
-- KA
    ["Lord Falgravn"] = {
        -- ["You dare face me? Baleful power lurks beneath your feet, and I will have it for my own!"] = 10.2, -- not sure if it might be a tick late
        ["You wish to see my works? Very well! I will plunge you into deeper darkness!"] = 12.6,
        -- Torturers
        ["Feed, my pets. Feed!"] = {time = 30, displayFormat = "Torturers in |c%s%.1f|r"},
        ["Come, cattle! Time for the slaughter!"] = {time = 30, displayFormat = "Torturers in |c%s%.1f|r"},
        ["Behold, my banquet!"] = {time = 30, displayFormat = "Torturers in |c%s%.1f|r"},
        ["Go, children, and drink your fill!"] = {time = 30, displayFormat = "Torturers in |c%s%.1f|r"},
    },
-- LC
    ["Xoryn"] = {
        -- Count Ryelaz & Zilyesset
        ["Like them!"] = 17.6,
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

-- SE
    ["Exarchanic Yaseyla"] = {
        -- Exarchanic Yaseyla
        ["Your sorcery deceives good people. It brings nothing but pain, malpracticer!"] = 7.9,
    },
    ["Archwizard Twelvane"] = {
        -- Archwizard Twelvane and Chimera
        ["Why do you still hesitate, Vanton?"] = 6.8,
    },
    ["Warlock Vanton"] = {
        -- 2nd boss - Gryphon
        ["The gryphon is strong, but you may be stronger."] = 6.5, -- Untested
        ["You tamed the gryphon. It's vulnerable."] = 6.5, -- Untested
        ["You did it? You woke the gryphon?"] = 6.5, -- Untested
        -- 2nd boss - Wamasu
        ["You have the wamasu's power?"] = 6.5, -- Untested
        ["You beat the wamasu. Please don't die now."] = 6.5, -- Untested
        ["The wamasu's power can turn against the chimera!"] = 6.5, -- Untested
        -- 2nd boss - Lion
        ["You beat the house of the lion?"] = 6.5, -- Untested
        ["Did you take the lion's fire?"] = 6.5, -- Untested
        -- Ansuul the Tormentor
        ["Who are you? Are you one of hers? She's hurting me."] = 13, -- Untested
    },

-- SS
    ["Nahviintaas"] = {
        -- Nahviintaas
        ["To restore the natural order. To reclaim all that was and will be. To correct the mortal mistake."] = 22.2,
        ["Um die natürliche Ordnung wiederherzustellen. Das, was war und sein wird. Um sterbliche Fehler zu berichtigen."] = 22.2,
    },

-- VH
    ["Shade of the Grove"] = {
        -- Shade of the Grove - Position 1
        ["You wish to challenge the Hunter's Grove? Very well—begin!"] = 3.8, -- Untested
        ["Do not wilt from this challenge, hunter."] = 3.8, -- Untested
        ["You face the full might of the hunt!"] = 3.8, -- Untested
        ["Are you predator or prey, hunter?"] = 3.8, -- Untested
        -- Shade of the Grove - Position 2
        ["I embody life! I cannot be defeated!"] = 4.1, -- Untested
        ["This shell brings your death!"] = 4.1, -- Untested
        ["This new host serves me better!"] = 4.1, -- Untested
    },
    ["Aydolan"] = {
        -- Maebroogha the Void Lich
        ["You made it all the way to the end! Only one final challenge left. Me!"] = 12.7,
        ["Ihr habt es ganz bis zum Ende geschafft! Nur noch eine letzte Herausforderung: Ich!"] = 12.7,
    },

-----------
-- Dungeons

-- Bal Sunnar
    ["Kovan Giryon"] = {
        -- Kovan Giryon
        ["Scourge! I've waited a lifetime for you."] = 14.1,
    },
    ["Matriarch Lladi Telvanni"] = {
        -- Roksa the Warped
        ["This power is ours! I will control my own fate!"] = 18.1,
    },
    ["Saresea"] = {
        -- Matriarch Lladi Telvanni
        ["Well, I was right. Here it is."] = 9.7,
    },

-- Bedlam Veil
    ["The Blind"] = {
        ["My spell destroys everything in my way!"] = 6.7, -- 80% port. this is accurate because she says it after porting
    },

-- Blessed Crucible
    ["Snagg gro-Mashul"] = {
        ["Congratulations. You've passed the first trial."] = 15.1,
    },
    ["The Beast Master"] = {
        ["And there we have it! The winners of the Grand Melee!"] = {time = 43.4, displayFormat = "INCINERATION BEETLES!!! in |c%s%.1f|r"},
        ["These challengers are surprisingly fierce! But here's the real reason you've come today!"] = 25.5, -- Stinger
        ["What? Impossible? How did you win?"] = 19.7, -- Troll King
    },

-- Castle Thorn
    ["Lady Thorn"] = {
        -- Blood Twilight
        ["Well done, Talfyg. You brought me a daughter of Verandis, as requested. She will complement our lord's army well."] = 19.2,
    },
    ["Fürstin Dorn"] = {
        -- Blood Twilight
        ["Gut gemacht, Talfyg. Ihr habt mir eine Tochter von Verandis gebracht. Wie erbeten. Sie wird die Armee unseres Fürsten gut ergänzen."] = 19.2,
    },
    ["Talfyg"] = {
        -- Talfyg
        ["How dare you reject Lady Thorn's offer? Look! Tremble before the power you might have wielded!"] = 9.1,
    },

-- Cradle of Shadows
    ["Dranos Velador"] = {
        ["Well done, my scaled friend. You have cast off your old skin, and the Silken Ring welcomes you as a brother. Seek out Velidreth and receive your blessing."] = 16.8,
    },

-- Depths of Malatar
    ["The Weeping Woman"] = {
        ["For her, we kept it hidden from our brethren and buried them with our tears. Here you too will drown."] = 11.1,
    } ,
    ["Tharayya"] = {
        -- King Narilmor
        ["Feel that? A chill breeze. We must be nearing an exit!"] = 23,
    },

-- Earthen Root Enclave
    ["Druid Laurel"] = {
        -- Archdruid Devyric
        ["He's killing the spirit. He has the seed. Stop him. Please stop him!"] = 12.3, -- TODO
    },

-- Falkreath Hold
    ["Cernunnon"] = {
        -- Deathlord Bjarfrud Skjoralmor
        ["Wake, little Jarl. See how your kingdom burns? Reap your vengeance."] = 8.3,
    },
    ["Jarl Skjoralmor"] = {
        -- Domihaus the Bloody-Horned
        ["I said to keep the fight out there! Oh, you aren't my guards. Nor are you Reachmen. We've won then?"] = 13.6,
    },

-- Fang Lair
    ["Orryn the Black"] = {
        -- Cadaverous Bear
        ["You're still here? If you must admire my work, at least allow me to put my best fossil forward."] = 10.9,
        -- Caluurion
        ["Caluurion. See that our uninvited guests are made comfortable for a very long stay."] = 14.2,
        -- Ulfnor and Sabina
        ["So many of the things you've broken I can easily replace, but Caluurion … he was a unique specimen. He'll never be the same."] = 17.5,
    },

-- Lair of Maarselok
    ["Selene"] = {
        -- Selene fight (bear, spider)
        ["Now for payment in kind. It's my turn to study your insides, warlock!"] = 4.8,
        ["Nun zu meiner Vergeltung. Jetzt studiere ich Eure Eingeweide, Hexer!"] = 4.8,
    },

-- Moongrave Fane
    ["Nisaazda"] = {
        -- Kujo Kethba
        ["This one won't have to."] = 12.8,
    },
    ["Grundwulf"] = {
        ["I can feel it! Haha"] = 19, -- TODO
    },

-- Moon Hunter Keep
    ["Vykosa the Ascendant"] = {
        -- Mylenne Moon-Caller
        ["Was Vykosa not told the intruders would be dealt with? Must she handle everything herself?"] = 14.7,
    },

-- Oathsworn Pit
    ["Anthelmir"] = {
        ["You cut me for the last time. Crush her!"] = 8.6,
    },
    ["Aradros the Awakened"] = {
        ["You think this place intimidates me? I am the forge's fire."] = 21.6,
    },

-- Red Petal Bastion
    ["Lyranth"] = {
        -- Rogerain the Sly
        ["I expected greater resistance. It seems the Silver Rose are short on more than servants."] = 12.6, -- Untested
        -- Prior Thierric Sarazen
        ["I feel a surge in the Daedric power. It's gathering."] = 22, -- Untested
    },
    ["Prior Thierric Sarazen"] = {
        -- Eliam Merick
        ["Does the heathen priest believe he can stand in the way of our divine purpose?"] = 21.8, -- Untested
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

-- Shipwright's Regret
    ["Caska"] = {
        -- Nazaray
        ["Huh. Looks dead now."] = 5.2,
    },
    ["Captain Za'ji"] = {
        -- Foreman Bradiggan
        ["And we're through! That wasn't so hard now, was it?"] = 8.3,
        -- Captain Numirril
        ["Come back you scaly scallywags! You take what is rightfully Captain Za'ji's!"] = 22.3,
    },
    ["Captain Numirril"] = {
        ["I am Dreadsail, born of the sea. I cannot be defeated!"] = 16,
    },

-- The Cauldron
    ["Baron Zaudrus"] = {
        ["What you want is right here, Lyranth. Come take it."] = 12,
    },

-- The Dread Cellar
    ["Martus Tullius"] = {
        -- Magma Incarnate
        ["The Daedra are pouring their energy into that machine!"] = 9.5, -- Untested
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

---------------------------------------------------------------------
-- API to merge data in I guess
-- This takes in a table of the same format as SUBTITLE_TIMES above,
-- allowing a separate addon to house data to be displayed, without
-- getting overwritten by changes.
---------------------------------------------------------------------
function Crutch.MergeDamageable(other)
    for npc, lines in pairs(other) do
        if (not SUBTITLE_TIMES[npc]) then
            SUBTITLE_TIMES[npc] = {}
        end

        local numLinesMerged = 0
        -- Prefer existing
        for line, value in pairs(lines) do
            if (SUBTITLE_TIMES[npc][line]) then
                Crutch.dbgOther("Skipping because already exists: " .. line)
            else
                SUBTITLE_TIMES[npc][line] = value
                numLinesMerged = numLinesMerged + 1
            end
        end
        Crutch.dbgOther(string.format("Merged %d lines for %s", numLinesMerged, npc))
    end
end

---------------------------------------------------------------------
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
local dmgDisplayFormat = "Boss in |c%s%.1f|r"
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
        CrutchAlertsDamageableLabel:SetText(string.format(dmgDisplayFormat, GetTimerColor(millisRemaining), millisRemaining / 1000))
    end
end

---------------------------------------------------------------------
-- Display the timer
function Crutch.DisplayDamageable(time, displayFormat)
    dmgDisplayFormat = displayFormat or "Boss in |c%s%.1f|r"
    pollTime = GetGameTimeMilliseconds() + time * 1000
    CrutchAlertsDamageableLabel:SetText(string.format(dmgDisplayFormat, GetTimerColor(time * 1000), time))
    CrutchAlertsDamageableLabel:SetHidden(false)

    if (not isPolling) then
        isPolling = true
        EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "PollDamageable", 100, UpdateDisplay)
    end
end

---------------------------------------------------------------------
-- This keeps track of whether it's the first time a "single" subtitle has played in an instance
local isInstanceFresh = true
local function OnPlayerActivated()
    isInstanceFresh = true
end

---------------------------------------------------------------------
-- EVENT_CHAT_MESSAGE_CHANNEL (number eventCode, MsgChannelType channelType, string fromName, string text, boolean isCustomerService, string fromDisplayName)
local function HandleChat(_, channelType, fromName, text, isCustomerService, fromDisplayName)
    if (not SUBTITLE_CHANNELS[channelType]) then
        return
    end

    local name = zo_strformat("<<C:1>>", fromName)
    if (Crutch.savedOptions.showSubtitles) then
        if (not Crutch.savedOptions.subtitlesIgnoredZones[GetZoneId(GetUnitZoneIndex("player"))]) then
            CHAT_SYSTEM:AddMessage(string.format("|c88FFFF%s: |cAAAAAA%s", name, text))
        else
            Crutch.dbgSpam(string.format("|c88FFFF%s: |cAAAAAA%s", name, text))
        end
    end

    if (not Crutch.savedOptions.general.showDamageable) then
        return
    end

    -- Dialogue NPC matches
    local lines = SUBTITLE_TIMES[name]
    if (not lines) then
        return
    end

    local time = lines[text]
    if (time) then
        Crutch.dbgSpam("|c00FF00[DMG]|r Found time using exact string: " .. text)
    else
        -- Check each one using string.find
        for line, t in pairs(lines) do
            if (string.find(text, line, 1, true)) then
                time = t
                Crutch.dbgSpam("|c00FF00[DMG]|r Found time using |cFF0000find|r: " .. text)
            end
        end

        if (not time) then
            return
        end
    end

    -- Extra info
    local displayFormat
    if (type(time) == "table") then
        -- If the time is a special case and it's the specified zone...
        if (time.singleZoneId and time.singleZoneId == GetZoneId(GetUnitZoneIndex("player"))) then
            -- ... only display if it's the first time one of these lines has been found in this instance
            if (not isInstanceFresh) then
                Crutch.dbgOther("|c88FF88Skipping damageable because this is not a fresh instance.|r")
                return
            end
            isInstanceFresh = false
            Crutch.dbgOther("|c88FF88Single-time line found, will only display this time.|r")
        end

        -- Special display format, for when it is not a boss
        displayFormat = time.displayFormat -- can be nil
        if (displayFormat) then
            Crutch.dbgOther("|c88FF88Displayformat|r: " .. displayFormat)
        end

        time = time.time
    end

    -- Have the number of seconds after which the boss should be damageable
    Crutch.DisplayDamageable(time, displayFormat)
end

---------------------------------------------------------------------
function Crutch.InitializeDamageable()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ChatHandler", EVENT_CHAT_MESSAGE_CHANNEL, HandleChat)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DamageablePlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end
