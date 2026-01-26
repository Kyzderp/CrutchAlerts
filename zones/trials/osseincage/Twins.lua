local Crutch = CrutchAlerts
local C = Crutch.Constants


---------------------------------------------------------------------
local JYNORAH_HEALTH_HM = 85320632
local JYNORAH_HEALTH_VET = 37257920
local JYNORAH_HEALTH_NORMAL = 10906420

local function IsHM()
    local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    return powerMax == JYNORAH_HEALTH_HM
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
    Crutch.InfoPanel.CountDownDuration(PANEL_LEAP_INDEX, GetAbilityName(233453) .. ": ", durationMs)
end

local function OnClashLeap()
    Crutch.dbgOther("clash leap")
end

local numClashes = 0
local function OnClash()
    Crutch.dbgOther("clash")
    numClashes = numClashes + 1

    -- Titanic Clash
    Crutch.InfoPanel.CountDownHardStop(PANEL_CLASH_INDEX, GetAbilityName(232517) .. ": ", 39800, true)

    -- Titanic Leap after Clash:
    -- HM: 55.77, 53.27, 52.5, 54.2, 56.2 why do they vary so much
    -- vet: 63.7, 63.37 (second),62.6, 62.7 (second)
    local timer = 62600
    if (IsHM()) then
        timer = 55000
    end
    CountDownLeap(timer, false)
end

local function OnLeap()
    Crutch.dbgOther("leap")
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

    local timer = 49900 -- TODO: OCH seems to say 48, and 43 after the 2nd jump after clash?
    CountDownLeap(timer, true)

    -- TODO: is the timer since the first titan to leap, or the 2nd?
end

-- Starting combat initial leap
local function OnCombatStart()
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
end

local function RegisterPanelEvents()
    Crutch.RegisterEnteredGroupCombatListener("CrutchOsseinCageJynorahEnteredCombat", OnCombatStart)
    Crutch.RegisterEnteredGroupCombatListener("CrutchOsseinCageJynorahExitedCombat", CleanUp)

    for _, id in ipairs(LEAP_IDS) do
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Leap" .. id, EVENT_COMBAT_EVENT, OnLeap)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Leap" .. id, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Leap" .. id, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
    end

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "MyrClashLeap", EVENT_COMBAT_EVENT, OnClashLeap)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "MyrClashLeap", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "MyrClashLeap", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 233500)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ValClashLeap", EVENT_COMBAT_EVENT, OnClashLeap)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ValClashLeap", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ValClashLeap", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 233512)

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "TitanicClash", EVENT_COMBAT_EVENT, OnClash)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TitanicClash", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "TitanicClash", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 232517)
end

local function UnregisterPanelEvents()
    Crutch.UnregisterEnteredGroupCombatListener("CrutchOsseinCageJynorahEnteredCombat")
    Crutch.UnregisterEnteredGroupCombatListener("CrutchOsseinCageJynorahExitedCombat")

    for _, id in ipairs(LEAP_IDS) do
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Leap" .. id, EVENT_COMBAT_EVENT)
    end

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "MyrClashLeap", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ValClashLeap", EVENT_COMBAT_EVENT)

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "TitanicClash", EVENT_COMBAT_EVENT)

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
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "OCColdFlameAtroSpawn", EVENT_EFFECT_CHANGED, OnRadiance)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCColdFlameAtroSpawn", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 234680)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "OCFlameAtroSpawn", EVENT_EFFECT_CHANGED, OnRadiance)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCFlameAtroSpawn", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 234683)
end

local function UnregisterHardmodeAtros()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OCColdFlameAtroSpawn", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OCFlameAtroSpawn", EVENT_EFFECT_CHANGED)
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
            Crutch.dbgOther("|cFF0000Couldn't find titans?????????|r")
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

    -- Crutch.dbgSpam(string.format("%s(%d) hit by %s(%d) for %d",
    --     targetTitan.name,
    --     targetUnitId,
    --     GetAbilityName(abilityId),
    --     abilityId,
    --     hitValue))

    targetTitan.hp = targetTitan.hp - hitValue

    -- Crutch.dbgSpam(string.format("%s(%d) HP %d / %d (%.2f)",
    --     targetTitan.name,
    --     targetUnitId,
    --     targetTitan.hp,
    --     titanMaxHp,
    --     targetTitan.hp * 100 / titanMaxHp))

    Crutch.UpdateSpoofedBossHealth(TITANS[targetTitan.name].tag, targetTitan.hp, titanMaxHp)
end

local exitKey

-- Event listening for all damage on enemies, registered only when Jynorah is active
local function UnregisterTwins()
    Crutch.dbgOther("Unregistering twins")
    UnspoofTitans()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OCTitanDamage", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OCTitanDotTick", EVENT_COMBAT_EVENT)

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
    Crutch.dbgOther("Registering twins")

    -- Titans BHB
    if (Crutch.savedOptions.bossHealthBar.enabled and Crutch.savedOptions.osseincage.showTitansHp) then
        -- Player damage ticks for only 1 each, so imo it's negligible enough to
        -- not do that extra processing. So it should be fine to ignore crits
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "OCTitanDamage", EVENT_COMBAT_EVENT, OnTitanDamage)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCTitanDamage", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DAMAGE) 
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCTitanDamage", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)

        -- The atro surges count as dots though
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "OCTitanDotTick", EVENT_COMBAT_EVENT, OnTitanDamage)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCTitanDotTick", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DOT_TICK)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCTitanDotTick", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
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

local function UpdateEnfeeblementIcon(atName, unitTag)
    Crutch.RemoveAttachedIconForUnit(unitTag, ENFEEBLEMENT_UNIQUE_NAME)

    local icon, color
    if (sparking[atName] and blazing[atName]) then
        -- Purplish
        icon = "/esoui/art/ava/ava_rankicon64_grandoverlord.dds"
        color = {183/255, 38/255, 1}
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
    Crutch.SetAttachedIconForUnit(unitTag, ENFEEBLEMENT_UNIQUE_NAME, C.PRIORITY.MECHANIC_1_PRIORITY, icon, 100, color)
end

local function OnEnfeeblement(enfeeblementStruct, changeType, unitTag)
    local atName = GetUnitDisplayName(unitTag)
    if (changeType == EFFECT_RESULT_GAINED) then
        enfeeblementStruct[atName] = true
        UpdateEnfeeblementIcon(atName, unitTag)
    elseif (changeType == EFFECT_RESULT_FADED) then
        enfeeblementStruct[atName] = nil
        UpdateEnfeeblementIcon(atName, unitTag)
    end
end

local function UnregisterEnfeeblement()
    Crutch.dbgSpam("Unregistering Enfeeblement")
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "SparkingEnfeeblement", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "BlazingEnfeeblement", EVENT_EFFECT_CHANGED)
end

local function RegisterEnfeeblement()
    UnregisterEnfeeblement()

    Crutch.dbgSpam("Registering Enfeeblement")
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "SparkingEnfeeblement", EVENT_EFFECT_CHANGED, function(_, changeType, _, _, unitTag)
        OnEnfeeblement(sparking, changeType, unitTag)
    end)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "SparkingEnfeeblement", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 233644)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "SparkingEnfeeblement", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "BlazingEnfeeblement", EVENT_EFFECT_CHANGED, function(_, changeType, _, _, unitTag)
        OnEnfeeblement(blazing, changeType, unitTag)
    end)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BlazingEnfeeblement", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 233692)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "BlazingEnfeeblement", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end


---------------------------------------------------------------------
-- Twins entry
---------------------------------------------------------------------
local function MaybeRegisterTwins()
    -- Check if it's Jynorah
    local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (TITAN_MAX_HPS[powerMax]) then
        RegisterTwins()
    else
        UnregisterTwins()
    end

    if (powerMax == JYNORAH_HEALTH_HM) then
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
    elseif (enfeeblementOption == "HM" and powerMax == JYNORAH_HEALTH_HM) then
        RegisterEnfeeblement()
    elseif (enfeeblementOption == "VET" and (powerMax == JYNORAH_HEALTH_HM or powerMax == JYNORAH_HEALTH_VET)) then
        RegisterEnfeeblement()
    else
        UnregisterEnfeeblement()
    end

    -- Reflective Scales
    for damageResult, str in pairs(damageTypes) do
        -- Only enable if on HM
        if (powerMax == JYNORAH_HEALTH_HM and Crutch.savedOptions.osseincage.printHMReflectiveScales) then
            EVENT_MANAGER:RegisterForEvent(Crutch.name .. "OCTitanReflect" .. tostring(damageResult), EVENT_COMBAT_EVENT, function(_, _, _, _, _, _, _, sourceType, _, _, _, _, _, _, _, targetUnitId, abilityId)
                if (sourceType == COMBAT_UNIT_TYPE_PLAYER and titanIds[targetUnitId]) then
                    Crutch.msg(string.format("You hit a titan with |cFF00FF%s|r%s", GetAbilityName(abilityId), str))
                end
            end)
            EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCTitanReflect" .. tostring(damageResult), EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, damageResult) 
            EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "OCTitanReflect" .. tostring(damageResult), EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
        else
            EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OCTitanReflect" .. tostring(damageResult), EVENT_COMBAT_EVENT)
        end
    end
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.OsseinCage.RegisterTwins()
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
end

function Crutch.OsseinCage.UnregisterTwins()
    Crutch.UnregisterExitedGroupCombatListener("ExitedCombatOsseinCageTwins")

    Crutch.UnregisterBossChangedListener("CrutchOsseinCage")

    UnregisterEnfeeblement()

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OCHealthUpdate", EVENT_POWER_UPDATE)

    for damageResult, _ in pairs(damageTypes) do
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OCTitanReflect" .. tostring(damageResult), EVENT_COMBAT_EVENT)
    end
end
