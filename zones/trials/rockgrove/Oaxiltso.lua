local Crutch = CrutchAlerts
local C = Crutch.Constants

local EXIT_LEFT_POOL = {x = 91973, y = 35751, z = 81764}  -- from QRH so that we use the same sorting

---------------------------------------------------------------------
-- Sludge icons
---------------------------------------------------------------------
local SLUDGE_UNIQUE_NAME = "CrutchAlertsRGSludge"

local function OnSludgeIcon(changeType, unitTag)
    if (changeType == EFFECT_RESULT_GAINED) then
        Crutch.SetAttachedIconForUnit(unitTag, SLUDGE_UNIQUE_NAME, C.PRIORITY.MECHANIC_1_PRIORITY, "CrutchAlerts/assets/poop.dds", nil, {0.6, 1, 0.6})
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.RemoveAttachedIconForUnit(unitTag, SLUDGE_UNIQUE_NAME)
    end
end

---------------------------------------------------------------------
-- Sludge sides matching QRH (but no longer really useful)
---------------------------------------------------------------------
local sludgeTag1 = nil
local lastSludge = 0 -- for resetting

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnNoxiousSludgeGained(_, changeType, _, _, unitTag)
    if (Crutch.savedOptions.rockgrove.showSludgeIcons) then
        OnSludgeIcon(changeType, unitTag)
    end

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
    Crutch.DisplayNotification(157860, label, 5000, 0, 0, 0, 0, 0, 0, 0, true)
end


---------------------------------------------------------------------
-- Register
---------------------------------------------------------------------
function Crutch.RegisterRockgroveOax()
    -- Register the Noxious Sludge
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "NoxiousSludge", EVENT_EFFECT_CHANGED, OnNoxiousSludgeGained)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "NoxiousSludge", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 157860)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "NoxiousSludge", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end

function Crutch.UnregisterRockgroveOax()
    -- Clean up in case of PTE; unit tags may change
    Crutch.RemoveAllAttachedIcons(SLUDGE_UNIQUE_NAME)

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "NoxiousSludge", EVENT_COMBAT_EVENT)
end

