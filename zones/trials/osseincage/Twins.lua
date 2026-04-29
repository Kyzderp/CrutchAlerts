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
local DANGEROUS_ABILITIES = {
    [38901] = true, -- Quick Cloak
    [22095] = true, -- Solar Barrage
    [32853] = true, -- Flames of Oblivion
    [23231] = true, -- Hurricane
    -- [61505] = true, -- Echoing Vigor (testing)
}

local spoofedAbilities = {}
local function SpoofIconIfDangerous(abilityId)
    if (not DANGEROUS_ABILITIES[abilityId]) then return end

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

-- Cleanup
local function CleanUp()
    Crutch.InfoPanel.StopCount(PANEL_LEAP_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_CLASH_INDEX)
    numClashes = 0
    firstLeap = true
    ZO_ClearTable(bossHealths)
    UnspoofAllIcons()
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

    CleanUp()
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
    -- Myrinax -> Valneer
    [232242] = "Myrinax", -- Monstrous Cleave
    [232243] = "Myrinax", -- Sparking Bolt
    [235806] = "Myrinax", -- Backhand
    -- Valneer -> Myrinax
    [232244] = "Valneer", -- Blazing Flame Bolt
    [232254] = "Valneer", -- Monstrous Cleave
    [235807] = "Valneer", -- Backhand
}

local TITANS = {
    ["Myrinax"] = {
        tag = "boss3",
        fgColor = {7/255, 87/255, 179/255},
        bgColor = {1/255, 11/255, 23/255},
    },
    ["Valneer"] = {
        tag = "boss4",
        fgColor = {230/255, 129/255, 34/255},
        bgColor = {18/255, 9/255, 1/255},
    }
}

local titanMaxHp = 0
local titanIds = {} -- { 12345 = {name = "Myrinax", hp = 3213544},}
local myrinaxFound = false
local valneerFound = false

local function SpoofTitans()
    -- Fake each boss for BHB
    for name, data in pairs(TITANS) do
        Crutch.SpoofBoss(data.tag, name, function()
            -- This probably isn't worth a reverse lookup, just iterate and find the right one
            for _, titan in pairs(titanIds) do
                if (titan.name == name) then
                    return titan.hp, titanMaxHp, titanMaxHp
                end
            end
            Crutch.dbgOther("|cFF0000Couldn't find titans (end of encounter?)|r")
            return 0.5, 1, 1
        end,
        data.fgColor,
        data.bgColor)
    end
end
Crutch.SpoofTitans = SpoofTitans

local function UnspoofTitans()
    for name, data in pairs(TITANS) do
        Crutch.UnspoofBoss(data.tag)
    end
end

function CrutchAlerts.TestSpoof()
    UnspoofTitans()
    ZO_ClearTable(titanIds)
    SpoofTitans()
end


-- Listen for incoming damage on the titans and subtract it from the max health
local function OnTitanDamage(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    -- Store the unit ids if not already known
    -- Source shows as 0, so we can't do both at once
    if (not valneerFound) then
        if (TITAN_ATTACKS[abilityId] == "Myrinax") then
            local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
            titanMaxHp = TITAN_MAX_HPS[powerMax]
            titanIds[targetUnitId] = {name = "Valneer", hp = titanMaxHp}
            Crutch.dbgOther(string.format("Identified Valneer %d", targetUnitId))
            valneerFound = true

            -- Both found, initialize
            if (myrinaxFound) then
                SpoofTitans()
            end
        end
    end

    if (not myrinaxFound) then
        if (TITAN_ATTACKS[abilityId] == "Valneer") then
            local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
            titanMaxHp = TITAN_MAX_HPS[powerMax]
            titanIds[targetUnitId] = {name = "Myrinax", hp = titanMaxHp}
            Crutch.dbgOther(string.format("Identified Myrinax %d", targetUnitId))
            myrinaxFound = true

            -- Both found, initialize
            if (valneerFound) then
                SpoofTitans()
            end
        end
    end

    local targetTitan = titanIds[targetUnitId]
    if (not targetTitan) then return end

    targetTitan.hp = targetTitan.hp - hitValue

    Crutch.UpdateSpoofedBossHealth(TITANS[targetTitan.name].tag, targetTitan.hp, titanMaxHp)
end

local exitKey

local function UnregisterTwins()
    UnspoofTitans()
    Crutch.UnregisterForCombatEvent("OCTitanDamage")
    Crutch.UnregisterForCombatEvent("OCTitanDotTick")

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

    -- Titans BHB
    -- Event listening for all damage on enemies, registered only when Jynorah is active
    if (Crutch.savedOptions.bossHealthBar.enabled and Crutch.savedOptions.osseincage.showTitansHp) then
        -- Player damage ticks for only 1 each, so imo it's negligible enough to
        -- not do that extra processing. So it should be fine to ignore crits
        Crutch.RegisterForCombatEvent("OCTitanDamage", OnTitanDamage, ACTION_RESULT_DAMAGE, nil, nil,  COMBAT_UNIT_TYPE_NONE)

        -- The atro surges count as dots though
        Crutch.RegisterForCombatEvent("OCTitanDotTick", OnTitanDamage, ACTION_RESULT_DOT_TICK, nil, nil,  COMBAT_UNIT_TYPE_NONE)
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
        color = {183/255, 38/255, 1}
        callback = function(icon)
            DoubleCurseIconCallback(icon, atName)
        end
        spaceOptions = {
            label = {
                text = "!",
                size = 30,
                color = {183/255, 38/255, 1},
            },
            texture = {
                path = "/esoui/art/ava/ava_rankicon64_grandoverlord.dds",
                size = 0.8,
                color = {183/255, 38/255, 1},
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

    -- Reflective Scales
    for damageResult, str in pairs(damageTypes) do
        -- Only enable if on HM
        if (IsHM() and Crutch.savedOptions.osseincage.printHMReflectiveScales) then
            Crutch.RegisterForCombatEvent("OCTitanReflect" .. tostring(damageResult), function(_, _, _, _, _, _, _, sourceType, _, _, _, _, _, _, _, targetUnitId, abilityId)
                if (sourceType == COMBAT_UNIT_TYPE_PLAYER and titanIds[targetUnitId]) then
                    Crutch.msg(string.format("You hit a titan with |cFF00FF%s|r%s", GetAbilityName(abilityId), str))
                end
            end, damageResult, nil, nil, COMBAT_UNIT_TYPE_NONE)
        else
            Crutch.UnregisterForCombatEvent("OCTitanReflect" .. tostring(damageResult))
        end
    end
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function OC.RegisterTwins()
    Crutch.RegisterEnteredGroupCombatListener("CrutchOsseinCageJynorahEnteredCombat", OnCombatStart)
    Crutch.RegisterExitedGroupCombatListener("CrutchOsseinCageJynorahExitedCombat", CleanUp)

    Crutch.RegisterExitedGroupCombatListener("ExitedCombatOsseinCageTwins", function()
        ZO_ClearTable(titanIds)
        titanMaxHp = 0
        myrinaxFound = false
        valneerFound = false
        UnspoofTitans()
        ZO_ClearTable(sparking)
        ZO_ClearTable(blazing)
    end)

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

    -- Check health for upcoming portal
    if (IsHM() and Crutch.savedOptions.osseincage.enableAbilityOverlay) then
        Crutch.dbgOther("registering twins health")
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "OCTwinsHealth", EVENT_POWER_UPDATE, OnTwinsHealth)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCTwinsHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCTwinsHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
    end
end

function OC.UnregisterTwins()
    Crutch.UnregisterEnteredGroupCombatListener("CrutchOsseinCageJynorahEnteredCombat")
    Crutch.UnregisterExitedGroupCombatListener("CrutchOsseinCageJynorahExitedCombat")

    Crutch.UnregisterExitedGroupCombatListener("ExitedCombatOsseinCageTwins")

    Crutch.UnregisterBossChangedListener("CrutchOsseinCage")

    UnregisterEnfeeblement()

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OCHealthUpdate", EVENT_POWER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OCTwinsHealth", EVENT_POWER_UPDATE)

    for damageResult, _ in pairs(damageTypes) do
        Crutch.UnregisterForCombatEvent("OCTitanReflect" .. tostring(damageResult))
    end
end
