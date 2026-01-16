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
-- UI
---------------------------------------------------------------------
local function CreateLabel(index)
    local label = WINDOW_MANAGER:CreateControlFromVirtual(
        "$(parent)Line" .. index,
        CrutchAlertsInfoPanel,
        "CrutchAlertsInfoPanelLineTemplate",
        "")
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
    for _, index in ipairs(keys) do
        local label = lines[index]
        label:ClearAnchors()
        label:SetAnchor(TOPLEFT, prevRelative, prevRelativeAnchor)
        prevRelative = label
        prevRelativeAnchor = BOTTOMLEFT
    end
end


---------------------------------------------------------------------
-- API
---------------------------------------------------------------------
local function SetLine(index, text)
    local label = lines[index]
    if (not label) then
        label = CreateLabel(index)
        UpdateAnchors()
    elseif (label:IsHidden()) then
        label:SetHidden(false)
        UpdateAnchors()
    end
    label:SetText(text)
end
IP.SetLine = SetLine
-- /script CrutchAlerts.InfoPanel.SetLine(1, "Line 1") CrutchAlerts.InfoPanel.SetLine(3, "Line 1=3")

local function RemoveLine(index)
    lines[index] = nil
    UpdateAnchors()
end
IP.RemoveLine = RemoveLine


---------------------------------------------------------------------
-- Style
---------------------------------------------------------------------
local KEYBOARD_STYLE = {
    thickFont = "$(BOLD_FONT)|20|soft-shadow-thick",
}

local GAMEPAD_STYLE = {
    thickFont = "ZoFontGamepad27",
}

local function ApplyStyle(style)
    for _, label in pairs(lines) do
        label:SetFont(style.thickFont)
    end
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Crutch.InitializeInfoPanel()
    ZO_PlatformStyle:New(ApplyStyle, KEYBOARD_STYLE, GAMEPAD_STYLE)
end
