local Crutch = CrutchAlerts
local IP = Crutch.InfoPanel

---------------------------------------------------------------------
local lines = {} -- {[1] = {label = Label, active = false, scale = 1,}


---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
local function CreateLabel(index, scale)
    local label = CreateControlFromVirtual(
        "$(parent)Line" .. index,
        CrutchAlertsInfoPanel,
        "CrutchAlertsInfoPanelLineTemplate",
        "")
    label:SetFont(Crutch.GetStyles().GetInfoPanelFont(Crutch.savedOptions.infoPanel.size * scale))
    lines[index] = {label = label, active = true, scale = scale}
    return label
end

-- Update anchors to ensure there are no gaps between lines
local function UpdateAnchors()
    local keys = {}
    for index, _ in pairs(lines) do
        table.insert(keys, index)
    end
    table.sort(keys)

    local prevRelative = CrutchAlertsInfoPanel
    local prevRelativeAnchor = TOPLEFT
    local numActiveLines = 0
    local totalHeight = 0
    for _, index in ipairs(keys) do
        local line = lines[index]
        if (line.active) then
            local label = line.label
            label:ClearAnchors()
            label:SetAnchor(TOPLEFT, prevRelative, prevRelativeAnchor)
            prevRelative = label
            prevRelativeAnchor = BOTTOMLEFT
            numActiveLines = numActiveLines + 1
            totalHeight = totalHeight + label:GetTextHeight()
        end
    end

    Crutch.dbgSpam("totalHeight " .. totalHeight)
    CrutchAlertsInfoPanel:SetHeight(totalHeight)
end


---------------------------------------------------------------------
-- API
---------------------------------------------------------------------
-- scale optional as a percentage of the default size, default 1
local function SetLine(index, text, scale)
    local line = lines[index]
    if (not scale) then scale = 1 end

    if (not line) then
        local label = CreateLabel(index, scale)
        label:SetText(text)
        UpdateAnchors()
    elseif (not line.active) then
        line.active = true
        line.scale = scale
        line.label:SetFont(Crutch.GetStyles().GetInfoPanelFont(Crutch.savedOptions.infoPanel.size * scale))
        line.label:SetText(text)
        line.label:SetHidden(false)
        UpdateAnchors()
    else
        line.label:SetText(text)
    end
end
IP.SetLine = SetLine
-- /script CrutchAlerts.InfoPanel.SetLine(1, "Line 1") CrutchAlerts.InfoPanel.SetLine(3, "Line 3") zo_callLater(function() CrutchAlerts.InfoPanel.RemoveLine(1) end, 3000)

local function RemoveLine(index)
    if (lines[index]) then
        lines[index].label:SetHidden(true)
        lines[index].label:SetText("")
        lines[index].active = false
        UpdateAnchors()
    end
end
IP.RemoveLine = RemoveLine


---------------------------------------------------------------------
-- Style
---------------------------------------------------------------------
local currentStyle
function IP.ApplyStyle(style)
    if (not style) then
        style = currentStyle
    else
        currentStyle = style
    end

    for _, line in pairs(lines) do
        line.label:SetFont(style.GetInfoPanelFont(Crutch.savedOptions.infoPanel.size * line.scale))
    end
    UpdateAnchors()
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Crutch.InitializeInfoPanel()
    local infoPanelFragment = ZO_SimpleSceneFragment:New(CrutchAlertsInfoPanel)
    HUD_SCENE:AddFragment(infoPanelFragment)
    HUD_UI_SCENE:AddFragment(infoPanelFragment)
end
