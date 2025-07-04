CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
---------------------------------------------------------------------
local KEYBOARD_STYLE = {
    alertFont = "$(BOLD_FONT)|32|soft-shadow-thick",
    damageableFont = "ZoFontWinH1",
    prominentFont = "$(BOLD_FONT)|80|soft-shadow-thick",
    smallFont = "$(BOLD_FONT)|14|shadow",
    GetBHBFont = function(size)
        return string.format("$(BOLD_FONT)|%d|shadow", math.floor(size))
    end,
}

local GAMEPAD_STYLE = {
    alertFont = "ZoFontGamepadBold34",
    damageableFont = "ZoFontGamepadBold27",
    prominentFont = "ZoFontGamepad61",
    smallFont = "ZoFontGamepad18", -- Adding this so it exists, but console won't have an option to show this
    GetBHBFont = function(size)
        return string.format("$(GAMEPAD_MEDIUM_FONT)|%d|soft-shadow-thick", math.floor(size))
    end,
}


---------------------------------------------------------------------
-- Apply styles to... everything
---------------------------------------------------------------------
local activeStyles = GAMEPAD_STYLE
local function ApplyStyle(style)
    activeStyles = style
    Crutch.BossHealthBar.UpdateScale(false)
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