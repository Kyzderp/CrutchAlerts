local Crutch = CrutchAlerts
local Draw = Crutch.Drawing
local C = Crutch.Constants

---------------------------------------------------------------------
-- Attached player icons and colors
---------------------------------------------------------------------
--[[
C.PRIORITY = {
    SUPPRESS = 10001, -- 10000 is the highest valid priority for public calling
    MECHANIC_2_PRIORITY = 510, -- Higher priority mechanic e.g. Roaring Flare over Hoarfrost
    MECHANIC_1_PRIORITY = 500,
    GROUP_DEAD = 110,
    ASPECT = 108, -- MoL twins aspects need to be lower priority than dead icons, which are also colored
    INDIVIDUAL_ICONS = 107,
    GROUP_CROWN = 105,
    GROUP_ROLE = 100,
}


C.COLORS_PRIORITY = {
    MECHANIC_2
    MECHANIC_1
    ASPECT
    GROUP_RESURRECTING
    GROUP_PENDING
    GROUP_DEAD
    INDIVIDUAL_ICON
    GROUP_CROWN
    GROUP_ROLE
}

must declare and register for priority maybe? else default



{
    [unitTag] = {
        key = key, -- Only showing 1 at a time, so only need the 1 key
        activeIcon = uniqueName,
        activeColor = uniqueName,
        icons = {
            [uniqueName] = {
                priority = 0, -- Higher shows before lower
                texture = "",
                size = 100,
                callback = function(control) end,
            },
        },
        colors = {
            [uniqueName] = {
                priority = 0,
                color = {1, 1, 1, 1},
            },
        },
    },
}
]]
