CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Orphic
---------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnFateSealerFaded(_, changeType, _, _, _, _, _, _, _, _, _, _, _, _, unitId)
    if (changeType == EFFECT_RESULT_FADED) then
        Crutch.Interrupted(unitId)
    end
end


---------------------------------------------------------------------
-- Arcane Knot
---------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnArcaneKnot(_, changeType, _, _, unitTag, beginTime, endTime)
    local atName = GetUnitDisplayName(unitTag)
    local tagNumber = string.gsub(unitTag, "group", "")
    local tagId = tonumber(tagNumber)
    local fakeSourceUnitId = 8880070 + tagId

    -- Pick up
    if (changeType == EFFECT_RESULT_GAINED) then
        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(zo_strformat("<<1>> picked up the knot", atName))
        end

        local label = zo_strformat("|cff7700<<C:1>>: <<2>>|r", GetAbilityName(213477), atName)
        Crutch.DisplayNotification(213477, label, (endTime - beginTime) * 1000, fakeSourceUnitId, 0, 0, 0, false)

    -- Drop
    elseif (changeType == EFFECT_RESULT_FADED) then
        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(zo_strformat("<<1>> dropped the knot", atName))
        end

        Crutch.Interrupted(fakeSourceUnitId)
    end
end


---------------------------------------------------------------------
-- Weakening Charge
---------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnWeakeningCharge(_, changeType, _, _, unitTag, beginTime, endTime)
    local atName = GetUnitDisplayName(unitTag)
    local tagNumber = string.gsub(unitTag, "group", "")
    local tagId = tonumber(tagNumber)
    local fakeSourceUnitId = 8880090 + tagId -- TODO: really gotta rework the alerts and stop hacking around like this

    -- Gained
    if (changeType == EFFECT_RESULT_GAINED) then
        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(zo_strformat("<<1>> got weakening charge", atName))
        end

        -- Event is not registered if NEVER, so the only other option is TANK
        if (Crutch.savedOptions.lucentcitadel.showWeakeningCharge == "ALWAYS" or GetSelectedLFGRole() == LFG_ROLE_TANK) then
            local label = zo_strformat("|ca361ff<<C:1>>: <<2>>|r", GetAbilityName(222613), atName)
            Crutch.DisplayNotification(222613, label, (endTime - beginTime) * 1000, fakeSourceUnitId, 0, 0, 0, false)
        end

    -- Faded
    elseif (changeType == EFFECT_RESULT_FADED) then
        if (Crutch.savedOptions.general.showRaidDiag) then
            Crutch.msg(zo_strformat("<<1>> is no longer weakened", atName))
        end

        Crutch.Interrupted(fakeSourceUnitId)
    end
end


---------------------------------------------------------------------
-- Mirror Icons
---------------------------------------------------------------------
-- Orphic Shattered Shard icons for mirrors
local function EnableMirrorIcons()
    Crutch.dbgOther("enabling mirror icons")
    if (Crutch.savedOptions.lucentcitadel.showOrphicIcons) then
        if (Crutch.savedOptions.lucentcitadel.orphicIconsNumbers) then
            if (GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN) then
                Crutch.EnableIcon("OrphicNum1")
                Crutch.EnableIcon("OrphicNum3")
                Crutch.EnableIcon("OrphicNum5")
                Crutch.EnableIcon("OrphicNum7")
            end
            Crutch.EnableIcon("OrphicNum2")
            Crutch.EnableIcon("OrphicNum4")
            Crutch.EnableIcon("OrphicNum6")
            Crutch.EnableIcon("OrphicNum8")
        else
            if (GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN) then
                Crutch.EnableIcon("OrphicN")
                Crutch.EnableIcon("OrphicE")
                Crutch.EnableIcon("OrphicS")
                Crutch.EnableIcon("OrphicW")
            end
            Crutch.EnableIcon("OrphicNE")
            Crutch.EnableIcon("OrphicSE")
            Crutch.EnableIcon("OrphicSW")
            Crutch.EnableIcon("OrphicNW")
        end
    end
end

local function DisableMirrorIcons()
    Crutch.dbgOther("disabling mirror icons")
    Crutch.DisableIcon("OrphicN")
    Crutch.DisableIcon("OrphicNE")
    Crutch.DisableIcon("OrphicE")
    Crutch.DisableIcon("OrphicSE")
    Crutch.DisableIcon("OrphicS")
    Crutch.DisableIcon("OrphicSW")
    Crutch.DisableIcon("OrphicW")
    Crutch.DisableIcon("OrphicNW")
    Crutch.DisableIcon("OrphicNum1")
    Crutch.DisableIcon("OrphicNum2")
    Crutch.DisableIcon("OrphicNum3")
    Crutch.DisableIcon("OrphicNum4")
    Crutch.DisableIcon("OrphicNum5")
    Crutch.DisableIcon("OrphicNum6")
    Crutch.DisableIcon("OrphicNum7")
    Crutch.DisableIcon("OrphicNum8")
end

local mirrorsEnabled = false
local function TryEnablingMirrorIcons()
    local bossName = GetUnitName("boss1")
    if (bossName and zo_strformat(SI_UNIT_NAME, bossName) == Crutch.GetCapitalizedString(CRUTCH_BHB_ORPHIC_SHATTERED_SHARD)) then
        if (not mirrorsEnabled) then
            EnableMirrorIcons()
            mirrorsEnabled = true
        end
    else
        if (mirrorsEnabled) then
            DisableMirrorIcons()
            mirrorsEnabled = true
        end
    end
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterLucentCitadel()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Lucent Citadel")

    if (not Crutch.WorldIconsEnabled()) then
        Crutch.msg("You must install OdySupportIcons 1.6.3+ to display in-world icons")
    else
        TryEnablingMirrorIcons()
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "LCBossesChanged", EVENT_BOSSES_CHANGED, TryEnablingMirrorIcons)
    end

    -- Orphic Fate Sealer effect faded, to remove the timer. TODO: stop using hacks and actually support this in a struct
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "FateSealerFaded", EVENT_EFFECT_CHANGED, OnFateSealerFaded)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "FateSealerFaded", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 214138)

    -- Arcane Knot
    if (Crutch.savedOptions.lucentcitadel.showKnotTimer) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ArcaneKnot", EVENT_EFFECT_CHANGED, OnArcaneKnot)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ArcaneKnot", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ArcaneKnot", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 213477)
    end

    -- Weakening Charge
    if (Crutch.savedOptions.lucentcitadel.showWeakeningCharge ~= "NEVER") then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "WeakeningCharge", EVENT_EFFECT_CHANGED, OnWeakeningCharge)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "WeakeningCharge", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "WeakeningCharge", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 222613)
    end
end

function Crutch.UnregisterLucentCitadel()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "LCBossesChanged", EVENT_BOSSES_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "FateSealerFaded", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ArcaneKnot", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "WeakeningCharge", EVENT_EFFECT_CHANGED)

    -- Orphic mirror icons
    DisableMirrorIcons()

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Lucent Citadel")
end
