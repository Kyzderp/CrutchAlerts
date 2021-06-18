CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Check each group member to see who has the Focused Fire DEBUFF
local function OnFocusFireGained(_, result, _, _, _, _, sourceName, sourceType, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    local toClear = {}
    for g = 1, GetGroupSize() do
        local unitTag = "group" .. tostring(g)
        local hasFocusedFire = false
        for i = 1, GetNumBuffs(unitTag) do
            local buffName, _, _, _, stackCount, iconFilename, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unitTag, i)
            if (abilityId == 121726) then
                d(string.format("|cAAAAAA%s|r has %d x %s", GetUnitDisplayName(unitTag), stackCount, buffName))
                hasFocusedFire = true
                break
            end
        end

        if (OSI and not hasFocusedFire) then
            OSI.SetMechanicIconForUnit(GetUnitDisplayName(unitTag), "odysupporticons/icons/squares/marker_lightblue.dds")
            table.insert(toClear, GetUnitDisplayName(unitTag))
        end
    end

    -- Clear icons 7 seconds later
    if (OSI) then
        EVENT_MANAGER:RegisterForUpdate(CrutchAlerts.name .. "ClearIcons", 7000, function()
                EVENT_MANAGER:UnregisterForUpdate(CrutchAlerts.name .. "ClearIcons")
                for _, name in pairs(toClear) do
                    OSI.RemoveMechanicIconForUnit(name)
                end
            end)
    end
end

---------------------------------------------------------------------
-- Register/Unregister
function Crutch.RegisterSunspire()
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CT]|r Registered Sunspire") end
    EVENT_MANAGER:RegisterForEvent(CrutchAlerts.name .. "FocusFireBegin", EVENT_COMBAT_EVENT, OnFocusFireGained)
    EVENT_MANAGER:AddFilterForEvent(CrutchAlerts.name .. "FocusFireBegin", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(CrutchAlerts.name .. "FocusFireBegin", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 121722)
    -- TODO: only show for self option
end

function Crutch.UnregisterSunspire()
    EVENT_MANAGER:UnregisterForEvent(CrutchAlerts.name .. "FocusFireBegin", EVENT_COMBAT_EVENT)
    if (Crutch.savedOptions.debugOther) then d("|c88FFFF[CT]|r Unregistered Sunspire") end
end
