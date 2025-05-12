CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

---------------------------------------------------------------------
-- Twins
---------------------------------------------------------------------
local function OnDestructiveEmber(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    if (changeType == EFFECT_RESULT_GAINED) then
        Crutch.msg(zo_strformat("<<1>> picked up |cff6600fire dome", GetUnitDisplayName(unitTag)))
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.msg(zo_strformat("<<1>> put away |cff6600fire dome", GetUnitDisplayName(unitTag)))
    end
end

local function OnPiercingHailstone(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    if (changeType == EFFECT_RESULT_GAINED) then
        Crutch.msg(zo_strformat("<<1>> picked up |c8ef5f5ice dome", GetUnitDisplayName(unitTag)))
    elseif (changeType == EFFECT_RESULT_FADED) then
        Crutch.msg(zo_strformat("<<1>> put away |c8ef5f5ice dome", GetUnitDisplayName(unitTag)))
    end
end


---------------------------------------------------------------------
-- Reef Guardian
---------------------------------------------------------------------
-- Display (and ding?) when reaching too many lightning stacks
-- Zaps seem to come every 3.3 seconds
local function OnLightningStacksChanged(_, changeType, _, _, _, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    if (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) then
        -- # of stacks that are dangerous probably depends on the role
        if (stackCount >= Crutch.savedOptions.dreadsailreef.staticThreshold) then
            Crutch.DisplayProminent(888004)
        end
    end
end

-- Display (and ding?) when reaching too many poison stacks
local function OnPoisonStacksChanged(_, changeType, _, _, _, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
    if (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) then
        -- # of stacks that are dangerous probably depends on the role
        if (stackCount >= Crutch.savedOptions.dreadsailreef.volatileThreshold) then
            Crutch.DisplayProminent(888006)
        end
    end
end

local numHearts = 0
local function OnHeartburn()
    numHearts = numHearts + 1

    local portalNumber = numHearts % 3
    if (portalNumber == 0) then portalNumber = 3 end
    Crutch.dbgOther(string.format("Reef Heart %d (Portal %d)", numHearts, portalNumber))
end

local function OnCombatStateChanged(_, inCombat)
    if (not inCombat) then
        -- Need to call later because combat briefly stops when accepting a rez during combat
        zo_callLater(function()
            if (not IsUnitInCombat("player")) then
                Crutch.dbgSpam("Resetting reef hearts")
                numHearts = 0
            end
        end, 3000)
    end
end

---------------------------------------------------------------------
-- Taleria
---------------------------------------------------------------------
local function ShowArcingCleave()
    local centerX = 57158 -- Linchal on mushroom patch
    local centerZ = 96815
    -- local centerX = 169744 -- Taleria center
    -- local centerZ = 29980
    local radius = 2000 -- Radius of the donut
    local tankTag = "player"

    -- Janky ass geometry
    local _, tankX, tankY, tankZ = GetUnitRawWorldPosition(tankTag)

    -- Find the tangent point whatever thing by finding the line and extending to the radius length
    -- tankZ = tankX * a + b
    -- centerZ = centerX * a + b
    -- y = ax + b
    -- b = y - ax
    local slope = (tankZ - centerZ) / (tankX - centerX)
    local intercept = tankZ - tankX * slope
    d("slope: " .. tostring(slope))
    d("intercept: " .. tostring(intercept))

    -- (centerX - desiredX)^2 + (centerZ - desiredZ)^2 = radius^2
    -- desiredZ = slope*desiredX + intercept
    -- (desiredZ - intercept) / slope = desiredX
    -- (centerX - desiredX)^2 + (centerZ - slope*desiredX - intercept)^2 = radius^2
    -- centerX^2 - 2*desiredX*centerX + desiredX^2 + centerZ^2 - centerZ*slope*desiredX - centerZ*intercept - slope*desiredX*centerZ + slope*desiredX*slope*desiredX + slope*desiredX*intercept - intercept*centerZ + intercept*slope*desiredX + intercept^2 = radius^2
    --[[
    centerX^2 - 2*desiredX*centerX + desiredX^2 + centerZ^2 - centerZ*slope*desiredX - centerZ*intercept - slope*desiredX*centerZ + slope*desiredX*slope*desiredX + slope*desiredX*intercept - intercept*centerZ + intercept*slope*desiredX + intercept^2 - radius^2 = 0

    + desiredX^2 + slope*slope*desiredX^2

    + (intercept*slope - 2*centerX - centerZ*slope - slope*centerZ + slope*intercept)*desiredX

    + centerX^2 + centerZ^2 - centerZ*intercept - intercept*centerZ + intercept^2 - radius^2 = 0
    ]]

    local a = 1 + slope*slope
    local b = 2*intercept*slope - 2*centerX - 2*centerZ*slope
    local c = centerX^2 + centerZ^2 - 2*centerZ*intercept + intercept^2 - radius^2


    -- WRONG
    -- (centerX - desiredX)^2 + (centerZ - desiredZ)^2 = radius^2
    -- desiredZ = a * desiredX + b
    -- (centerX - desiredX)(centerX - desiredX) + (centerZ - a * desiredX + b)(centerZ - a * desiredX + b) = radius^2
    -- centerX^2 - 2*centerX*desiredX + desiredX^2 + centerZ^2 - centerZ*a*desiredX + centerZ*b - a*desiredX*centerZ + (a*desiredX)^2 - a*desiredX*b + b*centerZ - b*a*desiredX + b^2 = radius^2
    -- centerX^2 - 2*centerX*desiredX + desiredX^2 + centerZ^2 - 2*centerZ*a*desiredX + 2*centerZ*b + (a*desiredX)^2 - 2*a*desiredX*b + b^2 = radius^2
    -- desiredX^2 - 2*centerX*desiredX - 2*centerZ*a*desiredX + a^2*desiredX^2 - 2*a*desiredX*b = radius^2 - b^2 - centerZ^2 - 2*centerZ*b - centerX^2
    -- desiredX^2 + a^2*desiredX^2 - 2*centerX*desiredX - 2*centerZ*a*desiredX - 2*a*desiredX*b = radius^2 - b^2 - centerZ^2 - 2*centerZ*b - centerX^2
    -- (a^2 + 1)*desiredX^2 - (2*centerX + 2*centerZ*a + 2*a*b)*desiredX = radius^2 - b^2 - centerZ^2 - 2*centerZ*b - centerX^2
    -- (a^2 + 1)*desiredX^2 - (2*centerX + 2*centerZ*a + 2*a*b)*desiredX - (radius^2 - b^2 - centerZ^2 - 2*centerZ*b - centerX^2) = 0
    -- (a^2 + 1)*desiredX^2 - (2*centerX + 2*centerZ*a + 2*a*b)*desiredX + (b^2 + centerZ^2 + 2*centerZ*b + centerX^2 - radius^2) = 0

    -- STILL WRONG
    -- (centerX - desiredX)^2 + (centerZ - desiredZ)^2 = radius^2
    -- desiredZ = a * desiredX + b
    -- (centerX - desiredX)(centerX - desiredX) + (centerZ - a * desiredX - b)(centerZ - a * desiredX - b) = radius^2
    -- centerX^2 - 2*centerX*desiredX + desiredX^2 + centerZ^2 - centerZ*a*desiredX - centerZ*b - a*desiredX*centerZ + (a*desiredX)^2 + a*desiredX*b - b*centerZ + b*a*desiredX - b^2 = radius^2
    -- centerX^2 - 2*centerX*desiredX + desiredX^2 + centerZ^2 - 2*centerZ*a*desiredX - 2*centerZ*b + (a*desiredX)^2 + 2*a*desiredX*b - b^2 = radius^2
    -- desiredX^2 - 2*centerX*desiredX - 2*centerZ*a*desiredX + a^2*desiredX^2 + 2*a*desiredX*b = radius^2 + b^2 - centerZ^2 + 2*centerZ*b - centerX^2
    -- desiredX^2 + a^2*desiredX^2 - 2*centerX*desiredX - 2*centerZ*a*desiredX + 2*a*desiredX*b = radius^2 + b^2 - centerZ^2 + 2*centerZ*b - centerX^2
    -- (a^2 + 1)*desiredX^2 - (2*centerX + 2*centerZ*a - 2*a*b)*desiredX = radius^2 + b^2 - centerZ^2 + 2*centerZ*b - centerX^2
    -- (a^2 + 1)*desiredX^2 - (2*centerX + 2*centerZ*a - 2*a*b)*desiredX - (radius^2 + b^2 - centerZ^2 + 2*centerZ*b - centerX^2) = 0
    -- (a^2 + 1)*desiredX^2 - (2*centerX + 2*centerZ*a - 2*a*b)*desiredX + (- b^2 + centerZ^2 - 2*centerZ*b + centerX^2 - radius^2) = 0

    -- STILL WRONG
    -- (centerX - desiredX)^2 + (centerZ - desiredZ)^2 = radius^2
    -- desiredZ = a * desiredX + b
    -- (centerX - desiredX)(centerX - desiredX) + (centerZ - a * desiredX - b)(centerZ - a * desiredX - b) - radius^2 = 0
    -- (centerX^2 - 2*desiredX*centerX + desiredX^2) + (centerZ^2 - a*desiredX*centerZ - b*centerZ - a*desiredX*centerZ + a*a*desiredX*desiredX - b*centerZ + a*b*desiredX + b*b) - radius^2 = 0
    -- (centerX^2 - 2*desiredX*centerX + desiredX^2) + (centerZ^2 - 2*a*desiredX*centerZ - 2*b*centerZ + a*a*desiredX^2 + a*b*desiredX + b*b) - radius^2 = 0
    -- centerX^2 - 2*desiredX*centerX + desiredX^2 + centerZ^2 - 2*a*desiredX*centerZ - 2*b*centerZ + a*a*desiredX^2 + a*b*desiredX + b*b - radius^2 = 0
    -- a*a*desiredX^2 + desiredX^2 + a*b*desiredX - 2*desiredX*centerX - 2*a*desiredX*centerZ + centerZ^2 - 2*b*centerZ + b*b - radius^2 + centerX^2= 0
    -- (a*a* + 1)*desiredX^2 + a*b*desiredX - 2*centerX*desiredX - 2*a*centerZ*desiredX + centerZ^2 - 2*b*centerZ + b*b - radius^2 + centerX^2= 0
    -- (a*a* + 1)*desiredX^2 + (a*b - 2*centerX - 2*a*centerZ)*desiredX + centerZ^2 - 2*b*centerZ + b*b - radius^2 + centerX^2= 0

    -- Solve quadratic equation
    -- local a = slope * slope + 1
    -- local b = -2 * (centerX + centerZ*slope - slope*intercept)
    -- local c = centerZ*centerZ - intercept*intercept - 2*centerZ*intercept - radius*radius

    -- local a = slope * slope + 1
    -- local b = slope*intercept - 2*centerX - 2*slope*centerZ
    -- local c = centerZ*centerZ - 2*intercept*centerZ + intercept*intercept - radius*radius + centerX*centerX

    d(a, b, c)
    d(b*b - 4*a*c)

    local desiredX1 = (-b + math.sqrt(b*b - 4*a*c)) / (2*a)
    local desiredZ1 = slope * desiredX1 + intercept

    local desiredX2 = (-b - math.sqrt(b*b - 4*a*c)) / (2*a)
    local desiredZ2 = slope * desiredX2 + intercept

    d(desiredX1, desiredZ1)
    d(desiredX2, desiredZ2)

    -- Draw the lines
    local icon1 = OSI.CreatePositionIcon(desiredX1, tankY, desiredZ1, "odysupporticons/icons/emoji-poop.dds", 150, {1, 1, 1})
    local icon2 = OSI.CreatePositionIcon(desiredX2, tankY, desiredZ2, "odysupporticons/icons/emoji-poop.dds", 150, {1, 1, 1})

    zo_callLater(function()
        OSI.DiscardPositionIcon(icon1)
        OSI.DiscardPositionIcon(icon2)
    end, 10000)
end
Crutch.ShowArcingCleave = ShowArcingCleave -- /script CrutchAlerts.ShowArcingCleave()


---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Crutch.RegisterDreadsailReef()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRCombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    -- Chat output for who picks up domes
    if (Crutch.savedOptions.general.showRaidDiag) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRDestructiveEmber", EVENT_EFFECT_CHANGED, OnDestructiveEmber)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRDestructiveEmber", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 166209)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRDestructiveEmber", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRPiercingHailstone", EVENT_EFFECT_CHANGED, OnPiercingHailstone)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRPiercingHailstone", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 166178)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRPiercingHailstone", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    end

    -- Lightning Stacks
    if (Crutch.savedOptions.dreadsailreef.alertStaticStacks) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED, OnLightningStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 163575)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED, OnLightningStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 169688)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
    end

    -- Volatile Stacks
    if (Crutch.savedOptions.dreadsailreef.alertVolatileStacks) then
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRVolatileBoss", EVENT_EFFECT_CHANGED, OnPoisonStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRVolatileBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 174835)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRVolatileBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
        EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRVolatileOther", EVENT_EFFECT_CHANGED, OnPoisonStacksChanged)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRVolatileOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 174932)
        EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRVolatileOther", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
    end

    -- Heartburn (portal)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "DSRPortal", EVENT_COMBAT_EVENT, OnHeartburn)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRPortal", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(Crutch.name .. "DSRPortal", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 163692)

    Crutch.dbgOther("|c88FFFF[CT]|r Registered Dreadsail Reef")
end

function Crutch.UnregisterDreadsailReef()
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRCombatState", EVENT_PLAYER_COMBAT_STATE)

    -- Domes
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRDestructiveEmber", EVENT_EFFECT_CHANGED, OnDestructiveEmber)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRPiercingHailstone", EVENT_EFFECT_CHANGED, OnPiercingHailstone)

    -- Lightning Stacks
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRStaticBoss", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRStaticOther", EVENT_EFFECT_CHANGED)

    -- Volatile Stacks
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRVolatileBoss", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRVolatileOther", EVENT_EFFECT_CHANGED)

    -- Heartburn (portal)
    EVENT_MANAGER:UnregisterForEvent(Crutch.name .. "DSRPortal", EVENT_COMBAT_EVENT)

    Crutch.dbgOther("|c88FFFF[CT]|r Unregistered Dreadsail Reef")
end
