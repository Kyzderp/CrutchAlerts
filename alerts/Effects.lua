CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts


---------------------------------------------------------------------
-- This is a generic system for displaying timers as "alerts" for
-- timed buffs or debuffs
---------------------------------------------------------------------
local effectData = {
    ----------
    -- General
    [-1] = {
        settingsSubcategory = "general",
        -- Magma Shell
        [17874] = {
            format = "|cff6600<<C:1>>|r",
            filters = {
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            settings = {
                name = "effectMagmaShell",
                title = "Show Magma Shell Timer",
                description = "Shows an \"alert\" timer for when your Magma Shell will expire",
            },
        },
        -- Magma Armor
        [15957] = {
            format = "|cff6600<<C:1>>|r",
            filters = {
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            settings = {
                name = "effectMagmaShell",
                title = "Show Magma Shell Timer",
                description = "Shows an \"alert\" timer for when your Magma Shell will expire",
            },
        },
        -- Corrosive Armor
        [17878] = {
            format = "|c64c200<<C:1>>|r",
            filters = {
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            settings = {
                name = "effectMagmaShell",
                title = "Show Magma Shell Timer",
                description = "Shows an \"alert\" timer for when your Magma Shell will expire",
            },
        },
        -- Shield Throw Parry
        [217089] = {
            format = "|cf5bf42Parry|r",
            filters = {
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            settings = {
                name = "effectParry",
                title = "Show Fencer's Parry",
                description = "Shows an \"alert\" timer for your Fencer's Parry duration, along with when it is removed",
            },
        },
        -- Traveling Knife Parry
        [217356] = {
            format = "|cf5bf42Parry|r",
            filters = {
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            settings = {
                name = "effectParry",
                title = "Show Fencer's Parry",
                description = "Shows an \"alert\" timer for your Fencer's Parry duration, along with when it is removed",
            },
        },
        -- Smash Parry
        [217195] = {
            format = "|cf5bf42Parry|r",
            filters = {
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            settings = {
                name = "effectParry",
                title = "Show Fencer's Parry",
                description = "Shows an \"alert\" timer for your Fencer's Parry duration, along with when it is removed",
            },
        },
    },

-----------------------------------------------------------
-- TRIALS
-----------------------------------------------------------

    ------------
    -- Cloudrest
    [1051] = {
        settingsSubcategory = "cloudrest",
        -- Hoarfrost
        [103695] = {
            format = "|c8ef5f5<<C:1>>|r",
            duration = 9000, -- Time until Overwhelming Hoarfrost... on vet
            filters = {
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            settings = {
                name = "effectHoarfrost",
                title = "Show Hoarfrost Timer",
                description = "Shows an \"alert\" timer for when Hoarfrost will kill you (on veteran difficulty)",
            },
        },
        -- Hoarfrost (in execute)
        [110516] = {
            format = "|c8ef5f5<<C:1>>|r",
            duration = 9000, -- Time until Overwhelming Hoarfrost... on vet
            filters = {
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            settings = {
                name = "effectHoarfrost",
                title = "Show Hoarfrost Timer",
                description = "Shows an \"alert\" timer for when Hoarfrost will kill you (on veteran difficulty)",
            },
        },
        -- Voltaic Overload
        [87346] = {
            format = "|c8ef5f5<<C:1>>|r",
            filters = {
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            settings = {
                name = "effectVoltaicOverload",
                title = "Show Voltaic Overload Timer",
                description = "Shows an \"alert\" timer for the duration of Voltaic Overload (barswap mechanic). Note that you still need \"Show gained casts\" enabled to see Voltaic Current, which is the warning you get before Overload",
            },
        },
    },
    -----------------
    -- Lucent Citadel
    [1478] = {
        settingsSubcategory = "lucentcitadel",
        -- Fate Sealer
        [214138] = {
            format = "|cFF00FF<<C:1>>|r",
            duration = 20100,
            filters = {
            },
            settings = {
                name = "effectFateSealer",
                title = "Show Fate Sealer Timer",
                description = "Shows an \"alert\" timer for when Fate Sealer will seal your group's fate",
            },
        },
        -- Arcane Knot
        [213477] = {
            format = "|cFF7700<<C:1>>: <<2>>|r",
            filters = {
                [REGISTER_FILTER_UNIT_TAG_PREFIX] = "group",
            },
            gainedCallback = function(atName)
                if (Crutch.savedOptions.general.showRaidDiag) then
                    Crutch.msg(zo_strformat("<<1>> picked up the knot", atName))
                end
            end,
            fadedCallback = function(atName, expiredTimer)
                if (Crutch.savedOptions.general.showRaidDiag) then
                    Crutch.msg(zo_strformat("<<1>> dropped the knot with <<2>>s remaining", atName, expiredTimer))
                end
            end,
            settings = {
                name = "showKnotTimer",
                title = "Show Arcane Knot Timer",
                description = "Shows an \"alert\" timer for the currently held Arcane Knot",
            },
        },
    },
    -----------------
    -- Maw of Lorkhaj
    [725] = {
        settingsSubcategory = "mawoflorkhaj",
        -- Shattered
        [73250] = {
            format = "|cfff1ab<<C:1>>|r",
            filters = {
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            settings = {
                name = "effectShattered",
                title = "Show Shattered Timer",
                description = "Shows an \"alert\" timer for how long your armor is shattered",
            },
        },
    },
    --------------
    -- Ossein Cage
    -- [1548] = {
    --     settingsSubcategory = "osseincage",
    --     [235594] = {
    --         format = "|c8ef5f5<<C:1>>|r",
    --         filters = {
    --             [REGISTER_FILTER_UNIT_TAG] = "player",
    --         },
    --         settings = {
    --             name = "effectDeathTouch",
    --             title = "Show Death Touch Timer",
    --             description = "Shows an \"alert\" timer for when your Bahsei curse will explode",
    --         },
    --     },
    -- },
    ------------
    -- Rockgrove
    [1263] = {
        settingsSubcategory = "rockgrove",
        -- Death Touch
        [150078] = {
            format = "|c7236ff<<C:1>>|r",
            filters = {
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            settings = {
                name = "effectDeathTouch",
                title = "Show Death Touch Timer",
                description = "Shows an \"alert\" timer for when your Bahsei curse will explode",
            },
        },
    },
}


-----------------------------------------------------------
-- Display it as an alert timer
-----------------------------------------------------------
local function GetGroupTagNumberForDisplayName(displayName)
    for i = 1, GetGroupSize() do
        if (GetUnitDisplayName(GetGroupUnitTagByIndex(i)) == displayName) then
            return i
        end
    end
end

local function OnEffectChanged(changeType, unitTag, beginTime, endTime, abilityId, abilityData)
    local atName = GetUnitDisplayName(unitTag)
    local tagId
    if (unitTag == "player") then
        if (IsUnitGrouped("player")) then
            tagId = GetGroupTagNumberForDisplayName(GetUnitDisplayName("player"))
        else
            tagId = 14
            Crutch.dbgSpam("|cFF0000unhandled unitTag " .. tostring(unitTag) .. ", probably player not grouped")
        end
    elseif (string.sub(unitTag, 1, 5) == "group") then
        local tagNumber = string.gsub(unitTag, "group", "")
        tagId = tonumber(tagNumber)
    else
        tagId = 13
        Crutch.dbgSpam("|cFF0000unhandled unitTag " .. tostring(unitTag))
    end
    local fakeSourceUnitId = 88800000 + abilityId*100 + tagId -- There is potential for collision... but it's probably fiiiiiiine

    -- Effect gained, add a fake alert
    if (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) then
        local label = zo_strformat(abilityData.format, GetAbilityName(abilityId), atName)
        Crutch.DisplayNotification(abilityId, label, abilityData.duration or (endTime - beginTime) * 1000, fakeSourceUnitId, 0, 0, 0, false)

        if (abilityData.gainedCallback) then
            abilityData.gainedCallback(atName)
        end

    -- Effect faded, "interrupt" the alert
    elseif (changeType == EFFECT_RESULT_FADED) then
        local expiredTimer = Crutch.Interrupted(fakeSourceUnitId)

        if (abilityData.fadedCallback) then
            abilityData.fadedCallback(atName, expiredTimer)
        end
    end
end


-----------------------------------------------------------
-- Called whenever we enter a zone
-----------------------------------------------------------
local effectResults = {
    [EFFECT_RESULT_FADED] = "FADED",
    [EFFECT_RESULT_FULL_REFRESH] = "FULL_REFRESH",
    [EFFECT_RESULT_GAINED] = "GAINED",
    [EFFECT_RESULT_TRANSFER] = "TRANSFER",
    [EFFECT_RESULT_UPDATED] = "UPDATED",
}

function Crutch.RegisterEffects(zoneId)
    if (zoneId ~= -1) then
        -- Also register the general effects
        Crutch.RegisterEffects(-1)
    end

    local zoneData = effectData[zoneId]
    if (not zoneData) then return end

    for abilityId, abilityData in pairs(zoneData) do
        local settingsData = abilityData.settings
        if (type(abilityId) == "number" and Crutch.savedOptions[zoneData.settingsSubcategory][settingsData.name]) then
            -- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
            local function EffectCallback(_, changeType, _, _, unitTag, beginTime, endTime)
                if (abilityData.filters and abilityData.filters.filterFunction) then
                    if (not abilityData.filters.filterFunction()) then
                        return
                    end
                end

                Crutch.dbgSpam(zo_strformat("|cFF5555<<1>>: <<2>> (<<3>>) on <<4>> (<<5>>) for <<6>> (<<7>> to <<8>>)",
                    effectResults[changeType],
                    GetAbilityName(abilityId),
                    abilityId,
                    GetUnitDisplayName(unitTag),
                    unitTag,
                    (endTime - beginTime) * 1000,
                    beginTime,
                    endTime))

                OnEffectChanged(changeType, unitTag, beginTime, endTime, abilityId, abilityData)
            end

            -- Register event
            local eventName = Crutch.name .. "EffectAlert" .. tostring(abilityId)
            EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, EffectCallback)
            EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
            -- Register filters if we have any
            if (abilityData.filters) then
                for filter, value in pairs(abilityData.filters) do
                    if (filter ~= "filterFunction") then
                        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, filter, value)
                    end
                end
            end
            Crutch.dbgSpam("Registered " .. GetAbilityName(abilityId))
        end
    end
end


-----------------------------------------------------------
-- Called whenever we exit a zone
-----------------------------------------------------------
function Crutch.UnregisterEffects(zoneId)
    if (zoneId ~= -1) then
        -- Also unregister the general effects (even though they'll just get registered again)
        Crutch.UnregisterEffects(-1)
    end

    local zoneData = effectData[zoneId]
    if (not zoneData) then return end

    for abilityId, abilityData in pairs(zoneData) do
        if (type(abilityId) == "number") then
            EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "EffectAlert" .. tostring(abilityId), EVENT_EFFECT_CHANGED)
            Crutch.dbgSpam("Unregistered " .. GetAbilityName(abilityId))
        end
    end
end


-----------------------------------------------------------
-- Settings
-----------------------------------------------------------
-- Represents one control toggle for one effect
local function GetEffectSetting(subcategory, settingsData)
    return {
        type = "checkbox",
        name = settingsData.title,
        tooltip = settingsData.description,
        default = true,
        getFunc = function() return Crutch.savedOptions[subcategory][settingsData.name] end,
        setFunc = function(value)
            Crutch.savedOptions[subcategory][settingsData.name] = value
            Crutch.OnPlayerActivated()
        end,
        width = "full",
    }
end

-- Called from Settings.lua to append effect alert sections to existing settings controls
function Crutch.GetEffectSettings(zoneId, controls)
    table.insert(controls, {
        type = "description",
        title = "|c08BD1DEffect Timers|r",
        text = "These are curated timers that display alongside incoming begin/gained casts, usually for specific timed mechanics such as debuffs on yourself.",
        width = "full",
    })

    local zoneData = effectData[zoneId]
    local added = {} -- Some IDs use the same setting
    for abilityId, abilityData in pairs(zoneData) do
        if (type(abilityId) == "number") then
            if (not added[abilityData.settings.name]) then
                table.insert(controls, GetEffectSetting(zoneData.settingsSubcategory, abilityData.settings))
                added[abilityData.settings.name] = true
            end
        end
    end
    return controls
end


-----------------------------------------------------------
-- Init
-----------------------------------------------------------
-- Initialize the defaults for all effects to true
function Crutch.AddEffectDefaults()
    for zoneId, zoneData in pairs(effectData) do
        local subcategory = zoneData.settingsSubcategory
        for abilityId, abilityData in pairs(zoneData) do
            if (type(abilityId) == "number") then
                Crutch.defaultOptions[subcategory][abilityData.settings.name] = true
            end
        end
    end
end

