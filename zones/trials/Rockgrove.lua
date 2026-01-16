local Crutch = CrutchAlerts
local C = Crutch.Constants

---------------------------------------------------------------------
local EXIT_LEFT_POOL = {x = 91973, y = 35751, z = 81764}  -- from QRH so that we use the same sorting

---------------------------------------------------------------------
-- Sludge icons
---------------------------------------------------------------------
local SLUDGE_UNIQUE_NAME = "CrutchAlertsRGSludge"

local function OnSludgeIcon(changeType, unitTag)
    if (changeType == EFFECT_RESULT_GAINED) then
        Crutch.SetAttachedIconForUnit(unitTag, SLUDGE_UNIQUE_NAME, C.PRIORITY.MECHANIC_1_PRIORITY, "CrutchAlerts/assets/poop.dds", nil, {0.6, 1, 0.6})
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.RemoveAttachedIconForUnit(unitTag, SLUDGE_UNIQUE_NAME)
    end
end

---------------------------------------------------------------------
-- OAXILTSO: NOXIOUS SLUDGE SIDES
---------------------------------------------------------------------
local sludgeTag1 = nil
local lastSludge = 0 -- for resetting

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnNoxiousSludgeGained(_, changeType, _, _, unitTag)
    if (Crutch.savedOptions.rockgrove.showSludgeIcons) then
        OnSludgeIcon(changeType, unitTag)
    end

    if (changeType ~= EFFECT_RESULT_GAINED) then return end
    Crutch.dbgSpam(string.format("|c00FF00Noxious Sludge: %s (%s)|r", GetUnitDisplayName(unitTag), unitTag))

    if (not Crutch.savedOptions.rockgrove.sludgeSides) then return end

    local currSeconds = GetGameTimeSeconds()
    if (currSeconds - lastSludge > 10) then
        -- Reset
        sludgeTag1 = nil
        lastSludge = currSeconds
    end

    if (not sludgeTag1) then
        sludgeTag1 = unitTag
        return
    elseif (sludgeTag1 == unitTag) then
        return
    end

    local leftPlayer, rightPlayer

    -- TODO: update this if QRH updates. QRH currently sends whoever is closer to
    -- exit left pool to the left
    leftPlayer = sludgeTag1
    rightPlayer = unitTag
    local _, p1x, p1y, p1z = GetUnitWorldPosition(sludgeTag1)
    local _, p2x, p2y, p2z = GetUnitWorldPosition(unitTag)

    -- We have sludgeTag1, and unitTag is second player
    -- Using the same logic as QRH to sort players
    -- QRH does this by checking who is closer to exit left pool
    -- Is problematic because of latency, but oh well
    local p1Dist = Crutch.GetSquaredDistance(p1x, p1y, p1z, EXIT_LEFT_POOL.x, EXIT_LEFT_POOL.y, EXIT_LEFT_POOL.z)
    local p2Dist = Crutch.GetSquaredDistance(p2x, p2y, p2z, EXIT_LEFT_POOL.x, EXIT_LEFT_POOL.y, EXIT_LEFT_POOL.z)
    -- Crutch.dbgOther(string.format("squared dist between: %f", Crutch.GetSquaredDistance(p1x, p1y, p1z, p2x, p2y, p2z)))
    if (p1Dist < p2Dist) then
        leftPlayer = sludgeTag1
        rightPlayer = unitTag
    else
        leftPlayer = unitTag
        rightPlayer = sludgeTag1
    end
    -- Crutch.dbgOther(string.format("%f", p1Dist))
    -- Crutch.dbgOther(string.format("%f", p2Dist))
    Crutch.dbgOther(GetUnitDisplayName(leftPlayer) .. "< >" .. GetUnitDisplayName(rightPlayer))
    local label = string.format("|c00FF00%s |c00d60b|t100%%:100%%:Esoui/Art/Buttons/large_leftarrow_up.dds:inheritcolor|t |c00FF00Noxious Sludge|r |c00d60b|t100%%:100%%:Esoui/Art/Buttons/large_rightarrow_up.dds:inheritcolor|t |c00FF00%s|r", GetUnitDisplayName(leftPlayer), GetUnitDisplayName(rightPlayer))
    Crutch.DisplayNotification(157860, label, 5000, 0, 0, 0, 0, 0, 0, 0, true)
end


---------------------------------------------------------------------
-- Bahsei
---------------------------------------------------------------------
local linesHidden = false

local effectResults = {
    [EFFECT_RESULT_FADED] = "FADED",
    [EFFECT_RESULT_FULL_REFRESH] = "FULL_REFRESH",
    [EFFECT_RESULT_GAINED] = "|cb95effGAINED",
    [EFFECT_RESULT_TRANSFER] = "TRANSFER",
    [EFFECT_RESULT_UPDATED] = "UPDATED",
}

local groupBitterMarrow = {}

local PANEL_PORTAL_COUNT_INDEX = 1
local function UpdatePlayersInPortal()
    local count = 0
    for _, hasMarrow in pairs(groupBitterMarrow) do
        if (hasMarrow == true) then
            count = count + 1
        end
    end
    Crutch.InfoPanel.SetLine(PANEL_PORTAL_COUNT_INDEX, count .. " in portal")
end

-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnBitterMarrowChanged(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    Crutch.dbgOther(string.format("|c8C00FF%s(%s): %d %s|r", GetUnitDisplayName(unitTag), unitTag, stackCount, effectResults[changeType]))

    local changed = false
    if (changeType == EFFECT_RESULT_GAINED) then
        groupBitterMarrow[unitTag] = true
        changed = true
    elseif (changeType == EFFECT_RESULT_FADED) then
        groupBitterMarrow[unitTag] = false
        changed = true
    end

    -- Update suppression
    if (changed) then
        -- If it was the player entering or exiting portal, all units need to be refreshed
        if (AreUnitsEqual("player", unitTag)) then
            Crutch.Drawing.EvaluateAllSuppression()
            linesHidden = groupBitterMarrow[unitTag]
        else
            Crutch.Drawing.EvaluateSuppressionFor(unitTag)
        end

        UpdatePlayersInPortal()
    end
end

-- Player state
local function IsInBahseiPortal(unitTag)
    if (not unitTag) then unitTag = Crutch.playerGroupTag end

    if (groupBitterMarrow[unitTag] == true) then return true end

    return false
end

-- Suppression for attached icons
local PORTAL_SUPPRESSION_FILTER = "CrutchAlertsBahseiPortal"
local function BahseiPortalFilter(unitTag)
    return IsInBahseiPortal(unitTag) == IsInBahseiPortal(Crutch.playerGroupTag)
end

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
    icon:SetTextureHidden(linesHidden)
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
-- Pre-portal ability icons & portal timers
---------------------------------------------------------------------
local PANEL_PORTAL_TIMER_INDEX = 2

-- 20s to start
-- 50s after previous finished
local nextPortal = 1
local nextPortalTimer = 20
local function OnPortalSummoned()
    Crutch.InfoPanel.StopCount(PANEL_PORTAL_TIMER_INDEX)
    UpdatePlayersInPortal()
end

local spoofedAbilities = {} -- Just for cleanup. {abilityId = true}

local function SpoofIcon(abilityId)
    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "BahseiIconChange" .. abilityId)
    spoofedAbilities[abilityId] = true
    Crutch.SetAbilityOverlay(abilityId)
    Crutch.dbgOther("Changing " .. GetAbilityName(abilityId))
end

local function UnspoofAllIcons()
    for abilityId, _ in pairs(spoofedAbilities) do
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "BahseiIconChange" .. abilityId)
        Crutch.RemoveAbilityOverlay(abilityId)
    end
end

-- Target time after portal spawns, e.g. Quick Cloak lasts 30s, margin is 4s, so icon should be changed at 26s before next portal
local function MaybeChangeIconLater(abilityId, msUntilPortal)
    if (not Crutch.savedOptions.rockgrove.abilitiesToReplace[abilityId]) then return end

    -- Time in ms until icon change
    local delay = msUntilPortal + Crutch.savedOptions.rockgrove.portalTimeMargin - GetAbilityDuration(abilityId)
    Crutch.dbgOther("Will change " .. GetAbilityName(abilityId) .. " icon in " .. delay .. "ms")
    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "BahseiIconChange" .. abilityId, delay, function() SpoofIcon(abilityId) end)
end

local function IsMyPortal(nextPortal)
    local myPortal = Crutch.savedOptions.rockgrove.portalNumber
    if (myPortal == 0) then return false end

    return myPortal == nextPortal
end

local function OnPortalEnded()
    nextPortal = (nextPortal == 1) and 2 or 1

    if (Crutch.savedOptions.rockgrove.showTimeToPortal) then
        -- TODO: a panel?
        Crutch.DisplayDamageable(50, "Portal " .. nextPortal .. " in |c%s%.1f|r")
    end

    -- TODO: setting
    Crutch.InfoPanel.RemoveLine(PANEL_PORTAL_COUNT_INDEX)
    Crutch.InfoPanel.CountDownDuration(PANEL_PORTAL_TIMER_INDEX, "Portal " .. nextPortal .. ": ", 50000)

    UnspoofAllIcons()

    if (not IsMyPortal(nextPortal)) then return end

    -- Check if any skills are slotted
    for i = 3, 8 do
        MaybeChangeIconLater(GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY), 50000)
        MaybeChangeIconLater(GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP), 50000)
    end
end

local function OnEnteredCombat()
    -- Check that it's Bahsei HM
    local _, maxHp = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (maxHp ~= 123882576) then
        return
    end

    if (Crutch.savedOptions.rockgrove.showTimeToPortal) then
        Crutch.DisplayDamageable(20, "Portal 1 in |c%s%.1f|r")
    end
    -- TODO: setting
    Crutch.InfoPanel.CountDownDuration(PANEL_PORTAL_TIMER_INDEX, "Portal 1: ", 20000)

    if (not IsMyPortal(1)) then return end

    -- Check if any skills are slotted
    for i = 3, 8 do
        MaybeChangeIconLater(GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY), 20000)
        MaybeChangeIconLater(GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP), 20000)
    end
end

function Crutch.TestChange()
    for i = 3, 8 do
        MaybeChangeIconLater(GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY), 20000)
        MaybeChangeIconLater(GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP), 20000)
    end
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
local origOSIUnitErrorCheck = nil

function Crutch.RegisterRockgrove()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Rockgrove")

    Crutch.RegisterEnteredGroupCombatListener("RockgroveEnteredCombat", OnEnteredCombat)

    Crutch.RegisterExitedGroupCombatListener("RockgroveExitedCombat", function()
        numBleeds = 0
        explosions = {}
        nextPortal = 1
        nextPortalTimer = 20
        Crutch.StopDamageable()
        UnspoofAllIcons()
        Crutch.InfoPanel.StopCount(PANEL_PORTAL_TIMER_INDEX)
        Crutch.InfoPanel.RemoveLine(PANEL_PORTAL_COUNT_INDEX)
    end)

    -- Register the Noxious Sludge
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "NoxiousSludge", EVENT_EFFECT_CHANGED, OnNoxiousSludgeGained)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "NoxiousSludge", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 157860)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "NoxiousSludge", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

    -- Register for Bahsei portal effect gained/faded
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED, OnBitterMarrowChanged)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 153423)

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

    -- Register for Portal summon and end
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Clockwise", EVENT_COMBAT_EVENT, OnPortalSummoned)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Clockwise", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Clockwise", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153517)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "CounterClockwise", EVENT_COMBAT_EVENT, OnPortalSummoned)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CounterClockwise", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "CounterClockwise", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153518)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "PortalExplode", EVENT_COMBAT_EVENT, OnPortalEnded)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "PortalExplode", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "PortalExplode", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153662)

    -- Override OdySupportIcons to also check whether the group member is in the same portal vs not portal
    if (OSI and OSI.UnitErrorCheck) then
        Crutch.dbgOther("|c88FFFF[CT]|r Overriding OSI.UnitErrorCheck")
        origOSIUnitErrorCheck = OSI.UnitErrorCheck
        OSI.UnitErrorCheck = function(unitTag, allowSelf)
            local error = origOSIUnitErrorCheck(unitTag, allowSelf)
            if (error ~= 0) then
                return error
            end
            if (IsInBahseiPortal(Crutch.playerGroupTag) == IsInBahseiPortal(unitTag)) then
                return 0
            else
                return 8
            end
        end
    end

    -- Suppress attached icons when in different portal
    Crutch.Drawing.RegisterSuppressionFilter(PORTAL_SUPPRESSION_FILTER, BahseiPortalFilter)
end

function Crutch.UnregisterRockgrove()
    -- Clean up in case of PTE; unit tags may change
    Crutch.RemoveAllAttachedIcons(SLUDGE_UNIQUE_NAME)
    if (playerCurseLinesKey) then
        Crutch.Drawing.RemoveWorldTexture(playerCurseLinesKey)
        playerCurseLinesKey = nil
    end

    groupBitterMarrow = {}

    Crutch.UnregisterExitedGroupCombatListener("RockgroveExitedCombat")

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "NoxiousSludge", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "BitterMarrowEffect", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "KissOfDeath", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Bleeding", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DeathTouch", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DeathTouchLines", EVENT_EFFECT_CHANGED)

    if (OSI and origOSIUnitErrorCheck) then
        Crutch.dbgOther("|c88FFFF[CT]|r Restoring OSI.UnitErrorCheck")
        OSI.UnitErrorCheck = origOSIUnitErrorCheck
    end

    Crutch.Drawing.UnregisterSuppressionFilter(PORTAL_SUPPRESSION_FILTER)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Rockgrove")
end
