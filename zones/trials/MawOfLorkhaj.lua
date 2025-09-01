CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts


---------------------------------------------------------------------
-- ZHAJ'HASSA
---------------------------------------------------------------------
-- 25 seconds cooldown
local PAD_COORDS = {
    [1] = {x = 104179, y = 45954, z = 130168},
    [2] = {x = 105015, y = 45967, z = 128699},
    [3] = {x = 104093, y = 45967, z = 126869},
    [4] = {x = 102971, y = 45967, z = 126115},
    [5] = {x = 100987, y = 45967, z = 126379},
    [6] = {x = 100543, y = 45959, z = 128344},
}

local padIdToIndex = {}
local padIndexToId = {}

local isPolling = false
local padEndTime = {}

local function UpdatePadsDisplay()
    local currTime = GetGameTimeMilliseconds()
    local hasTimers = false
    for index = 1, 6 do
        local label = CrutchAlertsMawOfLorkhaj:GetNamedChild("Pad" .. tostring(index) .. "Label")
        if (padEndTime[index] and (padEndTime[index] - currTime) > 0) then
            local seconds = (padEndTime[index] - currTime) / 1000
            label:SetHidden(false)
            label:SetText(string.format("%.1f", seconds))
            hasTimers = true
        else
            label:SetHidden(true)
        end
    end

    -- If no currently running timers, we don't need to update anymore
    if (not hasTimers) then
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "MoLPoll")
        Crutch.dbgSpam("stop polling pads display")
    end
end

local function StartPadCountdown(index)
    if (not index) then return end
    padEndTime[index] = GetGameTimeMilliseconds() + 25000
    UpdatePadsDisplay()

    if (not isPolling) then
        EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "MoLPoll", 100, UpdatePadsDisplay)
        Crutch.dbgSpam("start polling pads display")
    end
end

local function EndPadCountdown(index)
    if (not index) then return end
    padEndTime[index] = nil
    UpdatePadsDisplay()
end

-- Pads fire Jone's Blessing (57525) FADED when someone takes the pad
-- and then fire GAINED when it becomes available again
local function FindPad(padUnitId, findNew, skipRetry)
    if (padIdToIndex[padUnitId]) then
        Crutch.dbgOther(string.format("existing pad %d -> %d", padUnitId, padIdToIndex[padUnitId]))
        return padIdToIndex[padUnitId]
    end

    -- Do not look for new pad if it's the buff coming up, which shouldn't be possible unless
    -- we had just wiped and new unit IDs were assigned, or if
    if (not findNew) then
        Crutch.dbgOther(string.format("|cFF0000No existing pad for %d, and not finding new|r", padUnitId))
        return
    end

    -- Since pads can be taken whether player has curse or not, don't track via curse
    -- Instead, just find who the closest player is to any pad, and assume that the
    -- pad has been taken by that player
    local lowestDistance = 1000000000
    local lowestDistanceIndex = 0
    local lowestDistanceTag = ""
    for i, coords in pairs(PAD_COORDS) do
        -- Only check pads that haven't been discovered
        if (not padIndexToId[i]) then
            for j = 1, GetGroupSize() do
                local groupTag = GetGroupUnitTagByIndex(j)
                local _, x, y, z = GetUnitRawWorldPosition(groupTag)
                local dist = Crutch.GetSquaredDistance(x, y, z, coords.x, coords.y, coords.z)
                if (dist < lowestDistance) then
                    lowestDistance = dist
                    lowestDistanceTag = groupTag
                    lowestDistanceIndex = i
                end
            end
        end
    end

    -- Must be within 6 meters. If player is going fast enough, sometimes the desync means the player is already too far
    if (lowestDistance < 360000) then
        padIdToIndex[padUnitId] = lowestDistanceIndex
        padIndexToId[lowestDistanceIndex] = padUnitId
        Crutch.dbgOther(string.format("newly found pad %d -> %d used by %s", padUnitId, padIdToIndex[padUnitId], GetUnitDisplayName(lowestDistanceTag)))
        return lowestDistanceIndex
    end

    Crutch.dbgOther(string.format("|cFF0000Couldn't find close enough pad for %d!|r", padUnitId))
    Crutch.dbgOther(string.format("lowestDistance %d lowestDistanceIndex %d lowestDistanceTag %s", lowestDistance, lowestDistanceIndex, lowestDistanceTag))

    Crutch.dbgOther("RESETTING")
    padIdToIndex = {}
    padIndexToId = {}

    if (not skipRetry) then
        return FindPad(padUnitId, findNew, true)
    end
    return nil
end

-- When a pad's buff changes, update the UI
local function OnPadChanged(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId, abilityId, _)
    local padIndex
    if (changeType == EFFECT_RESULT_GAINED) then
        -- Pad has regenned
        padIndex = FindPad(unitId, false)
        EndPadCountdown(padIndex)
    elseif (changeType == EFFECT_RESULT_FADED) then
        -- Pad has been taken, and its death is your calling
        padIndex = FindPad(unitId, true)
        StartPadCountdown(padIndex)
    end
end

local function RegisterZhajhassa()
    if (GetMapTileTexture() == "Art/maps/reapersmarch/Maw_of_Lorkaj_Base_0.dds"
        and Crutch.savedOptions.mawoflorkhaj.showPads
        and DoesUnitExist("boss1")) then
        -- This is Zhaj'hassa
        CrutchAlertsMawOfLorkhaj:SetHidden(false)
        UpdatePadsDisplay()
    else
        CrutchAlertsMawOfLorkhaj:SetHidden(true)
    end

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "MoLCombatState", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if (not inCombat) then
            Crutch.dbgOther("resetting because combat state")
            padIdToIndex = {}
            padIndexToId = {}
        end
    end)

    -- Show pads
    Crutch.RegisterBossChangedListener("CrutchMawOfLorkhaj", function()
        if (GetMapTileTexture() == "Art/maps/reapersmarch/Maw_of_Lorkaj_Base_0.dds"
            and Crutch.savedOptions.mawoflorkhaj.showPads
            and DoesUnitExist("boss1")) then
            -- This is Zhaj'hassa
            CrutchAlertsMawOfLorkhaj:SetHidden(false)
        else
            CrutchAlertsMawOfLorkhaj:SetHidden(true)
        end
    end)

    -- Jone's Blessing (57525) fires when a pad's buff is restored, with the target unit ID as the pad's ID
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "JonesBlessing", EVENT_EFFECT_CHANGED, OnPadChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "JonesBlessing", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 57525) -- Jone's Blessing
end

local function UnregisterZhajhassa()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "MoLCombatState", EVENT_PLAYER_COMBAT_STATE)

    Crutch.UnregisterBossChangedListener("CrutchMawOfLorkhaj")

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "JonesBlessing", EVENT_EFFECT_CHANGED)

    -- Crutch.DisableIcon("ZhajM1")
    -- Crutch.DisableIcon("ZhajM2")
    -- Crutch.DisableIcon("ZhajM3")
    -- Crutch.DisableIcon("ZhajM4")
end


---------------------------------------------------------------------
-- TWINS
---------------------------------------------------------------------
-- lunar duration -> shadow conversion duration -> lunar faded -> shadow duration -> conversion faded
local currentlyDisplayingAbility = {}

local ASPECT_ICONS = {
    [59639] = {path = "/esoui/art/ava/ava_rankicon64_lieutenant.dds", color = {0, 0, 1}}, -- Shadow Aspect
    [59640] = {path = "/esoui/art/ava/ava_rankicon64_prefect.dds", color = {1, 206/255, 0}}, -- Lunar Aspect
    [59699] = {path = "/esoui/art/ava/ava_rankicon64_legate.dds", color = {0, 0, 1}}, -- Conversion (to shadow)
    [75460] = {path = "/esoui/art/ava/ava_rankicon64_tribune.dds", color = {1, 206/255, 0}}, -- Conversion (to lunar)
}

local function OnAspect(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, _, abilityId, _)
    local atName = GetUnitDisplayName(unitTag)
    if (changeType == EFFECT_RESULT_GAINED) then
        -- Gained an aspect, so we should change the displayed icon for the player
        local iconData = ASPECT_ICONS[abilityId]
        local iconPath = iconData.path
        currentlyDisplayingAbility[atName] = abilityId

        Crutch.dbgSpam(string.format("Setting |t100%%:100%%:%s|t for %s", iconPath, atName))
        Crutch.SetMechanicIconForUnit(atName, iconPath, nil, iconData.color)
    elseif (changeType == EFFECT_RESULT_FADED) then
        -- The aspect faded, but we should only remove the icon if it's the currently displayed one
        if (abilityId == currentlyDisplayingAbility[atName]) then
            Crutch.dbgSpam(string.format("Removing %s(%d) for %s", GetAbilityName(abilityId), abilityId, atName))
            Crutch.RemoveMechanicIconForUnit(atName)
            currentlyDisplayingAbility[atName] = nil
        end
    end
end
Crutch.TestAspect = function(unitTag, abilityId) OnAspect(_, EFFECT_RESULT_GAINED, _, _, unitTag, _, _, _, _, _, _, _, _, _, _, abilityId) end

local function OnConversion(_, result, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, targetUnitId, abilityId)
    local atName = GetUnitDisplayName(Crutch.groupIdToTag[targetUnitId])
    if (not atName) then
        Crutch.dbgSpam(string.format("couldn't find atName for %d", targetUnitId))
        return
    end

    if (result == ACTION_RESULT_EFFECT_GAINED_DURATION) then
        -- Gained conversion, so we should change the displayed icon for the player
        local iconData = ASPECT_ICONS[abilityId]
        local iconPath = iconData.path
        currentlyDisplayingAbility[atName] = abilityId

        Crutch.dbgSpam(string.format("Setting |t100%%:100%%:%s|t for %s", iconPath, atName))
        Crutch.SetMechanicIconForUnit(atName, iconPath, nil, iconData.color)

        -- If self, display a prominent alert because COLOR SWAP!
        local showProminent
        if (IsConsoleUI()) then
            showProminent = Crutch.savedOptions.console.showProminent
        else
            showProminent = Crutch.savedOptions.mawoflorkhaj.prominentColorSwap
        end
        if (atName == GetUnitDisplayName("player") and showProminent) then
            Crutch.DisplayProminent(888003)
        end
    elseif (result == ACTION_RESULT_EFFECT_FADED) then
        -- The conversion faded, but we should only remove the icon if it's the currently displayed one
        if (abilityId == currentlyDisplayingAbility[atName]) then
            Crutch.dbgSpam(string.format("Removing %s(%d) for %s", GetAbilityName(abilityId), abilityId, atName))
            Crutch.RemoveMechanicIconForUnit(atName)
            currentlyDisplayingAbility[atName] = nil
        end
    end
end

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
            local icon, color, size, anim, offset, isMech = origOSIGetIconDataForPlayer(displayName, config, unitTag)

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

            return icon, color, size, anim, offset, isMech
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
    -- Void Shackle
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "RakkhatVoidShackle", EVENT_COMBAT_EVENT, OnVoidShackleDamage)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "RakkhatVoidShackle", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 75507) -- Void Shackle (tether)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "RakkhatVoidShackle", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Self
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "RakkhatVoidShackle", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DAMAGE)
end

local function UnregisterRakkhat()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "RakkhatVoidShackle", EVENT_COMBAT_EVENT)
end


---------------------------------------------------------------------
-- Font shenanigans
---------------------------------------------------------------------
local function ApplyStyle(style)
    for i = 1, 6 do
        CrutchAlertsMawOfLorkhaj:GetNamedChild("Pad" .. tostring(i) .. "Label"):SetFont(style)
    end
end

local initialized = false
local function InitFont()
    if (initialized) then return end
    initialized = true

    ZO_PlatformStyle:New(ApplyStyle, "$(BOLD_FONT)|20|soft-shadow-thick", "ZoFontGamepad27")
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterMawOfLorkhaj()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Maw of Lorkhaj")

    InitFont()

    -- Zhaj'hassa cleanse pads
    RegisterZhajhassa()

    -- Twins icons
    RegisterTwins()

    -- Rakkhat
    RegisterRakkhat()
end

function Crutch.UnregisterMawOfLorkhaj()
    UnregisterZhajhassa()
    UnregisterTwins()
    UnregisterRakkhat()

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Maw of Lorkhaj")
end
