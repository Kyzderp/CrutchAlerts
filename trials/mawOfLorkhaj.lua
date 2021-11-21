CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------

---------------------------------------------------------------------
-- ZHAJ'HASSA
---------------------------------------------------------------------
-- {
--     {x=0.55496829748154, y=0.29175475239754},
--     {x=0.56342494487762, y=0.25405216217041},
--     {x=0.60077518224716, y=0.24876673519611},
--     {x=0.62297391891479, y=0.26250880956650},
--     {x=0.64059197902679, y=0.29774489998817},
--     {x=0.62508809566498, y=0.32699084281921},
-- }


---------------------------------------------------------------------
-- TWINS
---------------------------------------------------------------------
-- lunar duration -> shadow conversion duration -> lunar faded -> shadow duration -> conversion faded
local currentlyDisplayingAbility = {}

local aspectIcons = {
    [59639] = "odysupporticons/icons/squares/squaretwo_blue.dds", -- Shadow Aspect
    [59640] = "odysupporticons/icons/squares/squaretwo_yellow.dds", -- Lunar Aspect
    [59699] = "odysupporticons/icons/squares/squaretwo_blue.dds", -- Conversion (to shadow)
    [75460] = "odysupporticons/icons/squares/squaretwo_yellow.dds", -- Conversion (to lunar)
}

local function OnAspectOrConversion(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId, abilityId, _)
    local atName = GetUnitDisplayName(unitTag)
    if (changeType == EFFECT_RESULT_GAINED) then
        -- Gained an aspect or conversion, so we should change the displayed icon for the player
        local iconPath = aspectIcons[abilityId]
        currentlyDisplayingAbility[atName] = abilityId

        Crutch.dbgSpam(string.format("Setting |t100%%:100%%:%s|t for %s", iconPath, atName))
        OSI.SetMechanicIconForUnit(atName, iconPath)
    elseif (changeType == EFFECT_RESULT_FADED) then
        -- The aspect or conversion faded, but we should only remove the icon if it's the currently displayed one
        if (abilityId == currentlyDisplayingAbility[atName]) then
            Crutch.dbgSpam(string.format("Removing %s(%d) for %s", GetAbilityName(abilityId), abilityId, atName))
            OSI.RemoveMechanicIconForUnit(atName)
        end
    end
end

local function ResetTwins()
    for atName, _ in pairs(currentlyDisplayingAbility) do
        OSI.RemoveMechanicIconForUnit(atName)
    end
end

---------------------------------------------------------------------
-- General Listeners
---------------------------------------------------------------------
local isInCombat = false
local function OnCombatStateChanged(_, inCombat)
    -- Reset
    isInCombat = inCombat
    if (not inCombat) then
        -- TODO: see if this is necessary
        -- ResetTwins()
    else
    end
end

---------------------------------------------------------------------
-- Register/Unregister
function Crutch.RegisterMawOfLorkhaj()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Maw of Lorkhaj")

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "MoLCombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    -- Twins icons
    if (OSI and OSI.SetMechanicIconForUnit) then
        OSI.SetMechanicIconSize(200)

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TwinsShadow", EVENT_EFFECT_CHANGED, OnAspectOrConversion)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsShadow", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 59639) -- Shadow Aspect (duration)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsShadow", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TwinsLunar", EVENT_EFFECT_CHANGED, OnAspectOrConversion)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsLunar", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 59640) -- Lunar Aspect (duration)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsLunar", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TwinsShadowConversion", EVENT_EFFECT_CHANGED, OnAspectOrConversion)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsShadowConversion", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 59699) -- Conversion (to shadow)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsShadowConversion", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TwinsLunarConversion", EVENT_EFFECT_CHANGED, OnAspectOrConversion)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsLunarConversion", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 75460) -- Conversion (to lunar)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsLunarConversion", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    end
end

function Crutch.UnregisterMawOfLorkhaj()
    if (OSI and OSI.SetMechanicIconForUnit) then
        OSI.ResetMechanicIconSize()

        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "MoLCombatState", EVENT_PLAYER_COMBAT_STATE)
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TwinsShadow", EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TwinsLunar", EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TwinsShadowConversion", EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TwinsLunarConversion", EVENT_EFFECT_CHANGED)
    end

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Maw of Lorkhaj")
end
