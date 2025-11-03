local Crutch = CrutchAlerts


---------------------------------------------------------------------
-- Damageable timer for each round, based on combat exit
-- Note: sometimes stuck in combat can occur (for example ice round)
-- so the timer ends up not being accurate
---------------------------------------------------------------------
local TIME_TO_NEXT = 13100
local combatExitTime

local round

local function OnCombatExitedTimeout()
    -- Ignore if combat dropped sometime during the round
    if (Crutch.groupInCombat) then return end

    EVENT_MANAGER:UnregisterForUpdate(Crutch.name .. "DSACombatTimeout")

    -- Done with a round, increment
    round = round + 1
    if (round > 5) then
        return -- Was boss
    end

    -- And display next round
    local timer = combatExitTime + TIME_TO_NEXT - GetGameTimeMilliseconds()
    Crutch.DisplayDamageable(timer / 1000, "Portal spawns in |c%s%.1f|r")
end

-- Sometimes combat exit happens during the round (maybe adds are
-- far away?), so delay the check
local function OnCombatExited()
    combatExitTime = GetGameTimeMilliseconds()
    EVENT_MANAGER:RegisterForUpdate(Crutch.name .. "DSACombatTimeout", 8000, OnCombatExitedTimeout)
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterDragonstarArena()
    -- Reset
    round = 1

    -- Combat exit
    Crutch.RegisterExitedGroupCombatListener("DSACombatExit", OnCombatExited)

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Dragonstar Arena")
end

function Crutch.UnregisterDragonstarArena()
    Crutch.UnregisterExitedGroupCombatListener("DSACombatExit")

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Dragonstar Arena")
end
