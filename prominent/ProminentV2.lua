CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

-- Data for prominent display of notifications
-- Key by zoneId so we only register each one in the right zone
-- preMillis is how long before the end of the timer we should start the alert... which is currently not used in V2
-- millis is duration of the alert

-- filters can take a special "filterFunction" that should return true if the prominent alert should be shown
local prominentData = {
-----------------------------------------------------------
-- TRIALS
-----------------------------------------------------------

    ------------
    -- Cloudrest
    [1051] = {
        settingsSubcategory = "cloudrest",
        -- Direct Current (Relequen interruptible)
        [105380] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
                filterFunction = function(hitValue) return hitValue > 1000 end, -- Otherwise it fires twice, once for the initial cast probably
            },
            text = "INTERRUPT", 
            color = {0.5, 1, 1}, 
            slot = 2,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentDirectCurrent",
                title = "Alert Direct Current",
                description = "Shows a prominent alert for Relequen's interruptible attack, Direct Current",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Glacial Spikes (Galenwe interruptible)
        [106405] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "INTERRUPT",
            color = {0.5, 1, 1},
            slot = 2,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentGlacialSpikes",
                title = "Alert Glacial Spikes",
                description = "Shows a prominent alert for Galenwe's interruptible attack, Glacial Spikes",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Creeper spawn
        [105016] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "CREEPER",
            color = {0.5, 1, 0.5},
            slot = 1,
            playSound = true,
            millis = 3000,
            settings = {
                name = "prominentCreeper",
                title = "Alert Creeper Spawn",
                description = "Shows a prominent alert when a Malicious Creeper spawns",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Grievous Retaliation
        [104646] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_DAMAGE,
                [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = COMBAT_UNIT_TYPE_PLAYER,
            },
            text = "STOP REZZING",
            color = {0.6, 0, 1},
            slot = 3,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentGrievous",
                title = "Alert Grievous Retaliation",
                description = "Shows a prominent alert when you try to resurrect a player with their shade still up",
                checkOldForDefault = false,
                default = true,
            },
        },
    },

    -----------------
    -- Dreadsail Reef
    [1344] = {
        settingsSubcategory = "dreadsailreef",
        -- Cascading Boot (Dreadsail Overseer)
        [170188] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Untested, but probably correct
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
                [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = COMBAT_UNIT_TYPE_PLAYER,
            },
            text = "BOOT",
            color = {223/255, 71/255, 237/255},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentCascadingBoot",
                title = "Alert Cascading Boot",
                description = "Shows a prominent alert when a Dreadsail Overseer tries to yeet you with Cascading Boot",
                checkOldForDefault = true,
                default = true,
            },
        },
    },

    -----------------------
    -- Halls of Fabrication
    [975] = {
        settingsSubcategory = "hallsoffabrication",
        -- Direct Current (Pinnacle interruptible)
        [90876] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "INTERRUPT",
            color = {0.5, 1, 1},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentPinnacleDirectCurrent",
                title = "Alert Direct Current",
                description = "Shows a prominent alert when the Pinnacle Factotum casts its interruptible, Direct Current",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Reclaim the Ruined (Adds spawn)
        [90499] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_EFFECT_FADED, -- Use FADED because they take forever to become damageable
            },
            text = "ADDS",
            color = {1, 0.2, 0.2},
            slot = 1,
            playSound = false,
            millis = 2000,
            settings = {
                name = "prominentReclaimTheRuined",
                title = "Alert Reclaim the Ruined",
                description = "Shows a prominent alert when the adds spawn during the triplets fight",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Stomp (Assembly General)
        [91454] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "BLOCK",
            color = {1, 0.2, 0.2},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentStomp",
                title = "Alert Stomp",
                description = "Shows a prominent alert when the Assembly General does Stomp (for trench strat)",
                checkOldForDefault = true,
                default = true,
            },
        },
    },

    ---------------
    -- Kyne's Aegis
    [1196] = {
        settingsSubcategory = "kynesaegis",
        -- Booger
        [136548] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_EFFECT_FADED,
                filterFunction = function() return GetSelectedLFGRole() == LFG_ROLE_TANK end,
            },
            text = "BOOGER",
            color = {1, 0, 0},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentBooger",
                title = "Alert Hemorrhage Ended (Tank Only)",
                description = "Shows a prominent alert if you are a tank and the Hemorrhage phase ends, as a reminder to taunt the new coagulant",
                checkOldForDefault = true,
                default = true,
            },
        },
    },

    -----------------
    -- Lucent Citadel
    [1478] = {
        settingsSubcategory = "lucentcitadel",
        -- Darkness Inflicted
        [214338] = {
            event = EVENT_EFFECT_CHANGED,
            filters = { -- Verified
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            text = "DARK",
            color = {0.5, 0, 1},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentDarknessInflicted",
                title = "Alert Darkness Inflicted",
                description = "Shows a prominent alert when you gain Darkness Inflicted (3 stacks of Creeping Darkness)",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Fate Sealer
        [214136] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
                filterFunction = function() return GetSelectedLFGRole() == LFG_ROLE_TANK end,
            },
            text = "FATE SEALER",
            color = {1, 0, 1},
            slot = 1,
            playSound = true,
            millis = 2000,
            settings = {
                name = "prominentFateSealer",
                title = "Alert Fate Sealer",
                description = "Shows a prominent alert when the Orphic Shattered Shard summons a Fate Sealer orb and if you are a tank",
                checkOldForDefault = true,
                default = true,
            },
        },
    },

    -----------------
    -- Maw of Lorkhaj
    [725] = {
        settingsSubcategory = "mawoflorkhaj",
        -- Shattering Strike (Dro-m'Athra Savage)
        [73249] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
                [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = COMBAT_UNIT_TYPE_PLAYER,
            },
            text = "SHATTER",
            color = {1, 0, 0},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentShatteringStrike",
                title = "Alert Shattering Strike",
                description = "Shows a prominent alert when a Dro-m'Athra Savage targets you to shatter your armor with Shattering Strike",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Grip of Lorkhaj (Zhaj'hassa)
        [76049] = { -- 57469 is probably the cast
            event = EVENT_EFFECT_CHANGED,
            filters = { -- Verified
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            text = "CURSE",
            color = {0.5, 0, 1},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentGripOfLorkhaj",
                title = "Alert Grip of Lorkhaj",
                description = "Shows a prominent alert when you are cursed by Zhaj'hassa",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Threshing Wings (Rakkhat)
        [73741] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "BLOCK",
            color = {1, 0.9, 0.66},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentThreshingWings",
                title = "Alert Threshing Wings",
                description = "Shows a prominent alert when you should block to avoid Rakkhat's knockback",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Unstable Void (Rakkhat)
        [74488] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = COMBAT_UNIT_TYPE_PLAYER,
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_EFFECT_GAINED,
            },
            text = "UNSTABLE",
            color = {1, 0, 0},
            slot = 2,
            playSound = true,
            millis = 2000,
            settings = {
                name = "prominentUnstableVoid",
                title = "Alert Unstable Void",
                description = "Shows a prominent alert when you receive Unstable Void and should take the bomb out of group",
                checkOldForDefault = true,
                default = true,
            },
        },
    },

    ------------
    -- Rockgrove
    [1263] = {
        settingsSubcategory = "rockgrove",
        -- Savage Blitz (Oaxiltso)
        [149414] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "BLITZ",
            color = {1, 1, 0.5},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentSavageBlitz",
                title = "Alert Savage Blitz",
                description = "Shows a prominent alert when Oaxiltso charges",
                checkOldForDefault = true,
                default = true,
            },
        },
    },

    ----------------
    -- Sanity's Edge
    [1427] = {
        settingsSubcategory = "sanitysedge",
        -- Chain Pull (Exarchanic Yaseyla)
        [184540] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = COMBAT_UNIT_TYPE_PLAYER,
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "CHAIN",
            color = {1, 0, 0},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentChainPull",
                title = "Alert Chain Pull",
                description = "Shows a prominent alert when Yaseyla chains you and you should break free",
                checkOldForDefault = true,
                default = true,
            },
        },
    },

    -----------
    -- Sunspire
    [1121] = {
        settingsSubcategory = "sunspire",
        -- Shield Charge (Ruin of Alkosh)
        [117075] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
                [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = COMBAT_UNIT_TYPE_PLAYER,
            },
            text = "SHIELD CHARGE",
            color = {0.5, 1, 1},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentShieldCharge",
                title = "Alert Shield Charge",
                description = "Shows a prominent alert when a Ruin of Alkosh targets you with Shield Charge",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Sundering Gale (Eternal Servant)
        [121422] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
                [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = COMBAT_UNIT_TYPE_PLAYER,
            },
            text = "CONE",
            color = {0.5, 1, 1},
            slot = 1,
            playSound = true,
            preMillis = 1000,
            millis = 1000,
            settings = {
                name = "prominentSunderingGale",
                title = "Alert Sundering Gale",
                description = "Shows a prominent alert when the Eternal Servant in the portal targets you with the Sundering Gale cone",
                checkOldForDefault = true,
                default = true,
            },
        },
    },

    -----------------------------------------------------------
    -- ARENAS
    -----------------------------------------------------------

    -------------------
    -- Blackrose Prison
    [1082] = {
        settingsSubcategory = "blackrose",
        -- Lava Whip (Imperial Dread Knight)
        [111161] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Need re-test with player filter
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
                [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = COMBAT_UNIT_TYPE_PLAYER,
            },
            text = "LAVA WHIP",
            color = {1, 0.6, 0},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentLavaWhip",
                title = "Alert Lava Whip",
                description = "Shows a prominent alert when an Imperial Dread Knight targets you with Lava Whip",
                checkOldForDefault = true,
                default = true,
            },
        },
    },

    -------------------
    -- Dragonstar Arena
    [635] = {
        settingsSubcategory = "dragonstar",
        -- Heat Wave
        [15164] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "HEAT WAVE",
            color = {1, 0.3, 0.1},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentHeatWaveDSA",
                title = "Alert Heat Wave",
                description = "Shows a prominent alert when a fire mage casts Heat Wave",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Winter's Reach
        [12459] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "WINTER'S REACH",
            color = {0.5, 1, 1},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentWintersReachDSA",
                title = "Alert Winter's Reach",
                description = "Shows a prominent alert when an ice mage casts Winter's Reach",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Draining Poison (Pacthunter Ranger)
        [54608] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
                [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = COMBAT_UNIT_TYPE_PLAYER,
            },
            text = "DODGE",
            color = {0, 0.6, 0},
            slot = 1,
            playSound = true,
            millis = 1000, -- Also maybe need premillis?
            settings = {
                name = "prominentDrainingPoison",
                title = "Alert Draining Poison",
                description = "Shows a prominent alert when a Pacthunter Ranger targets you with Draining Poison. You should dodge to avoid having your resources drained",
                checkOldForDefault = true,
                default = true,
            },
        },
    },

    -------------------
    -- Infinite Archive
    [1436] = {
        settingsSubcategory = "endlessArchive",
        -- Grasp of Lorkhaj (Zhaj'hassa)
        [197434] = {
            event = EVENT_EFFECT_CHANGED,
            filters = { -- Verified
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            text = "CURSE",
            color = {0.5, 0, 1},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentGraspOfLorkhaj",
                title = "Alert Grasp of Lorkhaj",
                description = "Shows a prominent alert when you are cursed by Zhaj'hassa",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Meteor Call (Fabled Mystic)
        [211976] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "METEOR",
            color = {1, 0, 0},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentMeteorCall",
                title = "Alert Meteor Call",
                description = "Shows a prominent alert when a Fabled Mystic summons a Meteor",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Venomous Arrow (Ascendant Archer, Grovebound Blightbow)
        [196689] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
                [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = COMBAT_UNIT_TYPE_PLAYER,
                filterFunction = function(hitValue, effectUnitId)
                    Crutch.dbgSpam(zo_strformat("testing <<1>> unitId", effectUnitId))
                    return GetEndlessDungeonCounterValue(ENDLESS_DUNGEON_COUNTER_TYPE_ARC) > 3 and not Crutch.majorCowardiceUnitIds[effectUnitId]
                end,
            },
            text = "VENOM",
            color = {0.4, 0.9, 0},
            slot = 2,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentVenomousArrow",
                title = "Alert Venomous Arrow (Arc 4+)",
                description = "Shows a prominent alert when an Ascendant Archer or Grovebound Blightbow casts Venomous Arrow at you, only in Arc 4 and above and if there is no Major Cowardice on it. The DoT snapshots the current strength, so even if you debuff the archer afterwards, the DoT ticks will remain high. Therefore, it's better to dodge the shot when possible",
                checkOldForDefault = true,
                default = true,
            },
        },
    },

    ------------------
    -- Maelstrom Arena
    [677] = {
        settingsSubcategory = "maelstrom",
        -- Poison Arrow Spray
        [70701] = {
            event = EVENT_EFFECT_CHANGED,
            filters = { -- Verified
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            text = "CLEANSE",
            color = {0.5, 1, 0.5},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentPoisonArrowSpray",
                title = "Alert Poison Arrow Spray",
                description = "Shows a prominent alert when you get arrow sprayed by an Argonian Venomshot in the Vault of Umbrage and should cleanse the DoT",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Volatile Poison
        [69855] = {
            event = EVENT_EFFECT_CHANGED,
            filters = { -- Verified
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            text = "CLEANSE",
            color = {0.5, 1, 0.5},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentVolatilePoison",
                title = "Alert Volatile Poison",
                description = "Shows a prominent alert when you get poisoned by a plant in the Vault of Umbrage and should cleanse the DoT",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Heat Wave (Dremora Gandrakyn, etc.)
        [15164] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "HEAT WAVE",
            color = {1, 0.3, 0.1},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentHeatWaveMA",
                title = "Alert Heat Wave",
                description = "Shows a prominent alert when a fire mage casts Heat Wave",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Teleport Strike (Dremora Kynlurker)
        [75277] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "AMBUSH",
            color = {223/255, 71/255, 237/255},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentTeleportStrike",
                title = "Alert Teleport Strike",
                description = "Shows a prominent alert when a Dremora Kynlurker ambushes you",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Soul Tether (Dremora Kynlurker)
        [75281] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "TETHER",
            color = {223/255, 71/255, 237/255},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentSoulTether",
                title = "Alert Soul Tether",
                description = "Shows a prominent alert when a Dremora Kynlurker casts Soul Tether",
                checkOldForDefault = true,
                default = true,
            },
        },
    },

    --------------------
    -- Vateshran Hollows
    [1227] = {
        settingsSubcategory = "vateshran",
        -- Heat Wave
        [15164] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "HEAT WAVE",
            color = {1, 0.3, 0.1},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentHeatWaveVH",
                title = "Alert Heat Wave",
                description = "Shows a prominent alert when a fire mage casts Heat Wave",
                checkOldForDefault = true,
                default = true,
            },
        },
        -- Winter's Reach (Xivkyn Chillfiend?)
        [12459] = {
            event = EVENT_COMBAT_EVENT,
            filters = { -- Verified
                [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
            },
            text = "WINTER'S REACH",
            color = {0.5, 1, 1},
            slot = 1,
            playSound = true,
            millis = 1000,
            settings = {
                name = "prominentWintersReachVH",
                title = "Alert Winter's Reach",
                description = "Shows a prominent alert when an ice mage casts Winter's Reach",
                checkOldForDefault = true,
                default = true,
            },
        },
    },

    -----------------------------------------------------------
    -- DUNGEONS
    -----------------------------------------------------------
}

-- Represents one control toggle for one prominent ability
local function GetProminentSetting(subcategory, settingsData)
    return {
        type = "checkbox",
        name = settingsData.title,
        tooltip = settingsData.description,
        default = settingsData.default,
        getFunc = function() return Crutch.savedOptions[subcategory][settingsData.name] end,
        setFunc = function(value)
            Crutch.savedOptions[subcategory][settingsData.name] = value
            Crutch.OnPlayerActivated()
        end,
        width = "full",
    }
end

-- Called from Settings.lua to append prominent alert sections to existing settings controls
function Crutch.GetProminentSettings(zoneId, controls)
    table.insert(controls, {
        type = "description",
        title = "|c08BD1DProminent Alerts|r",
        text = "These display as large, obnoxious alerts, usually with a ding sound too.",
        width = "full",
    })

    local zoneData = prominentData[zoneId]
    for abilityId, abilityData in pairs(zoneData) do
        if (type(abilityId) == "number") then
            table.insert(controls, GetProminentSetting(zoneData.settingsSubcategory, abilityData.settings))
        end
    end
    return controls
end

local resultStrings = {
    [ACTION_RESULT_BEGIN] = "BEGIN",
    [ACTION_RESULT_EFFECT_GAINED] = "GAIN",
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = "DUR",
    [ACTION_RESULT_EFFECT_FADED] = "FADED",
    [ACTION_RESULT_DAMAGE] = "DAMAGE",
}

-----------------------------------------------------------
-- Called whenever we enter a zone
-----------------------------------------------------------
function Crutch.RegisterProminents(zoneId)
    local zoneData = prominentData[zoneId]
    if (not zoneData) then return end

    for abilityId, abilityData in pairs(zoneData) do
        local settingsData = abilityData.settings
        if (type(abilityId) == "number") then
            local prominentEnabled
            if (IsConsoleUI) then
                prominentEnabled = Crutch.savedOptions.console.showProminent
            else
                prominentEnabled = Crutch.savedOptions[zoneData.settingsSubcategory][settingsData.name]
            end
            if (prominentEnabled) then
                -- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
                -- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
                local function ProminentCallback(_, result, _, _, effectUnitTag, _, sourceName, _, targetName, _, hitValue, _, _, _, effectUnitId)
                    -- Since EVENT_EFFECT_CHANGED doesn't take filters for results, assume we only want EFFECT_RESULT_GAINED here
                    if (abilityData.event == EVENT_EFFECT_CHANGED and result ~= EFFECT_RESULT_GAINED) then
                        return
                    end

                    if (abilityData.filters and abilityData.filters.filterFunction) then
                        if (not abilityData.filters.filterFunction(hitValue, effectUnitId)) then
                            return
                        end
                    end

                    -- Ideally, all prominents should have the appropriate result filter, but if I don't know it yet, print
                    -- it out to add later
                    if (abilityData.event == EVENT_COMBAT_EVENT and abilityData.filters[REGISTER_FILTER_COMBAT_RESULT] == nil) then
                        Crutch.dbgOther(zo_strformat("|cFF0000<<1>>: <<2>> <<3>> -> <<4>> for <<5>>",
                            resultStrings[result],
                            sourceName,
                            GetAbilityName(abilityId),
                            targetName,
                            hitValue))
                    end

                    Crutch.DisplayProminent2(abilityId, abilityData)
                end

                -- Register event
                local eventName = Crutch.name .. "Prominent" .. tostring(abilityId) .. tostring(abilityData.event)
                EVENT_MANAGER:RegisterForEvent(eventName, abilityData.event, ProminentCallback)
                EVENT_MANAGER:AddFilterForEvent(eventName, abilityData.event, REGISTER_FILTER_ABILITY_ID, abilityId)
                -- Register filters if we have any
                if (abilityData.filters) then
                    for filter, value in pairs(abilityData.filters) do
                        if (filter ~= "filterFunction") then
                            EVENT_MANAGER:AddFilterForEvent(eventName, abilityData.event, filter, value)
                        end
                    end
                end
                Crutch.dbgSpam("Registered " .. GetAbilityName(abilityId))
            end
        end
    end
end

-----------------------------------------------------------
-- Called whenever we exit a zone
-----------------------------------------------------------
function Crutch.UnregisterProminents(zoneId)
    local zoneData = prominentData[zoneId]
    if (not zoneData) then return end

    for abilityId, abilityData in pairs(zoneData) do
        if (type(abilityId) == "number") then
            EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Prominent" .. tostring(abilityId) .. tostring(abilityData.event), abilityData.event)
            Crutch.dbgSpam("Unregistered " .. GetAbilityName(abilityId))
        end
    end
end

-----------------------------------------------------------
-- Init
-----------------------------------------------------------
-- Initialize the defaults for all prominents to true
function Crutch.AddProminentDefaults()
    for zoneId, zoneData in pairs(prominentData) do
        local subcategory = zoneData.settingsSubcategory
        for abilityId, abilityData in pairs(zoneData) do
            if (type(abilityId) == "number") then
                Crutch.defaultOptions[subcategory][abilityData.settings.name] = abilityData.settings.default
            end
        end
    end
end

-- Initialize the prominents values for the first time since V2
function Crutch.InitProminentV2Options()
    for zoneId, zoneData in pairs(prominentData) do
        local subcategory = zoneData.settingsSubcategory
        for abilityId, abilityData in pairs(zoneData) do
            if (type(abilityId) == "number") then
                local settingsData = abilityData.settings
                local value = settingsData.default
                if (settingsData.checkOldForDefault) then
                    value = Crutch.savedOptions.general.showProminent
                end
                Crutch.savedOptions[subcategory][settingsData.name] = value
            end
        end
    end
end
