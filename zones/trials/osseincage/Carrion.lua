local Crutch = CrutchAlerts
local C = Crutch.Constants

---------------------------------------------------------------------
-- Caustic Carrion
---------------------------------------------------------------------

-------------
-- Carrion UI
local BAR_MAX = 10

local function AddCarrionBarNotches()
    local width = CrutchAlertsCausticCarrion:GetWidth() / BAR_MAX
    for i = 0, BAR_MAX do
        local notch = WINDOW_MANAGER:CreateControl("$(parent)Notch" .. tostring(i), CrutchAlertsCausticCarrion, CT_BACKDROP)
        notch:SetEdgeColor(0, 0, 0, 0)
        notch:SetDrawLayer(2)

        if (i == 0) then
            -- Annoying edge
            notch:SetAnchor(TOPLEFT, CrutchAlertsCausticCarrion, TOPLEFT, width * i - 2, -4)
            notch:SetAnchor(BOTTOMRIGHT, CrutchAlertsCausticCarrion, BOTTOMLEFT, width * i - 1, 4)
            notch:SetCenterColor(0.9, 0.9, 0.9, 0.8)
        elseif (i == 5) then
            notch:SetAnchor(TOPLEFT, CrutchAlertsCausticCarrion, TOPLEFT, width * i - 1, -4)
            notch:SetAnchor(BOTTOMRIGHT, CrutchAlertsCausticCarrion, BOTTOMLEFT, width * i + 1, 4)
            notch:SetCenterColor(0.9, 0.9, 0.9, 0.8)
        elseif (i == BAR_MAX) then
            -- Annoying edge
            notch:SetAnchor(TOPLEFT, CrutchAlertsCausticCarrion, TOPLEFT, width * i, -4)
            notch:SetAnchor(BOTTOMRIGHT, CrutchAlertsCausticCarrion, BOTTOMLEFT, width * i + 2, 4)
            notch:SetCenterColor(0.9, 0.9, 0.9, 0.8)
        else
            if (i % 2 == 0) then
                notch:SetAnchor(TOPLEFT, CrutchAlertsCausticCarrion, TOPLEFT, width * i - 1, -4)
                notch:SetAnchor(BOTTOMRIGHT, CrutchAlertsCausticCarrion, BOTTOMLEFT, width * i, 4)
                notch:SetCenterColor(0.7, 0.7, 0.7, 0.8)
            else
                notch:SetAnchor(TOPLEFT, CrutchAlertsCausticCarrion, TOPLEFT, width * i - 1, 0)
                notch:SetAnchor(BOTTOMRIGHT, CrutchAlertsCausticCarrion, BOTTOMLEFT, width * i, 0)
                notch:SetCenterColor(0.7, 0.7, 0.7, 0.4)
            end
        end

        if (i % 2 == 0) then
            local label = WINDOW_MANAGER:CreateControl("$(parent)Label", notch, CT_LABEL)
            label:SetHorizontalAlignment(CENTER)
            label:SetAnchor(TOP, notch, BOTTOM, 0, 2)
            label:SetColor(0.8, 0.8, 0.8, 1)
            if (i < BAR_MAX) then
                label:SetText(tostring(i))
            else
                label:SetText(tostring(i) .. "+")
            end
        end
    end
end
Crutch.AddCarrionBarNotches = AddCarrionBarNotches

----------------
-- Carrion logic
local carrionStacks = {} -- {[tag] = {stacks = 4, tickTime = 1543,}}
local polling = false

-- Return keys in the order of highest stacks + closest to next tick
local function GetSortedCarrion()
    local sorted = {}
    for tag, data in pairs(carrionStacks) do
        local timeToTick = data.tickTime - GetGameTimeMilliseconds() % 2000
        if (timeToTick < 0) then timeToTick = timeToTick + 2000 end
        table.insert(sorted, {unitTag = tag, timeToTick = timeToTick, stacks = data.stacks})
    end

    table.sort(sorted, function(first, second)
        if (first.stacks == second.stacks) then
            return first.timeToTick < second.timeToTick
        end
        return first.stacks > second.stacks
    end)
    return sorted
end

-- Twins HM kills at 6 stacks, so turn it red at 5 (this color applies to nonHM too, which is probably fine for practice)
local regularThresholds = {8, 7}
local twinsThresholds = {5, 4}
local colorThresholds = regularThresholds

local function UpdateCarrionDisplay()
    local sorted = GetSortedCarrion()

    -- Individual stacks
    if (Crutch.savedOptions.osseincage.showCarrionIndividual) then
        local text = ""
        for _, data in ipairs(sorted) do
            local name = GetUnitDisplayName(data.unitTag)
            if (name) then
                text = string.format("%s%s%s(%s) - %d stacks; %dms to tick", text, text == "" and "" or "\n", name, data.unitTag, data.stacks, data.timeToTick)
            end
        end
        CrutchAlertsCausticCarrionText:SetText(text)
        CrutchAlertsCausticCarrionText:SetHidden(false)
    else
        CrutchAlertsCausticCarrionText:SetHidden(true)
    end

    -- Get the highest stacks
    if (#sorted > 0) then
        local highest = sorted[1]
        local progress = (2000 - highest.timeToTick) / 2000 + highest.stacks
        if (progress > colorThresholds[1]) then
            CrutchAlertsCausticCarrionBar:SetGradientColors(1, 0, 0, 1, 0.5, 0, 0, 1)
            CrutchAlertsCausticCarrionStacks:SetColor(1, 0, 0, 1)
        elseif (progress > colorThresholds[2]) then
            CrutchAlertsCausticCarrionBar:SetGradientColors(1, 1, 0, 1, 0.7, 0, 0, 1)
            CrutchAlertsCausticCarrionStacks:SetColor(1, 1, 0, 1)
        else
            ZO_StatusBar_SetGradientColor(CrutchAlertsCausticCarrionBar, ZO_XP_BAR_GRADIENT_COLORS)
            CrutchAlertsCausticCarrionStacks:SetColor(1, 1, 1, 1)
        end

        ZO_StatusBar_SmoothTransition(CrutchAlertsCausticCarrionBar, progress, BAR_MAX)
        CrutchAlertsCausticCarrionStacks:SetText(string.format("%.1f", math.floor(progress * 10) / 10))
    else
        ZO_StatusBar_SmoothTransition(CrutchAlertsCausticCarrionBar, 0, BAR_MAX)
        CrutchAlertsCausticCarrionStacks:SetText("0")
        CrutchAlertsCausticCarrionStacks:SetColor(1, 1, 1, 1)
    end
end

local function OnCausticCarrion(_, changeType, _, _, unitTag, beginTime, endTime, stackCount, _, _, _, _, _, _, _, abilityId)
    if (abilityId == 241089) then
        colorThresholds = twinsThresholds
    else
        colorThresholds = regularThresholds
    end

    if (changeType == EFFECT_RESULT_FADED) then
        carrionStacks[unitTag] = nil

        -- Check if there are no more stacks
        if (polling) then
            for _, _ in pairs(carrionStacks) do
                return -- Continue polling
            end
            polling = false
            EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "CarrionPoll")
            UpdateCarrionDisplay()
        end
        return
    end
    local tickRemainder = GetGameTimeMilliseconds() % 2000
    carrionStacks[unitTag] = {stacks = stackCount, tickTime = tickRemainder}

    if (not polling) then
        polling = true
        EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "CarrionPoll", 90, UpdateCarrionDisplay)
    end
end


---------------------------------------------------------------------
-- Font shenanigans
---------------------------------------------------------------------
local KEYBOARD_STYLE = {
    thickFont = "$(BOLD_FONT)|20|soft-shadow-thick",
    individualFont = "ZoFontGame",
    notchFont = "ZoFontGameSmall",
}

local GAMEPAD_STYLE = {
    thickFont = "ZoFontGamepad27",
    individualFont = "ZoFontGamepad18",
    notchFont = "ZoFontGamepad18",
}

local function ApplyStyle(style)
    CrutchAlertsCausticCarrionStacks:SetFont(style.thickFont)

    CrutchAlertsCausticCarrionTitle:SetFont(style.thickFont)
    CrutchAlertsCausticCarrionTitle:SetHeight(100)
    CrutchAlertsCausticCarrionTitle:SetHeight(CrutchAlertsCausticCarrionTitle:GetTextHeight())

    CrutchAlertsCausticCarrionText:SetFont(style.individualFont)

    for i = 0, BAR_MAX do
        if (i % 2 == 0) then
            local label = CrutchAlertsCausticCarrion:GetNamedChild("Notch" .. tostring(i) .. "Label")
            label:SetFont(style.notchFont)
        end
    end
end

local initialized = false
local function InitFont()
    if (initialized) then return end
    initialized = true

    ZO_PlatformStyle:New(ApplyStyle, KEYBOARD_STYLE, GAMEPAD_STYLE)
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
local carrionFragment

function Crutch.OsseinCage.RegisterCarrion()
    InitFont()

    Crutch.RegisterExitedGroupCombatListener("ExitedCombatCarrion", function()
        ZO_ClearTable(carrionStacks)
    end)

    -- Caustic Carrion
    if (Crutch.savedOptions.osseincage.showCarrion) then
        if (not carrionFragment) then
            carrionFragment = ZO_SimpleSceneFragment:New(CrutchAlertsCausticCarrion)
        end
        HUD_SCENE:AddFragment(carrionFragment)
        HUD_UI_SCENE:AddFragment(carrionFragment)

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CausticCarrionRegular", EVENT_EFFECT_CHANGED, OnCausticCarrion)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CausticCarrionRegular", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 240708)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CausticCarrionRegular", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CausticCarrionBoss2", EVENT_EFFECT_CHANGED, OnCausticCarrion)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CausticCarrionBoss2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 241089)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CausticCarrionBoss2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    end
end

function Crutch.OsseinCage.UnregisterCarrion()
    Crutch.UnregisterExitedGroupCombatListener("ExitedCombatCarrion")
    if (carrionFragment) then
        HUD_SCENE:RemoveFragment(carrionFragment)
        HUD_UI_SCENE:RemoveFragment(carrionFragment)
    end

    Crutch.UnregisterBossChangedListener("CrutchOsseinCage")

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "CausticCarrionRegular", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "CausticCarrionBoss2", EVENT_EFFECT_CHANGED)
end
