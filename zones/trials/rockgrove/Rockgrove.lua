local Crutch = CrutchAlerts
Crutch.Rockgrove = {
    linesHidden = false,
    PANEL_PORTAL_DIRECTION_INDEX = 5,
    PANEL_PORTAL_COUNT_INDEX = 6,
    PANEL_PORTAL_PLAYERS_INDEX = 7,
    PANEL_PORTAL_TIMER_INDEX = 8,
}
local C = Crutch.Constants

---------------------------------------------------------------------
-- Bahsei
---------------------------------------------------------------------
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnKissOfDeath(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    local unitTag = Crutch.groupIdToTag[targetUnitId]
    Crutch.msg(zo_strformat("Kiss of Death |cFF00FF<<1>>", GetUnitDisplayName(unitTag)))
end


------------------------------------------------------------
-- Curse lines
-- Ideas, curve estimate, data sharing, etc. implementation
-- help from @M0R_Gaming and @Ooki42
------------------------------------------------------------
local CURSE_LINE_Y_OFFSET = 5

local function LineCallback(icon)
    icon:SetTextureHidden(Crutch.Rockgrove.linesHidden)
end

local function DrawConfirmedCurseLines(x, y, z, angle, color, duration)
    local key = Crutch.Drawing.CreateWorldTexture(
        "CrutchAlerts/assets/floor/curse.dds",
        x, y + CURSE_LINE_Y_OFFSET, z,
        44.5, 44.5,
        color,
        false,
        false,
        {-math.pi/2, angle, 0},
        LineCallback)

    -- Natural expiry
    zo_callLater(function()
        Crutch.Drawing.RemoveWorldTexture(key)
    end, duration)
end

local playerCurseLinesKey
local function DrawInProgressCurseLines()
    -- Remove in progress lines
    if (playerCurseLinesKey) then
        Crutch.Drawing.RemoveWorldTexture(playerCurseLinesKey)
        playerCurseLinesKey = nil
    end

    if (not Crutch.savedOptions.rockgrove.showCursePreview) then return end

    local _, x, y, z = GetUnitRawWorldPosition("player")
    local _, _, heading = GetMapPlayerPosition("player")
    playerCurseLinesKey = Crutch.Drawing.CreateOrientedTexture(
        "CrutchAlerts/assets/floor/curse.dds",
        x, y + CURSE_LINE_Y_OFFSET, z,
        44.5,
        Crutch.savedOptions.rockgrove.cursePreviewColor,
        {-math.pi/2, heading, 0},
        function(icon)
            local _, x, y, z = GetUnitRawWorldPosition("player")
            local _, _, heading = GetMapPlayerPosition("player")
            icon:SetPosition(x, y + CURSE_LINE_Y_OFFSET, z)
            icon:SetOrientation(-math.pi/2, heading, 0)
        end)
end

-- Keep track of timestamps of explosions, setting an expiry of 8 seconds
-- If the LGB curse event isn't received within the expire time, remove
-- the tracked explosion. Otherwise, assume the received event corresponds
-- to the first in the queue.
local explosions = {} -- {[unitTag] = {12343254, 12323567}}
local function OnGroupMemberCurseReceived(unitTag, x, y, z, heading)
    -- Don't do self
    if (AreUnitsEqual("player", unitTag)) then return end

    local explosionTimes = explosions[unitTag]
    if (not explosionTimes) then
        Crutch.dbgOther("|cFF0000Didn't find explosion for " .. GetUnitDisplayName(unitTag))
        return
    end

    local currentTime = GetTimeStamp()

    -- Pop off queue and check it's within range
    local explosion
    while (#explosionTimes > 0) do
        local explosionTime = table.remove(explosionTimes, 1)
        if (currentTime - explosionTime < 8) then
            explosion = explosionTime
            break
        end
    end

    -- Check setting. This is after clearing queue intentionally
    if (not Crutch.savedOptions.rockgrove.showOthersCurseLines) then return end

    if (not explosion) then
        Crutch.dbgOther("|cFF0000Curse event for " .. GetUnitDisplayName(unitTag) .. " received out of range of known explosions")
        return
    end

    local remainingDuration = (explosion + 9 - GetTimeStamp()) * 1000 -- would be full seconds, but good enough (+1 second for safety)
    if (remainingDuration < 0) then
        Crutch.dbgOther("|cFF0000Curse event for " .. GetUnitDisplayName(unitTag) .. " has < 0 remaining duration?! Should not be possible")
        return
    end

    DrawConfirmedCurseLines(x, y, z, heading, Crutch.savedOptions.rockgrove.othersCurseLineColor, remainingDuration)
end
Crutch.OnGroupMemberCurseReceived = OnGroupMemberCurseReceived

local function OnDeathTouchLinesTimeout(changeType, unitTag, playerX, playerY, playerZ, playerHeading)
    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "CurseLineTimeout" .. unitTag)

    -- Group member curse
    if (not AreUnitsEqual("player", unitTag)) then
        -- Save the explosion timestamp
        if (changeType == EFFECT_RESULT_FADED) then
            if (not explosions[unitTag]) then
                explosions[unitTag] = {}
            end
            table.insert(explosions[unitTag], GetTimeStamp())
        end
        return
    end

    -- Self curse
    if (changeType == EFFECT_RESULT_GAINED) then
        DrawInProgressCurseLines()
    elseif (changeType == EFFECT_RESULT_FADED) then
        -- Remove in progress lines
        if (playerCurseLinesKey) then
            Crutch.Drawing.RemoveWorldTexture(playerCurseLinesKey)
            playerCurseLinesKey = nil
        end

        -- Draw confirmed lines for self
        if (Crutch.savedOptions.rockgrove.showCurseLines) then
            DrawConfirmedCurseLines(playerX, playerY, playerZ, playerHeading, Crutch.savedOptions.rockgrove.curseLineColor, 8000)
        end

        -- Always send to group members
        CrutchAlerts.Broadcast.SendCurseExplosion()
    end
end

-- EFFECT_RESULT_FADED fires when you aren't previously cursed, but you walk into cursed ground aoe, it keeps refreshing
-- So add a very short timeout to make sure it's actually an explosion
local function OnDeathTouchLines(_, changeType, _, _, unitTag)
    -- We get the positions here to avoid being... 10ms off
    local _, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    local _, _, playerHeading = GetMapPlayerPosition("player")
    if (changeType == EFFECT_RESULT_FADED) then
        EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "CurseLineTimeout" .. unitTag, 10, function()
            OnDeathTouchLinesTimeout(changeType, unitTag, playerX, playerY, playerZ, playerHeading)
        end)
    else
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "CurseLineTimeout" .. unitTag)
        OnDeathTouchLinesTimeout(changeType, unitTag, playerX, playerY, playerZ, playerHeading)
    end
end

local function TestCurseLines()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DeathTouchLinesTest", EVENT_EFFECT_CHANGED, OnDeathTouchLines)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DeathTouchLinesTest", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DeathTouchLinesTest", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 61509)
end
Crutch.TestCurseLines = TestCurseLines
-- /script CrutchAlerts.TestCurseLines()
-- /script CrutchAlerts.savedOptions.drawing.placedOriented.useDepthBuffers = false


------------------------------------------------------------
-- Curse icons
------------------------------------------------------------
local CURSE_UNIQUE_NAME = "CrutchAlertsRGDeathTouch"

local cycleTime = 700
local function DeathTouchIconUpdate(icon, unitTag, endTime)
    local duration = endTime * 1000 - GetGameTimeMilliseconds()
    if (duration < -1000) then
        Crutch.RemoveAttachedIconForUnit(unitTag, CURSE_UNIQUE_NAME)
        return
    end

    -- Countdown text
    local text
    if (duration <= 0) then
        text = "!"
    elseif (duration <= 1100) then
        text = string.format("%.1f", duration / 1000)
    else
        text = tostring(math.ceil(duration / 1000))
    end
    icon:SetText(text)

    -- Pulsing animation in last few seconds
    if (duration <= 2500) then
        local t = ((2500 - duration) % cycleTime) / cycleTime

        -- Color
        if (duration < 1000) then
            Crutch.Drawing.Animation.PulseUpdate(icon:GetCompositeTexture(), t, C.RED)
        else
            Crutch.Drawing.Animation.PulseUpdate(icon:GetCompositeTexture(), t, C.REDORANGE)
        end
    end
end

local function OnDeathTouch(_, changeType, _, _, unitTag, beginTime, endTime)
    if (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) then
        local duration = (endTime - beginTime) * 1000
        Crutch.SetAttachedIconForUnit(unitTag, CURSE_UNIQUE_NAME, C.PRIORITY.MECHANIC_1_PRIORITY, nil, 120, nil, false, function(icon)
            DeathTouchIconUpdate(icon, unitTag, endTime)
        end,
        {
            label = {
                text = "9",
                size = 45,
                color = {1, 1, 1, 0.8},
            },
            composite = {
                size = 1.7,
                init = function(composite)
                    Crutch.Drawing.Animation.PulseInitial(composite, "CrutchAlerts/assets/shape/diamond.dds", 0.5, {1, 0.5, 0, 1})
                    composite:SetAlpha(0.8)
                end,
            },
        })
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.RemoveAttachedIconForUnit(unitTag, CURSE_UNIQUE_NAME)
    end
end
Crutch.OnDeathTouch = OnDeathTouch
-- /script CrutchAlerts.OnDeathTouch(nil, EFFECT_RESULT_GAINED, nil, nil, "player", GetGameTimeMilliseconds() / 1000, GetGameTimeMilliseconds() / 1000 + 9) zo_callLater(function() CrutchAlerts.OnDeathTouch(nil, EFFECT_RESULT_FADED, nil, nil, "player") end, 9000)
-- /script CrutchAlerts.OnDeathTouch(nil, EFFECT_RESULT_GAINED, nil, nil, "player", GetGameTimeMilliseconds() / 1000, GetGameTimeMilliseconds() / 1000 + 9)
-- /script CrutchAlerts.OnDeathTouch(nil, EFFECT_RESULT_FADED, nil, nil, "player")


------------------------------------------------------------
-- Bleeding
------------------------------------------------------------
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local numBleeds = 0
local function OnBleeding(_, changeType, _, _, unitTag, beginTime, endTime)
    local atName = GetUnitDisplayName(unitTag)
    local tagNumber = string.gsub(unitTag, "group", "")
    local tagId = tonumber(tagNumber)
    local fakeSourceUnitId = 8880080 + tagId + numBleeds -- TODO: really gotta rework the alerts and stop hacking around like this
    -- numBleeds is added just to get a unique number, because core can only display one per source id * ability id

    -- Gained only; don't cancel it when FADED because it would only happen on death, and the hacky source ID wouldn't match anyway
    if (changeType ~= EFFECT_RESULT_GAINED) then
        return
    end

    numBleeds = numBleeds + 1

    -- Event is not registered if NEVER, so the only other option is HEAL (which includes self)
    if (Crutch.savedOptions.rockgrove.showBleeding == "ALWAYS"
        or atName == GetUnitDisplayName("player")
        or GetSelectedLFGRole() == LFG_ROLE_HEAL) then
        local label = zo_strformat("|cfff1ab<<C:1>>|cAAAAAA on <<2>>|r", GetAbilityName(153179), atName)
        Crutch.DisplayNotification(153179, label, (endTime - beginTime) * 1000, fakeSourceUnitId, 0, 0, 0, 0, 0, 0, false)
    end
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
local origOSIUnitErrorCheck = nil

function Crutch.RegisterRockgrove()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Rockgrove")

    Crutch.RegisterExitedGroupCombatListener("RockgroveExitedCombat", function()
        numBleeds = 0
        ZO_ClearTable(explosions)
    end)

    Crutch.Rockgrove.RegisterOax()
    Crutch.Rockgrove.RegisterBahseiPortal()

    -- Register for Kiss of Death
    if (Crutch.savedOptions.general.showRaidDiag) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "KissOfDeath", EVENT_COMBAT_EVENT, OnKissOfDeath)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "KissOfDeath", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 152654)
    end

    -- Register for Bleeding
    if (Crutch.savedOptions.rockgrove.showBleeding ~= "NEVER") then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Bleeding", EVENT_EFFECT_CHANGED, OnBleeding)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Bleeding", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Bleeding", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 153179)
    end

    -- Register for Death Touch
    if (Crutch.savedOptions.rockgrove.showCurseIcons) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DeathTouch", EVENT_EFFECT_CHANGED, OnDeathTouch)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DeathTouch", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DeathTouch", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 150078)
    end

    -- Register for Death Touch lines
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DeathTouchLines", EVENT_EFFECT_CHANGED, OnDeathTouchLines)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DeathTouchLines", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DeathTouchLines", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 150078)
end

function Crutch.UnregisterRockgrove()
    -- Clean up in case of PTE; unit tags may change
    if (playerCurseLinesKey) then
        Crutch.Drawing.RemoveWorldTexture(playerCurseLinesKey)
        playerCurseLinesKey = nil
    end

    Crutch.UnregisterExitedGroupCombatListener("RockgroveExitedCombat")

    Crutch.Rockgrove.UnregisterOax()
    Crutch.Rockgrove.UnregisterBahseiPortal()

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "KissOfDeath", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Bleeding", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DeathTouch", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DeathTouchLines", EVENT_EFFECT_CHANGED)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Rockgrove")
end
