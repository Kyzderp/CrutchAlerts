CrutchAlerts = CrutchAlerts or {}
CrutchAlerts.BossHealthBar = CrutchAlerts.BossHealthBar or {}
local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

-- CrutchAlertsBossHealthBarContainerBar
-- ZO_StatusBar_SmoothTransition(self, value, max, forceInit, onStopCallback, customApproachAmountMs)
-- /script ZO_StatusBar_SmoothTransition(CrutchAlertsBossHealthBarContainerBar, 0, 1)
-- SetBarGradient
-- /script CrutchAlertsBossHealthBarContainerBar:SetGradientColors(1, 0, 0, 1, 0.5, 0, 0, 1)

-- I was really hoping to be able to use status bar gradient colors, but it seems to have really unexpected behavior with the vertical orientation

local numBosses = 0

---------------------------------------------------------------------------------------------------
-- Stages
---------------------------------------------------------------------------------------------------
local numMechanicControls = 0

local function GetOrCreatePercentageAndMechanicControls(index, percentage)
    -- Number percentage on the left of the bar
    local percentageLabel = CrutchAlertsBossHealthBarContainer:GetNamedChild("Percent" .. tostring(index))
    if (not percentageLabel) then
        percentageLabel = CreateControlFromVirtual(
            "$(parent)Percent" .. tostring(index), -- name
            CrutchAlertsBossHealthBarContainer, -- parent
            "CrutchAlertsBossHealthBarPercentageTemplate", -- template
            "") -- suffix
        numMechanicControls = index
    end
    percentageLabel:SetAnchor(RIGHT, CrutchAlertsBossHealthBarContainer, TOPLEFT, -5, (100 - percentage) / 5 * 16)
    percentageLabel:SetHidden(false)

    -- Mechanic text on the right of the bar
    local mechanicLabel = CrutchAlertsBossHealthBarContainer:GetNamedChild("Mechanic" .. tostring(index))
    if (not mechanicLabel) then
        mechanicLabel = CreateControlFromVirtual(
            "$(parent)Mechanic" .. tostring(index), -- name
            CrutchAlertsBossHealthBarContainer, -- parent
            "CrutchAlertsBossHealthBarMechanicTemplate", -- template
            "") -- suffix
        numMechanicControls = index
    end
    mechanicLabel:SetAnchor(LEFT, CrutchAlertsBossHealthBarContainer, TOPRIGHT, 6, (100 - percentage) / 5 * 16)
    mechanicLabel:SetHidden(false)

    -- Line marking the percentage through the bar
    local lineControl = CrutchAlertsBossHealthBarContainer:GetNamedChild("Line" .. tostring(index))
    if (not lineControl) then
        lineControl = CreateControlFromVirtual(
            "$(parent)Line" .. tostring(index), -- name
            CrutchAlertsBossHealthBarContainer, -- parent
            "CrutchAlertsBossHealthBarLineTemplate", -- template
            "") -- suffix
        numMechanicControls = index
    end
    lineControl:SetAnchor(TOPLEFT, CrutchAlertsBossHealthBarContainer, TOPLEFT, -4, (100 - percentage) / 5 * 16 + 1)
    lineControl:SetAnchor(BOTTOMRIGHT, CrutchAlertsBossHealthBarContainer, TOPRIGHT, 4, (100 - percentage) / 5 * 16 + 2)
    lineControl:SetHidden(false)

    return percentageLabel, mechanicLabel, lineControl
end

local function DrawStages()
    local bossName = GetUnitName("boss1")
    bossName = "Exarchanic Yaseyla" -- TODO
    local data = BHB.thresholds[bossName] or BHB.thresholds[BHB.aliases[bossName]]
    -- TODO: detect HM
    data = data.Hardmode
    local i = 1
    for percentage, mechanic in pairs(data) do
        local percentageLabel, mechanicLabel, lineControl = GetOrCreatePercentageAndMechanicControls(i, percentage)
        percentageLabel:SetText(tostring(percentage))
        mechanicLabel:SetText(mechanic)
        i = i + 1
    end

    -- Hide unused controls
    for j = i, numMechanicControls do
        local percentageLabel, mechanicLabel, lineControl = GetOrCreatePercentageAndMechanicControls(j)
        percentageLabel:SetHidden(true)
        mechanicLabel:SetHidden(true)
        lineControl:SetHidden(true)
    end
end

---------------------------------------------------------------------------------------------------
local function ShowOrHideBars()
    -- TODO
end

local function OnBossesChanged()
    numBosses = 0
    for i = 1, MAX_BOSSES do
        local name = GetUnitName("boss" .. tostring(i))
        if (name) then
            numBosses = numBosses + 1
        end
    end
    DrawStages()
end

-- EVENT_POWER_UPDATE (number eventCode, string unitTag, number powerIndex, CombatMechanicType powerType, number powerValue, number powerMax, number powerEffectiveMax)
local function OnPowerUpdate(_, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    -- TODO
end

function BHB.Initialize()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Boss Health Bar")
    EVENT_MANAGER:RegisterForEvent("CrutchAlertsBossHealthBarBossChange", EVENT_BOSSES_CHANGED, OnBossesChanged)
    EVENT_MANAGER:RegisterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")

    OnBossesChanged()
end
