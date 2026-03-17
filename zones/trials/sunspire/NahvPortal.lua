local Crutch = CrutchAlerts
local SS = Crutch.Sunspire
local C = Crutch.Constants


---------------------------------------------------------------------
-- Data
---------------------------------------------------------------------
local CONE = 121422 -- Sundering Gale
local NEGATE = 121411 -- Negate Field
local METEOR = 121074 -- Aspect of Winter
local PINS = 121436 -- Translation Apocalypse
local KITE = 121271 -- Lightning Storm

local SERVANT_IDS = {
    [CONE] = "fff1ab",
    [NEGATE] = "9447ff",
    [METEOR] = "3a9dd6",
    [PINS] = "ff00ff",
    [KITE] = "8ef5f5",
}
local SERVANT_SEQUENCE = {
    CONE,
    NEGATE,
    CONE,
    CONE,
    PINS,
    METEOR,
    KITE,
    NEGATE,
    CONE,
    CONE,
    PINS,
    METEOR,
    KITE,
    NEGATE,
    CONE,
    CONE,
    PINS,
    METEOR,
    KITE,
    NEGATE,
    CONE,
    CONE,
    PINS,
}


---------------------------------------------------------------------
-- Display & logic
---------------------------------------------------------------------
local SERVANT_INDEX_OFFSET = 10
local nextIndex = 1

local function UpdateDisplay()
    Crutch.InfoPanel.SetLine(SERVANT_INDEX_OFFSET, "|cCCCCCCUp next:|r", 0.7)

    local first = SERVANT_SEQUENCE[nextIndex]
    if (first) then
        Crutch.InfoPanel.SetLine(SERVANT_INDEX_OFFSET + 1, zo_strformat("|c<<1>><<C:2>>|r", SERVANT_IDS[first], GetAbilityName(first)))
    else
        Crutch.InfoPanel.RemoveLine(SERVANT_INDEX_OFFSET + 1)
    end

    local second = SERVANT_SEQUENCE[nextIndex + 1]
    if (second) then
        Crutch.InfoPanel.SetLine(SERVANT_INDEX_OFFSET + 2, zo_strformat("|c<<1>><<C:2>>|r", SERVANT_IDS[second], GetAbilityName(second)), nil, 0.6)
    else
        Crutch.InfoPanel.RemoveLine(SERVANT_INDEX_OFFSET + 2)
    end

    local third = SERVANT_SEQUENCE[nextIndex + 2]
    if (third) then
        Crutch.InfoPanel.SetLine(SERVANT_INDEX_OFFSET + 3, zo_strformat("|c<<1>><<C:2>>|r", SERVANT_IDS[third], GetAbilityName(third)), nil, 0.3)
    else
        Crutch.InfoPanel.RemoveLine(SERVANT_INDEX_OFFSET + 3)
    end
end

-- Upon confirmed ability, move everything up
local function OnServantBegin(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, _, abilityId)
    if (abilityId == PINS and hitValue ~= 2000) then return end

    if (abilityId ~= SERVANT_SEQUENCE[nextIndex]) then
        Crutch.dbgOther("|cFF0000happened out of sequence? " .. GetAbilityName(abilityId) .. " current " .. nextIndex .. " is " .. GetAbilityName(SERVANT_SEQUENCE[nextIndex]))

        -- Maybe skip ahead to the next one?
        local newIndex
        for i = nextIndex, #SERVANT_SEQUENCE do
            if (SERVANT_SEQUENCE[i] == abilityId) then
                newIndex = i
                break
            end
        end

        if (not newIndex) then
            Crutch.dbgOther("|cFF0000unable to find next matching ability to skip to")
            return
        else
            Crutch.dbgOther("|cFF4400skipping ahead to index " .. newIndex)
            nextIndex = newIndex
        end
    end

    nextIndex = nextIndex + 1

    UpdateDisplay()
end

function SS.Test(abilityId)
    OnServantBegin(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, abilityId)
end
-- /script CrutchAlerts.Sunspire.Test(121422)


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function SS.ShowNahvPortal()
    UpdateDisplay()
end

function SS.StopNahvPortal()
    nextIndex = 1
    for i = 0, 3 do
        Crutch.InfoPanel.StopCount(SERVANT_INDEX_OFFSET + i)
    end
end

-- Registering can't only be done after entering portal, because player may not be the first in
function SS.RegisterNahvPortal()
    nextIndex = 1
    for id, _ in pairs(SERVANT_IDS) do
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "SSServant" .. id, EVENT_COMBAT_EVENT, OnServantBegin)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "SSServant" .. id, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "SSServant" .. id, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
    end
end

function SS.UnregisterNahvPortal()
    nextIndex = 1
    for id, _ in pairs(SERVANT_IDS) do
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "SSServant" .. id, EVENT_COMBAT_EVENT)
    end
end
