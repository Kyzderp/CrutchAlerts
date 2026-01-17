local Crutch = CrutchAlerts
local IP = Crutch.InfoPanel

---------------------------------------------------------------------
--[[
want: add by key? or just number
display: should it close gaps? prob yes
each item is 1 label?
truncate
settings: font size, position
font
vertical line side bar?
]]
local lines = {} -- {[1] = Label}



---------------------------------------------------------------------
local size = 30


---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
local function CreateLabel(index)
    local label = CreateControlFromVirtual(
        "$(parent)Line" .. index,
        CrutchAlertsInfoPanel,
        "CrutchAlertsInfoPanelLineTemplate",
        "")
    label:SetFont(Crutch.GetStyles().GetInfoPanelFont(size)) -- TODO: setting
    lines[index] = label
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
        local label = lines[index]
        if (not label:IsHidden()) then
            label:ClearAnchors()
            label:SetAnchor(TOPLEFT, prevRelative, prevRelativeAnchor)
            prevRelative = label
            prevRelativeAnchor = BOTTOMLEFT
            numActiveLines = numActiveLines + 1
            totalHeight = totalHeight + label:GetTextHeight()
        end
    end

    CrutchAlertsInfoPanel:SetHeight(totalHeight)
end


---------------------------------------------------------------------
-- API
---------------------------------------------------------------------
local function SetLine(index, text)
    local label = lines[index]
    if (not label) then
        label = CreateLabel(index)
        label:SetText(text)
        UpdateAnchors()
    elseif (label:IsHidden()) then
        label:SetText(text)
        label:SetHidden(false)
        UpdateAnchors()
    else
        label:SetText(text)
    end
end
IP.SetLine = SetLine
-- /script CrutchAlerts.InfoPanel.SetLine(1, "Line 1") CrutchAlerts.InfoPanel.SetLine(3, "Line 3") zo_callLater(function() CrutchAlerts.InfoPanel.RemoveLine(1) end, 3000)

local function RemoveLine(index)
    if (lines[index]) then
        lines[index]:SetHidden(true)
        lines[index]:SetText("")
        UpdateAnchors()
    end
end
IP.RemoveLine = RemoveLine


---------------------------------------------------------------------
-- Style
---------------------------------------------------------------------
function IP.ApplyStyle(style)
    for _, label in pairs(lines) do
        label:SetFont(style.GetInfoPanelFont(size))
    end
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Crutch.InitializeInfoPanel()
    local infoPanelFragment = ZO_SimpleSceneFragment:New(CrutchAlertsInfoPanel)
    HUD_SCENE:AddFragment(infoPanelFragment)
    HUD_UI_SCENE:AddFragment(infoPanelFragment)
end
