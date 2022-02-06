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

local ASPECT_ICONS = {
    [59639] = "odysupporticons/icons/squares/squaretwo_blue.dds", -- Shadow Aspect
    [59640] = "odysupporticons/icons/squares/squaretwo_yellow.dds", -- Lunar Aspect
    [59699] = "odysupporticons/icons/squares/square_blue.dds", -- Conversion (to shadow)
    [75460] = "odysupporticons/icons/squares/square_yellow.dds", -- Conversion (to lunar)
}

local function OnAspect(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId, abilityId, _)
    local atName = GetUnitDisplayName(unitTag)
    if (changeType == EFFECT_RESULT_GAINED) then
        -- Gained an aspect, so we should change the displayed icon for the player
        local iconPath = ASPECT_ICONS[abilityId]
        currentlyDisplayingAbility[atName] = abilityId

        Crutch.dbgSpam(string.format("Setting |t100%%:100%%:%s|t for %s", iconPath, atName))
        OSI.SetMechanicIconForUnit(atName, iconPath)
    elseif (changeType == EFFECT_RESULT_FADED) then
        -- The aspect faded, but we should only remove the icon if it's the currently displayed one
        if (abilityId == currentlyDisplayingAbility[atName]) then
            Crutch.dbgSpam(string.format("Removing %s(%d) for %s", GetAbilityName(abilityId), abilityId, atName))
            OSI.RemoveMechanicIconForUnit(atName)
            currentlyDisplayingAbility[atName] = nil
        end
    end
end

local function OnConversion(_, result, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, targetUnitId, abilityId)
    local atName = GetUnitDisplayName(Crutch.groupIdToTag[targetUnitId])
    if (not atName) then
        Crutch.dbgSpam(string.format("couldn't find atName for %d", targetUnitId))
        return
    end

    if (result == ACTION_RESULT_EFFECT_GAINED_DURATION) then
        -- Gained conversion, so we should change the displayed icon for the player
        local iconPath = ASPECT_ICONS[abilityId]
        currentlyDisplayingAbility[atName] = abilityId

        Crutch.dbgSpam(string.format("Setting |t100%%:100%%:%s|t for %s", iconPath, atName))
        OSI.SetMechanicIconForUnit(atName, iconPath)
    elseif (result == ACTION_RESULT_EFFECT_FADED) then
        -- The conversion faded, but we should only remove the icon if it's the currently displayed one
        if (abilityId == currentlyDisplayingAbility[atName]) then
            Crutch.dbgSpam(string.format("Removing %s(%d) for %s", GetAbilityName(abilityId), abilityId, atName))
            OSI.RemoveMechanicIconForUnit(atName)
            currentlyDisplayingAbility[atName] = nil
        end
    end
end

-- local function ReassignTwins()
--     Crutch.dbgSpam("reassigning twins")
--     for atName, abilityId in pairs(currentlyDisplayingAbility) do
--         local iconPath = ASPECT_ICONS[abilityId]
--         Crutch.dbgSpam(string.format("Reassigning |t100%%:100%%:%s|t for %s", iconPath, atName))
--         OSI.SetMechanicIconForUnit(atName, iconPath)
--     end
-- end

local origOSIGetIconDataForPlayer = nil
local function RegisterTwins()
    if (OSI and OSI.SetMechanicIconForUnit) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TwinsShadow", EVENT_EFFECT_CHANGED, OnAspect)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsShadow", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 59639) -- Shadow Aspect (duration)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsShadow", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TwinsLunar", EVENT_EFFECT_CHANGED, OnAspect)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsLunar", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 59640) -- Lunar Aspect (duration)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsLunar", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TwinsShadowConversion", EVENT_COMBAT_EVENT, OnConversion)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsShadowConversion", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 59699) -- Conversion (to shadow)

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TwinsLunarConversion", EVENT_COMBAT_EVENT, OnConversion)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TwinsLunarConversion", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 75460) -- Conversion (to lunar)

        -- Override the dead icon to be whichever color
        Crutch.dbgOther("|c88FFFF[CT]|r Overriding OSI.GetIconDataForPlayer")
        origOSIGetIconDataForPlayer = OSI.GetIconDataForPlayer
        OSI.GetIconDataForPlayer = function(displayName, config, unitTag)
            local icon, color, size, anim, offset = origOSIGetIconDataForPlayer(displayName, config, unitTag)

            local isDead = unitTag and IsUnitDead(unitTag) or false
            if (config.dead and isDead) then
                local abilityId = currentlyDisplayingAbility[displayName]
                if (abilityId == 59639 or abilityId == 59699) then
                    -- Shadow
                    color = {26/255, 36/255, 1}
                elseif (abilityId == 59640 or abilityId == 75460) then
                    -- Lunar
                    color = {1, 207/255, 0}
                else
                    -- Keep same color
                end
            end

            return icon, color, size, anim, offset
        end
    end
end

local function UnregisterTwins()
    if (OSI and OSI.SetMechanicIconForUnit) then
        OSI.ResetMechanicIcons()

        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TwinsShadow", EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TwinsLunar", EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TwinsShadowConversion", EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TwinsLunarConversion", EVENT_EFFECT_CHANGED)

        if (OSI and origOSIGetIconDataForPlayer) then
            Crutch.dbgOther("|c88FFFF[CT]|r Restoring OSI.GetIconDataForPlayer")
            OSI.GetIconDataForPlayer = origOSIGetIconDataForPlayer
        end
    end
end

---------------------------------------------------------------------
-- Rakkhat
---------------------------------------------------------------------
local function OnVoidShackleDamage()
    Crutch.DisplayNotification(75507, "|c6a00ffTETHERED!|r", 1100, 0, 0, 0, 0, false)
end

local function RegisterRakkhat()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "RakkhatVoidShackle", EVENT_COMBAT_EVENT, OnVoidShackleDamage)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "RakkhatVoidShackle", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 75507) -- Void Shackle (tether)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "RakkhatVoidShackle", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Self
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "RakkhatVoidShackle", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DAMAGE)
end

local function UnregisterRakkhat()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "RakkhatVoidShackle", EVENT_COMBAT_EVENT)
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterMawOfLorkhaj()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Maw of Lorkhaj")

    -- Twins icons
    RegisterTwins()

    -- Rakkhat
    RegisterRakkhat()
end

function Crutch.UnregisterMawOfLorkhaj()
    UnregisterTwins()
    UnregisterRakkhat()

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Maw of Lorkhaj")
end
