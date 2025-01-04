CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
local EXIT_LEFT_POOL = {x = 91973, y = 35751, z = 81764}  -- from QRH so that we use the same sorting

---------------------------------------------------------------------
-- OAXILTSO: NOXIOUS SLUDGE SIDES
---------------------------------------------------------------------
local sludgeTag1 = nil
local lastSludge = 0 -- for resetting

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnNoxiousSludgeGained(_, changeType, _, _, unitTag)
    if (changeType ~= EFFECT_RESULT_GAINED) then return end
    Crutch.dbgSpam(string.format("|c00FF00Noxious Sludge: %s (%s)|r", GetUnitDisplayName(unitTag), unitTag))

    if (not Crutch.savedOptions.rockgrove.sludgeSides) then return end

    local currSeconds = GetGameTimeSeconds()
    if (currSeconds - lastSludge > 10) then
        -- Reset
        sludgeTag1 = nil
        lastSludge = currSeconds
    end

    if (not sludgeTag1) then
        sludgeTag1 = unitTag
        return
    elseif (sludgeTag1 == unitTag) then
        return
    end

    local leftPlayer, rightPlayer

    -- TODO: update this if QRH updates. QRH currently sends whoever is closer to
    -- exit left pool to the left
    leftPlayer = sludgeTag1
    rightPlayer = unitTag
    local _, p1x, p1y, p1z = GetUnitWorldPosition(sludgeTag1)
    local _, p2x, p2y, p2z = GetUnitWorldPosition(unitTag)

    -- We have sludgeTag1, and unitTag is second player
    -- Using the same logic as QRH to sort players
    -- QRH does this by checking who is closer to exit left pool
    -- Is problematic because of latency, but oh well
    local p1Dist = Crutch.GetSquaredDistance(p1x, p1y, p1z, EXIT_LEFT_POOL.x, EXIT_LEFT_POOL.y, EXIT_LEFT_POOL.z)
    local p2Dist = Crutch.GetSquaredDistance(p2x, p2y, p2z, EXIT_LEFT_POOL.x, EXIT_LEFT_POOL.y, EXIT_LEFT_POOL.z)
    -- Crutch.dbgOther(string.format("squared dist between: %f", Crutch.GetSquaredDistance(p1x, p1y, p1z, p2x, p2y, p2z)))
    if (p1Dist < p2Dist) then
        leftPlayer = sludgeTag1
        rightPlayer = unitTag
    else
        leftPlayer = unitTag
        rightPlayer = sludgeTag1
    end
    -- Crutch.dbgOther(string.format("%f", p1Dist))
    -- Crutch.dbgOther(string.format("%f", p2Dist))
    Crutch.dbgOther(GetUnitDisplayName(leftPlayer) .. "< >" .. GetUnitDisplayName(rightPlayer))
    local label = string.format("|c00FF00%s |c00d60b|t100%%:100%%:Esoui/Art/Buttons/large_leftarrow_up.dds:inheritcolor|t |c00FF00Noxious Sludge|r |c00d60b|t100%%:100%%:Esoui/Art/Buttons/large_rightarrow_up.dds:inheritcolor|t |c00FF00%s|r", GetUnitDisplayName(leftPlayer), GetUnitDisplayName(rightPlayer))
    Crutch.DisplayNotification(157860, label, 5000, 0, 0, 0, 0, true)
end

---------------------------------------------------------------------
-- Bahsei
---------------------------------------------------------------------
local effectResults = {
    [EFFECT_RESULT_FADED] = "FADED",
    [EFFECT_RESULT_FULL_REFRESH] = "FULL_REFRESH",
    [EFFECT_RESULT_GAINED] = "|cb95effGAINED",
    [EFFECT_RESULT_TRANSFER] = "TRANSFER",
    [EFFECT_RESULT_UPDATED] = "UPDATED",
}

local groupBitterMarrow = {}

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnBitterMarrowChanged(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    Crutch.dbgOther(string.format("|c8C00FF%s(%s): %d %s|r", GetUnitDisplayName(unitTag), unitTag, stackCount, effectResults[changeType]))

    if (changeType == EFFECT_RESULT_GAINED) then
        groupBitterMarrow[unitTag] = true
    elseif (changeType == EFFECT_RESULT_FADED) then
        groupBitterMarrow[unitTag] = false
    end
end

-- Player state
local function IsInBahseiPortal(unitTag)
    if (not unitTag) then unitTag = Crutch.playerGroupTag end

    if (groupBitterMarrow[unitTag] == true) then return true end

    return false
end

-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnKissOfDeath(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    local unitTag = Crutch.groupIdToTag[targetUnitId]
    Crutch.msg(zo_strformat("Kiss of Death |cFF00FF<<1>>", GetUnitDisplayName(unitTag)))
end

------------------------------------------------------------
-- Fire Behemoth spawn, because subtitles can get overlapped
-- TODO: turns out this still isn't great, it doesn't gain anything immediately, so healers are still in danger of being bonked
local function StartsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

local seenBehemoths = {}

local function OnBehemothFound(unitId)
    if (not seenBehemoths[unitId]) then
        d("|cFF0000FOUND BEHEMOTH " .. tostring(unitId))
        seenBehemoths[unitId] = true
    end
end

local function RegisterBehemoth(behemothName)
    Crutch.RegisterExitedGroupCombatListener("BehemothExitedCombat", function() seenBehemoths = {} end)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "BehemothCombat", EVENT_COMBAT_EVENT,
        function(_, result, _, _, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
            if (sourceName and StartsWith(sourceName, behemothName)) then
                Crutch.SpamEventDebug(result, sourceName, sourceType, targetName, targetType, hitValue, sourceUnitId, targetUnitId, abilityId, "[FIRE]")
                OnBehemothFound(sourceUnitId)
            elseif (targetName and StartsWith(targetName, behemothName)) then
                Crutch.SpamEventDebug(result, sourceName, sourceType, targetName, targetType, hitValue, sourceUnitId, targetUnitId, abilityId, "[FIRE]")
                OnBehemothFound(targetUnitId)
            end
        end)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "BehemothEffect", EVENT_EFFECT_CHANGED,
        function(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, unitName, unitId, abilityId, sourceType)
            if (unitName and StartsWith(unitName, behemothName)) then
                Crutch.SpamDebugEffect(changeType, unitTag, stackCount, unitName, unitId, abilityId, sourceType)
                OnBehemothFound(unitId)
            end
        end)
end
Crutch.RegisterBehemoth = RegisterBehemoth -- /script CrutchAlerts.RegisterBehemoth("Fire Behem")

local function UnregisterBehemoth()
    seenBehemoths = {}
    Crutch.UnregisterExitedGroupCombatListener("BehemothExitedCombat")
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "BehemothCombat", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "BehemothEffect", EVENT_EFFECT_CHANGED)
end
Crutch.UnregisterBehemoth = UnregisterBehemoth -- /script CrutchAlerts.UnregisterBehemoth()

-----------
-- Bleeding
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local numBleeds = 0
local function OnBleeding(_, changeType, _, _, unitTag, beginTime, endTime)
    local atName = GetUnitDisplayName(unitTag)
    local tagNumber = string.gsub(unitTag, "group", "")
    local tagId = tonumber(tagNumber)
    local fakeSourceUnitId = 8880080 + tagId + numBleeds -- TODO: really gotta rework the alerts and stop hacking around like this
    -- numBleeds is added just to get a unique number, because core can only display one per source id * ability id

    -- Gained only; don't cancel it when FADED because it would only happen on death, and the hacky source ID wouldn't match anyway
    if (changeType ~= EFFECT_RESULT_GAINED) then
        return
    end

    numBleeds = numBleeds + 1

    -- Event is not registered if NEVER, so the only other option is HEAL (which includes self)
    if (Crutch.savedOptions.rockgrove.showBleeding == "ALWAYS"
        or atName == GetUnitDisplayName("player")
        or GetSelectedLFGRole() == LFG_ROLE_HEAL) then
        local label = zo_strformat("|cfff1ab<<C:1>>|cAAAAAA on <<2>>|r", GetAbilityName(153179), atName)
        Crutch.DisplayNotification(153179, label, (endTime - beginTime) * 1000, fakeSourceUnitId, 0, 0, 0, false)
    end
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
local origOSIUnitErrorCheck = nil

function Crutch.RegisterRockgrove()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Rockgrove")

    Crutch.RegisterExitedGroupCombatListener("RockgroveExitedCombat", function() numBleeds = 0 end)

    -- Register the Noxious Sludge
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "NoxiousSludge", EVENT_EFFECT_CHANGED, OnNoxiousSludgeGained)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "NoxiousSludge", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 157860)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "NoxiousSludge", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

    -- Register for Bahsei portal effect gained/faded
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED, OnBitterMarrowChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 153423)

    -- Register for Kiss of Death
    if (Crutch.savedOptions.general.showRaidDiag) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "KissOfDeath", EVENT_COMBAT_EVENT, OnKissOfDeath)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "KissOfDeath", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 152654)
    end

    -- Register for Bleeding
    if (Crutch.savedOptions.rockgrove.showBleeding ~= "NEVER") then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Bleeding", EVENT_EFFECT_CHANGED, OnBleeding)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Bleeding", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Bleeding", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 153179)
    end

    -- RegisterBehemoth("Fire Behem")

    -- Override OdySupportIcons to also check whether the group member is in the same portal vs not portal
    if (OSI) then
        Crutch.dbgOther("|c88FFFF[CT]|r Overriding OSI.UnitErrorCheck")
        origOSIUnitErrorCheck = OSI.UnitErrorCheck
        OSI.UnitErrorCheck = function(unitTag, allowSelf)
            local error = origOSIUnitErrorCheck(unitTag, allowSelf)
            if (error ~= 0) then
                return error
            end
            if (IsInBahseiPortal(Crutch.playerGroupTag) == IsInBahseiPortal(unitTag)) then
                return 0
            else
                return 8
            end
        end
    end
end

function Crutch.UnregisterRockgrove()
    Crutch.UnregisterExitedGroupCombatListener("RockgroveExitedCombat")

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "NoxiousSludge", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "KissOfDeath", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Bleeding", EVENT_EFFECT_CHANGED)

    UnregisterBehemoth()

    if (OSI and origOSIUnitErrorCheck) then
        Crutch.dbgOther("|c88FFFF[CT]|r Restoring OSI.UnitErrorCheck")
        OSI.UnitErrorCheck = origOSIUnitErrorCheck
    end

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Rockgrove")
end
