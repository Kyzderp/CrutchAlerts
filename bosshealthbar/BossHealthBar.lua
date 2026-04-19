local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar

-- CrutchAlertsBossHealthBarContainerBar
-- ZO_StatusBar_SmoothTransition(self, value, max, forceInit, onStopCallback, customApproachAmountMs)
-- /script ZO_StatusBar_SmoothTransition(CrutchAlertsBossHealthBarContainerBar, 0, 1)
-- SetBarGradient
-- /script CrutchAlertsBossHealthBarContainerBar:SetGradientColors(1, 0, 0, 1, 0.5, 0, 0, 1)

-- I was really hoping to be able to use status bar gradient colors, but it seems to have really unexpected behavior with the vertical orientation

---------------------------------------------------------------------------------------------------
-- Boss spoofing
---------------------------------------------------------------------------------------------------
local spoofedBosses = {} -- {["boss3"] = {name = "Blazeforged Valneer", getHealthFunction = function() return powerValue, powerMax, powerEffectiveMax end}}

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


---------------------------------------------------------------------------------------------------
-- Threshold overrides, to be used when threshold determination is
-- more complicated than just a name match
---------------------------------------------------------------------------------------------------
local thresholdOverrides = {}
local function AddThresholdOverride(name, thresholds)
    thresholdOverrides[name] = thresholds
    for _, listener in pairs(BHB.thresholdsChangeListeners) do
        listener(name, true)
    end
end
BHB.AddThresholdOverride = AddThresholdOverride

local function RemoveThresholdOverride(name)
    if (thresholdOverrides[name]) then
        thresholdOverrides[name] = nil
        for _, listener in pairs(BHB.thresholdsChangeListeners) do
            listener(name, false)
        end
    end
end
BHB.RemoveThresholdOverride = RemoveThresholdOverride

local function GetThresholdOverride(name)
    return thresholdOverrides[name]
end
BHB.GetThresholdOverride = GetThresholdOverride


---------------------------------------------------------------------------------------------------
-- Util
---------------------------------------------------------------------------------------------------
local function dbg(msg)
    Crutch.dbgSpam(string.format("|c8888FF[BHB]|r %s", msg))
end

local function GetUnitNameIfExists(unitTag)
    if (spoofedBosses[unitTag]) then
        return spoofedBosses[unitTag].name
    end

    if (DoesUnitExist(unitTag)) then
        return GetUnitName(unitTag)
    end
end
BHB.GetUnitNameIfExists = GetUnitNameIfExists

local function GetUnitHealths(unitTag)
    if (spoofedBosses[unitTag]) then
        return spoofedBosses[unitTag].getHealthFunction()
    end
    return GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
end
BHB.GetUnitHealths = GetUnitHealths

-- See settings for a wall of text about why this matters
local function RoundHealth(num)
    if (Crutch.savedOptions.bossHealthBar.useFloorRounding) then
        return math.floor(num)
    else
        return zo_round(num)
    end
end

---------------------------------------------------------------------------------------------------
-- Scale is messy
---------------------------------------------------------------------------------------------------
local function GetScale()
    return Crutch.savedOptions.bossHealthBar.scale
end

local function GetScaledFont(size)
    return Crutch.GetStyles().GetBHBFont(size * GetScale())
end

---------------------------------------------------------------------------------------------------
-- Stages
---------------------------------------------------------------------------------------------------
-- individual: the tag if using multi boss1 boss2 etc to draw line on only that boss, nil otherwise
local mechanicControls = {} -- { [1] = { state = ACTIVE, percentNumber = 70, percentage = control, mechanic = control, line = control, individual = "boss1"}, }
local multiMechanics = {} -- {[percentNumber] = {mechanicControlsIndex, mechanicControlsIndex}}
local INACTIVE = "INACTIVE"
local ACTIVE = "ACTIVE"
local IMMINENT = "IMMINENT"
local PASSED = "PASSED"

local function DumpMechanicControls()
    d(mechanicControls)
    d("--------------")
    for i, mech in ipairs(mechanicControls) do
        d(string.format("[%d] %s - %d - %s", i, mech.state, mech.percentNumber, mech.individual or "all"))
    end
end
BHB.DumpMechanicControls = DumpMechanicControls -- /script CrutchAlerts.BossHealthBar.DumpMechanicControls()

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

    mechanicControls[index] = {
        state = ACTIVE,
        percentage = percentageLabel,
        mechanic = mechanicLabel,
        line = lineControl,
    }

    return index
end

-- Returns the individual controls for a stage
-- bossTag is usually nil, unless doing individual thresholds
local function CreateStageControl(percentage, bossTag)
    local controlIndex = GetUnusedControlsIndex()
    local controls = mechanicControls[controlIndex]
    controls.state = ACTIVE
    controls.percentNumber = percentage
    controls.individual = bossTag

    if (bossTag) then
        if (not multiMechanics[percentage]) then
            multiMechanics[percentage] = {}
        end
        table.insert(multiMechanics[percentage], controlIndex)
    end
    return controls.percentage, controls.mechanic, controls.line
end

local function HideAllStages()
    for _, controls in ipairs(mechanicControls) do
        controls.state = INACTIVE
        controls.percentage:SetHidden(true)
        controls.mechanic:SetHidden(true)
        controls.line:SetHidden(true)
    end
    ZO_ClearTable(multiMechanics)
end

-- It is possible for boss1 to die and have its health bar disappear
local function GetFirstValidBossTag()
    for i = 1, BOSS_RANK_ITERATION_END do
        local unitTag = "boss" .. tostring(i)
        if (DoesUnitExist(unitTag)) then
            return unitTag
        end
    end
    return ""
end
BHB.GetFirstValidBossTag = GetFirstValidBossTag


---------------------------------------------------------------------------------------------------
-- When health changes
---------------------------------------------------------------------------------------------------
local bossHealths = {} -- { [1] = {current = 7231, max = 329131,}, }

local function GetBossHealthFraction(id)
    -- Do not include spoofed bosses in stage highlighting
    local tag = "boss" .. tostring(id)
    if (spoofedBosses[tag]) then
        return 0
    end

    if (not bossHealths[id]) then
        return 0
    end

    return bossHealths[id].current / bossHealths[id].max
end

local function SetThresholdColor(control, settingsColor)
    control:SetColor(unpack(settingsColor))
end

----------
-- For multi-mechanics that are the same percent number, we keep track of all the mechanic controls
-- and should only display 1 number and 1 mechanic name label.
-- @return state, mechanicControlIndexToShow - latter can be nil
--[[
local mechanicControls = {} -- { [1] = { state = ACTIVE, percentNumber = 70, percentage = control, mechanic = control, line = control, individual = "boss1"}, }
local multiMechanics = {} -- {[percentNumber] = {mechanicControlsIndex, mechanicControlsIndex}}
]]
local function GetMultiMechanicHighlightInfo(percentageNumber, bossTag)
    local multiMechanic = multiMechanics[percentageNumber]

    -- If it's an individual mech without multiple of the same number, just treat it normally
    if (#multiMechanic == 1) then
        local mechanicControlsIndex = multiMechanic[1]
        local mechanicControl = mechanicControls[mechanicControlsIndex]
        return mechanicControl.state, mechanicControlsIndex
    end

    -- Go through all the associated mechanicControls...
    local allPassed = true
    local imminentIndex = nil
    local activeIndex = nil
    for _, mechanicControlsIndex in ipairs(multiMechanic) do
        local mechanicControl = mechanicControls[mechanicControlsIndex]
        if (mechanicControl.state == IMMINENT) then
            allPassed = false
            imminentIndex = mechanicControlsIndex
        end
        if (mechanicControl.state == ACTIVE) then
            allPassed = false
            activeIndex = mechanicControlsIndex
        end
    end

    if (allPassed) then
        -- If all of them are PASSED, the labels should also be shown as passed. Leave the last shown name.
        return PASSED, nil
    elseif (imminentIndex) then
        -- If at least one is IMMINENT, the labels should be shown as imminent. Show the imminent name.
        return IMMINENT, imminentIndex
    elseif (activeIndex) then
        -- If any are ACTIVE, the labels should be shown as active. Show any active name. Can vary depending on previously available mechanicControls slots.
        return ACTIVE, activeIndex
    end

    Crutch.dbgOther("|cFF0000multi mechanic highlight?? " .. percentageNumber .. " " .. bossTag)
    return ACTIVE, nil
end

-- Make stages that have already passed less obvious, and highlight imminent stages
-- TODO: add another type that deactivates after boss heals, e.g. vUG Hakgrym goes invuln and heals
-- at 6%, leaving the stage yellow
local function UpdateStagesWithBossHealth()
    -- Use the maximum health
    local highestHealth = 0
    for i = 1, BOSS_RANK_ITERATION_END do
        local hp = GetBossHealthFraction(i)
        if (hp > highestHealth) then
            highestHealth = hp
        end
    end
    highestHealth = RoundHealth(highestHealth * 100)

    -- First pass: just update the state; this is needed to determine multi threshold logic later
    for _, controls in ipairs(mechanicControls) do
        if (controls.state ~= INACTIVE) then
            -- Normally use highest health, but if it's individual threshold, use that boss
            local healthToCheck = highestHealth
            if (controls.individual) then
                local bossIndex = string.gsub(controls.individual, "boss", "")
                healthToCheck = RoundHealth(GetBossHealthFraction(tonumber(bossIndex)) * 100)
            end

            if (controls.state ~= PASSED and healthToCheck < controls.percentNumber - 1) then
                -- If the highest health is already more than 1% lower than mechanic, gray out mechanic
                controls.state = PASSED
                Crutch.dbgOther(string.format("%s now %s", controls.individual or "highest", controls.state))
            elseif (controls.state ~= IMMINENT
                and healthToCheck >= controls.percentNumber - 1
                and healthToCheck <= controls.percentNumber + 5) then
                -- If the highest health is within 5% above the mechanic or 1% just after, highlight it
                -- e.g. 75, 74, 73, 72, 71, 70, 69 % would display as yellow
                controls.state = IMMINENT
                Crutch.dbgOther(string.format("%s now %s", controls.individual or "highest", controls.state))
            end
            -- Don't redo the ones that have already passed,
            -- don't "clean" the ones that are still below the health,
            -- because if boss heals up, this would still leave them grayed out, which is good
        end
    end

    -- Second pass: update displays
    for index, controls in ipairs(mechanicControls) do
        if (controls.state ~= INACTIVE) then
            local labelsState = controls.state
            local showLabels = true

            -- If it's individual/multi (I need to name these consistently...)
            -- need more handling to not overlap multiple labels
            if (controls.individual) then
                local state, activeIndex = GetMultiMechanicHighlightInfo(controls.percentNumber, controls.individual)
                labelsState = state
                showLabels = activeIndex == index
            end

            -- Line highlights according to the control, ignoring multi mechanic
            local backdrop = controls.line:GetNamedChild("Backdrop")
            if (controls.state == PASSED) then
                backdrop:SetCenterColor(unpack(Crutch.savedOptions.bossHealthBar.passedColor))
                -- backdrop:SetEdgeColor(unpack(Crutch.savedOptions.bossHealthBar.passedColor))
            elseif (controls.state == IMMINENT) then
                backdrop:SetCenterColor(unpack(Crutch.savedOptions.bossHealthBar.imminentColor))
                -- backdrop:SetEdgeColor(unpack(Crutch.savedOptions.bossHealthBar.imminentColor))
            end -- Shouldn't ever need ACTIVE here because lines will never go naturally back to ACTIVE?

            -- Labels may be shown differently from the line
            if (labelsState == PASSED) then
                SetThresholdColor(controls.percentage, Crutch.savedOptions.bossHealthBar.passedColor)
                SetThresholdColor(controls.mechanic, Crutch.savedOptions.bossHealthBar.passedColor)
            elseif (labelsState == IMMINENT) then
                SetThresholdColor(controls.percentage, Crutch.savedOptions.bossHealthBar.imminentColor)
                SetThresholdColor(controls.mechanic, Crutch.savedOptions.bossHealthBar.imminentColor)
            elseif (controls.state == ACTIVE) then
                SetThresholdColor(controls.percentage, Crutch.savedOptions.bossHealthBar.activeColor)
                SetThresholdColor(controls.mechanic, Crutch.savedOptions.bossHealthBar.activeColor)
            end

            controls.percentage:SetHidden(not showLabels)
            controls.mechanic:SetHidden(not showLabels)
        end
    end
end

local DEFAULT_STAGES = {
    [75] = "",
    [50] = "",
    [25] = "",
}

local function DrawStage(percentage, mechanic, bossTag)
    local percentageLabel, mechanicLabel, lineControl = CreateStageControl(percentage, bossTag)

    -- Since mechanics almost always trigger when floor rounding is that percentage, add 0.99 here
    -- to raise the mechanic line enough so that the status bar lines up with the mechanic line
    -- when the floored percent number would say that threshold
    local barHeight = 320 * GetScale()
    local stageYOffset = zo_clamp(100 - percentage - 0.99, 0, 100) / 100 * barHeight

    -- Number percentage on the left of the bar
    percentageLabel:ClearAnchors()
    percentageLabel:SetAnchor(RIGHT, CrutchAlertsBossHealthBarContainer, TOPLEFT, -5 * GetScale(), stageYOffset)
    percentageLabel:SetFont(GetScaledFont(14))
    percentageLabel:SetText(tostring(percentage))
    percentageLabel:SetWidth(40 * GetScale())
    percentageLabel:SetWidth(percentageLabel:GetTextWidth())
    percentageLabel:SetHeight(16 * GetScale())
    percentageLabel:SetColor(unpack(Crutch.savedOptions.bossHealthBar.activeColor))
    percentageLabel:SetHidden(false)
    if (Crutch.savedOptions.bossHealthBar.horizontal) then
        percentageLabel:SetTransformRotationZ(math.pi / 2)
    else
        percentageLabel:SetTransformRotationZ(0)
    end

    -- Mechanic text on the right of the bar
    mechanicLabel:ClearAnchors()
    mechanicLabel:SetAnchor(LEFT, CrutchAlertsBossHealthBarContainer, TOPRIGHT, 6 * GetScale(), stageYOffset)
    mechanicLabel:SetWidth(600 * GetScale())
    mechanicLabel:SetHeight(16 * GetScale())
    mechanicLabel:SetFont(GetScaledFont(14))
    mechanicLabel:SetText(mechanic)
    mechanicLabel:SetColor(unpack(Crutch.savedOptions.bossHealthBar.activeColor))
    mechanicLabel:SetHidden(false)

    -- Line marking the percentage through the bar
    lineControl:ClearAnchors()

    if (not bossTag) then
        lineControl:SetAnchor(TOPLEFT, CrutchAlertsBossHealthBarContainer, TOPLEFT, -4 * GetScale(), stageYOffset)
        lineControl:SetAnchor(TOPRIGHT, CrutchAlertsBossHealthBarContainer, TOPRIGHT, 4 * GetScale(), stageYOffset)
    else
        local index = string.gsub(bossTag, "boss", "")
        index = tonumber(index)

        local statusBar = CrutchAlertsBossHealthBarContainer:GetNamedChild("Bar" .. tostring(index))
        if (index == 1) then
            lineControl:SetAnchor(TOPLEFT, CrutchAlertsBossHealthBarContainer, TOPLEFT, -4 * GetScale(), stageYOffset)
        else
            lineControl:SetAnchor(TOPLEFT, statusBar, TOPLEFT, -2 * GetScale(), stageYOffset)
        end

        if (index == 2) then -- TODO: not good for more than 2 bosses
            lineControl:SetAnchor(TOPRIGHT, CrutchAlertsBossHealthBarContainer, TOPRIGHT, 4 * GetScale(), stageYOffset)
        else
            lineControl:SetAnchor(TOPRIGHT, statusBar, TOPRIGHT, 2 * GetScale(), stageYOffset)
        end
    end

    -- Some funky line thickness stuff, because at too small of a UI scale, the line could become
    -- invisible. Setting constraints doesn't quite work, because the lines can appear different
    -- thicknesses and it looks ugly. So calculate based on UI and BHB scale, and set it in px.
    local lineThiccness = math.max(1, math.ceil(GetUIGlobalScale() * GetScale()))
    lineControl:SetHeight(lineThiccness .. "px")
    lineControl:GetNamedChild("Backdrop"):SetCenterColor(unpack(Crutch.savedOptions.bossHealthBar.activeColor))
    -- lineControl:GetNamedChild("Backdrop"):SetEdgeColor(unpack(Crutch.savedOptions.bossHealthBar.activeColor))
    lineControl:SetHidden(false)
end

-- Draw number on the left, line through the bars, and text on the right for each boss stage threshold
-- optionalBossName: If specified, uses the threshold data for that name instead of auto-detect first boss
local function RedrawStages(optionalBossName)
    HideAllStages()

    local data = BHB.GetBossThresholds(optionalBossName)
    if (not data) then
        data = DEFAULT_STAGES
    end

    -- For encounters that have different stages for each boss, care only about the individual stages
    -- TODO: or are there encounters where we do care about both kinds?
    local isMulti = false
    for i = 1, BOSS_RANK_ITERATION_END do
        local unitTag = "boss" .. tostring(i)
        if (data[unitTag]) then
            isMulti = true
            for percentage, mechanic in pairs(data[unitTag]) do
                if (type(percentage) == "number") then
                    DrawStage(percentage, mechanic, unitTag)
                end
            end
        end
    end
    if (isMulti) then return end

    -- Create the controls and set the properties
    for percentage, mechanic in pairs(data) do
        if (type(percentage) == "number") then -- Obv can't do stages for "vetHealth" etc.
            DrawStage(percentage, mechanic, bossTag)
        end
    end
end

local function OnThresholdsChanged(name, isAdded)
    if (GetFirstValidBossTag() ~= "") then
        RedrawStages()
    end
end

local logNextPowerUpdate = 0 -- Used to log the next X health updates after max health change because sometimes the stages get grayed out :angy:
local powerUpdateDebug = false -- Manual enabling of health update spam

-- EVENT_POWER_UPDATE (number eventCode, string unitTag, number powerIndex, CombatMechanicType powerType, number powerValue, number powerMax, number powerEffectiveMax)
local function OnPowerUpdate(_, unitTag, _, _, powerValue, powerMax, powerEffectiveMax)
    -- Still not sure the difference between powerMax and powerEffectiveMax...
    local index = tonumber(unitTag:sub(5, 5))
    local statusBar = CrutchAlertsBossHealthBarContainer:GetNamedChild("Bar" .. tostring(index))
    if (statusBar) then
        -- ZO_StatusBar_SmoothTransition(self, value, max, forceInit, onStopCallback, customApproachAmountMs)
        ZO_StatusBar_SmoothTransition(statusBar, powerValue, powerMax)
        local roundedPercent = RoundHealth(powerValue * 100 / powerMax)
        local percentText = zo_strformat("<<1>>%", tostring(roundedPercent))
        statusBar:GetNamedChild("Percent"):SetText(percentText)

        -- The attached percent label needs an animation, otherwise it looks choppy
        local attachedPercent = statusBar:GetNamedChild("AttachedPercent")
        attachedPercent:SetText(percentText)
        local _, originY = attachedPercent:GetCenter()
        local targetY
        if (Crutch.savedOptions.bossHealthBar.horizontal) then
            targetY = statusBar:GetTop() + (100 - roundedPercent) / 5 * 16 * GetScale() - 18 * GetScale()
        else
            targetY = statusBar:GetTop() + (100 - roundedPercent) / 5 * 16 * GetScale() - 12 * GetScale()
        end
        attachedPercent.slide:SetDeltaOffsetX(0)
        attachedPercent.slide:SetDeltaOffsetY(targetY - originY)
        attachedPercent.slideAnimation:PlayFromStart()

        -- TODO: figure out if any bosses change in max health during the fight.
        -- Otherwise, we can naively use this as a HM detector (and therefore NOT update stages)

        if (bossHealths[index]) then
            local prevValue = bossHealths[index].current
            local prevMax = bossHealths[index].max

            if (logNextPowerUpdate > 0) then
                Crutch.dbgSpam(string.format("|cFFFF00[BHB]|r boss %d changed (%d -> %d) / (%d -> %d) {%d} [logNextPowerUpdate %d]",
                    index, prevValue, powerValue, prevMax, powerMax, powerEffectiveMax, logNextPowerUpdate))
                logNextPowerUpdate = logNextPowerUpdate - 1
            elseif (powerUpdateDebug and powerValue ~= prevValue) then
                Crutch.dbgSpam(string.format("|c64e1fa[BHB]|r %s (boss%d) %.1fk || |c64e1fa%s|r / |c64e1fa%s|r (|c64e1fa%.3f|r)",
                    GetUnitNameIfExists(unitTag), index, (powerValue - prevValue) / 1000,
                    ZO_CommaDelimitDecimalNumber(powerValue), ZO_CommaDelimitDecimalNumber(powerMax), powerValue * 100 / powerMax))
            end

            -- Also fixes the persistent highlighting bug when reticle is over the boss when it respawns
            if (powerValue == prevValue and powerMax == prevMax) then
                -- Crutch.dbgSpam("no actual change??")
                return
            end

            if (powerMax > prevMax) then
                -- The boss' max health increased, meaning turning on HM
                Crutch.dbgSpam(string.format("|cFF0000[BHB] boss %d MAX INCREASE|r %d / %d -> %d",
                    index, powerValue, prevMax, powerMax))
                logNextPowerUpdate = 5
                
                -- Do not update stages, and wait for the next event (heal) to change the stages instead
                bossHealths[index] = {current = powerValue, max = powerMax} -- Do NOT delete this, prevMax bases off this
                RedrawStages()
                return
            elseif (powerMax < prevMax) then
                -- The boss' max health decreased, meaning turning off HM
                Crutch.dbgSpam(string.format("|c00FFFF[BHB] boss %d MAX DECREASE|r %d / %d -> %d",
                    index, powerValue, prevMax, powerMax))
                logNextPowerUpdate = 5

                -- Do not update stages, and wait for the next event (heal) to change the stages instead
                bossHealths[index] = {current = powerValue, max = powerMax} -- Do NOT delete this, prevMax bases off this
                RedrawStages()
                return
            end

            if (powerValue > prevValue) then
                -- The boss healed :O This debug doesn't seem that useful, many bosses seem to "heal" very small amounts... not sure why
                -- Crutch.dbgSpam(string.format("|cFFFF00[BHB]|r boss %d healed %d -> %d",
                --     index, prevValue, powerValue))
            end
        end

        bossHealths[index] = {current = powerValue, max = powerMax}
        UpdateStagesWithBossHealth()
    end
end

local function UpdateSpoofedBossHealth(unitTag, value, max)
    OnPowerUpdate(nil, unitTag, nil, nil, value, max, max)
end
Crutch.UpdateSpoofedBossHealth = UpdateSpoofedBossHealth

--[[
/script CrutchAlerts.SpoofBoss("boss3", "yeetus", function() return 28394, 32939, 32939 end,
        {230/256, 129/256, 34/256, 0.73},
        {18/256, 9/256, 1/256, 0.66})
/script CrutchAlerts.UpdateSpoofedBossHealth("boss3", 4939, 32939)
/script CrutchAlerts.UnspoofBoss("boss3")
]]

local function ToggleHealthDebug()
    powerUpdateDebug = not powerUpdateDebug
    d(powerUpdateDebug)
end
Crutch.ToggleHealthDebug = ToggleHealthDebug
-- /script CrutchAlerts.ToggleHealthDebug()

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
        SetBarColors(index, nil, nil)
        dbg("Created new control Bar" .. tostring(index))
    end
    -- Scale-related changes
    statusBar:SetWidth(30 * GetScale())
    statusBar:SetHeight(320 * GetScale())
    statusBar:ClearAnchors()
    statusBar:SetAnchor(TOPLEFT, CrutchAlertsBossHealthBarContainer, TOPLEFT, (index - 1) * 36 * GetScale() + 2 * GetScale())

    statusBar:GetNamedChild("Backdrop"):ClearAnchors()
    statusBar:GetNamedChild("Backdrop"):SetAnchor(TOPLEFT, statusBar, TOPLEFT, -2 * GetScale(), -2 * GetScale())
    statusBar:GetNamedChild("Backdrop"):SetAnchor(BOTTOMRIGHT, statusBar, BOTTOMRIGHT, 2 * GetScale(), 2 * GetScale())

    statusBar:GetNamedChild("BossName"):SetFont(GetScaledFont(16))
    statusBar:GetNamedChild("BossName"):SetWidth(200 * GetScale())
    statusBar:GetNamedChild("BossName"):SetHeight(20 * GetScale())
    statusBar:GetNamedChild("BossName"):ClearAnchors()
    statusBar:GetNamedChild("BossName"):SetAnchor(CENTER, statusBar, BOTTOM, 0, -104 * GetScale())

    statusBar:GetNamedChild("Percent"):SetFont(GetScaledFont(15))
    statusBar:GetNamedChild("Percent"):SetWidth(40 * GetScale())
    statusBar:GetNamedChild("Percent"):SetHeight(16 * GetScale())
    statusBar:GetNamedChild("Percent"):ClearAnchors()
    if (Crutch.savedOptions.bossHealthBar.horizontal) then
        statusBar:GetNamedChild("Percent"):SetAnchor(TOP, statusBar, BOTTOM, 0, 10 * GetScale())
        statusBar:GetNamedChild("Percent"):SetTransformRotationZ(math.pi / 2)
    else
        statusBar:GetNamedChild("Percent"):SetAnchor(TOP, statusBar, BOTTOM, 0, 2 * GetScale())
        statusBar:GetNamedChild("Percent"):SetTransformRotationZ(0)
    end

    statusBar:GetNamedChild("AttachedPercent"):SetFont(GetScaledFont(15))
    statusBar:GetNamedChild("AttachedPercent"):SetWidth(40 * GetScale())
    statusBar:GetNamedChild("AttachedPercent"):SetHeight(16 * GetScale())
    statusBar:GetNamedChild("AttachedPercent"):ClearAnchors()
    if (Crutch.savedOptions.bossHealthBar.horizontal) then
        statusBar:GetNamedChild("AttachedPercent"):SetAnchor(CENTER, statusBar, TOP, 0, -18 * GetScale())
        statusBar:GetNamedChild("AttachedPercent"):SetTransformRotationZ(math.pi / 2)
    else
        statusBar:GetNamedChild("AttachedPercent"):SetAnchor(CENTER, statusBar, TOP, 0, -12 * GetScale())
        statusBar:GetNamedChild("AttachedPercent"):SetTransformRotationZ(0)
    end

    statusBar:SetHidden(false)

    return statusBar
end

-- Shows or hides hp bars for each bossX unit. It may be possible for bosses to disappear,
-- leaving a gap (e.g. Reef Guardian), so we can't just base it on number of bosses.
-- onlyReanchorStages: Some fights like Reef Guardian trigger BOSSES_CHANGED when one dies.
--                     We don't want to redraw the stages for that.
local function ShowOrHideBars(showAllForMoving, onlyReanchorStages)
    local highestTag = 0

    for i = 1, BOSS_RANK_ITERATION_END do
        local unitTag = "boss" .. tostring(i)
        local name = GetUnitNameIfExists(unitTag)
        if (showAllForMoving) then
            name = "Example Boss " .. tostring(i)
        end
        if (name and name ~= "") then
            highestTag = i
            local statusBar = GetOrCreateStatusBar(i)

            -- Also need to manually update the boss health to initialize
            local powerValue, powerMax, powerEffectiveMax = GetUnitHealths(unitTag)
            if (showAllForMoving) then
                -- Example for moving
                powerMax = 1

                -- Show shield and invuln on 1 each only
                if (i == 4) then
                    name = "Shielded Boss 4"
                    powerValue = 0.4
                    BHB.UpdateBar(unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, false, 0.7, 1)
                    BHB.UpdateBar(unitTag, ATTRIBUTE_VISUAL_UNWAVERING_POWER, true, 0, 1)
                elseif (i == 5) then
                    name = "Invulnerable Boss 5"
                    powerValue = 0.6
                    BHB.UpdateBar(unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, true, 0, 1)
                    BHB.UpdateBar(unitTag, ATTRIBUTE_VISUAL_UNWAVERING_POWER, false, 1, 1)
                else
                    powerValue = math.random()
                    BHB.UpdateBar(unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, true, 0, 1)
                    BHB.UpdateBar(unitTag, ATTRIBUTE_VISUAL_UNWAVERING_POWER, true, 0, 1)
                end
            else
                -- Real tags
                BHB.UpdateAttributeVisuals(unitTag)
            end
            statusBar:GetNamedChild("BossName"):SetText(name)
            dbg(string.format("%s (%s) value: %d max: %d effectiveMax: %d", name, unitTag, powerValue, powerMax, powerEffectiveMax))
            OnPowerUpdate(nil, unitTag, nil, nil, powerValue, powerMax, powerEffectiveMax)
        else
            bossHealths[i] = nil -- Clean lingering after unlock
            local statusBar = CrutchAlertsBossHealthBarContainer:GetNamedChild("Bar" .. tostring(i))
            if (statusBar) then
                statusBar:SetHidden(true)
            end
        end
    end

    -- Adjust container size so the lines and text have something to anchor on the right
    if (highestTag == 0) then
        CrutchAlertsBossHealthBarContainer:SetWidth(36 * GetScale())
    else
        CrutchAlertsBossHealthBarContainer:SetWidth(highestTag * 36 * GetScale())
    end

    if (highestTag > 0) then
        if (not onlyReanchorStages) then
            if (showAllForMoving) then
                RedrawStages("Example Boss 1")
                UpdateStagesWithBossHealth()
            else
                RedrawStages()
            end
        end
    else
        HideAllStages()
    end
end
BHB.ShowOrHideBars = ShowOrHideBars
-- /script CrutchAlerts.BossHealthBar.ShowOrHideBars(1)

local function OnBossesChanged(boss1IsSame)
    -- If boss1 has not changed, don't redraw stages, because some fights like Reef Guardian triggers bosses changed when a new one spawns. The stages' anchors get automatically updated because they're based on the container
    -- Note: I say "boss1" but actually use GetFirstValidBossTag() because Felms and Llothis (on their own) are both "boss2" for some reason, so "boss1" does not exist at all for those encounters. This caused the mechanics lines to not show up and potentially affected the NaN or too many anchors issues
    if (boss1IsSame) then
        ShowOrHideBars(false, true)
    else
        ShowOrHideBars()
    end
end
BHB.OnBossesChanged = OnBossesChanged
-- /script CrutchAlerts.BossHealthBar.OnBossesChanged()

-- TODO: check if there are any bosses that don't despawn and respawn when you wipe?


---------------------------------------------------------------------------------------------------
-- Style refresh
---------------------------------------------------------------------------------------------------
local function UpdateScale(showAllForMoving)
    if (showAllForMoving == nil) then showAllForMoving = true end

    CrutchAlertsBossHealthBarContainer:SetHeight(320 * GetScale())
    OnBossesChanged()
    ShowOrHideBars(showAllForMoving)
end
BHB.UpdateScale = UpdateScale

local function UpdateColors()
    ShowOrHideBars(true)
    for i = 1, BOSS_RANK_ITERATION_END do
        SetBarColors(i, nil, nil)
    end
end
BHB.UpdateColors = UpdateColors

local function UpdateRotation(showAllForMoving)
    -- Rotate from top left corner, because center is different depending on how many bosses
    CrutchAlertsBossHealthBarContainer:SetTransformNormalizedOriginPoint(0, 0)
    if (Crutch.savedOptions.bossHealthBar.horizontal) then
        CrutchAlertsBossHealthBarContainer:SetTransformRotationZ(-math.pi/2)
    else
        -- Default vertical
        CrutchAlertsBossHealthBarContainer:SetTransformRotationZ(0)
    end
    if (showAllForMoving) then
        ShowOrHideBars(showAllForMoving)
    end
end
BHB.UpdateRotation = UpdateRotation


---------------------------------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------------------------------
local bhbFragment = nil

local function RegisterEvents()
    Crutch.RegisterBossChangedListener("CrutchBHBBossChange", OnBossesChanged)
    BHB.RegisterThresholdsChangeListener("CrutchBHBThresholdsChange", OnThresholdsChanged)

    EVENT_MANAGER:RegisterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
    EVENT_MANAGER:AddFilterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
end

-- Don't want event overload if the health bars are off
local function UnregisterEvents()
    Crutch.dbgOther("|c88FFFF[CT]|r Unregistering Boss Health Bar events")

    Crutch.UnregisterBossChangedListener("CrutchBHBBossChange")
    BHB.UnregisterThresholdsChangeListener("CrutchBHBThresholdsChange")

    EVENT_MANAGER:UnregisterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE)
end

-- Entry point
function BHB.Initialize()
    Crutch.dbgOther("|c88FFFF[CT]|r Initializing Boss Health Bar")

    CrutchAlertsBossHealthBarContainer:ClearAnchors()
    CrutchAlertsBossHealthBarContainer:SetAnchor(TOPLEFT, GuiRoot, CENTER, 
        Crutch.savedOptions.bossHealthBarDisplay.x, Crutch.savedOptions.bossHealthBarDisplay.y)
    UpdateRotation()

    -- Display only on HUD/HUD_UI
    if (not bhbFragment) then
        bhbFragment = ZO_SimpleSceneFragment:New(CrutchAlertsBossHealthBarContainer)
    end

    if (Crutch.savedOptions.bossHealthBar.enabled) then
        HUD_SCENE:AddFragment(bhbFragment)
        HUD_UI_SCENE:AddFragment(bhbFragment)
        RegisterEvents()
        BHB.RegisterVisualizers()
        OnBossesChanged()
        ShowOrHideBars()
    else
        HUD_SCENE:RemoveFragment(bhbFragment)
        HUD_UI_SCENE:RemoveFragment(bhbFragment)
        UnregisterEvents()
        BHB.UnregisterVisualizers()
    end
    CrutchAlertsBossHealthBarContainer:SetHidden(not Crutch.savedOptions.bossHealthBar.enabled)

    -- TODO: skull when dead?
    -- TODO: remove attached % when dead?
    -- TODO: larger scale 0 <- I have no idea what I meant when I wrote this
end
