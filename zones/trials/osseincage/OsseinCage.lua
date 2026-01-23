local Crutch = CrutchAlerts
Crutch.OsseinCage = {}
local C = Crutch.Constants


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
    [85320632] = 242176464,
    [37257920] = 151360288,
    [10906420] = 35445864,
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
end

-- TODO: sync if you pass reticle over them?


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
Crutch.Spark = function(tag, effect) OnEnfeeblement(sparking, effect, tag) end
Crutch.Blaze = function(tag, effect) OnEnfeeblement(blazing, effect, tag) end
--[[
/script CrutchAlerts.Spark("group1", EFFECT_RESULT_GAINED)
/script CrutchAlerts.Spark("group1", EFFECT_RESULT_FADED)
/script CrutchAlerts.Blaze("group1", EFFECT_RESULT_GAINED)
/script CrutchAlerts.Blaze("group1", EFFECT_RESULT_FADED)
]]

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

    if (powerMax == 85320632 or powerMax == 37257920) then -- TODO: for testing, remove later
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
    elseif (enfeeblementOption == "HM" and powerMax == 85320632) then
        RegisterEnfeeblement()
    elseif (enfeeblementOption == "VET" and (powerMax == 85320632 or powerMax == 37257920)) then
        RegisterEnfeeblement()
    else
        UnregisterEnfeeblement()
    end

    -- Reflective Scales
    for damageResult, str in pairs(damageTypes) do
        -- Only enable if on HM
        if (powerMax == 85320632 and Crutch.savedOptions.osseincage.printHMReflectiveScales) then
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
-- Stricken
---------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnStricken(_, changeType, _, _, unitTag, beginTime, endTime)
    local atName = GetUnitDisplayName(unitTag)
    local tagNumber = string.gsub(unitTag, "group", "")
    local tagId = tonumber(tagNumber)
    local fakeSourceUnitId = 8880100 + tagId -- TODO: really gotta rework the alerts and stop hacking around like this

    -- Gained
    if (changeType == EFFECT_RESULT_GAINED) then
        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(zo_strformat("<<1>> got Stricken", atName))
        end

        -- Event is not registered if NEVER, so the only other option is TANK
        if (Crutch.savedOptions.osseincage.showStricken == "ALWAYS" or GetSelectedLFGRole() == LFG_ROLE_TANK) then
            local label = zo_strformat("|ca361ff<<C:1>>: <<2>>|r", GetAbilityName(235594), atName)
            Crutch.DisplayNotification(235594, label, (endTime - beginTime) * 1000, fakeSourceUnitId, 0, 0, 0, 0, 0, 0, false)
        end

    -- Faded
    elseif (changeType == EFFECT_RESULT_FADED) then
        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(zo_strformat("<<1>> is no longer Stricken", atName))
        end

        Crutch.Interrupted(fakeSourceUnitId)
    end
end


---------------------------------------------------------------------
-- Icons for Dominator's Chains
---------------------------------------------------------------------
-- Chains start off with an initial debuff, 232773 and 232775
-- 4 seconds later, the real tether starts, 232780 and 232779. The initial debuff fades immediately after
-- We need to account for the possibility of someone dying during the 4 seconds,
-- which means the tether doesn't cast
local CHAIN_UNIQUE_NAME = "CrutchAlertsOCChain"
local chainsDisplaying1, chainsDisplaying2 -- unit tag of player if there is some kind of chains on them

local UNSAFE = 20 -- Chains have red effect when under 20m
local SUS = 25
local SAFE = 30 -- Arbitrary number just for the constant
local prevInThreshold = UNSAFE
local function ChangeLineColor(distance)
    if (distance <= UNSAFE) then
        if (prevInThreshold == UNSAFE) then
            return -- No change, still red
        end
        prevInThreshold = UNSAFE
        Crutch.SetLineColor(1, 0, 0, 0.5, 0.5, Crutch.savedOptions.debugLineDistance)
    elseif (distance <= SUS) then
        if (prevInThreshold == SUS) then
            return -- No change, still yellow
        end
        prevInThreshold = SUS
        Crutch.SetLineColor(1, 1, 0, 0.4, 0.4, Crutch.savedOptions.debugLineDistance)
    else
        if (prevInThreshold == SAFE) then
            return -- No change, still green
        end
        prevInThreshold = SAFE
        Crutch.SetLineColor(0, 1, 0, 0.3, 0.3, Crutch.savedOptions.debugLineDistance)
    end
end

local function AddChainToPlayer(unitTag)
    if (chainsDisplaying1 == unitTag or chainsDisplaying2 == unitTag) then
        -- If this is the same player, do nothing because it's already displaying
        return
    end

    local iconPath = "esoui/art/trials/vitalitydepletion.dds"

    Crutch.dbgSpam(string.format("Setting |t100%%:100%%:%s|t for %s", iconPath, GetUnitDisplayName(unitTag)))
    Crutch.SetAttachedIconForUnit(unitTag, CHAIN_UNIQUE_NAME, C.PRIORITY.MECHANIC_1_PRIORITY, iconPath, 100, {1, 0, 1, 1})


    if (not chainsDisplaying1) then
        -- If no one has chains yet, consider this the first one and save it for later
        chainsDisplaying1 = unitTag
    else
        -- If the other player has already received it, we can draw the line
        chainsDisplaying2 = unitTag
        prevInThreshold = UNSAFE
        Crutch.SetLineColor(1, 0, 0, 0.4, 0.4, Crutch.savedOptions.debugLineDistance)
        Crutch.DrawLineBetweenPlayers(chainsDisplaying1, unitTag, ChangeLineColor)
    end
end
Crutch.AddChainToPlayer = AddChainToPlayer -- /script CrutchAlerts.AddChainToPlayer("group1") CrutchAlerts.AddChainToPlayer("group2")

-- Completely remove it from both players, and remove the line
local function RemoveChain()
    Crutch.RemoveLine()
    Crutch.RemoveAttachedIconForUnit(chainsDisplaying1, CHAIN_UNIQUE_NAME)
    Crutch.RemoveAttachedIconForUnit(chainsDisplaying2, CHAIN_UNIQUE_NAME)
    chainsDisplaying1 = nil
    chainsDisplaying2 = nil
end

local tethered = {} -- Anyone who has the real tether. [@name] = true
local function OnChainsInitial(_, changeType, _, _, unitTag)
    if (changeType == EFFECT_RESULT_GAINED) then
        -- Show the icons and line as soon as the initial debuff starts
        AddChainToPlayer(unitTag)
    elseif (changeType == EFFECT_RESULT_FADED) then
        -- When it fades, check if the real tether is already up. If yes, do nothing.
        if (tethered[unitTag]) then
            return
        end

        -- If not, then the player died before the actual tether appeared, so remove the icons
        RemoveChain()
    end
end

-- The actual tether when it's active
local function OnChainsTether(_, changeType, _, _, unitTag)
    if (changeType == EFFECT_RESULT_GAINED) then
        tethered[unitTag] = true
        AddChainToPlayer(unitTag) -- This shouldn't be needed, but idk, do it anyway
    elseif (changeType == EFFECT_RESULT_FADED) then
        tethered[unitTag] = nil
        RemoveChain()
    end
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterOsseinCage()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Ossein Cage")

    Crutch.OsseinCage.RegisterCarrion()

    Crutch.RegisterExitedGroupCombatListener("ExitedCombatOsseinCage", function()
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

    -- Stricken (tank swap)
    if (Crutch.savedOptions.osseincage.showStricken ~= "NEVER") then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Stricken", EVENT_EFFECT_CHANGED, OnStricken)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Stricken", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Stricken", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 235594)
    end

    -- Icons/line for Dominator's Chains
    if (Crutch.savedOptions.osseincage.showChains) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ChainsInitial1", EVENT_EFFECT_CHANGED, OnChainsInitial)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ChainsInitial1", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 232773)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ChainsInitial1", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ChainsInitial2", EVENT_EFFECT_CHANGED, OnChainsInitial)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ChainsInitial2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 232775)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ChainsInitial2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ChainsTether1", EVENT_EFFECT_CHANGED, OnChainsTether)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ChainsTether1", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 232779)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ChainsTether1", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ChainsTether2", EVENT_EFFECT_CHANGED, OnChainsTether)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ChainsTether2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 232780)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ChainsTether2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    end
end

function Crutch.UnregisterOsseinCage()
    Crutch.OsseinCage.UnregisterCarrion()

    Crutch.UnregisterExitedGroupCombatListener("ExitedCombatOsseinCage")

    Crutch.UnregisterBossChangedListener("CrutchOsseinCage")

    UnregisterEnfeeblement()

    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OCHealthUpdate", EVENT_POWER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Stricken", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ChainsInitial1", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ChainsInitial2", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ChainsTether1", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ChainsTether2", EVENT_EFFECT_CHANGED)

    for damageResult, _ in pairs(damageTypes) do
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "OCTitanReflect" .. tostring(damageResult), EVENT_COMBAT_EVENT)
    end

    -- Clean up in case of PTE; unit tags may change
    Crutch.RemoveAllAttachedIcons(ENFEEBLEMENT_UNIQUE_NAME)
    Crutch.RemoveAllAttachedIcons(CHAIN_UNIQUE_NAME)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Ossein Cage")
end
