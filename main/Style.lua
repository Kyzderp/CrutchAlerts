CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
---------------------------------------------------------------------
local KEYBOARD_STYLE = {
    alertFont = "$(BOLD_FONT)|32|soft-shadow-thick",
    damageableFont = "ZoFontWinH1",
    prominentFont = "$(BOLD_FONT)|80|soft-shadow-thick",
    normalFont = "ZoFontGame",
    smallFont = "$(BOLD_FONT)|14|shadow",
}

local GAMEPAD_STYLE = {
    alertFont = "ZoFontGamepadBold34",
    damageableFont = "ZoFontGamepadBold27",
    prominentFont = "ZoFontGamepad61",
    normalFont = "ZoFontGamepad18",
    smallFont = "ZoFontGamepad18", -- Adding this so it exists, but console won't have an option to show this
}


---------------------------------------------------------------------
-- Apply styles to... everything
---------------------------------------------------------------------
local activeStyles = GAMEPAD_STYLE
local function ApplyStyle(style)
    activeStyles = style
end

local function GetStyles()
    return activeStyles
end
Crutch.GetStyles = GetStyles


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local initialized = false
function Crutch.InitializeStyles()
    if (initialized) then
        CrutchAlerts.dbgOther("|cFF0000InitializeStyle called twice?!|r")
        return
    end
    initialized = true

    ZO_PlatformStyle:New(ApplyStyle, KEYBOARD_STYLE, GAMEPAD_STYLE)
end