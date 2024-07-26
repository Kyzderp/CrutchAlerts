CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Orphic
---------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function OnFateSealerFaded(_, changeType, _, _, _, _, _, _, _, _, _, _, _, _, unitId, abilityId)
    if (changeType == EFFECT_RESULT_FADED) then
        Crutch.InterruptAbility(abilityId)
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
-- Icons for Arcane Conveyance
---------------------------------------------------------------------
-- Arcane Conveyance starts off with an initial debuff, 223028 and 223029
-- 4 seconds later, the real tether starts, 223060. The initial debuff seems to fade immediately after
-- We need to account for the possibility of someone dying during the 4 seconds,
-- which means the tether doesn't cast

local conveyanceDisplaying1, conveyanceDisplaying2 -- @ name of player if there is some kind of conveyance on them

local function AddArcaneConveyanceToPlayer(atName)
    if (conveyanceDisplaying1 == atName or conveyanceDisplaying2 == atName) then
        -- If this is the same player, do nothing because it's already displaying
        return
    end

    local iconPath = "esoui/art/trials/vitalitydepletion.dds"

    Crutch.dbgSpam(string.format("Setting |t100%%:100%%:%s|t for %s", iconPath, atName))
    Crutch.SetMechanicIconForUnit(atName, iconPath, 150, {1, 0, 1})


    if (not conveyanceDisplaying1) then
        -- If no one has conveyance yet, consider this the first one and save it for later
        conveyanceDisplaying1 = atName
    else
        -- If the other player has already received it, we can draw the line
        conveyanceDisplaying2 = atName
        Crutch.DrawLineBetweenPlayers(conveyanceDisplaying1, atName)
    end
end

-- Completely remove it from both players, and remove the line
local function RemoveArcaneConveyance()
    Crutch.RemoveLine()
    Crutch.RemoveMechanicIconForUnit(conveyanceDisplaying1)
    Crutch.RemoveMechanicIconForUnit(conveyanceDisplaying2)
    conveyanceDisplaying1 = nil
    conveyanceDisplaying2 = nil
end

local tethered = {} -- Anyone who has the real tether. [@name] = true
local function OnArcaneConveyanceInitial(_, changeType, _, _, unitTag)
    if (changeType == EFFECT_RESULT_GAINED) then
        -- Show the icons and line as soon as the initial debuff starts
        local atName = GetUnitDisplayName(unitTag)
        AddArcaneConveyanceToPlayer(atName)
    elseif (changeType == EFFECT_RESULT_FADED) then
        local atName = GetUnitDisplayName(unitTag)
        -- When it fades, check if the real tether is already up. If yes, do nothing.
        if (tethered[atName]) then
            return
        end

        -- If not, then the player died before the actual tether appeared, so remove the icons
        RemoveArcaneConveyance()
    end
end

-- The actual tether when it's active
local function OnArcaneConveyanceTether(_, changeType, _, _, unitTag)
    if (changeType == EFFECT_RESULT_GAINED) then
        local atName = GetUnitDisplayName(unitTag)
        tethered[atName] = true
        AddArcaneConveyanceToPlayer(atName) -- This shouldn't be needed, but idk, do it anyway
    elseif (changeType == EFFECT_RESULT_FADED) then
        local atName = GetUnitDisplayName(unitTag)
        tethered[atName] = nil
        RemoveArcaneConveyance()
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
-- Enable Orphic mirror icons if the boss is present
local function TryEnablingMirrorIcons()
    local _, powerMax, _ = GetUnitPower("boss1", POWERTYPE_HEALTH)
    if (powerMax == 97802032 -- Hardmode
        or powerMax == 65201356 -- Veteran
        or powerMax == 21812840) then -- Normal
        if (not mirrorsEnabled) then
            EnableMirrorIcons()
            mirrorsEnabled = true
        end
    else
        if (mirrorsEnabled) then
            DisableMirrorIcons()
            mirrorsEnabled = false
        end
    end
end


---------------------------------------------------------------------
-- Tempest Icons
---------------------------------------------------------------------
local function EnableTempestIcons()
    Crutch.EnableIcon("TempestH1")
    Crutch.EnableIcon("Tempest1")
    Crutch.EnableIcon("Tempest2")
    Crutch.EnableIcon("Tempest3")
    Crutch.EnableIcon("Tempest4")
    Crutch.EnableIcon("TempestH2")
    Crutch.EnableIcon("Tempest5")
    Crutch.EnableIcon("Tempest6")
    Crutch.EnableIcon("Tempest7")
    Crutch.EnableIcon("Tempest8")
end

local function DisableTempestIcons()
    Crutch.DisableIcon("TempestH1")
    Crutch.DisableIcon("Tempest1")
    Crutch.DisableIcon("Tempest2")
    Crutch.DisableIcon("Tempest3")
    Crutch.DisableIcon("Tempest4")
    Crutch.DisableIcon("TempestH2")
    Crutch.DisableIcon("Tempest5")
    Crutch.DisableIcon("Tempest6")
    Crutch.DisableIcon("Tempest7")
    Crutch.DisableIcon("Tempest8")
end

local tempestEnabled = false
-- Enable Tempest icons on vet if it's the start of the trial or Xoryn is present
local function TryEnablingTempestIcons()
    -- Tempest isn't important enough on normal
    if (GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_VETERAN) then
        return
    end

    -- In case this was reloaded at the beginning of the trial
    if (not tempestEnabled and GetCurrentRaidScore() == 36000 and GetCurrentRaidLifeScoreBonus() == 36000) then
        EnableTempestIcons()
        tempestEnabled = true
        return
    end

    -- Else, check for Xoryn
    local _, powerMax, _ = GetUnitPower("boss1", POWERTYPE_HEALTH)
    if (powerMax == 118759584 -- Hardmode
        or powerMax == 69858576) then -- Veteran
        if (not tempestEnabled) then
            EnableTempestIcons()
            tempestEnabled = true
        end
    else
        if (tempestEnabled) then
            DisableTempestIcons()
            tempestEnabled = false
        end
    end
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
local function GetUnitNameIfExists(unitTag)
    if (DoesUnitExist(unitTag)) then
        return GetUnitName(unitTag)
    end
end

local prevBosses = ""
function Crutch.RegisterLucentCitadel()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Lucent Citadel")

    if (not Crutch.WorldIconsEnabled()) then
        Crutch.msg("You must install OdySupportIcons 1.6.3+ to display in-world icons")
    else
        local showOrphic = Crutch.savedOptions.lucentcitadel.showOrphicIcons
        local showTempest = Crutch.savedOptions.lucentcitadel.showTempestIcons

        -- In case we reload at Orphic
        if (showOrphic) then TryEnablingMirrorIcons() end

        -- In case we reload at Xoryn... for some reason
        if (showTempest) then
            TryEnablingTempestIcons()

            --  Show tempest icons when the trial starts...
            EVENT_MANAGER:RegisterForEvent(Crutch.name .. "LCTrialStarted", EVENT_RAID_TRIAL_STARTED, function()
                if (not tempestEnabled) then
                    EnableTempestIcons()
                    tempestEnabled = true
                end
            end)
            -- ... and hide them once adds are killed
            EVENT_MANAGER:RegisterForEvent(Crutch.name .. "LCScoreUpdate", EVENT_RAID_TRIAL_SCORE_UPDATE, function(_, scoreUpdateReason)
                if (scoreUpdateReason == RAID_POINT_REASON_KILL_BANNERMEN) then
                    if (tempestEnabled) then
                        DisableTempestIcons()
                        tempestEnabled = false
                    end
                    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "LCScoreUpdate", EVENT_RAID_TRIAL_SCORE_UPDATE)
                end
            end)
        end

        -- Show icons on certain bosses
        if (showOrphic or showTempest) then
            EVENT_MANAGER:RegisterForEvent(Crutch.name .. "LCBossesChanged", EVENT_BOSSES_CHANGED, function()
                -- Only do this when the bosses actually change
                local bossHash = ""
                for i = 1, MAX_BOSSES do
                    local name = GetUnitNameIfExists("boss" .. tostring(i))
                    if (name and name ~= "") then
                        bossHash = bossHash .. name
                    end
                end
                if (bossHash == prevBosses) then return end
                prevBosses = bossHash

                if (showOrphic) then TryEnablingMirrorIcons() end
                if (showTempest) then TryEnablingTempestIcons() end
            end)
        end

        -- Icons for Arcane Conveyance
        if (Crutch.savedOptions.lucentcitadel.showArcaneConveyance) then
            EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ArcaneConveyanceInitial1", EVENT_EFFECT_CHANGED, OnArcaneConveyanceInitial)
            EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ArcaneConveyanceInitial1", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 223028)
            EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ArcaneConveyanceInitial1", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

            EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ArcaneConveyanceInitial2", EVENT_EFFECT_CHANGED, OnArcaneConveyanceInitial)
            EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ArcaneConveyanceInitial2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 223029)
            EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ArcaneConveyanceInitial2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

            EVENT_MANAGER:RegisterForEvent(Crutch.name .. "ArcaneConveyanceTether", EVENT_EFFECT_CHANGED, OnArcaneConveyanceTether)
            EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ArcaneConveyanceTether", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 223060)
            EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "ArcaneConveyanceTether", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        end
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
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ArcaneConveyanceInitial1", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ArcaneConveyanceInitial2", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ArcaneConveyanceTether", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "FateSealerFaded", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "ArcaneKnot", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "WeakeningCharge", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "LCTrialStarted", EVENT_RAID_TRIAL_STARTED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "LCScoreUpdate", EVENT_RAID_TRIAL_SCORE_UPDATE)

    -- Icons
    DisableMirrorIcons()
    DisableTempestIcons()

    tethered = {}

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Lucent Citadel")
end
