local Crutch = CrutchAlerts

---------------------------------------------------------------------
---------------------------------------------------------------------
local KEYBOARD_STYLE = {
    GetAlertFont = function(size)
        return string.format("$(BOLD_FONT)|%d|soft-shadow-thick", math.floor(size))
    end,
    damageableFont = "ZoFontWinH1",
    prominentFont = "$(BOLD_FONT)|80|soft-shadow-thick",
    GetBHBFont = function(size)
        return string.format("$(BOLD_FONT)|%d|shadow", math.floor(size))
    end,
    GetMarkerFont = function(size)
        return string.format("$(BOLD_FONT)|%d|thick-outline", math.floor(size))
    end,
}

local GAMEPAD_STYLE = {
    GetAlertFont = function(size)
        return string.format("$(GAMEPAD_BOLD_FONT)|%d|soft-shadow-thick", math.floor(size))
    end,
    damageableFont = "ZoFontGamepadBold27",
    prominentFont = "ZoFontGamepad61",
    GetBHBFont = function(size)
        return string.format("$(GAMEPAD_MEDIUM_FONT)|%d|soft-shadow-thick", math.floor(size))
    end,
    GetMarkerFont = function(size)
        return string.format("$(GAMEPAD_BOLD_FONT)|%d|thick-outline", math.floor(size))
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