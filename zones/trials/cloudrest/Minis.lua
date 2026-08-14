local Crutch = CrutchAlerts
local CR = Crutch.Cloudrest
local C = Crutch.Constants

local function IsZmaja()
    return zo_strformat(SI_UNIT_NAME, GetUnitName("boss1") or "") == Crutch.GetCapitalizedString(CRUTCH_BHB_ZMAJA)
end


---------------------------------------------------------------------
-- Mini reticle syncing
-- When the number of minis is detected, we don't know which ones
-- they are, so we'll start listening to combat events. If flare
-- happens, we know there's Siroria, etc.
---------------------------------------------------------------------
local function GetBossName(id)
    return Crutch.GetCapitalizedString(id)
end

-- for ordering
local MINI_NAMES = {
    GetBossName(CRUTCH_BHB_SHADE_OF_SIRORIA),
    GetBossName(CRUTCH_BHB_SHADE_OF_RELEQUEN),
    GetBossName(CRUTCH_BHB_SHADE_OF_GALENWE),
}

local numMinisToSpoof = 0

local MINI_DATA = {
    [GetBossName(CRUTCH_BHB_SHADE_OF_SIRORIA)] = {
        unitTag = "boss2",
        fgColor = C.FELMS_FG,
        bgColor = C.FELMS_BG,
        detectIds = {103531}, -- Roaring Flare
    },
    [GetBossName(CRUTCH_BHB_SHADE_OF_RELEQUEN)] = {
        unitTag = "boss3",
        fgColor = {7/255, 87/255, 179/255}, -- TODO: color
        bgColor = {1/255, 11/255, 23/255},
        detectIds = {103555}, -- Voltaic Current
    },
    [GetBossName(CRUTCH_BHB_SHADE_OF_GALENWE)] = {
        unitTag = "boss4",
        fgColor = C.LLOTHIS_FG, -- TODO: color
        bgColor = C.LLOTHIS_BG,
        detectIds = {HOARFROST_CAST_ID},
    },
}

local totalMinis = 0
local knownMinis = {} -- {"Shade of Siroria" = "boss2"}

local trackedUnits = {} -- for cleanup {[id] = unitTag}

local function GetTrackedId(unitTag)
    for id, tag in pairs(trackedUnits) do
        if (tag == unitTag) then return id end
    end
end

local function GetMiniNumber(name)
    if (name == GetBossName(CRUTCH_BHB_SHADE_OF_SIRORIA)) then
        return 2 -- Siroria always the first
    elseif (name == GetBossName(CRUTCH_BHB_SHADE_OF_GALENWE)) then
        return totalMinis + 1 -- Galenwe always the last
    else
        -- Rele
        if (totalMinis == 1) then return 2 end -- If +1
        if (knownMinis[GetBossName(CRUTCH_BHB_SHADE_OF_SIRORIA)]) then return 3 end -- If +2 and Siroria has already been found
        return 2
    end
end

local function OnMiniMechanicEvent(name)
    local tag = "boss" .. GetMiniNumber(name)
    knownMinis[tag] = name
    for _, id in ipairs(MINI_DATA[name].detectIds) do
        Crutch.UnregisterForCombatEvent("CRMiniDetect" .. id)
    end

    -- Start reticle tracking if the unit ID is already known
    if (GetTrackedId(tag)) then
        Crutch.TrackUnitForReticleSyncing(name, GetTrackedId(tag))
        Crutch.dbgOther("mini was already spawned")
    end

    -- TODO: update existing bosses?
end

-- Once we know how many minis there are, we can start looking for which minis are needed
local function OnNumMinisDetected()
    -- If there are 3 minis then obv all are needed
    if (totalMinis == 3) then
        for i, name in ipairs(MINI_NAMES) do
            local tag = "boss" .. (i + 1)
            knownMinis[tag] = name

            -- Start reticle tracking if the unit ID is already known
            if (GetTrackedId(tag)) then
                Crutch.TrackUnitForReticleSyncing(name, GetTrackedId(tag))
                Crutch.dbgOther("mini was already spawned")
            end
        end
        -- TODO: anything else?
        return
    end

    -- Otherwise, look for events to identify which minis
    for name, data in pairs(MINI_DATA) do
        for _, id in ipairs(data.detectIds) do
            Crutch.RegisterForCombatEvent("CRMiniDetect" .. id, function()
                Crutch.dbgOther("|cFF9900Detected " .. GetAbilityName(id))
                OnMiniMechanicEvent(name)
            end, nil, id)
        end
    end
end


---------------------------------------------------------------------
-- BHB spoofing start
---------------------------------------------------------------------
local function MaybeStartTracking(unitName, unitId, abilityId)
    if (trackedUnits[unitId]) then return end -- this one already being tracked
    local MINI_MAX_HEALTH = (GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN) and 13971720 or 6816516

    trackedUnits[unitId] = "boss" .. (2 + NonContiguousCount(trackedUnits))
    local unitTag = trackedUnits[unitId]
    Crutch.dbgOther(zo_strformat("found <<1>> via <<2>> (<<3>>)", unitName, GetAbilityName(abilityId), abilityId))

    Crutch.TrackUnitForSpoofing(unitId, unitName, unitTag, MINI_MAX_HEALTH)
    -- If which mini it is is already known, start reticle tracking
    if (knownMinis[unitTag]) then
        Crutch.TrackUnitForReticleSyncing(knownMinis[unitTag], unitId)
        Crutch.dbgOther(knownMinis[unitTag] .. " was found first, now tracking new spawn")
    end

    numMinisToSpoof = numMinisToSpoof - 1
    if (numMinisToSpoof <= 0) then
        Crutch.UnregisterForCombatEvent("CRMiniSpoofDetect")
    end
end

local function OnMiniCombatEvent(_, _, _, _, _, _, sourceName, _, targetName, _, _, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (not IsZmaja() or numMinisToSpoof <= 0) then
        Crutch.dbgOther("not Z'Maja")
        Crutch.UnregisterForCombatEvent("CRMiniSpoofDetect")
        return
    end

    MaybeStartTracking("Mini", targetUnitId, abilityId)
end


---------------------------------------------------------------------
-- Boss health bar thresholds
---------------------------------------------------------------------
local knownHealths = {[1] = {50}, [2] = {65, 35}, [3] = {75, 50, 25}}
local foundMiniShades = {} -- Key by unit id just in case there are dupes?
local zmajaThresholds = {}
local foundMinis = false

local function OverrideBHBThresholds()
    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "CRBossSpeedTimeout")

    foundMinis = true
    numMinisToSpoof = NonContiguousCount(foundMiniShades)
    totalMinis = numMinisToSpoof
    ZO_ClearTable(zmajaThresholds)

    -- Add each threshold
    for _, threshold in ipairs(knownHealths[numMinisToSpoof]) do
        zmajaThresholds[threshold] = "Mini"
    end

    Crutch.dbgOther("Inferred " .. numMinisToSpoof .. " minis, overriding thresholds...")
    Crutch.BossHealthBar.AddThresholdOverride(Crutch.GetCapitalizedString(CRUTCH_BHB_ZMAJA), zmajaThresholds)

    if (not Crutch.savedOptions.experimental) then return end
    -- TODO: setting
    OnNumMinisDetected()
    Crutch.RegisterForCombatEvent("CRMiniSpoofDetect", OnMiniCombatEvent, ACTION_RESULT_EFFECT_GAINED, 105541)
end

local function OnMiniBoss(_, _, _, _, _, _, _, _, _, _, _, _, _, _, sourceUnitId, targetUnitId)
    if (foundMinis) then return end

    -- We don't get the target names for this >:[
    Crutch.dbgSpam("detected a mini, unit ID " .. targetUnitId)
    foundMiniShades[targetUnitId] = true

    -- Since we've found a new shade, set a short timeout to wait for
    -- other shades to be found
    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "CRBossSpeedTimeout", 500, OverrideBHBThresholds)
end


---------------------------------------------------------------------
-- Reset/cleanup
local function UntrackAll()
    for unitId, _ in pairs(trackedUnits) do
        Crutch.UntrackUnitForSpoofing(unitId)
        trackedUnits[unitId] = nil
    end

    for _, name in ipairs(MINI_NAMES) do
        Crutch.UntrackUnitForReticleSyncing(name)
    end
end

local function CleanUp()
    -- mini detection
    foundMinis = false
    ZO_ClearTable(foundMiniShades)
    Crutch.BossHealthBar.RemoveThresholdOverride(Crutch.GetCapitalizedString(CRUTCH_BHB_ZMAJA))

    -- mini spoofing
    numMinisToSpoof = 0
    totalMinis = 0
    UntrackAll()
    ZO_ClearTable(knownMinis)

    for name, data in pairs(MINI_DATA) do
        for _, id in ipairs(data.detectIds) do
            Crutch.UnregisterForCombatEvent("CRMiniDetect" .. id)
        end
    end
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function CR.RegisterMinis()
    Crutch.RegisterExitedGroupCombatListener("ExitedCombatCloudrestMinis", CleanUp)

    -- Listen for mini shades to determine Z'Maja thresholds
    if (Crutch.savedOptions.bossHealthBar.enabled) then
        Crutch.RegisterForCombatEvent("CRMiniBossDetect", OnMiniBoss, ACTION_RESULT_EFFECT_GAINED_DURATION, 105541)
    end
end

function CR.UnregisterMinis()
    Crutch.UnregisterExitedGroupCombatListener("ExitedCombatCloudrestMinis")

    Crutch.UnregisterForCombatEvent("CRMiniBossDetect")

    CleanUp()
end
