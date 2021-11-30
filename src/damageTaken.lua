CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Data
---------------------------------------------------------------------
local damageTakenData = {
-- Dragonstar Arena
    [83468] = {prominent = true, sound = SOUNDS.DUEL_START}, -- Nature's Blessing (AOE left by beasts)

-- Testing
    -- [82862] = {prominent = true, sound = SOUNDS.DUEL_START}, -- Shard Burst (Duriatundur WB in Coldharbor)
}

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Crutch.InitializeDamageTaken()
    for abilityId, data in pairs(damageTakenData) do
        local eventName = Crutch.name .. "DmgTaken" .. tostring(abilityId)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, _, abilityId)
            if (data.sound) then
                PlaySound(data.sound)
            end
            if (data.prominent) then
                Crutch.DisplayProminent(888002)
            end
        end)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DAMAGE)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
    end
end
