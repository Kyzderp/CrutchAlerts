local Crutch = CrutchAlerts
local DSR = Crutch.DreadsailReef

local PANEL_REEF_INDEX_OFFSET = 10
local REEF_SCALE = 0.7

local onReef = false -- Track current state because we don't want to reset stuff on bosses changed

---------------------------------------------------------------------
---------------------------------------------------------------------
local function SetReefLine(index, suffix)
    Crutch.InfoPanel.SetLine(PANEL_REEF_INDEX_OFFSET + index, "#" .. index .. suffix, REEF_SCALE)
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local function OnReefStart()
    for i = 1, 5 do
        SetReefLine(i, "")
    end
end

local function OnReefHealth(_, unitTag, _, _, powerValue, powerMax)
    local bossIndex = tonumber(unitTag:sub(5, 5))
    if (powerValue == 0) then
        SetReefLine(bossIndex, " - |t100%:100%:esoui/art/icons/mapkey/mapkey_groupboss.dds|t")
    end
end

local function OnHeartburn(_, changeType, _, _, unitTag, beginTime, endTime)
    local bossIndex = tonumber(unitTag:sub(5, 5))
    if (changeType == EFFECT_RESULT_GAINED) then
        Crutch.InfoPanel.CountDownDuration(PANEL_REEF_INDEX_OFFSET + bossIndex, "#" .. index .. " - ", (endTime - beginTime) * 1000, REEF_SCALE)
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.InfoPanel.StopCount(PANEL_REEF_INDEX_OFFSET + bossIndex)
        Crutch.InfoPanel.CountDownDuration(PANEL_REEF_INDEX_OFFSET + bossIndex, "#" .. index .. " - can run in ", 60000, REEF_SCALE) -- TODO: 1:01, 
    end
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local function MaybeRegisterReef()
    -- TODO: only change if actually reef, because bosses can change - check if correct
    local _, powerMax, _ = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (not onReef and (powerMax == 41915160 or powerMax == 27943440)) then -- Reef only TODO: norm?
        onReef = true
        -- TODO: register for replication, reef heart
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRReefHealth", EVENT_POWER_UPDATE, OnReefHealth)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRReefHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRReefHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)

        Crutch.RegisterForEffectChanged("DSRReefHeartburn", OnHeartburn, 170481, "boss")
    else
        onReef = false
        -- TODO: unregister
    end
end

local function CleanUp()
    onReef = false
    for i = 1, 5 do
        Crutch.InfoPanel.StopCount(PANEL_REEF_INDEX_OFFSET + i)
    end
end

function DSR.RegisterReefGuardian()
    Crutch.RegisterBossChangedListener("CrutchDreadsailReefReefGuardianBossesChanged", MaybeRegisterReef)
    Crutch.RegisterEnteredGroupCombatListener("CrutchDreadsailReefGuardianEnteredCombat", MaybeRegisterReef)
    Crutch.RegisterExitedGroupCombatListener("CrutchDreadsailReefGuardianExitedCombat", CleanUp)

    MaybeRegisterReef()
end

function DSR.UnregisterReef()
    Crutch.UnregisterBossChangedListener("CrutchDreadsailReefReefGuardianBossesChanged")
    Crutch.UnregisterEnteredGroupCombatListener("CrutchDreadsailReefGuardianEnteredCombat")
    Crutch.UnregisterExitedGroupCombatListener("CrutchDreadsailReefGuardianExitedCombat")
end
