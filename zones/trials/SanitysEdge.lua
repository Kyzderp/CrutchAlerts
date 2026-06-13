local Crutch = CrutchAlerts
local C = Crutch.Constants


---------------------------------------------------------------------
-- Frost Bombs
---------------------------------------------------------------------
local PANEL_FROST_BOMB_INDEX = 4
local FROST_BOMB_ID = 183768
local FROST_BOMB_DOUBLE_ID = 185392
local FROST_BOMB_PREFIX = zo_strformat("|c66CCFF<<C:1>>: ", GetAbilityName(FROST_BOMB_ID)) -- matching cca color

-- 27.84, 28.60, 30.98, 33.85, 34.30, 34.60, 35.42, 35.52
local function OnFrostBomb()
    Crutch.InfoPanel.CountDownDuration(PANEL_FROST_BOMB_INDEX, FROST_BOMB_PREFIX, 27800)
end


---------------------------------------------------------------------
-- Chimera Icons
---------------------------------------------------------------------
local function DisableChimeraIcons()
    Crutch.DisableIconGroup("SEChimeraVetGryphon")
    Crutch.DisableIconGroup("SEChimeraVetLion")
    Crutch.DisableIconGroup("SEChimeraVetWamasu")
    Crutch.DisableIconGroup("SEChimeraHMGryphon")
    Crutch.DisableIconGroup("SEChimeraHMLion")
    Crutch.DisableIconGroup("SEChimeraHMWamasu")
end

local mantleIds = {
    [183640] = "Gryphon",
    [184983] = "Lion",
    [184984] = "Wamasu",
}

-- Do this as a check rather than listening for events, because
-- it needs to be checked after player activation (or else the
-- icons will just get disabled after going into portal)
local function CheckMantle()
    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        local portal = mantleIds[abilityId]
        if (portal) then
            local iconGroupString = "SEChimera"
            local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)

            -- boss1 is Chimera
            if (powerMax == 93144792) then
                iconGroupString = iconGroupString .. "HM"
            elseif (powerMax == 46572396) then
                iconGroupString = iconGroupString .. "Vet"
            else
                iconGroupString = iconGroupString .. "Norm"
            end

            Crutch.EnableIconGroup(iconGroupString .. portal)
        end
    end
end


---------------------------------------------------------------------
-- Arctic Shred
---------------------------------------------------------------------
-- Chimera casts it twice per "cycle," once after Chain Lightning,
-- and again after 1~2 more (Maul + Lightning Bolt (optional))
local PANEL_ARCTIC_INDEX = 5
local ARCTIC_PREFIX = zo_strformat("|c8ef5f5<<C:1>>: ", GetAbilityName(184275))
local numArctic = 0

local function OnArcticShred()
    numArctic = numArctic + 1

    if (numArctic == 1) then
        -- There will be a Maul and maybe Lightning Bolt before next, so just set timer?
        -- 8.1, 7.9, 5.5, 7.8, 8.5, 5.5, 7.9
        Crutch.InfoPanel.CountDownDuration(PANEL_ARCTIC_INDEX, ARCTIC_PREFIX, 5500)
    elseif (numArctic == 2) then
        -- Wait for next Chain Lightning (or maybe Inferno?)
        Crutch.InfoPanel.StopCount(PANEL_ARCTIC_INDEX)
        Crutch.InfoPanel.SetLine(PANEL_ARCTIC_INDEX, ARCTIC_PREFIX .. zo_strformat("|cFFFF00after <<C:1>>", GetAbilityName(183858)))
    end
end

-- 6.3, 7.4, 6.3, 6.3, 6.3
local function OnChainLightning()
    numArctic = 0
    Crutch.InfoPanel.CountDownDuration(PANEL_ARCTIC_INDEX, ARCTIC_PREFIX, 6300)
end

local function OnActivated()
    numArctic = 0
    local current, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    local current2, powerMax2 = GetUnitPower("boss2", COMBAT_MECHANIC_FLAGS_HEALTH)

    if (not current2 or not powerMax2 or current2 / powerMax2 > 0.1) then
        Crutch.dbgOther("boss2 not dead")
        return
    end -- Twelvane must be dead

    -- Must be Chimera
    if (powerMax ~= 93144792 -- HM
        and powerMax ~= 46572396 -- vet
        and powerMax ~= 16359630) then -- norm
        Crutch.dbgOther("not chimera")
        return
    end

    -- It is possible for the Chimera to cast it before Chain Lightning,
    -- so just start with SoonTM; the first one doesn't really matter anyway
    Crutch.InfoPanel.CountDownDuration(PANEL_ARCTIC_INDEX, ARCTIC_PREFIX, 0)

    Crutch.RegisterForCombatEvent("SEArcticShred", OnArcticShred, ACTION_RESULT_BEGIN, 184275)
    Crutch.RegisterForCombatEvent("SEChainLightning", OnChainLightning, ACTION_RESULT_BEGIN, 183858)
end


---------------------------------------------------------------------
-- Ansuul
---------------------------------------------------------------------
local PANEL_WRATHSTORM_INDEX = 6
local WRATHSTORM_ID = 198759
local WRATHSTORM_PREFIX = zo_strformat("|cCC0000<<C:1>>: ", GetAbilityName(WRATHSTORM_ID)) -- matching cca color

local function OnWrathstorm()
    -- 25.1, 25.6, 24.97, 23.9, 27.7, 25.35
    Crutch.InfoPanel.CountDownDuration(PANEL_WRATHSTORM_INDEX, WRATHSTORM_PREFIX, 23900)
end

-- Remove timer when maze starts; it only restarts much later
local function OnRitual()
    Crutch.InfoPanel.StopCount(PANEL_WRATHSTORM_INDEX)
end

-- When recombining, 23.67, 24.221, 24.334, 23.681
local function OnBreakdownFaded()
    Crutch.InfoPanel.CountDownDuration(PANEL_WRATHSTORM_INDEX, WRATHSTORM_PREFIX, 23600)
end

-- worth adding enraged fragments? 11.90, 11.92, 11.97, 11.98, 11.99, 12.00, 12.01, 12.02, 12.03, 12.04


---------------------------------------------------------------------
local ATTUNEMENT_ID = 242224 -- one of the many...
local UNATTUNED_ID = 189027 -- Blind to the Unattuned fades when done
local attuned = {}

local function OnAttunement(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
    local unitTag = Crutch.groupIdToTag[targetUnitId]
    if (not unitTag) then return end

    Crutch.dbgOther(zo_strformat("attunement gained: <<1>>", GetUnitDisplayName(unitTag)))
    attuned[unitTag] = true
end

local function OnUnattuned()
    Crutch.dbgOther("unattuning")
    ZO_ClearTable(attuned)
end

function Crutch.IsInVantonPortal(unitTag)
    if (attuned[unitTag]) then
        Crutch.dbgSpam(zo_strformat("<<1>> is in portal", unitTag))
    else
        Crutch.dbgSpam(zo_strformat("<<1>> is not in portal", unitTag))
    end
    return attuned[unitTag]
end


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
local function CleanUp()
    numArctic = 0
    Crutch.InfoPanel.StopCount(PANEL_FROST_BOMB_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_ARCTIC_INDEX)
    Crutch.InfoPanel.StopCount(PANEL_WRATHSTORM_INDEX)
    ZO_ClearTable(attuned)
end

function Crutch.RegisterSanitysEdge()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Sanity's Edge")

    Crutch.RegisterExitedGroupCombatListener("CrutchSanitysEdgeChimeraExitedCombat", CleanUp)

    if (Crutch.savedOptions.sanitysedge.infoPanel.showFrostBomb) then
        Crutch.RegisterForCombatEvent("SEFrostBomb", OnFrostBomb, ACTION_RESULT_BEGIN, FROST_BOMB_ID)
        Crutch.RegisterForCombatEvent("SEFrostBombDouble", OnFrostBomb, ACTION_RESULT_BEGIN, FROST_BOMB_DOUBLE_ID)
    end

    if (Crutch.savedOptions.sanitysedge.showArcticShred) then
        OnActivated() -- For returning from Chimera portal
    end

    -- Ansuul icon
    if (Crutch.savedOptions.sanitysedge.showAnsuulIcon) then
        Crutch.EnableIcon("AnsuulCenter")
    end

    if (Crutch.savedOptions.sanitysedge.showChimeraIcons) then
        CheckMantle()
    end

    if (Crutch.savedOptions.sanitysedge.infoPanel.showWrathstorm) then
        Crutch.RegisterForCombatEvent("SEWrathstorm", OnWrathstorm, ACTION_RESULT_BEGIN, WRATHSTORM_ID)
        Crutch.RegisterForCombatEvent("SERitual", OnRitual, ACTION_RESULT_BEGIN, 183855)
        Crutch.RegisterForCombatEvent("SEBreakdownFaded", OnBreakdownFaded, ACTION_RESULT_EFFECT_FADED, 188760)
    end

    Crutch.RegisterForCombatEvent("SEAttunement", OnAttunement, ACTION_RESULT_EFFECT_GAINED, ATTUNEMENT_ID)
    Crutch.RegisterForCombatEvent("SEUnattuned", OnUnattuned, ACTION_RESULT_EFFECT_FADED, UNATTUNED_ID)
end

function Crutch.UnregisterSanitysEdge()
    Crutch.UnregisterExitedGroupCombatListener("CrutchSanitysEdgeChimeraExitedCombat")

    Crutch.UnregisterForCombatEvent("SEFrostBomb")
    Crutch.UnregisterForCombatEvent("SEFrostBombDouble")

    -- Ansuul icon
    Crutch.DisableIcon("AnsuulCenter")

    -- Chimera oracle icons
    DisableChimeraIcons()

    Crutch.UnregisterForCombatEvent("SEArcticShred")
    Crutch.UnregisterForCombatEvent("SEChainLightning")

    Crutch.UnregisterForCombatEvent("SEWrathstorm")
    Crutch.UnregisterForCombatEvent("SERitual")
    Crutch.UnregisterForCombatEvent("SEBreakdownFaded")

    Crutch.UnregisterForCombatEvent("SEAttunement")
    Crutch.UnregisterForCombatEvent("SEUnattuned")

    CleanUp()

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Sanity's Edge")
end
