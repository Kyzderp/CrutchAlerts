local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Varallion
---------------------------------------------------------------------
local gryphonCheckerIds = {
    [158700] = "Ofallo",
    [158715] = "Iliata",
    [158716] = "Mafremare",
    -- HM
    [163184] = "Ofallo",
    [163185] = "Iliata",
    [163188] = "Mafremare",
    [163597] = "Kargaeda",
}

local function OnGryphon(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    Crutch.DisplayDamageable(9.2, gryphonCheckerIds[abilityId] .. " in ")
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterCoralAerie()
    Crutch.dbgOther("|c88FFFF[CT]|r Registered Coral Aerie")

    if (Crutch.savedOptions.general.showDamageable) then
        for abilityId, _ in pairs(gryphonCheckerIds) do
            Crutch.RegisterForCombatEvent("Gryphon" .. abilityId, OnGryphon, ACTION_RESULT_EFFECT_GAINED, abilityId)
        end
    end
end

function Crutch.UnregisterCoralAerie()
    for abilityId, _ in pairs(gryphonCheckerIds) do
        Crutch.UnregisterForCombatEvent("Gryphon" .. abilityId)
    end

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Coral Aerie")
end