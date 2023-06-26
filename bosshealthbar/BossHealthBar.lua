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
-- When bosses change
---------------------------------------------------------------------------------------------------
local function GetOrCreateStatusBar(index)
    local statusBar = CrutchAlertsBossHealthBarContainer:GetNamedChild("Bar" .. tostring(index))
    if (not statusBar) then
        statusBar = CreateControlFromVirtual(
            "$(parent)Bar" .. tostring(index), -- name
            CrutchAlertsBossHealthBarContainer, -- parent
            "CrutchAlertsBossHealthBarBarTemplate", -- template
            "") -- suffix
        numMechanicControls = index
    end
    statusBar:SetAnchor(TOPLEFT, CrutchAlertsBossHealthBarContainer, TOPLEFT, (index - 1) * 36 + 2, 2)
    statusBar:SetHidden(false)

    return statusBar
end

-- Shows or hides hp bars for each bossX unit. It may be possible for bosses to disappear,
-- leaving a gap (Reef Guardian?), so we can't just base it on number of bosses.
local function ShowOrHideBars()
    local highestTag = 0

    for i = 1, MAX_BOSSES do
        local name = GetUnitName("boss" .. tostring(i))
        name = "Unit " .. tostring(i) -- TODO
        if (name and name ~= "") then
            highestTag = i
            local statusBar = GetOrCreateStatusBar(i)
            statusBar:GetNamedChild("BossName"):SetText(name)
        else
            local statusBar = CrutchAlertsBossHealthBarContainer:GetNamedChild("Bar" .. tostring(i))
            if (statusBar) then
                statusBar:SetHidden(true)
            end
        end
    end

    -- Adjust container size so the lines and text have something to anchor on the right
    if (highestTag == 0) then
        CrutchAlertsBossHealthBarContainer:SetWidth(34)
    else
        CrutchAlertsBossHealthBarContainer:SetWidth(highestTag * 36)
    end

    if (highestTag > 0) then
        DrawStages()
    end
    DrawStages() -- TODO
end
BHB.ShowOrHideBars = ShowOrHideBars
-- /script CrutchAlerts.BossHealthBar.ShowOrHideBars(1)

local prevBosses = ""
local function OnBossesChanged()
    local bossHash = ""

    for i = 1, MAX_BOSSES do
        local name = GetUnitName("boss" .. tostring(i))
        if (name and name ~= "") then
            bossHash = bossHash .. name
        end
    end

    -- There's no need to redraw the bars if bosses didn't change, which sometimes fires the event anyway for some reason
    if (bossHash ~= prevBosses) then
        prevBosses = bossHash
        ShowOrHideBars()
    end
    ShowOrHideBars() -- TODO
end
BHB.OnBossesChanged = OnBossesChanged
-- /script CrutchAlerts.BossHealthBar.OnBossesChanged()

---------------------------------------------------------------------------------------------------
-- When health changes
---------------------------------------------------------------------------------------------------
-- EVENT_POWER_UPDATE (number eventCode, string unitTag, number powerIndex, CombatMechanicType powerType, number powerValue, number powerMax, number powerEffectiveMax)
local function OnPowerUpdate(_, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    -- TODO
end

---------------------------------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------------------------------
function BHB.Initialize()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Boss Health Bar")
    EVENT_MANAGER:RegisterForEvent("CrutchAlertsBossHealthBarBossChange", EVENT_BOSSES_CHANGED, OnBossesChanged)
    EVENT_MANAGER:RegisterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")

    OnBossesChanged()
end
