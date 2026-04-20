local Crutch = CrutchAlerts

local SUBTITLE_CHANNELS = {
    [CHAT_CHANNEL_MONSTER_WHISPER] = true,
    [CHAT_CHANNEL_MONSTER_EMOTE] = true,
    [CHAT_CHANNEL_MONSTER_YELL] = true,
    [CHAT_CHANNEL_MONSTER_SAY] = true,
}

local function GetNameStr(id)
    return Crutch.GetCapitalizedString(id)
end

local function GetSubtitleStr(id)
    return GetString(id)
end

-- TODO: migrate these to lang files
-- /script d(GetZoneId(GetUnitZoneIndex("player")))
local SUBTITLE_TIMES = {
-- CR
    [GetNameStr(CRUTCH_BHB_ZMAJA)] = {
        [GetSubtitleStr(CRUTCH_DMG_I_WONT_BE_BEATEN_ILL_SMASH_THIS)] = 14.4,

        -- These are unfortunately also idle voice lines, so to work around this, only display them once ("singleZoneId") in an instance
        [GetSubtitleStr(CRUTCH_DMG_YOU_CHALLENGE_THE_POWER_OF_THE_SEA)] = {time = 7.5, singleZoneId = 1051},
        [GetSubtitleStr(CRUTCH_DMG_YOU_DARE_FIGHT_AGAINST_DARKNESS_ITSELF)] = {time = 7.5, singleZoneId = 1051},
        [GetSubtitleStr(CRUTCH_DMG_DARKNESS_SHALL_REIGN_ACROSS_SUMMERSET)] = {time = 7.5, singleZoneId = 1051},
        [GetSubtitleStr(CRUTCH_DMG_CLOUDREST_HAS_ALREADY_FALLEN_AND_SO_TOO)] = {time = 7.5, singleZoneId = 1051},
        [GetSubtitleStr(CRUTCH_DMG_SOON_MY_SHADOWS_SHALL_SPREAD_TO_ALL_OF)] = {time = 7.5, singleZoneId = 1051},
        [GetSubtitleStr(CRUTCH_DMG_THE_SHADOWS_ANSWER_TO_ME_NOW)] = {time = 7.5, singleZoneId = 1051},
        [GetSubtitleStr(CRUTCH_DMG_DO_YOU_TRULY_THINK_YOU_CAN_STAND_AGAINST)] = {time = 7.5, singleZoneId = 1051},
        [GetSubtitleStr(CRUTCH_DMG_I_CAN_WAIT_AFTER_ALL_YOUR_DEATHS_ARE)] = {time = 7.5, singleZoneId = 1051},
    },
-- DSR
    [GetNameStr(CRUTCH_DMG_TURLASSIL)] = {
        -- Lylanar and Turlassil
        [GetSubtitleStr(CRUTCH_DMG_FRESH_CHALLENGERS_MORE_LIKE)] = 16.6,

        -- First
        [GetSubtitleStr(CRUTCH_DMG_DONT_GET_UP_LY_THIS_WILL_JUST_BE_A)] = 6.4,
        [GetSubtitleStr(CRUTCH_DMG_ILL_TAKE_THE_FIRST_ROUND_LY)] = 6.4,
        [GetSubtitleStr(CRUTCH_DMG_THAT_WAS_JUST_A_TASTE_OF_WHATS_TO_COME)] = 6.4,
        [GetSubtitleStr(CRUTCH_DMG_YOU_LOOKED_A_LITTLE_TOO_EAGER_TO_KILL)] = 6.4,
        [GetSubtitleStr(CRUTCH_DMG_YOU_PASS_BARELY)] = 6.4,

        -- Second to come down
        [GetSubtitleStr(CRUTCH_DMG_I_DONT_WANT_TO_FINISH_THEM_OFF_BEFORE)] = 7.5,
        [GetSubtitleStr(CRUTCH_DMG_NOT_YOUR_FINEST_HOUR_LY_LET_ME_SHOW)] = 7.5,

        -- Double: Ly second
        [GetSubtitleStr(CRUTCH_DMG_IF_YOURE_DONE_SULKING_LY_SOME)] = 8,

        -- Double: Turli second
        [GetSubtitleStr(CRUTCH_DMG_IT_WOULD_SEEM_MY_BAD_LUCK_HAS_RUBBED_OFF)] = 8,
    },
    [GetNameStr(CRUTCH_BHB_LYLANAR)] = {
        -- First
        [GetSubtitleStr(CRUTCH_DMG_HAD_YOUR_WARM_UP_THEN)] = 6.4,
        [GetSubtitleStr(CRUTCH_DMG_ILL_CALL_FIRST_ROUND)] = 6.4,
        [GetSubtitleStr(CRUTCH_DMG_MADE_IT_FARTHER_THAN_THE_THRALLS_DO)] = 6.4,
        [GetSubtitleStr(CRUTCH_DMG_NOW_THE_REAL_FIGHT_BEGINS)] = 6.4,
        [GetSubtitleStr(CRUTCH_DMG_WATCH_ME_TURLI_THIS_IS_HOW_ITS_DONE)] = 6.4,

        -- Second to come down
        [GetSubtitleStr(CRUTCH_DMG_I_DONT_WISH_TO_HOG_ALL_THE_EXCITEMENT)] = 7.5,
        [GetSubtitleStr(CRUTCH_DMG_THAT_WAS_A_LIMP_PERFORMANCE_TURLI_ILL)] = 7.5,

        -- Double: Ly second
        [GetSubtitleStr(CRUTCH_DMG_YOU_DONT_LOOK_TO_BE_FAIRING_ANY_BETTER)] = 8, -- [sic]

        -- Double: Turli second
        [GetSubtitleStr(CRUTCH_DMG_COME_ON_TURLI_LETS_SECURE_THE)] = 8,
    },
    [GetNameStr(CRUTCH_BHB_TIDEBORN_TALERIA)] = {
        -- Taleria
        [GetSubtitleStr(CRUTCH_DMG_BARGING_INTO_A_LADYS_PRIVATE_CHAMBERS)] = 23.5,
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
        ["You dare face me? Baleful power lurks beneath your feet, and I will have it for my own!"] = 9.7, -- could be a tick late
        ["You wish to see my works? Very well! I will plunge you into deeper darkness!"] = 12.6,
        -- Torturers
        ["Feed, my pets. Feed!"] = {time = 30, displayFormat = "Torturers in "},
        ["Come, cattle! Time for the slaughter!"] = {time = 30, displayFormat = "Torturers in "},
        ["Behold, my banquet!"] = {time = 30, displayFormat = "Torturers in "},
        ["Go, children, and drink your fill!"] = {time = 30, displayFormat = "Torturers in "},
    },
-- LC
    [GetNameStr(CRUTCH_DMG_XORYN)] = {
        -- Count Ryelaz & Zilyesset
        [GetSubtitleStr(CRUTCH_DMG_LIKE_THEM)] = 17.6,
    },
-- MoL
    ["Mirarro"] = {
        -- Zhaj'hassa
        ["Don't …. It's … trap. He's coming!"] = 16.8,
        ["Nicht*… Eine*… Falle."] = 16.8,
        ["Er kommt!"] = 16.8,
    },
    ["Kulan-Dro"] = {
        -- Rakkhat
        ["Have you not heard me? Have I not made your choice plain? You will listen, mortals ... even if it means peeling the ears from your scalps and shouting Namiira's will into whatever's left of your broken skulls!"] = 26.4, -- TODO: probably fix the ...
        ["Have you not heard me? Have I not made your choice plain? You will listen, mortals"] = 26.4,
    },
    ["Kulan-dro"] = {
        -- Rakkhat
        ["Habt Ihr mich nicht gehört? Hatte ich mich nicht klar ausgedrückt? Ihr werdet zuhören, Sterbliche"] = 26.4,
    },

-- OC
    ["Skorkhif"] = {
        ["When I'm the one who caused their suffering?"] = 13.4, -- en
        ["Obwohl ich doch der bin, der sie leiden ließ?"] = 13.4, -- de
        ["¿Cuando fui yo quien causó su sufrimiento?"] = 13.4, -- es
        ["Alors que c'est moi qui les fais souffrir ?"] = 13.4, -- fr
        ["Quando fui eu quem causou o sofrimento deles?"] = 13.4, -- br
    },
    -- jp
    ["スコルキフ"] = {
        ["奴らを苦しめたのは私なのに？"] = 13.4,
    },
    -- ru
    ["Скоркиф"] = {
        ["Но ведь это я заставил их страдать."] = 13.4,
    },
    -- zh
    ["斯科尔基弗"] = {
        ["让他们受苦的人不是我吗？"] = 13.4,
    },

-- RG
    ["Flame-Herald Bahsei"] = {
        ["Great Xalvakka drank deep from the souls we served her. Soon, she arrives!"] = 7.0, -- TODO: not sure if 7 or 8, both have happened...
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
    [GetNameStr(CRUTCH_BHB_NAHVIINTAAS)] = {
        -- Nahviintaas
        [GetSubtitleStr(CRUTCH_DMG_TO_RESTORE_THE_NATURAL_ORDER_TO_RECLAIM)] = 22.2,
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
        ["And there we have it! The winners of the Grand Melee!"] = {time = 43.4, displayFormat = "INCINERATION BEETLES!!! in "},
        ["These challengers are surprisingly fierce! But here's the real reason you've come today!"] = 25.5, -- Stinger
        ["What? Impossible? How did you win?"] = 19.7, -- Troll King
    },

-- Castle Thorn
    ["Lady Thorn"] = {
        -- Blood Twilight
        ["Well done, Talfyg. You brought me a daughter of Verandis, as requested. She will complement our lord's army well."] = 23.1,
    },
    ["Fürstin Dorn"] = {
        -- Blood Twilight
        ["Gut gemacht, Talfyg. Ihr habt mir eine Tochter von Verandis gebracht. Wie erbeten. Sie wird die Armee unseres Fürsten gut ergänzen."] = 19.2,
    },
    ["Talfyg"] = {
        -- Talfyg
        ["How dare you reject Lady Thorn's offer? Look! Tremble before the power you might have wielded!"] = 9.1,
    },

-- Coral Aerie
    ["Jakarn"] = {
        -- S'zarzo the Bulwark
        ["Hah! You thought I'd crack that soon? I'm Jakarn! The Jak—Kaleen?"] = 13.6,
    },
    ["Sarydil"] = {
        ["Well, well. Look what washed into our yaghra trap. You can surrender, or you can become bait. Choose."] = 13,
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
        ["He's killing the spirit. He has the seed. Stop him. Please stop him!"] = 11.2,
    },

-- Exiled Redoubt
    ["Cato Albus"] = {
        ["Who dares interrupt? I cannot avenge my son without these deaths!"] = 6.9,
    },
    ["Prime Sorcerer Vandorallen"] = {
        ["No one can stop us. You stand no chance!"] = 4.3,
    },
    ["Lucilla Caprenia"] = {
        -- Squall of Retribution
        ["Cato! It's over. Stop this madness!"] = 6.9,
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

-- Icereach
    ["Sister Gohlla"] = {
        -- Kjarg the Tuskscraper
        ["More intruders? Marvelous. On your feet, my sweet boy. Smash them for mother, won't you?"] = 8.8,
    },
    ["Sister Maefyn"] = {
        -- Stormborn Revenant
        ["So simple, is it? Arise, and fight on, champion!"] = 5.7,
    },
    ["Sister Bani"] = {
        -- Vearogh the Shambler
        ["Disgusting intruders! I won't have it. I will not have it!"] = 9.2,
    },

-- Lair of Maarselok
    ["Selene"] = {
        -- Selene fight (bear, spider)
        ["Now for payment in kind. It's my turn to study your insides, warlock!"] = 4.8,
        ["Nun zu meiner Vergeltung. Jetzt studiere ich Eure Eingeweide, Hexer!"] = 4.8,
    },

-- Lep Seclusa
    ["Noriwen"] = {
        ["Alcunar!"] = {time = 5.3, singleZoneId = 1497},
    },
    ["Sister Chana Nirine"] = {
        ["You'll never read this scroll!"] = 11,
    },

-- March of Sacrifices
    ["Dagrund the Bulky"] = {
        ["Troll's blood, it has to be here somewhere! Keep an eye out."] = 18.2,
    },

-- Moongrave Fane
    ["Nisaazda"] = {
        -- Risen Ruins
        ["Renald is slippery, but Nisaazda will catch him in time. You will not be so lucky."] = 9.5,
        -- Kujo Kethba
        ["This one won't have to."] = 12.8,
    },
    ["Grundwulf"] = {
        ["I can feel it! Haha"] = 19,
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

-- Scalecaller Peak
    ["Plague Concocter Mortieu"] = {
        ["So busy, so busy, and now I must entertain these guests?"] = 6.2,
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

-- Spindleclutch II
    ["Guardian Sud-Hareem"] = {
        -- Bloodspawn
        ["Over there! It's Mereel!"] = 23.8,
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

-- Wayrest Sewers II
    ["Master Pellingare"] = {
        ["Allene! Varaine! It's your father! I love you, and I want to talk to you!"] = 20.4,
    },

---------
-- Arenas

-- DSA
    ["Hiath the Battlemaster"] = {
        -- Arena 1 start
        ["We have new challengers! Will they survive the competition, or will their blood decorate the floor of our grand Arena?"] = {time = 20.0, displayFormat = "Portal spawns in "},
        -- Arena 2 start
        ["You dare to go on? This pleases my master. Let's hope you continue to please her and she grants you the strength to survive the coming battles."] = {time = 24.0, displayFormat = "Portal spawns in "},
        -- 3
        ["Every victory elevates you in the eyes of the master, mortals. But how will you fare in the marsh? Can you handle the mud and the bugs and the creatures intent on eating you once they defeat you?"] = {time = 27.1, displayFormat = "Portal spawns in "},
        -- 4
        ["I'm sure you're starting to wonder what's going on in here. You'll come to understand—provided you survive!"] = {time = 25.3, displayFormat = "Portal spawns in "},
        -- 5
        ["How puzzling! What could those strange tiles be used for? I guess you better figure it out quickly—if you don't want to die, of course!"] = {time = 22.1, displayFormat = "Portal spawns in "},
        -- 7
        ["And so your journey takes you into the depths of my master's domain. Her most-beloved worshipers reside here, including her favorite champions. Those who would gladly sacrifice themselves to become something … more."] = {time = 31.2, displayFormat = "Portal spawns in "},
        -- 9
        ["You must think you're really something. Arena after arena, you emerge victorious. But you are nothing. Nothing but lowly insects waiting to be stepped on."] = {time = 32.2, displayFormat = "Portal spawns in "},
    },
    ["Boethiah"] = {
        -- 6
        ["Now the real challenge begins, my honored contestants. My champion has been silenced so that I may congratulate you personally for making it this far. From this point on, you will be pushed to your limits."] = {time = 40.1, displayFormat = "Portal spawns in "},
        -- 8
        ["Your strength knows no bounds. Rarely have I seen a group that works so well together. The last time must have been, oh, those poor Mages Guild members I found in the Dwemer ruins years ago."] = {time = 36.0, displayFormat = "Portal spawns in "},
        -- 10 TODO: precise time unknown; 39 from Cas for now
        ["And so the final challenge begins. Those who would represent me as champion now stand in this arena, deep within my realm. Only those who remain standing will receive my highest honor."] = 40.0,
    },

-----------
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
    if (Crutch.savedOptions.general.consolidateDamageableInInfoPanel) then
        Crutch.InfoPanel.CountDownDamageable(time, displayFormat or "Boss in ")
    else
        dmgDisplayFormat = displayFormat or "Boss in "
        dmgDisplayFormat = dmgDisplayFormat .. "|c%s%.1f|r"
        pollTime = GetGameTimeMilliseconds() + time * 1000
        CrutchAlertsDamageableLabel:SetFont(Crutch.GetStyles().damageableFont)
        CrutchAlertsDamageableLabel:SetText(string.format(dmgDisplayFormat, GetTimerColor(time * 1000), time))
        CrutchAlertsDamageableLabel:SetHidden(false)

        if (not isPolling) then
            isPolling = true
            EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "PollDamageable", 100, UpdateDisplay)
        end
    end
end

function Crutch.StopDamageable()
    pollTime = GetGameTimeMilliseconds()
    CrutchAlertsDamageableLabel:SetHidden(true)
    Crutch.InfoPanel.StopDamageable()
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
            CHAT_ROUTER:AddSystemMessage(string.format("|c88FFFF%s: |cAAAAAA%s", name, text))
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
                Crutch.dbgSpam("|c88FF88Skipping damageable because this is not a fresh instance.|r")
                return
            end
            isInstanceFresh = false
            Crutch.dbgSpam("|c88FF88Single-time line found, will only display this time.|r")
        end

        -- Special display format, for when it is not a boss
        displayFormat = time.displayFormat -- can be nil
        if (displayFormat) then
            Crutch.dbgSpam("|c88FF88Displayformat|r: " .. displayFormat)
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
