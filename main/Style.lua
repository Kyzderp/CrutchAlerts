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
    GetBHBFont = function(size)
        return string.format("$(BOLD_FONT)|%d|shadow", math.floor(size))
    end,
}

local GAMEPAD_STYLE = {
    alertFont = "ZoFontGamepadBold34",
    damageableFont = "ZoFontGamepadBold27",
    prominentFont = "ZoFontGamepad61",
    normalFont = "ZoFontGamepad18",
    smallFont = "ZoFontGamepad18", -- Adding this so it exists, but console won't have an option to show this
    GetBHBFont = function(size)
        if (size <= 18) then return "ZoFontGamepad18" end
        if (size <= 20) then return "ZoFontGamepad20" end
        if (size <= 22) then return "ZoFontGamepad22" end
        if (size <= 25) then return "ZoFontGamepad25" end
        if (size <= 27) then return "ZoFontGamepad27" end
        if (size <= 34) then return "ZoFontGamepad34" end
        if (size <= 36) then return "ZoFontGamepad36" end
        if (size <= 42) then return "ZoFontGamepad42" end
        if (size <= 54) then return "ZoFontGamepad54" end
        return "ZoFontGamepad61"
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