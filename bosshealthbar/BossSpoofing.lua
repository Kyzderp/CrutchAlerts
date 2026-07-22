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
local function OnDamage(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    local trackedUnit = trackedUnits[targetUnitId]
    if (not trackedUnit) then return end

    trackedUnit.health = trackedUnit.health - hitValue
    UpdateSpoofedBossHealth(trackedUnit.unitTag, trackedUnit.health, trackedUnit.maxHealth)
end

local damageTypes = {
    [ACTION_RESULT_DAMAGE] = "dmg",
    [ACTION_RESULT_CRITICAL_DAMAGE] = "dmg*",
    [ACTION_RESULT_DOT_TICK] = "tick",
    [ACTION_RESULT_DOT_TICK_CRITICAL] = "tick*",
}

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
-- API
---------------------------------------------------------------------
local function TrackUnitForSpoofing(unitId, name, unitTag, maxHealth, fgColor, bgColor)
    trackedUnits[unitId] = {
        name = name,
        unitTag = unitTag,
        maxHealth = maxHealth,
        health = maxHealth,
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
    local trackedUnit = trackedUnits[unitId] = nil
    if (trackedUnit) then
        UnspoofBoss(trackedUnit.unitTag)
    end
    trackedUnits[unitId] = nil

    if (ZO_IsTableEmpty(trackedUnits)) then
        UnregisterDamageEvents()
    end
end
Crutch.UntrackUnitForSpoofing = UntrackUnitForSpoofing
