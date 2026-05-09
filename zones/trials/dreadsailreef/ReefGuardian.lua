local Crutch = CrutchAlerts
local DSR = Crutch.DreadsailReef

local PANEL_REEF_INDEX_OFFSET = 10
local REEF_SCALE = 0.7

local HEARTBURN_ID = 170481
local CHARGE_ID = 166022

local onReef = false -- Track current state because we don't want to reset stuff on bosses changed

---------------------------------------------------------------------
-- TODO: big med1 small1 small2 med2?
---------------------------------------------------------------------
local REEF_INDICES = {"big", "med1", "small1", "small2", "med2"}
local function GetReefPrefix(index)
    return string.format("#%d (%s)", index, REEF_INDICES[index])
end

local function SetReefLine(index, suffix)
    Crutch.InfoPanel.SetLine(PANEL_REEF_INDEX_OFFSET + index, GetReefPrefix(index) .. suffix, REEF_SCALE)
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local bossUnitIds = {}

local function OnReefStart()
    for i = 1, 5 do
        SetReefLine(i, "")
    end
end

-- Above 80% on a reef, count down the health until 80
local function OnReefHealth(_, unitTag, _, _, powerValue, powerMax)
    local bossIndex = tonumber(unitTag:sub(5, 5))
    if (powerValue == 0) then
        SetReefLine(bossIndex, " - |t100%:100%:esoui/art/icons/mapkey/mapkey_groupboss.dds|t")
        return
    end

    -- TODO: is it also 80 for vet and norm?
    local percent = powerValue / powerMax * 100
    if (percent >= 81) then
        local remaining = math.floor((percent - 81) * 10) / 10
        SetReefLine(index, " - can run in " .. remaining .. "%")
    end
    -- TODO: do anything under 80?
end

-- During Heartburn, count down to portal wipe. After Heartburn, count until next Charge
local function OnHeartburn(changeType, bossIndex, durationSeconds)
    if (changeType == EFFECT_RESULT_GAINED) then
        Crutch.InfoPanel.CountDownDuration(PANEL_REEF_INDEX_OFFSET + bossIndex, GetReefPrefix(bossIndex) .. " - ", durationSeconds * 1000, REEF_SCALE)
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.InfoPanel.StopCount(PANEL_REEF_INDEX_OFFSET + bossIndex)
        Crutch.InfoPanel.CountDownDuration(PANEL_REEF_INDEX_OFFSET + bossIndex, GetReefPrefix(bossIndex) .. " - can run in ", 57400, REEF_SCALE) -- TODO
    end
end

-- Unit ID caching
local function OnBossEffect(_, changeType, _, _, unitTag, beginTime, endTime, _, _, _, _, _, _, _, unitId, abilityId)
    bossUnitIds[unitId] = unitTag
    if (abilityId == HEARTBURN_ID) then
        local bossIndex = tonumber(unitTag:sub(5, 5))
        OnHeartburn(changeType, bossIndex, endTime - beginTime)
    end
end

-- Just show running, it will be overwritten by Heartburn or deadge
local function OnCharge(_, _, _, _, _, _, _, _, _, _, _, _, _, _, sourceUnitId)
    local bossTag = bossUnitIds[sourceUnitId]
    if (not bossTag) then
        Crutch.dbgOther("|cFF0000Unable to find boss tag for " .. sourceUnitId)
        return
    end

    local bossIndex = tonumber(bossTag:sub(5, 5))
    Crutch.InfoPanel.StopCount(PANEL_REEF_INDEX_OFFSET + bossIndex)
    SetReefLine(bossIndex, zo_strformat(" - <<C:1>>", GetAbilityName(CHARGE_ID)))
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local function MaybeRegisterReef()
    -- TODO: only change if actually reef, because bosses can change - check if correct
    local _, powerMax, _ = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (not onReef and (powerMax == 41915160 or powerMax == 27943440)) then -- Reef only TODO: norm?
        Crutch.dbgOther("Registering reef info panel")
        onReef = true

        -- TODO: register for replication?
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRReefHealth", EVENT_POWER_UPDATE, OnReefHealth)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRReefHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRReefHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)

        Crutch.RegisterForEffectChanged("DSRReefBossEffect", OnBossEffect, nil, "boss")
        Crutch.RegisterForCombatEvent("DSRReefCharge", OnCharge, ACTION_RESULT_BEGIN, CHARGE_ID)
    else
        Crutch.dbgOther("Unregistering reef info panel")
        onReef = false
        -- TODO: unregister
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRReefHealth", EVENT_POWER_UPDATE)
        Crutch.UnregisterForEffectChanged("DSRReefHeartburn")
        Crutch.UnregisterForCombatEvent("DSRReefCharge")
    end
end

local function CleanUp()
    onReef = false
    for i = 1, 5 do
        Crutch.InfoPanel.StopCount(PANEL_REEF_INDEX_OFFSET + i)
    end
    ZO_ClearTable(bossUnitIds)
end

function DSR.RegisterReefGuardian()
    Crutch.RegisterBossChangedListener("CrutchDreadsailReefReefGuardianBossesChanged", MaybeRegisterReef)
    Crutch.RegisterEnteredGroupCombatListener("CrutchDreadsailReefGuardianEnteredCombat", MaybeRegisterReef)
    Crutch.RegisterExitedGroupCombatListener("CrutchDreadsailReefGuardianExitedCombat", CleanUp)

    MaybeRegisterReef()
end

function DSR.UnregisterReefGuardian()
    CleanUp()
    Crutch.UnregisterBossChangedListener("CrutchDreadsailReefReefGuardianBossesChanged")
    Crutch.UnregisterEnteredGroupCombatListener("CrutchDreadsailReefGuardianEnteredCombat")
    Crutch.UnregisterExitedGroupCombatListener("CrutchDreadsailReefGuardianExitedCombat")
end
