CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

----------------------------------------------------------------------
-- /script all()
-- /script EVENT_MANAGER:UnregisterForAllEvents("ZO_Debug_EventNotification0")

local resultStrings = {
    [ACTION_RESULT_ABILITY_ON_COOLDOWN] = "ABILITY_ON_COOLDOWN",
    [ACTION_RESULT_ABSORBED] = "ABSORBED",
    [ACTION_RESULT_BAD_TARGET] = "BAD_TARGET",
    [ACTION_RESULT_BATTLE_STANDARD_ALREADY_EXISTS_FOR_GUILD] = "BATTLE_STANDARD_ALREADY_EXISTS_FOR_GUILD",
    [ACTION_RESULT_BATTLE_STANDARD_LIMIT] = "BATTLE_STANDARD_LIMIT",
    [ACTION_RESULT_BATTLE_STANDARD_NO_PERMISSION] = "BATTLE_STANDARD_NO_PERMISSION",
    [ACTION_RESULT_BATTLE_STANDARD_TABARD_MISMATCH] = "BATTLE_STANDARD_TABARD_MISMATCH",
    [ACTION_RESULT_BATTLE_STANDARD_TOO_CLOSE_TO_CAPTURABLE] = "BATTLE_STANDARD_TOO_CLOSE_TO_CAPTURABLE",
    [ACTION_RESULT_BATTLE_STANDARDS_DISABLED] = "BATTLE_STANDARDS_DISABLED",
    [ACTION_RESULT_BEGIN] = "BEGIN",
    [ACTION_RESULT_BEGIN_CHANNEL] = "BEGIN_CHANNEL",
    [ACTION_RESULT_BLADETURN] = "BLADETURN",
    [ACTION_RESULT_BLOCKED] = "BLOCKED",
    [ACTION_RESULT_BLOCKED_DAMAGE] = "BLOCKED_DAMAGE",
    [ACTION_RESULT_BUSY] = "BUSY",
    [ACTION_RESULT_CANNOT_USE] = "CANNOT_USE",
    [ACTION_RESULT_CANT_SEE_TARGET] = "CANT_SEE_TARGET",
    [ACTION_RESULT_CANT_SWAP_WHILE_CHANGING_GEAR] = "CANT_SWAP_WHILE_CHANGING_GEAR",
    [ACTION_RESULT_CASTER_DEAD] = "CASTER_DEAD",
    [ACTION_RESULT_CRITICAL_DAMAGE] = "CRITICAL_DAMAGE",
    [ACTION_RESULT_CRITICAL_HEAL] = "CRITICAL_HEAL",
    [ACTION_RESULT_DAMAGE] = "DAMAGE",
    [ACTION_RESULT_DAMAGE_SHIELDED] = "DAMAGE_SHIELDED",
    [ACTION_RESULT_DEFENDED] = "DEFENDED",
    [ACTION_RESULT_DIED] = "DIED",
    [ACTION_RESULT_DIED_XP] = "DIED_XP",
    [ACTION_RESULT_DISARMED] = "DISARMED",
    [ACTION_RESULT_DISORIENTED] = "DISORIENTED",
    [ACTION_RESULT_DODGED] = "DODGED",
    [ACTION_RESULT_DOT_TICK] = "DOT_TICK",
    [ACTION_RESULT_DOT_TICK_CRITICAL] = "DOT_TICK_CRITICAL",
    [ACTION_RESULT_EFFECT_FADED] = "FADED",
    [ACTION_RESULT_EFFECT_GAINED] = "GAINED",
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = "DURATION",
    [ACTION_RESULT_FAILED] = "FAILED",
    [ACTION_RESULT_FAILED_REQUIREMENTS] = "FAILED_REQUIREMENTS",
    [ACTION_RESULT_FAILED_SIEGE_CREATION_REQUIREMENTS] = "FAILED_SIEGE_CREATION_REQUIREMENTS",
    [ACTION_RESULT_FALL_DAMAGE] = "FALL_DAMAGE",
    [ACTION_RESULT_FALLING] = "FALLING",
    [ACTION_RESULT_FEARED] = "FEARED",
    [ACTION_RESULT_FORWARD_CAMP_ALREADY_EXISTS_FOR_GUILD] = "FORWARD_CAMP_ALREADY_EXISTS_FOR_GUILD",
    [ACTION_RESULT_FORWARD_CAMP_NO_PERMISSION] = "FORWARD_CAMP_NO_PERMISSION",
    [ACTION_RESULT_FORWARD_CAMP_TABARD_MISMATCH] = "FORWARD_CAMP_TABARD_MISMATCH",
    [ACTION_RESULT_GRAVEYARD_DISALLOWED_IN_INSTANCE] = "GRAVEYARD_DISALLOWED_IN_INSTANCE",
    [ACTION_RESULT_GRAVEYARD_TOO_CLOSE] = "GRAVEYARD_TOO_CLOSE",
    [ACTION_RESULT_HEAL] = "HEAL",
    [ACTION_RESULT_HOT_TICK] = "HOT_TICK",
    [ACTION_RESULT_HOT_TICK_CRITICAL] = "HOT_TICK_CRITICAL",
    [ACTION_RESULT_IMMUNE] = "IMMUNE",
    [ACTION_RESULT_IN_AIR] = "IN_AIR",
    [ACTION_RESULT_IN_COMBAT] = "IN_COMBAT",
    [ACTION_RESULT_IN_ENEMY_KEEP] = "IN_ENEMY_KEEP",
    [ACTION_RESULT_INSUFFICIENT_RESOURCE] = "INSUFFICIENT_RESOURCE",
    [ACTION_RESULT_INTERCEPTED] = "INTERCEPTED",
    [ACTION_RESULT_INTERRUPT] = "INTERRUPT",
    [ACTION_RESULT_INVALID] = "INVALID",
    [ACTION_RESULT_INVALID_FIXTURE] = "INVALID_FIXTURE",
    [ACTION_RESULT_INVALID_JUSTICE_TARGET] = "INVALID_JUSTICE_TARGET",
    [ACTION_RESULT_INVALID_TERRAIN] = "INVALID_TERRAIN",
    [ACTION_RESULT_KILLED_BY_SUBZONE] = "KILLED_BY_SUBZONE",
    [ACTION_RESULT_KILLING_BLOW] = "KILLING_BLOW",
    [ACTION_RESULT_KNOCKBACK] = "KNOCKBACK",
    [ACTION_RESULT_LEVITATED] = "LEVITATED",
    [ACTION_RESULT_LINKED_CAST] = "LINKED_CAST",
    [ACTION_RESULT_MERCENARY_LIMIT] = "MERCENARY_LIMIT",
    [ACTION_RESULT_MISS] = "MISS",
    [ACTION_RESULT_MISSING_EMPTY_SOUL_GEM] = "MISSING_EMPTY_SOUL_GEM",
    [ACTION_RESULT_MISSING_FILLED_SOUL_GEM] = "MISSING_FILLED_SOUL_GEM",
    [ACTION_RESULT_MOBILE_GRAVEYARD_LIMIT] = "MOBILE_GRAVEYARD_LIMIT",
    [ACTION_RESULT_MOUNTED] = "MOUNTED",
    [ACTION_RESULT_MUST_BE_IN_OWN_KEEP] = "MUST_BE_IN_OWN_KEEP",
    [ACTION_RESULT_NO_LOCATION_FOUND] = "NO_LOCATION_FOUND",
    [ACTION_RESULT_NO_RAM_ATTACKABLE_TARGET_WITHIN_RANGE] = "NO_RAM_ATTACKABLE_TARGET_WITHIN_RANGE",
    [ACTION_RESULT_NO_WEAPONS_TO_SWAP_TO] = "NO_WEAPONS_TO_SWAP_TO",
    [ACTION_RESULT_NOT_ENOUGH_INVENTORY_SPACE] = "NOT_ENOUGH_INVENTORY_SPACE",
    [ACTION_RESULT_NOT_ENOUGH_SPACE_FOR_SIEGE] = "NOT_ENOUGH_SPACE_FOR_SIEGE",
    [ACTION_RESULT_NPC_TOO_CLOSE] = "NPC_TOO_CLOSE",
    [ACTION_RESULT_OFFBALANCE] = "OFFBALANCE",
    [ACTION_RESULT_PACIFIED] = "PACIFIED",
    [ACTION_RESULT_PARRIED] = "PARRIED",
    [ACTION_RESULT_PARTIAL_RESIST] = "PARTIAL_RESIST",
    [ACTION_RESULT_POWER_DRAIN] = "POWER_DRAIN",
    [ACTION_RESULT_POWER_ENERGIZE] = "POWER_ENERGIZE",
    [ACTION_RESULT_PRECISE_DAMAGE] = "PRECISE_DAMAGE",
    [ACTION_RESULT_QUEUED] = "QUEUED",
    [ACTION_RESULT_RAM_ATTACKABLE_TARGETS_ALL_DESTROYED] = "RAM_ATTACKABLE_TARGETS_ALL_DESTROYED",
    [ACTION_RESULT_RAM_ATTACKABLE_TARGETS_ALL_OCCUPIED] = "RAM_ATTACKABLE_TARGETS_ALL_OCCUPIED",
    [ACTION_RESULT_RECALLING] = "RECALLING",
    [ACTION_RESULT_REFLECTED] = "REFLECTED",
    [ACTION_RESULT_REINCARNATING] = "REINCARNATING",
    [ACTION_RESULT_RESIST] = "RESIST",
    [ACTION_RESULT_RESURRECT] = "RESURRECT",
    [ACTION_RESULT_ROOTED] = "ROOTED",
    [ACTION_RESULT_SIEGE_LIMIT] = "SIEGE_LIMIT",
    [ACTION_RESULT_SIEGE_NOT_ALLOWED_IN_ZONE] = "SIEGE_NOT_ALLOWED_IN_ZONE",
    [ACTION_RESULT_SIEGE_TOO_CLOSE] = "SIEGE_TOO_CLOSE",
    [ACTION_RESULT_SILENCED] = "SILENCED",
    [ACTION_RESULT_SPRINTING] = "SPRINTING",
    [ACTION_RESULT_STAGGERED] = "STAGGERED",
    [ACTION_RESULT_STUNNED] = "STUNNED",
    [ACTION_RESULT_SWIMMING] = "SWIMMING",
    [ACTION_RESULT_TARGET_DEAD] = "TARGET_DEAD",
    [ACTION_RESULT_TARGET_NOT_IN_VIEW] = "TARGET_NOT_IN_VIEW",
    [ACTION_RESULT_TARGET_NOT_PVP_FLAGGED] = "TARGET_NOT_PVP_FLAGGED",
    [ACTION_RESULT_TARGET_OUT_OF_RANGE] = "TARGET_OUT_OF_RANGE",
    [ACTION_RESULT_TARGET_TOO_CLOSE] = "TARGET_TOO_CLOSE",
    [ACTION_RESULT_UNEVEN_TERRAIN] = "UNEVEN_TERRAIN",
    [ACTION_RESULT_WEAPONSWAP] = "WEAPONSWAP",
    [ACTION_RESULT_WRECKING_DAMAGE] = "WRECKING_DAMAGE",
    [ACTION_RESULT_WRONG_WEAPON] = "WRONG_WEAPON",
}

local typeStrings = {
    [COMBAT_UNIT_TYPE_NONE] = "N",
    [COMBAT_UNIT_TYPE_PLAYER] = "P",
    [COMBAT_UNIT_TYPE_PLAYER_PET] = "PET",
    [COMBAT_UNIT_TYPE_GROUP] = "G",
    [COMBAT_UNIT_TYPE_TARGET_DUMMY] = "D",
    [COMBAT_UNIT_TYPE_OTHER] = "O",
}

local skipResults = {
    [ACTION_RESULT_EFFECT_FADED] = true,
    [ACTION_RESULT_DAMAGE] = true,
    [ACTION_RESULT_DAMAGE_SHIELDED] = true,
    [ACTION_RESULT_DOT_TICK] = true,
    [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
    [ACTION_RESULT_CRITICAL_DAMAGE] = true,
    [ACTION_RESULT_CRITICAL_HEAL] = true,
    [ACTION_RESULT_HOT_TICK] = true,
    [ACTION_RESULT_HOT_TICK_CRITICAL] = true,
    [ACTION_RESULT_REFLECTED] = true,
}

Crutch.skipAbilityNames = {
    ["Prioritize Hit"] = true, -- Not sure what it is but it's spammy af and has many different IDs
    ["Randomize Base Attack"] = true,
    --
    ["Medium Armor Evasion"] = true,
    ["Tri Focus"] = true,
    ["Penetrating Magic"] = true,
    ["Ancient Knowledge"] = true,
    ["Destruction Expert"] = true,
    ["Shocking Siphon"] = true,
    ["ESO Plus Member"] = true,
    --
    ["Lord Warden Dusk"] = true,
    ["Hollowfang Thirst"] = true,
    ["Weapon Damage"] = true,
    --
    ["Combat Prayer"] = true,
    ["Radiating Regeneration"] = true,
    ["Crushing Wall"] = true,
    ["Overflowing Altar"] = true,
    ["Siege Shield"] = true,
    ["Stalking Blastbones"] = true,
    ["Unstable Wall of Fire"] = true,
    ["Empowering Grasp"] = true,
    ["Swallow Soul"] = true,
    ["Puncturing Sweep"] = true,
    ["Healing Combustion"] = true,
    ["Defensive Stance"] = true,
    ["Crystal Fragments"] = true,
    ["Energy Orb"] = true,
    ["Blazing Spear"] = true,
    ["Reusable Parts"] = true,
    ["Fortress"] = true,
    ["Deadly Bash"] = true,
    ["Rebate"] = true,
    ["Fire Wall Damage Bonus"] = true,
    ["Player Pet Defenses"] = true,
    ["Player Pet Speed"] = true,
    ["Player Pet Battle Spirit"] = true,
    ["Player Pet Critical Chance"] = true,
    ["Pet Battle Spirit"] = true,
    ["Intensive Mender"] = true,
    ["Constitution"] = true,
    ["Enlivening Overflow"] = true,
    ["Bound Aegis"] = true,
    ["Leeching Strikes"] = true,
    ["Grand Healing Fx"] = true,
    ["Grand Rejuvenation"] = true,
    ["Mystic Siphon"] = true,
    ["Concentrated Barrier"] = true,
    ["Sacred Ground"] = true,
    --
    ["Light Attack (Inferno)"] = true,
    ["Light Attack (Restoration)"] = true,
    ["Medium Attack (Inferno)"] = true,
    --
    ["Shadow of the Dead"] = true,
    --
    ["Empower"] = true,
    ["Major Aegis"] = true,
    ["Major Berserk"] = true,
    ["Major Brutality"] = true,
    ["Major Courage"] = true,
    ["Major Endurance"] = true,
    ["Major Evasion"] = true,
    ["Major Expedition"] = true,
    ["Major Force"] = true,
    ["Major Fortitude"] = true,
    ["Major Gallop"] = true,
    ["Major Heroism"] = true,
    ["Major Champion"] = true,
    ["Major Intellect"] = true,
    ["Major Mending"] = true,
    ["Major Prophecy"] = true,
    ["Major Protection"] = true,
    ["Major Resolve"] = true,
    ["Major Savagery"] = true,
    ["Major Slayer"] = true,
    ["Major Sorcery"] = true,
    ["Major Toughness"] = true,
    ["Major Vitality"] = true,
    ["Minor Aegis"] = true,
    ["Minor Berserk"] = true,
    ["Minor Brutality"] = true,
    ["Minor Courage"] = true,
    ["Minor Endurance"] = true,
    ["Minor Evasion"] = true,
    ["Minor Expedition"] = true,
    ["Minor Force"] = true,
    ["Minor Fortitude"] = true,
    ["Minor Gallop"] = true,
    ["Minor Heroism"] = true,
    ["Minor Champion"] = true,
    ["Minor Intellect"] = true,
    ["Minor Mending"] = true,
    ["Minor Prophecy"] = true,
    ["Minor Protection"] = true,
    ["Minor Resolve"] = true,
    ["Minor Savagery"] = true,
    ["Minor Slayer"] = true,
    ["Minor Sorcery"] = true,
    ["Minor Toughness"] = true,
    ["Minor Vitality"] = true,
    --
    ["Major Breach"] = true,
    ["Major Brittle"] = true,
    ["Major Cowardice"] = true,
    ["Major Defile"] = true,
    ["Major Enervation"] = true,
    ["Major Fracture"] = true,
    ["Major Hindrance"] = true,
    ["Major Lifesteal"] = true,
    ["Major Magickasteal"] = true,
    ["Major Maim"] = true,
    ["Major Mangle"] = true,
    ["Major Uncertainty"] = true,
    ["Major Vulnerability"] = true,
    ["Minor Breach"] = true,
    ["Minor Brittle"] = true,
    ["Minor Cowardice"] = true,
    ["Minor Defile"] = true,
    ["Minor Enervation"] = true,
    ["Minor Fracture"] = true,
    ["Minor Hindrance"] = true,
    ["Minor Lifesteal"] = true,
    ["Minor Magickasteal"] = true,
    ["Minor Maim"] = true,
    ["Minor Mangle"] = true,
    ["Minor Uncertainty"] = true,
    ["Minor Vulnerability"] = true,
}

----------------------------------------------------------------------
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnCombatEvent(_, result, _, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    -- Don't care about certain results
    if (skipResults[result]) then return end
    if (Crutch.skipAbilityNames[GetAbilityName(abilityId)]) then return end

    local resultString = resultStrings[result] or ("|cFFAAAA" .. tostring(result) .. "|r")
    local sourceString = typeStrings[sourceType]
    local targetString = typeStrings[targetType]

    if (not sourceName or sourceName == "") then
        sourceName = Crutch.groupMembers[sourceUnitId]
        if (sourceName) then
            sourceName = "|cFCEB4C" .. sourceName .. "|r"
        else
            sourceName = "???"
        end
    end

    if (not targetName or targetName == "") then
        targetName = Crutch.groupMembers[targetUnitId]
        if (targetName) then
            targetName = "|cFCEB4C" .. targetName .. "|r"
        else
            targetName = "???"
        end
    end

    sourceName = zo_strformat("<<1>>", sourceName)
    targetName = zo_strformat("<<1>>", targetName)

    if (sourceName == GetUnitName("player")) then
        sourceName = "|c3bdb5e" .. sourceName .. "|r"
    end
    if (targetName == GetUnitName("player")) then
        targetName = "|c3bdb5e" .. targetName .. "|r"
    end

    -- TODO: add timestamp and color coding
    local line = string.format("[%s] %s(%d)[%s] %s %s(%d)[%s] with |cFFFFFF%s|r(%d) for %d",
        GetTimeString() .. "." .. string.format("%03d", math.fmod(GetGameTimeMilliseconds(), 1000)),
        sourceName, sourceUnitId, sourceString,
        resultString,
        targetName, targetUnitId, targetString,
        GetAbilityName(abilityId), abilityId, hitValue)

    CrutchAlertsSpamBuffer:AddMessage(line, 0.7, 0.7, 0.7)
end


----------------------------------------------------------------------
-- Slash commands
----------------------------------------------------------------------
local function HandleCommand(argString)
    local args = {}
    local length = 0
    for word in argString:gmatch("%S+") do
        table.insert(args, word)
        length = length + 1
    end

    local usage = "/crutchspam <show||hide||start||stop>"

    if (length == 0) then
        d(usage)
        return
    end

    if (args[1] == "show") then
        CrutchAlertsSpam:SetHidden(false)
        CrutchAlertsSpam:SetMouseEnabled(true)
        CrutchAlertsSpam:SetMovable(true)
    elseif (args[1] == "hide") then
        CrutchAlertsSpam:SetHidden(true)
        CrutchAlertsSpam:SetMouseEnabled(false)
        CrutchAlertsSpam:SetMovable(false)
    elseif (args[1] == "start") then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "SpamWindow", EVENT_COMBAT_EVENT, OnCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "SpamWindow", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
    elseif (args[1] == "stop") then
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "SpamWindow", EVENT_COMBAT_EVENT)
    else
        d(usage)
    end
end

----------------------------------------------------------------------
local expanded = false
function Crutch.OnSpamSidebarClicked()
    if (expanded) then
        -- Close it and turn it off
        CrutchAlertsSpam.slide:SetDeltaOffsetX(520)
        EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "SpamWindow", EVENT_COMBAT_EVENT)
    else
        -- Expand it and turn it on
        CrutchAlertsSpam.slide:SetDeltaOffsetX(-520)
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "SpamWindow", EVENT_COMBAT_EVENT, OnCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "SpamWindow", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
    end
    expanded = not expanded
    CrutchAlertsSpam.slideAnimation:PlayFromStart()
end

----------------------------------------------------------------------
function Crutch.InitializeSpamWindow()
    CrutchAlertsSpamBuffer:AddMessage("yeet", 0.6, 0.6, 0.6)

    CrutchAlertsSpam.slideAnimation = GetAnimationManager():CreateTimelineFromVirtual("ZO_LootSlideInAnimation", CrutchAlertsSpam)
    CrutchAlertsSpam.slide = CrutchAlertsSpam.slideAnimation:GetFirstAnimation()
end

SLASH_COMMANDS["/crutchspam"] = HandleCommand
