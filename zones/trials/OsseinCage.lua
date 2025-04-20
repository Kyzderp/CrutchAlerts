CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts


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
            Crutch.DisplayNotification(235594, label, (endTime - beginTime) * 1000, fakeSourceUnitId, 0, 0, 0, false)
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

local chainsDisplaying1, chainsDisplaying2 -- unit tag of player if there is some kind of chains on them

local UNSAFE = 20 -- Chains have red effect when under 20m
local SUS = 25
local SAFE = 30 -- Arbitrary number just for the constant
local SHOW_DISTANCE_LABEL = false
local prevInThreshold = UNSAFE
local function ChangeLineColor(distance)
    if (distance <= UNSAFE) then
        if (prevInThreshold == UNSAFE) then
            return -- No change, still red
        end
        prevInThreshold = UNSAFE
        Crutch.SetLineColor(1, 0, 0, 0.8, 0.8, SHOW_DISTANCE_LABEL)
    elseif (distance <= SUS) then
        if (prevInThreshold == SUS) then
            return -- No change, still yellow
        end
        prevInThreshold = SUS
        Crutch.SetLineColor(1, 1, 0, 0.5, 0.5, SHOW_DISTANCE_LABEL)
    else
        if (prevInThreshold == SAFE) then
            return -- No change, still green
        end
        prevInThreshold = SAFE
        Crutch.SetLineColor(0, 1, 0, 0.4, 0.4, SHOW_DISTANCE_LABEL)
    end
end

local function AddChainToPlayer(unitTag)
    if (chainsDisplaying1 == unitTag or chainsDisplaying2 == unitTag) then
        -- If this is the same player, do nothing because it's already displaying
        return
    end

    local iconPath = "esoui/art/trials/vitalitydepletion.dds"

    Crutch.dbgSpam(string.format("Setting |t100%%:100%%:%s|t for %s", iconPath, GetUnitDisplayName(unitTag)))
    Crutch.SetMechanicIconForUnit(GetUnitDisplayName(unitTag), iconPath, 100, {1, 0, 1})


    if (not chainsDisplaying1) then
        -- If no one has chains yet, consider this the first one and save it for later
        chainsDisplaying1 = unitTag
    else
        -- If the other player has already received it, we can draw the line
        chainsDisplaying2 = unitTag
        prevInThreshold = UNSAFE
        Crutch.SetLineColor(1, 0, 0, 0.4, 0.4, SHOW_DISTANCE_LABEL)
        Crutch.DrawLineBetweenPlayers(chainsDisplaying1, unitTag, ChangeLineColor)
    end
end
Crutch.AddChainToPlayer = AddChainToPlayer -- /script CrutchAlerts.AddChainToPlayer("group1") CrutchAlerts.AddChainToPlayer("group2")

-- Completely remove it from both players, and remove the line
local function RemoveChain()
    Crutch.RemoveLine()
    Crutch.RemoveMechanicIconForUnit(GetUnitDisplayName(chainsDisplaying1))
    Crutch.RemoveMechanicIconForUnit(GetUnitDisplayName(chainsDisplaying2))
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

    -- Stricken (tank swap)
    if (Crutch.savedOptions.osseincage.showStricken ~= "NEVER") then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "Stricken", EVENT_EFFECT_CHANGED, OnStricken)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Stricken", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "Stricken", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 235594)
    end

    if (not Crutch.WorldIconsEnabled()) then
        Crutch.msg("You must install OdySupportIcons 1.6.3+ to display in-world icons")
    else
        -- Icons for Dominator's Chains
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
end

function Crutch.UnregisterOsseinCage()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "Stricken", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ChainsInitial1", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ChainsInitial2", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ChainsTether1", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ChainsTether2", EVENT_EFFECT_CHANGED)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Ossein Cage")
end
