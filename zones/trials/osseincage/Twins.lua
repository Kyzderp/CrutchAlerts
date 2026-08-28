local Crutch = CrutchAlerts
local C = Crutch.Constants
local OC = Crutch.OsseinCage


---------------------------------------------------------------------
local JYNORAH_HEALTH_HM = 85320632
local JYNORAH_HEALTH_VET = 37257920
local JYNORAH_HEALTH_NORMAL = 10906420

local function IsHM()
    local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    return powerMax == JYNORAH_HEALTH_HM
end

local function IsBaseVet()
    local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    return powerMax == JYNORAH_HEALTH_VET
end


---------------------------------------------------------------------
-- Check health for next portal
---------------------------------------------------------------------
local spoofedAbilities = {}
local function SpoofIconIfDangerous(abilityId)
    if (not Crutch.savedOptions.osseincage.abilitiesToReplace[abilityId]) then return end

    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "TwinsIconChange" .. abilityId)
    spoofedAbilities[abilityId] = true
    Crutch.SetAbilityOverlay(abilityId)
    Crutch.dbgOther("Changing " .. GetAbilityName(abilityId))
end

local function UnspoofAllIcons()
    for abilityId, _ in pairs(spoofedAbilities) do
        EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "TwinsIconChange" .. abilityId)
        Crutch.RemoveAbilityOverlay(abilityId)
    end
end

local function SpoofAllIcons()
    -- Check if any skills are slotted
    for i = 3, 8 do
        SpoofIconIfDangerous(GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY))
        SpoofIconIfDangerous(GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP))
    end
end

local bossHealths = {}
local prevTotalValue
local function OnTwinsHealth(_, unitTag, _, _, powerValue, powerMax)
    if (not bossHealths[unitTag]) then
        bossHealths[unitTag] = {}
    end
    bossHealths[unitTag].value = powerValue
    bossHealths[unitTag].max = powerMax

    -- Get total health: portals at 75% 35%
    local totalValue = 0
    local totalMax = 0
    for _, data in pairs(bossHealths) do
        totalValue = totalValue + data.value
        totalMax = totalMax + data.max
    end

    -- Start at max
    if (not prevTotalValue) then prevTotalValue = totalMax end

    local targetPercent = Crutch.savedOptions.osseincage.portalPercentMargin

    -- Check if it's newly in range
    local portalTarget = totalMax * (0.76 + targetPercent / 100)
    if (prevTotalValue >= portalTarget and portalTarget > totalValue) then
        Crutch.dbgOther("Reached target for portal 1")
        SpoofAllIcons()
        prevTotalValue = totalValue
        return
    end

    portalTarget = totalMax * (0.36 + targetPercent / 100)
    if (prevTotalValue >= portalTarget and portalTarget > totalValue) then
        Crutch.dbgOther("Reached target for portal 2")
        SpoofAllIcons()
        prevTotalValue = totalValue
        return
    end

    prevTotalValue = totalValue
end


---------------------------------------------------------------------
-- Notifications / Info Panel
---------------------------------------------------------------------
local PANEL_CLASH_INDEX = 3
local PANEL_LEAP_INDEX = 5

--[[
Myr Titanic Clash Leap AL (233500)
Val Titanic Clash Leap AL (233512)

Myr Leap DESPAWN (234738)

Myr Leap Exit AL (234704)
Myrinax Leap AL (233452)
Myrinax Leap UPPER AL (233477)
Val Exit Leap AL (234722)
Valneer Leap AL (233466)
Valnner Leap UPPER AL (233489)
]]
local LEAP_IDS = {
    234704, -- Myr Leap Exit AL
    233452, -- Myrinax Leap AL
    233477, -- Myrinax Leap UPPER AL
    234722, -- Val Exit Leap AL
    233466, -- Valneer Leap AL
    233489, -- Valnner Leap UPPER AL
}

-- Update the panel's leap timer. If preventOverwrite, the timer will not
-- be set if it's within 3 seconds of the previous update. This is because
-- both titans jump at different times, to not refresh the timer
local lastLeap = 0
local function CountDownLeap(durationMs, preventOverwrite)
    local currTime = GetGameTimeMilliseconds()
    if (preventOverwrite and currTime - lastLeap < 3000) then
        lastLeap = currTime
        return
    end
    lastLeap = currTime

    if (Crutch.savedOptions.osseincage.panel.showLeap) then
        Crutch.InfoPanel.CountDownDuration(PANEL_LEAP_INDEX, "|cfff1ab" .. GetAbilityName(233453) .. ": ", durationMs)
    end
end

local firstLeap = true -- Used to do initial leap timer
local numClashes = 0
-- 36.906, 38.246, 36.941, 36.819, 38.268, 38.263, 36.899
-- 36.6, 36.56, 37.9, 36.9, 36.58, 37.84, 36.9, 36.5
local function OnClashBegin()
    Crutch.dbgOther("clash begin")
    firstLeap = false -- just in case the user was pulled into the encounter
    numClashes = numClashes + 1

    Crutch.InfoPanel.StopCount(PANEL_LEAP_INDEX)

    if (Crutch.savedOptions.osseincage.panel.showClash) then
        Crutch.InfoPanel.CountDownHardStop(PANEL_CLASH_INDEX, "|cff6600" .. GetAbilityName(232517) .. ": ", 36500, true)
    end
end

-- Titanic Leap after Clash:
-- HM: 12.55, 12.58, 12.63, 12.56, 12.6, 12.65
-- vet: 21.60, 21.58
local function OnClashFaded()
    Crutch.dbgOther("clash FADED")

    UnspoofAllIcons()

    local timer = 21500
    if (IsHM()) then
        timer = 12500
    end
    CountDownLeap(timer, false)

    if (Crutch.savedOptions.general.showDamageable) then
        -- OCH shows it 2250 ms in, but they might be accounting for jump time. Carrion and Superheat VFX don't fade until 3s after clash fades
        Crutch.DisplayDamageable(2.25, "Jump in ")
    end
end

local function OnLeap()
    -- HM:
    -- 5.5, 5.58, 5.6 initial leap
    -- 1 usually leaps ~0.7s after the other in the beginning. this applies to after clash too. otherwise, it's ~2s after the other
    -- 1842.532 - 1758.016 = 84.5 from initial first leap to second first leap (maybe it's delayed by curse though)
    -- 2926.121 - 2840.647 = 85.5 "
    -- 3280.769 - 3195.939 = 84.8
    -- 4423.714 - 4366.224 = 57.5 from clash first leap to first leap after clash
    -- 4473.658 - 4423.714 = 49.9 post-clash 1st to 2nd leap
    -- regular vet:
    -- 10.55 initial leap
    -- 4664.415 - 4599.160 = 65.3 from clash first leap to first leap after clash. may be the nonhm timer
    -- 4762.558 - 4696.712 = 65.8 from second clash first leap to first leap after second clash

    -- more HM 75~35%: 48.4, 46.1, 47.4
    local timer = 46100 -- TODO: OCH seems to say 48, and 43 after the 2nd jump after 2nd clash?

    if (firstLeap) then -- First one of the pull is "delayed" by curse or something like that. 1:25.44, 1:24.8, 1:26.18, 1:24.26
        firstLeap = false
        timer = 84000
    end

    CountDownLeap(timer, true)

    -- TODO: is the timer since the first titan to leap, or the 2nd?
end

-- Starting combat initial leap
local function OnCombatStart()
    if (not OC.IsJynorah()) then
        return
    end

    local timer = 10500
    if (IsHM()) then
        timer = 5500
    end
    CountDownLeap(timer, true)
end

local function RegisterPanelEvents()
    for _, id in ipairs(LEAP_IDS) do
        Crutch.RegisterForCombatEvent("Leap" .. id, OnLeap, ACTION_RESULT_BEGIN, id)
    end

    Crutch.RegisterForCombatEvent("TitanicClashBegin", OnClashBegin, ACTION_RESULT_BEGIN, 232375)

    Crutch.RegisterForCombatEvent("TitanicClashFaded", OnClashFaded, ACTION_RESULT_EFFECT_FADED, 232375)
end

local function UnregisterPanelEvents()
    for _, id in ipairs(LEAP_IDS) do
        Crutch.UnregisterForCombatEvent("Leap" .. id)
    end

    Crutch.UnregisterForCombatEvent("TitanicClashBegin")
    Crutch.UnregisterForCombatEvent("TitanicClashFaded")

    OC.CleanUp()
end


---------------------------------------------------------------------
-- Atro Seeking Surge
-- Idea & prototype by @M0R_Gaming
---------------------------------------------------------------------
local atros = {}

-- Atro spawned, only care about the ones with Radiance, i.e. not channeler portal
local function OnRadiance(_, changeType, _, _, _, _, _, _, _, _, _, _, _, unitName, unitId, abilityId, sourceType)
    if (changeType == EFFECT_RESULT_GAINED) then
        atros[unitId] = 625279 -- Atro HP on HM
        -- [234683] = true, -- Radiance (Blazing Flame Atronach)
        -- [234680] = true, -- Radiance (Sparking Cold-Flame Atronach)

        -- TODO: only show if it's a relevant portal
        Crutch.DisplayNotification(abilityId, GetAbilityName(abilityId), 3, unitId, unitName, sourceType, unitId, unitName, sourceType, changeType, true)
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.DisplayNotification(C.ID.SEEKING_SURGE_DROPPED, "|cff00ffSeeking Surge dropped!|r", 5, unitId, unitName, sourceType, unitId, unitName, sourceType, changeType, true)
        atros[unitId] = nil
    end
end

local function RegisterHardmodeAtros()
    Crutch.RegisterForEffectChanged("OCColdFlameAtroSpawn", OnRadiance, 234680)
    Crutch.RegisterForEffectChanged("OCFlameAtroSpawn", OnRadiance, 234683)
end

local function UnregisterHardmodeAtros()
    Crutch.UnregisterForEffectChanged("OCColdFlameAtroSpawn")
    Crutch.UnregisterForEffectChanged("OCFlameAtroSpawn")
end


---------------------------------------------------------------------
-- Titan HP
---------------------------------------------------------------------
-- For Reflective Scale tracking
local damageTypes = {
    [ACTION_RESULT_DAMAGE] = "",
    [ACTION_RESULT_CRITICAL_DAMAGE] = "",
    [ACTION_RESULT_DOT_TICK] = " |cAAAAAA(dot)|r",
    [ACTION_RESULT_DOT_TICK_CRITICAL] = " |cAAAAAA(dot)|r",
}

-- Jynorah hp to titan hp
local TITAN_MAX_HPS = {
    [JYNORAH_HEALTH_HM] = 242176464,
    [JYNORAH_HEALTH_VET] = 151360288,
    [JYNORAH_HEALTH_NORMAL] = 35445864,
}

local TITAN_ATTACKS = {
    Valneer = {
        -- Myrinax -> Valneer
        [232242] = true, -- Monstrous Cleave
        [232243] = true, -- Sparking Bolt
        [235806] = true, -- Backhand
    },
    Myrinax = {
        -- Valneer -> Myrinax
        [232244] = true, -- Blazing Flame Bolt
        [232254] = true, -- Monstrous Cleave
        [235807] = true, -- Backhand
    },
}

local TITANS = {
    ["Myrinax"] = {
        fgColor = {7/255, 87/255, 179/255},
        bgColor = {1/255, 11/255, 23/255},
    },
    ["Valneer"] = {
        fgColor = {230/255, 129/255, 34/255},
        bgColor = {18/255, 9/255, 1/255},
    }
}

local titanIds = {} -- { 12345 = "Myrinax",} used for damage warning and cleanup

local function UnspoofTitans()
    for id, _ in pairs(titanIds) do
        Crutch.UntrackUnitForSpoofing(id)
    end
    ZO_ClearTable(titanIds)
end

local function StartTrackingTitan(unitId, bossTag, name)
    titanIds[unitId] = name

    if (Crutch.savedOptions.bossHealthBar.enabled and Crutch.savedOptions.osseincage.showTitansHp) then
        local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
        Crutch.TrackUnitForSpoofing(unitId, name, bossTag, TITAN_MAX_HPS[powerMax], TITANS[name].fgColor, TITANS[name].bgColor)
    end
end

local function UnregisterMyrinaxIdentification()
    Crutch.UnregisterForCombatEvent("IdentifyMyrinaxStunSelf")
    for abilityId, _ in pairs(TITAN_ATTACKS.Myrinax) do
        Crutch.UnregisterForCombatEvent("IdentifyMyrinax" .. abilityId)
    end
end

local function UnregisterValneerIdentification()
    Crutch.UnregisterForCombatEvent("IdentifyValneerStunSelf")
    for abilityId, _ in pairs(TITAN_ATTACKS.Valneer) do
        Crutch.UnregisterForCombatEvent("IdentifyValneer" .. abilityId)
    end
end

-- Earliest identifyable event on all(?) difficulties
local function OnMyrinaxStunSelf(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    Crutch.dbgOther(string.format("Identified Myrinax %d using Stun Self", targetUnitId))
    StartTrackingTitan(targetUnitId, "boss3", "Myrinax")
    UnregisterMyrinaxIdentification()
end

local function OnValneerStunSelf(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    Crutch.dbgOther(string.format("Identified Valneer %d using Stun Self", targetUnitId))
    StartTrackingTitan(targetUnitId, "boss4", "Valneer")
    UnregisterValneerIdentification()
end

-- Backup in case player is pulled into encounter
local function OnMyrinaxDamagedByValneer(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId, abilityId)
    Crutch.dbgOther(string.format("Identified Myrinax %d using %s", targetUnitId, GetAbilityName(abilityId)))
    StartTrackingTitan(targetUnitId, "boss3", "Myrinax")
    UnregisterMyrinaxIdentification()
end

local function OnValneerDamagedByMyrinax(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId, abilityId)
    Crutch.dbgOther(string.format("Identified Valneer %d using %s", targetUnitId, GetAbilityName(abilityId)))
    StartTrackingTitan(targetUnitId, "boss4", "Valneer")
    UnregisterValneerIdentification()
end

local function RegisterTitanIdentification()
    Crutch.RegisterForCombatEvent("IdentifyMyrinaxStunSelf", OnMyrinaxStunSelf, ACTION_RESULT_EFFECT_GAINED, 233486)
    for abilityId, _ in pairs(TITAN_ATTACKS.Myrinax) do
        Crutch.RegisterForCombatEvent("IdentifyMyrinax" .. abilityId, OnMyrinaxDamagedByValneer, ACTION_RESULT_DAMAGE, abilityId)
    end

    Crutch.RegisterForCombatEvent("IdentifyValneerStunSelf", OnValneerStunSelf, ACTION_RESULT_EFFECT_GAINED, 233497)
    for abilityId, _ in pairs(TITAN_ATTACKS.Valneer) do
        Crutch.RegisterForCombatEvent("IdentifyValneer" .. abilityId, OnValneerDamagedByMyrinax, ACTION_RESULT_DAMAGE, abilityId)
    end
end

local exitKey

local function UnregisterTwins()
    UnspoofTitans()

    UnregisterMyrinaxIdentification()
    UnregisterValneerIdentification()

    Crutch.DisableIconGroup("OCAOCH")
    Crutch.DisableIconGroup("OCAlt")
    Crutch.DisableIconGroup("OCMiddle")

    if (exitKey) then
        Crutch.Drawing.RemoveWorldTexture(exitKey)
        exitKey = nil
    end

    UnregisterPanelEvents()
end

local function RegisterTwins()
    UnregisterTwins()

    -- Titans BHB or reflective warning
    if ((Crutch.savedOptions.bossHealthBar.enabled and Crutch.savedOptions.osseincage.showTitansHp) or Crutch.savedOptions.osseincage.printHMReflectiveScales) then
        RegisterTitanIdentification()
    end

    -- Positioning icons
    if (Crutch.savedOptions.osseincage.showTwinsIcons) then
        if (Crutch.savedOptions.osseincage.useAOCHIcons) then
            Crutch.EnableIconGroup("OCAOCH")
        else
            Crutch.EnableIconGroup("OCAlt")
        end
        if (Crutch.savedOptions.osseincage.useMiddleIcons) then
            Crutch.EnableIconGroup("OCMiddle")
        end

        if (exitKey) then
            Crutch.Drawing.RemoveWorldTexture(exitKey)
        end
        exitKey = Crutch.Drawing.CreateSpaceLabel("Exit", 105100, 26400, 133400, 120, C.WHITE, false, {0, math.pi, 0})
    end

    -- Info panel
    RegisterPanelEvents()
end


---------------------------------------------------------------------
-- Which side player should be on
-- Assume the player receives the correct curse in the beginning, and
-- just flip it every time curse happens. Because prog groups would
-- be more likely to call wipe if the initial curse messes up, as
-- opposed to bad ones later. Also don't show it for tanks.
---------------------------------------------------------------------
local PANEL_ENFEEBLEMENT_INDEX = 7
local BLAZING_MALEDICTION_ID = 234284
local SPARKING_MALEDICTION_ID = 234011

local shouldTargetJynorah = nil

-- Initial curse
local function OnMaledictionGainedSelf(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    shouldTargetJynorah = (abilityId == SPARKING_MALEDICTION_ID) -- do the opposite here initially, because timeout will swap it
    Crutch.dbgOther("initialized shouldTargetJynorah " .. tostring(shouldTargetJynorah))
    Crutch.UnregisterForCombatEvent("SparkingMaledictionInfoPanelSelf")
    Crutch.UnregisterForCombatEvent("BlazingMaledictionInfoPanelSelf")
end

-- The player may not be guaranteed to get a curse themselves, so listen for all and debounce
local function OnMaledictionTimeout()
    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "MaledictionTimeout")

    zo_callLater(function()
        if (not Crutch.groupInCombat) then return end
        if (shouldTargetJynorah == nil) then
            Crutch.dbgOther("|cFF0000shouldTargetJynorah nil")
            return
        end

        -- Always flip sides
        shouldTargetJynorah = not shouldTargetJynorah
        Crutch.dbgOther("flipped shouldTargetJynorah: " .. tostring(shouldTargetJynorah))

        if (shouldTargetJynorah) then
            Crutch.InfoPanel.SetLine(PANEL_ENFEEBLEMENT_INDEX, "|c8ef5f5Target Jynorah / blue portal|r", 0.8)
        else
            Crutch.InfoPanel.SetLine(PANEL_ENFEEBLEMENT_INDEX, "|cff6600Target Skorkhif / orange portal|r", 0.8)
        end
    end, 4500)
end

local function OnMaledictionGained(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "MaledictionTimeout", 500, OnMaledictionTimeout)
end


---------------------------------------------------------------------
-- Player-attached icons for Enfeeblement
---------------------------------------------------------------------
-- {"Kyzeragon" = true}
local sparking = {}
local blazing = {}
local ENFEEBLEMENT_UNIQUE_NAME = "CrutchAlertsOCEnfeeblement"

-- If player is double cursed, show how long they are double cursed for
local function DoubleCurseIconCallback(icon, atName)
    if (sparking[atName] and blazing[atName]) then
        local doubleCursedDuration = math.min(sparking[atName], blazing[atName]) - GetGameTimeMilliseconds()
        icon:SetText(math.ceil(doubleCursedDuration / 1000))
    end
end

local function UpdateEnfeeblementIcon(atName, unitTag)
    Crutch.RemoveAttachedIconForUnit(unitTag, ENFEEBLEMENT_UNIQUE_NAME)

    local icon, color, callback, spaceOptions
    if (sparking[atName] and blazing[atName]) then
        -- Purplish
        icon = "/esoui/art/ava/ava_rankicon64_grandoverlord.dds"
        color = C.CURSEPURPLE
        callback = function(icon)
            DoubleCurseIconCallback(icon, atName)
        end
        spaceOptions = {
            label = {
                text = "!",
                size = 30,
                color = C.CURSEPURPLE,
            },
            texture = {
                path = "/esoui/art/ava/ava_rankicon64_grandoverlord.dds",
                size = 0.8,
                color = C.CURSEPURPLE,
            },
        }
    elseif (sparking[atName]) then
        -- Blue, matching OSI
        icon = "/esoui/art/ava/ava_rankicon64_tribune.dds"
        color = {0, 4/255, 1}
    elseif (blazing[atName]) then
        -- Orange, matching OSI
        icon = "/esoui/art/ava/ava_rankicon64_prefect.dds"
        color = {1, 113/255, 0}
    else
        -- No more icon
        Crutch.dbgSpam("Removed icon for " .. atName)
        return
    end

    Crutch.dbgSpam(string.format("Setting |t100%%:100%%:%s|t for %s", icon, atName))
    Crutch.SetAttachedIconForUnit(unitTag, ENFEEBLEMENT_UNIQUE_NAME, C.PRIORITY.MECHANIC_1_PRIORITY, icon, 100, color, false, callback, spaceOptions)
end

local areIconsEnabled
-- To be called when unit tags change
local function RefreshAllEnfeeblementIcons()
    if (not areIconsEnabled) then return end
    Crutch.dbgOther("|cFF0000REFRESHING ALL ENFEEBLEMENT ICONS!")
    Crutch.RemoveAllAttachedIcons(ENFEEBLEMENT_UNIQUE_NAME)
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if (unitTag and DoesUnitExist(unitTag)) then
            local atName = GetUnitDisplayName(unitTag)
            UpdateEnfeeblementIcon(atName, unitTag)
        end
    end
end

local function OnEnfeeblement(enfeeblementStruct, changeType, unitTag, durationMs)
    local atName = GetUnitDisplayName(unitTag)
    if (changeType == EFFECT_RESULT_GAINED) then
        enfeeblementStruct[atName] = GetGameTimeMilliseconds() + durationMs
        UpdateEnfeeblementIcon(atName, unitTag)
    elseif (changeType == EFFECT_RESULT_UPDATED) then
        enfeeblementStruct[atName] = GetGameTimeMilliseconds() + durationMs
    elseif (changeType == EFFECT_RESULT_FADED) then
        enfeeblementStruct[atName] = nil
        UpdateEnfeeblementIcon(atName, unitTag)
    end
end

local function UnregisterEnfeeblement()
    Crutch.dbgSpam("Unregistering Enfeeblement")
    Crutch.UnregisterForEffectChanged("SparkingEnfeeblement")
    Crutch.UnregisterForEffectChanged("BlazingEnfeeblement")
    areIconsEnabled = false
end

local function RegisterEnfeeblement()
    UnregisterEnfeeblement()

    Crutch.dbgSpam("Registering Enfeeblement")
    Crutch.RegisterForEffectChanged("SparkingEnfeeblement", function(_, changeType, _, _, unitTag, beginTime, endTime)
        OnEnfeeblement(sparking, changeType, unitTag, (endTime - beginTime) * 1000)
    end, 233644, "group")

    Crutch.RegisterForEffectChanged("BlazingEnfeeblement", function(_, changeType, _, _, unitTag, beginTime, endTime)
        OnEnfeeblement(blazing, changeType, unitTag, (endTime - beginTime) * 1000)
    end, 233692, "group")

    areIconsEnabled = true
end


---------------------------------------------------------------------
-- Twins entry
---------------------------------------------------------------------
local function IsJynorah()
    local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    return TITAN_MAX_HPS[powerMax] ~= nil
end
OC.IsJynorah = IsJynorah

local function MaybeRegisterTwins()
    if (IsJynorah()) then
        RegisterTwins()
    else
        UnregisterTwins()
    end

    if (IsHM()) then
        RegisterHardmodeAtros()
    else
        UnregisterHardmodeAtros()
    end

    -- Check health for upcoming portal
    if (IsHM() and Crutch.savedOptions.osseincage.enableAbilityOverlay) then
        Crutch.dbgOther("registering twins health")
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "OCTwinsHealth", EVENT_POWER_UPDATE, OnTwinsHealth)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCTwinsHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCTwinsHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
    else
        Crutch.dbgOther("unregistering twins health")
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OCTwinsHealth", EVENT_POWER_UPDATE)
    end

    -- Only enable enfeeblement icons if the difficulty is appropriate
    local enfeeblementOption = Crutch.savedOptions.osseincage.showEnfeeblementIcons
    if (enfeeblementOption == "NEVER") then
        UnregisterEnfeeblement()
        return
    elseif (enfeeblementOption == "ALWAYS") then
        RegisterEnfeeblement()
    elseif (enfeeblementOption == "HM" and IsHM()) then
        RegisterEnfeeblement()
    elseif (enfeeblementOption == "VET" and (IsHM() or IsBaseVet())) then
        RegisterEnfeeblement()
    else
        UnregisterEnfeeblement()
    end

    -- Info panel target / portal
    if (Crutch.savedOptions.osseincage.panel.showTarget and IsHM() and GetSelectedLFGRole() ~= LFG_ROLE_TANK) then
        Crutch.RegisterForCombatEvent("SparkingMaledictionInfoPanel", OnMaledictionGained, ACTION_RESULT_EFFECT_GAINED, SPARKING_MALEDICTION_ID)
        Crutch.RegisterForCombatEvent("SparkingMaledictionInfoPanelSelf", OnMaledictionGainedSelf, ACTION_RESULT_EFFECT_GAINED, SPARKING_MALEDICTION_ID, nil, COMBAT_UNIT_TYPE_PLAYER)
        Crutch.RegisterForCombatEvent("BlazingMaledictionInfoPanel", OnMaledictionGained, ACTION_RESULT_EFFECT_GAINED, BLAZING_MALEDICTION_ID)
        Crutch.RegisterForCombatEvent("BlazingMaledictionInfoPanelSelf", OnMaledictionGainedSelf, ACTION_RESULT_EFFECT_GAINED, BLAZING_MALEDICTION_ID, nil, COMBAT_UNIT_TYPE_PLAYER)
    else
        Crutch.UnregisterForCombatEvent("SparkingMaledictionInfoPanel")
        Crutch.UnregisterForCombatEvent("SparkingMaledictionInfoPanelSelf")
        Crutch.UnregisterForCombatEvent("BlazingMaledictionInfoPanel")
        Crutch.UnregisterForCombatEvent("BlazingMaledictionInfoPanelSelf")
    end

    -- Reflective Scales
    for damageResult, str in pairs(damageTypes) do
        -- Only enable if on HM
        if (IsHM() and Crutch.savedOptions.osseincage.printHMReflectiveScales) then
            Crutch.RegisterForCombatEvent("OCTitanReflect" .. tostring(damageResult), function(_, _, _, _, _, _, _, sourceType, _, _, _, _, _, _, _, targetUnitId, abilityId)
                if (sourceType == COMBAT_UNIT_TYPE_PLAYER and titanIds[targetUnitId]) then
                    Crutch.msg(string.format("You hit %s with |cFF00FF%s|r%s", titanIds[targetUnitId], GetAbilityName(abilityId), str))
                end
            end, damageResult, nil, nil, COMBAT_UNIT_TYPE_NONE)
        else
            Crutch.UnregisterForCombatEvent("OCTitanReflect" .. tostring(damageResult))
        end
    end
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local function CleanUp()
    Crutch.InfoPanel.StopCount(PANEL_LEAP_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_CLASH_INDEX)
    numClashes = 0
    firstLeap = true
    ZO_ClearTable(bossHealths)
    UnspoofAllIcons()

    UnspoofTitans()
    ZO_ClearTable(sparking)
    ZO_ClearTable(blazing)

    shouldTargetJynorah = nil

    Crutch.InfoPanel.StopCount(PANEL_ENFEEBLEMENT_INDEX)
end
OC.CleanUp = CleanUp -- TODO: maybe rearrange stuff


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function OC.RegisterOCZoneTwins()
    Crutch.RegisterEnteredGroupCombatListener("CrutchOsseinCageJynorahEnteredCombat", OnCombatStart)
    Crutch.RegisterExitedGroupCombatListener("CrutchOsseinCageJynorahExitedCombat", CleanUp)

    -- Bosses changed, for titan spoofing and Enfeeblement markers
    -- This is delayed a bit because HM wipes respawn the boss at the nonHM health, and then increase max health.
    -- That doesn't seem to trigger my power update below? idk need more testing, but want to upload working version first
    Crutch.RegisterBossChangedListener("CrutchOsseinCage", function() zo_callLater(MaybeRegisterTwins, 3000) end)
    MaybeRegisterTwins()

    -- Register for OC difficulty change (to enable Enfeeblement)
    local prevMaxHealth = 0
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "OCHealthUpdate", EVENT_POWER_UPDATE, function(_, _, _, _, _, powerMax)
        -- Crutch.dbgSpam(string.format("%d %d", powerMax, prevMaxHealth))
        if (prevMaxHealth == powerMax) then return end -- Only check if the max health changed, not when % changes
        prevMaxHealth = powerMax
        Crutch.dbgSpam("max hp changed")
        MaybeRegisterTwins()
    end)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCHealthUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss1")
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCHealthUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)

    Crutch.RegisterUnitTagListener("CrutchAlertsOCEnfeeblementRefresh", RefreshAllEnfeeblementIcons)
end

function OC.UnregisterOCZoneTwins()
    Crutch.UnregisterEnteredGroupCombatListener("CrutchOsseinCageJynorahEnteredCombat")
    Crutch.UnregisterExitedGroupCombatListener("CrutchOsseinCageJynorahExitedCombat")

    Crutch.UnregisterBossChangedListener("CrutchOsseinCage")

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OCHealthUpdate", EVENT_POWER_UPDATE)

    Crutch.UnregisterUnitTagListener("CrutchAlertsOCEnfeeblementRefresh")

    MaybeRegisterTwins()
end
