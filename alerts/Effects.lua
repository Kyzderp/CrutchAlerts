CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts


---------------------------------------------------------------------
-- This is a generic system for displaying timers as "alerts" for
-- timed buffs or debuffs
---------------------------------------------------------------------
local effectData = {
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
        [87346] = {
            format = "|c8ef5f5<<C:1>>|r",
            filters = {
                [REGISTER_FILTER_UNIT_TAG] = "player",
            },
            settings = {
                name = "effectVoltaicOverload",
                title = "Show Voltaic Overload Timer",
                description = "Shows an \"alert\" timer for the duration of Voltaic Overload (barswap mechanic)",
            },
        },
    },

    -----------------
    -- Maw of Lorkhaj
    [725] = {
        settingsSubcategory = "mawoflorkhaj",
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
}


-----------------------------------------------------------
-- Display it as an alert timer
-----------------------------------------------------------
local function GetGroupTagNumberForDisplayName(displayName)
    for i = 1, GetGroupSize() do
        if (GetUnitDisplayName("group" .. tostring(i)) == displayName) then
            return i
        end
    end
end

local function OnEffectChanged(changeType, unitTag, beginTime, endTime, abilityId, abilityData)
    local atName = GetUnitDisplayName(unitTag)
    local tagId
    if (unitTag == "player") then
        tagId = GetGroupTagNumberForDisplayName(GetUnitDisplayName("player"))
    elseif (string.sub(unitTag, 1, 5) == "group") then
        local tagNumber = string.gsub(unitTag, "group", "")
        tagId = tonumber(tagNumber)
    else
        tagId = 13
        Crutch.dbgOther("|cFF0000unhandled unitTag " .. tostring(unitTag))
    end
    local fakeSourceUnitId = 8880000 + abilityId + tagId -- There is potential for collision...

    -- Effect gained, add a fake alert
    if (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) then
        local label = zo_strformat(abilityData.format, GetAbilityName(abilityId), atName)
        Crutch.DisplayNotification(abilityId, label, abilityData.duration or (endTime - beginTime) * 1000, fakeSourceUnitId, 0, 0, 0, false)

        if (abilityData.gainedCallback) then
            abilityData.gainedCallback()
        end

    -- Effect faded, "interrupt" the alert
    elseif (changeType == EFFECT_RESULT_FADED) then
        if (abilityData.fadedCallback) then
            abilityData.fadedCallback()
        end

        Crutch.Interrupted(fakeSourceUnitId)
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


-- TODO: settings
