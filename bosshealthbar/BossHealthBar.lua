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
local mechanicControls = {} -- { [1] = { active = true, percentage = control, mechanic = control, line = control, }, }

-- My elementary control pool. Gets index for percentage, mechanic, and line controls, or creates new ones if none available
local function GetUnusedControlsIndex()
    -- First check if any existing ones are free
    local index = 0
    for i, controls in ipairs(mechanicControls) do
        if (not controls.active) then
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
        active = false,
        percentage = percentageLabel,
        mechanic = mechanicLabel,
        line = lineControl,
    }

    return index
end

-- Returns the individual controls for a stage
local function GetStageControls()
    local controls = mechanicControls[GetUnusedControlsIndex()]
    controls.active = true
    return controls.percentage, controls.mechanic, controls.line
end

local function HideAllStages()
    for _, controls in ipairs(mechanicControls) do
        controls.active = false
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
        local percentageLabel, mechanicLabel, lineControl = GetStageControls()

        -- Number percentage on the left of the bar
        percentageLabel:SetAnchor(RIGHT, CrutchAlertsBossHealthBarContainer, TOPLEFT, -5, (100 - percentage) / 5 * 16)
        percentageLabel:SetText(tostring(percentage))
        percentageLabel:SetHidden(false)

        -- Mechanic text on the right of the bar
        mechanicLabel:SetAnchor(LEFT, CrutchAlertsBossHealthBarContainer, TOPRIGHT, 6, (100 - percentage) / 5 * 16)
        mechanicLabel:SetText(mechanic)
        mechanicLabel:SetHidden(false)

        -- Line marking the percentage through the bar
        lineControl:SetAnchor(TOPLEFT, CrutchAlertsBossHealthBarContainer, TOPLEFT, -4, (100 - percentage) / 5 * 16 + 1)
        lineControl:SetAnchor(BOTTOMRIGHT, CrutchAlertsBossHealthBarContainer, TOPRIGHT, 4, (100 - percentage) / 5 * 16 + 2)
        lineControl:SetHidden(false)
    end
end

---------------------------------------------------------------------------------------------------
-- When health changes
---------------------------------------------------------------------------------------------------
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
