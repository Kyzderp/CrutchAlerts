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
-- Util
---------------------------------------------------------------------------------------------------
local function dbg(msg)
    Crutch.dbgSpam(string.format("|c8888FF[BHB]|r %s", msg))
end

---------------------------------------------------------------------------------------------------
-- Stages
---------------------------------------------------------------------------------------------------
local mechanicControls = {} -- { [1] = { state = ACTIVE, percentNumber = 70, percentage = control, mechanic = control, line = control, }, }
local INACTIVE = 0
local ACTIVE = 1
local IMMINENT = 2
local PASSED = 3

-- My elementary control pool. Gets index for percentage, mechanic, and line controls, or creates new ones if none available
local function GetUnusedControlsIndex()
    -- First check if any existing ones are free
    local index = 0
    for i, controls in ipairs(mechanicControls) do
        if (controls.state == INACTIVE) then
            index = i
            break
        end
    end

    if (index ~= 0) then
        return index
    end

    index = #mechanicControls + 1

    -- If there are no free controls, we need to create them
    dbg("creating new controls for index " .. tostring(index))

    -- Number percentage on the left of the bar
    local percentageLabel = CreateControlFromVirtual(
        "$(parent)Percent" .. tostring(index), -- name
        CrutchAlertsBossHealthBarContainer, -- parent
        "CrutchAlertsBossHealthBarPercentageTemplate", -- template
        "") -- suffix

    -- Mechanic text on the right of the bar
    local mechanicLabel = CreateControlFromVirtual(
        "$(parent)Mechanic" .. tostring(index), -- name
        CrutchAlertsBossHealthBarContainer, -- parent
        "CrutchAlertsBossHealthBarMechanicTemplate", -- template
        "") -- suffix

    -- Line marking the percentage through the bar
    local lineControl = CreateControlFromVirtual(
        "$(parent)Line" .. tostring(index), -- name
        CrutchAlertsBossHealthBarContainer, -- parent
        "CrutchAlertsBossHealthBarLineTemplate", -- template
        "") -- suffix

    -- Don't forget to put the new controls in the struct
    mechanicControls[index] = {
        state = ACTIVE,
        percentage = percentageLabel,
        mechanic = mechanicLabel,
        line = lineControl,
    }

    return index
end

-- Returns the individual controls for a stage
local function CreateStageControl(percentage)
    local controls = mechanicControls[GetUnusedControlsIndex()]
    controls.state = ACTIVE
    controls.percentNumber = percentage
    return controls.percentage, controls.mechanic, controls.line
end

local function HideAllStages()
    for _, controls in ipairs(mechanicControls) do
        controls.state = INACTIVE
        controls.percentage:SetHidden(true)
        controls.mechanic:SetHidden(true)
        controls.line:SetHidden(true)
    end
end

-- Check Thresholds.lua for boss stages
local function GetBossThresholds()
    local bossName = GetUnitName("boss1")
    local data = BHB.thresholds[bossName] or BHB.thresholds[BHB.aliases[bossName]]

    -- If there's no stages, do a default 75, 50, 25
    if (not data) then
        data = {
            [75] = "",
            [50] = "",
            [25] = "",
        }
    end

    -- TODO: detect HM
    if (data.Hardmode) then
        data = data.Hardmode
    elseif (data.Veteran) then
        data = data.Veteran
    end

    return data
end

-- Draw number on the left, line through the bars, and text on the right for each boss stage threshold
local function DrawStages()
    HideAllStages()

    local data = GetBossThresholds()
    d(data)

    -- Create the controls and set the properties
    for percentage, mechanic in pairs(data) do
        local percentageLabel, mechanicLabel, lineControl = CreateStageControl(percentage)

        -- Number percentage on the left of the bar
        percentageLabel:SetAnchor(RIGHT, CrutchAlertsBossHealthBarContainer, TOPLEFT, -5, (100 - percentage) / 5 * 16)
        percentageLabel:SetText(tostring(percentage))
        percentageLabel:SetColor(0.53, 0.53, 0.53)
        percentageLabel:SetHidden(false)

        -- Mechanic text on the right of the bar
        mechanicLabel:SetAnchor(LEFT, CrutchAlertsBossHealthBarContainer, TOPRIGHT, 6, (100 - percentage) / 5 * 16)
        mechanicLabel:SetText(mechanic)
        mechanicLabel:SetColor(0.53, 0.53, 0.53, 1)
        mechanicLabel:SetHidden(false)

        -- Line marking the percentage through the bar
        lineControl:SetAnchor(TOPLEFT, CrutchAlertsBossHealthBarContainer, TOPLEFT, -4, (100 - percentage) / 5 * 16 + 1)
        lineControl:SetAnchor(BOTTOMRIGHT, CrutchAlertsBossHealthBarContainer, TOPRIGHT, 4, (100 - percentage) / 5 * 16 + 2)
        lineControl:GetNamedChild("Backdrop"):SetCenterColor(0.53, 0.53, 0.53, 0.67)
        lineControl:GetNamedChild("Backdrop"):SetEdgeColor(0.53, 0.53, 0.53, 0.67)
        lineControl:SetHidden(false)
    end
end

---------------------------------------------------------------------------------------------------
-- When health changes
---------------------------------------------------------------------------------------------------
local bossHealths = {} -- { [1] = 0.7231, }

-- Make stages that have already passed less obvious, and maybe highlight imminent stages
-- Currently this doesn't really work well for encounters with multiple bosses, because I check
-- both boss' health and take the maximum, and gray out things that haven't passed that. This means
-- for things like Ly+Turli, the ticks don't get grayed out until both are < 70/65. Not yet sure of
-- a good way to represent this in the data
local function UpdateStagesWithBossHealth()
    -- Use the maximum health
    local highestHealth = math.max(
        bossHealths[1] or 0,
        bossHealths[2] or 0,
        bossHealths[3] or 0,
        bossHealths[4] or 0,
        bossHealths[5] or 0,
        bossHealths[6] or 0
        )
    highestHealth = zo_round(highestHealth * 100)

    for _, controls in ipairs(mechanicControls) do
        if (controls.state ~= INACTIVE) then
            if (controls.state == PASSED) then
                -- Don't redo the ones that have already passed, because if boss heals up,
                -- this would still leave them grayed out, which is good
            elseif (highestHealth < controls.percentNumber - 1) then
                -- If the highest health is already more than 1% lower than mechanic, gray out mechanic
                controls.state = PASSED
                controls.percentage:SetColor(0.53, 0.53, 0.53, 0.5)
                controls.mechanic:SetColor(0.53, 0.53, 0.53, 0.5)
                controls.line:GetNamedChild("Backdrop"):SetCenterColor(0.53, 0.53, 0.53, 0.1)
                controls.line:GetNamedChild("Backdrop"):SetEdgeColor(0.53, 0.53, 0.53, 0.1)
            elseif (highestHealth >= controls.percentNumber - 1 and highestHealth <= controls.percentNumber + 5) then
                -- If the highest health is within 5% above the mechanic or 1% just after, highlight it
                -- e.g. 75, 74, 73, 72, 71, 70, 69 % would display as yellow
                controls.state = IMMINENT
                controls.percentage:SetColor(1, 1, 0, 0.5)
                controls.mechanic:SetColor(1, 1, 0, 0.5)
                controls.line:GetNamedChild("Backdrop"):SetCenterColor(1, 1, 0, 0.67)
                controls.line:GetNamedChild("Backdrop"):SetEdgeColor(1, 1, 0, 0.67)
            else
                -- Don't "clean" the ones that are still below the health, because if boss heals up,
                -- this would still leave them grayed out, which is good
            end
        end
    end
end

-- EVENT_POWER_UPDATE (number eventCode, string unitTag, number powerIndex, CombatMechanicType powerType, number powerValue, number powerMax, number powerEffectiveMax)
local function OnPowerUpdate(_, unitTag, _, _, powerValue, powerMax, powerEffectiveMax)
    -- Still not sure the difference between powerMax and powerEffectiveMax...
    local index = tonumber(unitTag:sub(5, 5))
    local statusBar = CrutchAlertsBossHealthBarContainer:GetNamedChild("Bar" .. tostring(index))
    if (statusBar) then
        -- ZO_StatusBar_SmoothTransition(self, value, max, forceInit, onStopCallback, customApproachAmountMs)
        ZO_StatusBar_SmoothTransition(statusBar, powerValue, powerMax)
        local percentText = zo_strformat("<<1>>%", tostring(zo_round(powerValue * 100 / powerMax)))
        statusBar:GetNamedChild("Percent"):SetText(percentText)

        bossHealths[index] = powerValue / powerMax
        UpdateStagesWithBossHealth()
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
        dbg("Created new control Bar" .. tostring(index))
    end
    statusBar:SetAnchor(TOPLEFT, CrutchAlertsBossHealthBarContainer, TOPLEFT, (index - 1) * 36 + 2, 2)
    statusBar:SetHidden(false)

    return statusBar
end

-- Shows or hides hp bars for each bossX unit. It may be possible for bosses to disappear,
-- leaving a gap (Reef Guardian?), so we can't just base it on number of bosses.
local function ShowOrHideBars(showAllForMoving)
    local highestTag = 0

    for i = 1, MAX_BOSSES do
        local unitTag = "boss" .. tostring(i)
        local name = GetUnitName(unitTag)
        if (showAllForMoving) then
            name = "Example Boss " .. tostring(i)
        end
        if (name and name ~= "") then
            highestTag = i
            local statusBar = GetOrCreateStatusBar(i)
            statusBar:GetNamedChild("BossName"):SetText(name)

            -- Also need to manually update the boss health to initialize
            local powerValue, powerMax, powerEffectiveMax = GetUnitPower(unitTag, POWERTYPE_HEALTH)
            if (showAllForMoving) then
                powerValue = math.random()
                powerMax = 1
            end
            OnPowerUpdate(_, unitTag, _, _, powerValue, powerMax, powerEffectiveMax)
        else
            local statusBar = CrutchAlertsBossHealthBarContainer:GetNamedChild("Bar" .. tostring(i))
            if (statusBar) then
                statusBar:SetHidden(true)
            end
        end
    end

    -- Adjust container size so the lines and text have something to anchor on the right
    if (highestTag == 0) then
        CrutchAlertsBossHealthBarContainer:SetWidth(36)
    else
        CrutchAlertsBossHealthBarContainer:SetWidth(highestTag * 36)
    end

    if (highestTag > 0) then
        DrawStages()
    else
        HideAllStages()
    end
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
        bossHealths = {}
        ShowOrHideBars()
    end
end
BHB.OnBossesChanged = OnBossesChanged
-- /script CrutchAlerts.BossHealthBar.OnBossesChanged()

---------------------------------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------------------------------
function BHB.Initialize()
    Crutch.dbgOther("|c88FFFF[CT]|r Initialized Boss Health Bar")
    EVENT_MANAGER:RegisterForEvent("CrutchAlertsBossHealthBarBossChange", EVENT_BOSSES_CHANGED, OnBossesChanged)
    EVENT_MANAGER:RegisterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
    EVENT_MANAGER:AddFilterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)

    -- TODO: shields
    CrutchAlertsBossHealthBarContainer:SetAnchor(TOPLEFT, GuiRoot, CENTER, 
        Crutch.savedOptions.bossHealthBarDisplay.x, Crutch.savedOptions.bossHealthBarDisplay.y)

    OnBossesChanged()
end
