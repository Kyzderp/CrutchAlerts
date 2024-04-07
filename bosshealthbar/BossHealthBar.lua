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

local function GetUnitNameIfExists(unitTag)
    if (DoesUnitExist(unitTag)) then
        return GetUnitName(unitTag)
    end
end

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
    return string.format("$(BOLD_FONT)|%d|shadow", math.floor(size * GetScale()))
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

-- It is possible for boss1 to die and have its health bar disappear
local function GetFirstValidBossTag()
    for i = 1, MAX_BOSSES do
        local unitTag = "boss" .. tostring(i)
        if (DoesUnitExist(unitTag)) then
            return unitTag
        end
    end
    return ""
end

-- Check Thresholds.lua for boss stages
-- optionalBossName: If specified, uses the threshold data for that name instead of auto-detect boss1
local function GetBossThresholds(optionalBossName)
    local bossName = zo_strformat(SI_UNIT_NAME, optionalBossName or GetUnitName(GetFirstValidBossTag()))
    local data
    if (GetZoneId(GetUnitZoneIndex("player")) == 1436) then
        -- Endless Archive has different boss thresholds
        data = BHB.eaThresholds[bossName] -- or BHB.eaThresholds[BHB.aliases[bossName]]
    else
        data = BHB.thresholds[bossName] -- or BHB.thresholds[BHB.aliases[bossName]]
    end

    -- Detect HM or vet or normal first based on boss health
    -- If not found, prioritize HM, then vet, and finally whatever data there is
    -- If there's no stages, do a default 75, 50, 25
    local _, powerMax, _ = GetUnitPower(GetFirstValidBossTag(), POWERTYPE_HEALTH)
    if (not data) then
        dbg(string.format("No data found for %s, using default", bossName))
        data = {
            [75] = "",
            [50] = "",
            [25] = "",
        }
    elseif (powerMax == data.hmHealth and data.Hardmode) then
        dbg(string.format("%s hp matched HARDMODE %d", bossName, powerMax))
        data = data.Hardmode
    elseif (powerMax == data.vetHealth and data.Veteran) then
        dbg(string.format("%s hp matched VETERAN %d", bossName, powerMax))
        data = data.Veteran
    elseif (powerMax == data.normHealth and data.Normal) then
        dbg(string.format("%s hp matched NORMAL %d", bossName, powerMax))
        data = data.Normal
    elseif (data.Hardmode) then
        dbg(string.format("No hp match for %s %d, but found Hardmode data", bossName, powerMax))
        data = data.Hardmode
    elseif (data.Veteran) then
        dbg(string.format("No hp match for %s %d, but found Veteran data", bossName, powerMax))
        data = data.Veteran
    elseif (data.Normal) then
        dbg(string.format("No hp match for %s %d, but found Normal data", bossName, powerMax))
        data = data.Normal
    else
        dbg(string.format("No difficulty data found for %s %d", bossName, powerMax))
    end

    return data
end


---------------------------------------------------------------------------------------------------
-- When health changes
---------------------------------------------------------------------------------------------------
local bossHealths = {} -- { [1] = {current = 7231, max = 329131,}, }

local function GetBossHealth(id)
    if (not bossHealths[id]) then
        return 0
    end

    return bossHealths[id].current / bossHealths[id].max
end

-- Make stages that have already passed less obvious, and maybe highlight imminent stages
-- Currently this doesn't really work well for encounters with multiple bosses, because I check
-- both boss' health and take the maximum, and gray out things that haven't passed that. This means
-- for things like Ly+Turli, the ticks don't get grayed out until both are < 70/65. Not yet sure of
-- a good way to represent this in the data
-- TODO: maybe add an optional "type" to the mechanic? if it's set to "single" or whatever, gray it
-- when one boss passes?
-- TODO: add another type that deactivates after boss heals, e.g. vUG Hakgrym goes invuln and heals
-- at 6%, leaving the stage yellow
local function UpdateStagesWithBossHealth()
    -- Use the maximum health
    local highestHealth = math.max(
        GetBossHealth(1),
        GetBossHealth(2),
        GetBossHealth(3),
        GetBossHealth(4),
        GetBossHealth(5),
        GetBossHealth(6)
        )
    highestHealth = RoundHealth(highestHealth * 100)

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

-- Draw number on the left, line through the bars, and text on the right for each boss stage threshold
-- optionalBossName: If specified, uses the threshold data for that name instead of auto-detect first boss
local function RedrawStages(optionalBossName)
    HideAllStages()

    local data = GetBossThresholds(optionalBossName)

    -- Create the controls and set the properties
    for percentage, mechanic in pairs(data) do
        if (type(percentage) == "number") then -- Obv can't do stages for "vetHealth" etc.
            local percentageLabel, mechanicLabel, lineControl = CreateStageControl(percentage)

            -- Number percentage on the left of the bar
            percentageLabel:ClearAnchors()
            percentageLabel:SetAnchor(RIGHT, CrutchAlertsBossHealthBarContainer, TOPLEFT, -5 * GetScale(), (100 - percentage) / 5 * 16 * GetScale())
            percentageLabel:SetWidth(40 * GetScale())
            percentageLabel:SetHeight(16 * GetScale())
            percentageLabel:SetFont(GetScaledFont(14))
            percentageLabel:SetText(tostring(percentage))
            percentageLabel:SetColor(0.53, 0.53, 0.53)
            percentageLabel:SetHidden(false)

            -- Mechanic text on the right of the bar
            mechanicLabel:ClearAnchors()
            mechanicLabel:SetAnchor(LEFT, CrutchAlertsBossHealthBarContainer, TOPRIGHT, 6 * GetScale(), (100 - percentage) / 5 * 16 * GetScale())
            mechanicLabel:SetWidth(600 * GetScale())
            mechanicLabel:SetHeight(16 * GetScale())
            mechanicLabel:SetFont(GetScaledFont(14))
            mechanicLabel:SetText(mechanic)
            mechanicLabel:SetColor(0.53, 0.53, 0.53, 1)
            mechanicLabel:SetHidden(false)

            -- Line marking the percentage through the bar
            lineControl:ClearAnchors()
            lineControl:SetAnchor(TOPLEFT, CrutchAlertsBossHealthBarContainer, TOPLEFT, -4 * GetScale(), (100 - percentage) / 5 * 16 * GetScale() + 1)
            lineControl:SetAnchor(BOTTOMRIGHT, CrutchAlertsBossHealthBarContainer, TOPRIGHT, 4 * GetScale(), (100 - percentage) / 5 * 16 * GetScale() + 2 * GetScale())
            lineControl:GetNamedChild("Backdrop"):SetCenterColor(0.53, 0.53, 0.53, 0.67)
            lineControl:GetNamedChild("Backdrop"):SetEdgeColor(0.53, 0.53, 0.53, 0.67)
            lineControl:SetHidden(false)
        end
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
        local targetY = statusBar:GetTop() + (100 - roundedPercent) / 5 * 16 * GetScale() - 12 * GetScale()
        attachedPercent.slide:SetDeltaOffsetX(0)
        attachedPercent.slide:SetDeltaOffsetY(targetY - originY)
        attachedPercent.slideAnimation:PlayFromStart()

        -- TODO: figure out if any bosses change in max health during the fight.
        -- Otherwise, we can naively use this as a HM detector (and therefore NOT update stages)

        if (bossHealths[index]) then
            local prevValue = bossHealths[index].current
            local prevMax = bossHealths[index].max

            if (logNextPowerUpdate > 0) then
                Crutch.dbgSpam(string.format("|cFFFF00[BHB]|r boss %d changed %d -> %d [logNextPowerUpdate %d]",
                    index, prevValue, powerValue, logNextPowerUpdate))
                logNextPowerUpdate = logNextPowerUpdate - 1
            elseif (powerUpdateDebug and powerValue ~= prevValue) then
                Crutch.dbgSpam(string.format("|c64e1fa[BHB]|r %s (boss%d) %.1fk || |c64e1fa%s|r / |c64e1fa%s|r (|c64e1fa%.3f|r)",
                    GetUnitName(unitTag), index, (powerValue - prevValue) / 1000,
                    ZO_LocalizeDecimalNumber(powerValue), ZO_LocalizeDecimalNumber(powerMax), powerValue * 100 / powerMax))
            end

            if (powerMax > prevMax) then
                -- The boss' max health increased, meaning turning on HM
                Crutch.dbgSpam(string.format("|cFF0000[BHB] boss %d MAX INCREASE|r %d -> %d",
                    index, prevMax, powerMax))
                logNextPowerUpdate = 5
                
                -- Do not update stages, and wait for the next event (heal) to change the stages instead
                bossHealths[index] = {current = powerValue, max = powerMax} -- Do NOT delete this, prevMax bases off this
                RedrawStages()
                return
            elseif (powerMax < prevMax) then
                -- The boss' max health decreased, meaning turning off HM
                Crutch.dbgSpam(string.format("|c00FFFF[BHB] boss %d MAX DECREASE|r %d -> %d",
                    index, prevMax, powerMax))
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
        dbg("Created new control Bar" .. tostring(index))
    end
    -- Scale-related changes
    statusBar:SetWidth(30 * GetScale())
    statusBar:SetHeight(320 * GetScale())
    statusBar:ClearAnchors()
    statusBar:SetAnchor(TOPLEFT, CrutchAlertsBossHealthBarContainer, TOPLEFT, (index - 1) * 36 * GetScale() + 2 * GetScale(), 2 * GetScale())

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
    statusBar:GetNamedChild("Percent"):SetAnchor(TOP, statusBar, BOTTOM, 0, 2 * GetScale())

    statusBar:GetNamedChild("AttachedPercent"):SetFont(GetScaledFont(15))
    statusBar:GetNamedChild("AttachedPercent"):SetWidth(40 * GetScale())
    statusBar:GetNamedChild("AttachedPercent"):SetHeight(16 * GetScale())
    statusBar:GetNamedChild("AttachedPercent"):ClearAnchors()
    statusBar:GetNamedChild("AttachedPercent"):SetAnchor(CENTER, statusBar, TOP, 0, -12 * GetScale())

    statusBar:SetHidden(false)

    return statusBar
end

-- Shows or hides hp bars for each bossX unit. It may be possible for bosses to disappear,
-- leaving a gap (e.g. Reef Guardian), so we can't just base it on number of bosses.
-- onlyReanchorStages: Some fights like Reef Guardian trigger BOSSES_CHANGED when one dies.
--                     We don't want to redraw the stages for that.
local function ShowOrHideBars(showAllForMoving, onlyReanchorStages)
    local highestTag = 0

    for i = 1, MAX_BOSSES do
        local unitTag = "boss" .. tostring(i)
        local name = GetUnitNameIfExists(unitTag)
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
            dbg(string.format("%s (%s) value: %d max: %d effectiveMax: %d", name, unitTag, powerValue, powerMax, powerEffectiveMax))
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

local prevBosses = ""
local prevBoss1 = ""
local function OnBossesChanged()
    local bossHash = ""

    for i = 1, MAX_BOSSES do
        local name = GetUnitNameIfExists("boss" .. tostring(i))
        if (name and name ~= "") then
            bossHash = bossHash .. name
        end
    end

    -- There's no need to redraw the bars if bosses didn't change, which sometimes fires the event anyway for some reason
    if (bossHash ~= prevBosses) then
        prevBosses = bossHash
        local boss1 = GetUnitName(GetFirstValidBossTag()) or ""
        bossHealths = {}

        -- If boss1 has not changed, don't redraw stages, because some fights like Reef Guardian triggers bosses changed when a new one spawns. The stages' anchors get automatically updated because they're based on the container
        -- Note: I say "boss1" but actually use GetFirstValidBossTag() because Felms and Llothis (on their own) are both "boss2" for some reason, so "boss1" does not exist at all for those encounters. This caused the mechanics lines to not show up and potentially affected the NaN or too many anchors issues
        if (prevBoss1 == boss1) then
            ShowOrHideBars(false, true)
        else
            ShowOrHideBars()
        end
    end
end
BHB.OnBossesChanged = OnBossesChanged
-- /script CrutchAlerts.BossHealthBar.OnBossesChanged()

-- TODO: check if there are any bosses that don't despawn and respawn when you wipe?


---------------------------------------------------------------------------------------------------
-- First time BHB
---------------------------------------------------------------------------------------------------
local function DisplayWarning()
    local warningText = "CrutchAlerts has a new feature: vertical boss health bars with mechanic markers. It's still a work in progress, but I'd recommend adjusting the location on your UI or toggling it if you don't want it, before it gets in your way in real content!\nSettings > Addons > CrutchAlerts > Unlock UI / Vertical Boss Health Bar Settings."

    if (not LibDialog) then
        CHAT_SYSTEM:AddMessage(warningText)
        return
    end

    LibDialog:RegisterDialog(
        Crutch.name,
        "BHBFirstTimeWarning",
        "Vertical Boss Health Bars",
        warningText .. "\n\nGo to settings now?",
        function() LibAddonMenu2:OpenToPanel(Crutch.addonPanel) end,
        nil,
        nil,
        true)
    LibDialog:ShowDialog(Crutch.name, "BHBFirstTimeWarning")
end
BHB.DisplayWarning = DisplayWarning


---------------------------------------------------------------------------------------------------
-- Scale, pt. 2
---------------------------------------------------------------------------------------------------
local function UpdateScale()
    CrutchAlertsBossHealthBarContainer:SetHeight(324 * GetScale())
    OnBossesChanged()
    ShowOrHideBars(true)
end
BHB.UpdateScale = UpdateScale

---------------------------------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------------------------------
local bhbFragment = nil

local function RegisterEvents()
    EVENT_MANAGER:RegisterForEvent("CrutchAlertsBossHealthBarBossChange", EVENT_BOSSES_CHANGED, OnBossesChanged)

    EVENT_MANAGER:RegisterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
    EVENT_MANAGER:AddFilterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)

    EVENT_MANAGER:RegisterForEvent("CrutchAlertsBossHealthBarPlayerActivated", EVENT_PLAYER_ACTIVATED, OnBossesChanged)
end

-- Don't want event overload if the health bars are off
local function UnregisterEvents()
    Crutch.dbgOther("|c88FFFF[CT]|r Unregistering Boss Health Bar events")

    EVENT_MANAGER:UnregisterForEvent("CrutchAlertsBossHealthBarBossChange", EVENT_BOSSES_CHANGED)

    EVENT_MANAGER:UnregisterForEvent("CrutchAlertsBossHealthBarPowerUpdate", EVENT_POWER_UPDATE)

    EVENT_MANAGER:UnregisterForEvent("CrutchAlertsBossHealthBarPlayerActivated", EVENT_PLAYER_ACTIVATED)
end

-- Entry point
function BHB.Initialize()
    Crutch.dbgOther("|c88FFFF[CT]|r Initializing Boss Health Bar")

    CrutchAlertsBossHealthBarContainer:ClearAnchors()
    CrutchAlertsBossHealthBarContainer:SetAnchor(TOPLEFT, GuiRoot, CENTER, 
        Crutch.savedOptions.bossHealthBarDisplay.x, Crutch.savedOptions.bossHealthBarDisplay.y)

    -- Display only on HUD/HUD_UI
    if (not bhbFragment) then
        bhbFragment = ZO_SimpleSceneFragment:New(CrutchAlertsBossHealthBarContainer)
    end

    if (Crutch.savedOptions.bossHealthBar.enabled) then
        HUD_SCENE:AddFragment(bhbFragment)
        HUD_UI_SCENE:AddFragment(bhbFragment)
        RegisterEvents()
        OnBossesChanged()
        ShowOrHideBars()
    else
        HUD_SCENE:RemoveFragment(bhbFragment)
        HUD_UI_SCENE:RemoveFragment(bhbFragment)
        UnregisterEvents()
    end
    CrutchAlertsBossHealthBarContainer:SetHidden(not Crutch.savedOptions.bossHealthBar.enabled)

    -- TODO: shields
    -- TODO: invuln indicator
    -- TODO: skull when dead?
    -- TODO: remove attached % when dead?
    -- TODO: larger scale 0 <- I have no idea what I meant when I wrote this
end
