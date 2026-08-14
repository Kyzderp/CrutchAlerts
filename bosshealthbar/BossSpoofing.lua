local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar


---------------------------------------------------------------------
-- Boss spoofing
---------------------------------------------------------------------
local spoofedBosses = {} -- {["boss3"] = {name = "Blazeforged Valneer", getHealthFunction = function() return powerValue, powerMax, powerEffectiveMax end}}
BHB.spoofedBosses = spoofedBosses

local function SetBarColors(index, fgColor, bgColor)
    fgColor = fgColor or Crutch.savedOptions.bossHealthBar.foreground
    bgColor = bgColor or Crutch.savedOptions.bossHealthBar.background

    local bar = CrutchAlertsBossHealthBarContainer:GetNamedChild("Bar" .. tostring(index))
    -- Use the user-set alphas if not specified
    bar:SetColor(fgColor[1], fgColor[2], fgColor[3], fgColor[4] or Crutch.savedOptions.bossHealthBar.foreground[4])
    bar:GetNamedChild("Backdrop"):SetEdgeColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4] or Crutch.savedOptions.bossHealthBar.background[4])
    bar:GetNamedChild("Backdrop"):SetCenterColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4] or Crutch.savedOptions.bossHealthBar.background[4])
end
Crutch.SetBarColors = SetBarColors

local function SpoofBoss(unitTag, name, getHealthFunction, fgColor, bgColor)
    spoofedBosses[unitTag] = {
        name = name,
        getHealthFunction = getHealthFunction,
        fgColor = fgColor or Crutch.savedOptions.bossHealthBar.foreground,
        bgColor = bgColor or Crutch.savedOptions.bossHealthBar.background,
    }

    BHB.ShowOrHideBars(false, true)
    local index = unitTag:sub(5, 5)
    SetBarColors(index, spoofedBosses[unitTag].fgColor, spoofedBosses[unitTag].bgColor)
    Crutch.dbgOther(string.format("Spoofing %s as %s", name, unitTag))
end
Crutch.SpoofBoss = SpoofBoss

local function UnspoofBoss(unitTag)
    if (spoofedBosses[unitTag]) then
        Crutch.dbgOther(string.format("Unspoofing %s", unitTag))
        spoofedBosses[unitTag] = nil

        BHB.ShowOrHideBars(false, true)
        local index = unitTag:sub(5, 5)
        SetBarColors(index, nil, nil)
    end
end
Crutch.UnspoofBoss = UnspoofBoss

local function UpdateSpoofedBossHealth(unitTag, value, max)
    BHB.OnPowerUpdate(nil, unitTag, nil, nil, value, max, max)
end
Crutch.UpdateSpoofedBossHealth = UpdateSpoofedBossHealth
--[[
/script CrutchAlerts.SpoofBoss("boss3", "yeetus", function() return 28394, 32939, 32939 end,
        {230/256, 129/256, 34/256, 0.73},
        {18/256, 9/256, 1/256, 0.66})
/script CrutchAlerts.UpdateSpoofedBossHealth("boss3", 4939, 32939)
/script CrutchAlerts.UnspoofBoss("boss3")
]]


---------------------------------------------------------------------
-- "Auto" tracking
---------------------------------------------------------------------
local trackedUnits = {}
--[[
{
    [12345] = {
        name = "Valneer",
        unitTag = "boss3",
        maxHealth = 88888888888,
        health = 123151,
        fgColor = {1, 1, 1},
        bgColor = {1, 1, 1},
    }
}
]]


---------------------------------------------------------------------
-- Events
---------------------------------------------------------------------
local damageTypes = {
    [ACTION_RESULT_DAMAGE] = "dmg",
    [ACTION_RESULT_CRITICAL_DAMAGE] = "dmg*",
    [ACTION_RESULT_DOT_TICK] = "tick",
    [ACTION_RESULT_DOT_TICK_CRITICAL] = "tick*",
    [ACTION_RESULT_HEAL] = "heal",
    [ACTION_RESULT_CRITICAL_HEAL] = "heal*",
}

local function OnDamage(_, result, _, _, _, _, _, _, _, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    local trackedUnit = trackedUnits[targetUnitId]
    if (not trackedUnit) then return end

    if (result == ACTION_RESULT_HEAL or result == ACTION_RESULT_CRITICAL_HEAL) then
        trackedUnit.health = zo_clamp(trackedUnit.health + hitValue, 0, trackedUnit.maxHealth)
        Crutch.dbgOther(string.format("|cFFAA00%s (%d) %s for %d via %s (%d)", trackedUnit.name, targetUnitId, damageTypes[result], hitValue, GetAbilityName(abilityId), abilityId))
    else
        trackedUnit.health = zo_clamp(trackedUnit.health - hitValue, 0, trackedUnit.maxHealth)
    end
    UpdateSpoofedBossHealth(trackedUnit.unitTag, trackedUnit.health, trackedUnit.maxHealth)
end

local function UnregisterDamageEvents()
    for _, text in pairs(damageTypes) do
        Crutch.UnregisterForCombatEvent("BossSpoofing" .. text)
    end
end

local function RegisterDamageEvents()
    UnregisterDamageEvents()
    for result, text in pairs(damageTypes) do
        Crutch.RegisterForCombatEvent("BossSpoofing" .. text, OnDamage, result, nil, nil, COMBAT_UNIT_TYPE_NONE)
    end
end


---------------------------------------------------------------------
-- reticleover syncing
---------------------------------------------------------------------
local reticleTrackingUnits = {} -- {["Shade of Relequen"] = 12355,}

local function OnReticleTargetChanged()
    if (not DoesUnitExist("reticleover")) then return end
    local name = zo_strformat(SI_UNIT_NAME, GetUnitName("reticleover"))
    local unitId = reticleTrackingUnits[name]
    if (not unitId) then return end

    local trackedUnit = trackedUnits[unitId]
    if (not trackedUnit) then
        Crutch.dbgOther(zo_strformat("|cFF0000<<1>> (<<2>>) is registered for reticle tracking but not tracked unit?", name, unitId))
        return
    end

    local current, max = GetUnitPower("reticleover", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (trackedUnit.maxHealth ~= max) then
        Crutch.dbgOther(zo_strformat("|cFF0000<<1>> (<<2>>) max health <<3>> does not match initial; updating. Initial: <<4>>", name, unitId, max, trackedUnit.maxHealth))
        trackedUnit.maxHealth = max
    end

    if (trackedUnit.health ~= current) then
        Crutch.dbgOther(zo_strformat("|cFFAA00<<1>> (<<2>>) syncing health from <<3>> -> <<4>>", name, unitId, trackedUnit.health, current))
        trackedUnit.health = current
        UpdateSpoofedBossHealth(trackedUnit.unitTag, trackedUnit.health, trackedUnit.maxHealth)
    end
end

local function UnregisterReticleEvents()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "BossSpoofingReticle", EVENT_RETICLE_TARGET_CHANGED)
end

local function RegisterReticleEvents()
    UnregisterReticleEvents()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "BossSpoofingReticle", EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)
end


---------------------------------------------------------------------
-- API
---------------------------------------------------------------------
local function TrackUnitForSpoofing(unitId, name, unitTag, maxHealth, fgColor, bgColor, initialHealth)
    trackedUnits[unitId] = {
        name = name,
        unitTag = unitTag,
        maxHealth = maxHealth,
        health = initialHealth or maxHealth,
        fgColor = fgColor,
        bgColor = bgColor,
    }

    local function GetHealthFunction()
        return trackedUnits[unitId].health, trackedUnits[unitId].maxHealth, trackedUnits[unitId].maxHealth
    end

    SpoofBoss(unitTag, name, GetHealthFunction, fgColor, bgColor)

    RegisterDamageEvents()
end
Crutch.TrackUnitForSpoofing = TrackUnitForSpoofing

local function UntrackUnitForSpoofing(unitId)
    local trackedUnit = trackedUnits[unitId]
    if (trackedUnit) then
        UnspoofBoss(trackedUnit.unitTag)
    end
    trackedUnits[unitId] = nil

    if (ZO_IsTableEmpty(trackedUnits)) then
        UnregisterDamageEvents()
    end
end
Crutch.UntrackUnitForSpoofing = UntrackUnitForSpoofing

-- Should not be used for non-unique names
local function TrackUnitForReticleSyncing(name, unitId)
    Crutch.dbgOther("Starting reticle tracking for " .. name .. " " .. unitId)
    reticleTrackingUnits[name] = unitId

    RegisterReticleEvents()
end
Crutch.TrackUnitForReticleSyncing = TrackUnitForReticleSyncing

local function UntrackUnitForReticleSyncing(name)
    Crutch.dbgOther("Stopping reticle tracking for " .. name)
    reticleTrackingUnits[name] = nil

    if (ZO_IsTableEmpty(reticleTrackingUnits)) then
        UnregisterReticleEvents()
    end
end
Crutch.UntrackUnitForReticleSyncing = UntrackUnitForReticleSyncing
