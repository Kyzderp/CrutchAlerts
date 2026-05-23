local Crutch = CrutchAlerts
local DSR = Crutch.DreadsailReef

local PANEL_REEF_INDEX_OFFSET = 10
local REEF_SCALE = 0.7

local HEARTBURN_ID = 170481


---------------------------------------------------------------------
---------------------------------------------------------------------
local REEF_INDICES = {"big", "med1", "small1", "small2", "med2"}
local function GetReefPrefix(index)
    return string.format("#%d (%s)", index, REEF_INDICES[index])
end

local function SetReefLine(index, suffix, alpha)
    Crutch.InfoPanel.SetLine(PANEL_REEF_INDEX_OFFSET + index, GetReefPrefix(index) .. suffix, REEF_SCALE, alpha)
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local bossUnitIds = {}
local lastHeartburns = {}

local function OnReefStart()
    SetReefLine(1, "")
    for i = 2, 5 do
        SetReefLine(i, "", 0.5)
    end
end

-- Above 80% on a reef, count down the health until 80
local function OnReefHealth(_, unitTag, _, _, powerValue, powerMax)
    local bossIndex = tonumber(unitTag:sub(5, 5))
    if (powerValue == 0) then
        Crutch.InfoPanel.StopCount(PANEL_REEF_INDEX_OFFSET + bossIndex)
        SetReefLine(bossIndex, " - |t100%:100%:esoui/art/icons/mapkey/mapkey_groupboss.dds|t", 0.7)
        return
    end

    if (bossIndex == 1) then return end -- First one isn't gated by health... TODO: is this HM only?

    -- TODO: is it also 80 for vet and norm?
    local percent = powerValue / powerMax * 100
    if (percent >= 81) then
        local remaining = math.floor((percent - 81) * 10) / 10
        SetReefLine(bossIndex, zo_strformat(" - can run in <<1>><<2>>%",
            (remaining == 0) and "|cFF8C00" or "",
            remaining))
    elseif (not lastHeartburns[bossIndex]) then
        -- If it hasn't run before, just set it to 0% once it's under so we don't have to keep track
        -- of the first time it went below 80
        SetReefLine(bossIndex, " - can run in |cFF8C000%")
    end
end

-- During Heartburn, count down to portal wipe
local function OnHeartburnGained(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, targetUnitId)
    local bossTag = bossUnitIds[targetUnitId]
    if (not bossTag) then
        Crutch.dbgOther("|cFF0000Unable to find boss tag for " .. targetUnitId)
        return
    end
    local bossIndex = tonumber(bossTag:sub(5, 5))

    Crutch.dbgOther(bossIndex .. " heartburn gained")
    Crutch.InfoPanel.CountDownDuration(PANEL_REEF_INDEX_OFFSET + bossIndex, GetReefPrefix(bossIndex) .. " - ", hitValue, REEF_SCALE)
    lastHeartburns[bossIndex] = GetGameTimeMilliseconds()
end

-- After Heartburn, count until next run. Except we haven't figured it out?
local function OnHeartburnFaded(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    local bossTag = bossUnitIds[targetUnitId]
    if (not bossTag) then
        Crutch.dbgOther("|cFF0000Unable to find boss tag for " .. targetUnitId)
        return
    end
    local bossIndex = tonumber(bossTag:sub(5, 5))

    Crutch.dbgOther(bossIndex .. " heartburn faded")
    Crutch.InfoPanel.StopCount(PANEL_REEF_INDEX_OFFSET + bossIndex)
    local targetTime = lastHeartburns[bossIndex] + 57400 -- TODO
    Crutch.InfoPanel.CountDownToTargetTime(PANEL_REEF_INDEX_OFFSET + bossIndex, GetReefPrefix(bossIndex) .. " - can run in ", targetTime, REEF_SCALE)
end

-- Unit ID caching
local function OnBossEffect(_, _, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId)
    bossUnitIds[unitId] = unitTag
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local reefRegistered = false
local function MaybeRegisterReef()
    if (reefRegistered) then return end

    if (GetUnitName("boss1") == Crutch.GetCapitalizedString(CRUTCH_BHB_REEF_GUARDIAN)) then -- Reef only
        Crutch.dbgOther("Registering reef info panel: " .. tostring(GetUnitName("boss1")))
        reefRegistered = true

        -- TODO: register for replication?
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRReefHealth", EVENT_POWER_UPDATE, OnReefHealth)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRReefHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRReefHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)

        Crutch.RegisterForEffectChanged("DSRReefBossEffect", OnBossEffect, nil, "boss")
        Crutch.RegisterForCombatEvent("DSRReefHeartburnGained", OnHeartburnGained, ACTION_RESULT_EFFECT_GAINED_DURATION, HEARTBURN_ID)
        Crutch.RegisterForCombatEvent("DSRReefHeartburnFaded", OnHeartburnFaded, ACTION_RESULT_EFFECT_FADED, HEARTBURN_ID)

        OnReefStart()
    end
end

local function UnregisterReef()
    Crutch.dbgOther("Unregistering reef info panel")
    reefRegistered = false
    -- TODO: unregister
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRReefHealth", EVENT_POWER_UPDATE)
    Crutch.UnregisterForEffectChanged("DSRReefBossEffect")
    Crutch.UnregisterForCombatEvent("DSRReefHeartburnGained")
    Crutch.UnregisterForCombatEvent("DSRReefHeartburnFaded")
end

local function CleanUp()
    UnregisterReef()

    for i = 1, 5 do
        Crutch.InfoPanel.StopCount(PANEL_REEF_INDEX_OFFSET + i)
    end
    ZO_ClearTable(bossUnitIds)
    ZO_ClearTable(lastHeartburns)
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
