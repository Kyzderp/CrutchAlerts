local Crutch = CrutchAlerts
local C = Crutch.Constants

---------------------------------------------------------------------
-- Data
---------------------------------------------------------------------
local damageTakenData = {
-- Dragonstar Arena
    [83468] = { -- Nature's Blessing (AOE left by beasts)
        prominent = true, sound = SOUNDS.DUEL_START,
        preqFunc = function() return Crutch.savedOptions.dragonstar.normalDamageTaken and GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_VETERAN end,
    },

-- Maelstrom Arena
    [72525] = { -- Frigid Waters
        prominent = true, sound = SOUNDS.DUEL_START,
        preqFunc = function() return Crutch.savedOptions.maelstrom.normalDamageTaken and GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_VETERAN end,
    },
    [70822] = { -- Infectious Bite
        prominent = true, sound = SOUNDS.DUEL_START,
        preqFunc = function() return Crutch.savedOptions.maelstrom.normalDamageTaken and GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_VETERAN end,
    },
    [69855] = { -- Volatile Poison
        prominent = true, sound = SOUNDS.DUEL_START, isDot = true,
        preqFunc = function() return Crutch.savedOptions.maelstrom.normalDamageTaken and GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_VETERAN end,
    },
    [71862] = { -- Standard of Might
        prominent = true, sound = SOUNDS.DUEL_START,
        preqFunc = function() return Crutch.savedOptions.maelstrom.normalDamageTaken and GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_VETERAN end,
    },
    [70765] = { -- Molten Destruction
        prominent = true, sound = SOUNDS.DUEL_START,
        preqFunc = function() return Crutch.savedOptions.maelstrom.normalDamageTaken and GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_VETERAN end,
    },
}

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Crutch.InitializeDamageTaken()
    for abilityId, data in pairs(damageTakenData) do
        local eventName = Crutch.name .. "DmgTaken" .. tostring(abilityId)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, _, abilityId)
            if (data.preqFunc and not data.preqFunc()) then
                -- If there is a prerequisite function, require it to return true to continue
                return
            end
            if (data.sound) then
                PlaySound(data.sound)
            end
            if (data.prominent) then
                Crutch.DisplayProminent(C.ID.DAMAGE_TAKEN)
            end
        end)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, data.isDot and ACTION_RESULT_DOT_TICK or ACTION_RESULT_DAMAGE)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
    end
end
