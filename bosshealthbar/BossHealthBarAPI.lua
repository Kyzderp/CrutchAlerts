local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar


local function dbg(msg)
    Crutch.dbgSpam(string.format("|c8888FF[BHB]|r %s", msg))
end


----------------
-- PUBLIC API --
----------------
-------------------------------------------------------------------------------
-- CrutchAlerts.BossHealthBar.GetBossThresholds()
-- Gets boss stages from Thresholds.lua, based on the current first boss tag's
-- name and HP
-- @param optionalBossName - if specified, uses the threshold data for that
--     name instead of auto-detect boss1
-- @return a table containing threshold number -> mechanic name, or nil if
--     there are no thresholds. The difficulty is taken into account. Note that
--     this can contain non-number keys or sub-tables with more info.
--[[
Example return value:
{
    [90] = "Same-color Atro",
    [85] = "Off-color Atro",
    [80] = "Same-color Atro",
    [75] = "Off-color Atro",
    [70] = "2nd Teleports",
    [65] = "1st Teleports",
    boss1 = {
        [90] = "Same-color Atro",
        [85] = "Off-color Atro",
        [80] = "Same-color Atro",
        [75] = "Off-color Atro",
        [65] = "1st Teleports",
    },
    boss2 = {
        [90] = "Same-color Atro",
        [85] = "Off-color Atro",
        [80] = "Same-color Atro",
        [75] = "Off-color Atro",
        [70] = "2nd Teleports",
    },
}

In this case, boss1 and boss2 are provided because this is a "multi" threshold,
meaning each threshold is relevant only to the individual boss tag. For Crutch,
the threshold will be drawn with the line through that bar only, instead of
across all the bars. Note that the same mechanic number for different boss tags
could have different mechanic names in the future... but not yet.

The top level of the table will always contain key-value pairs that are
[thresholdNumber] = "mechanicName" (unless there are no thresholds
deliberately). These will remain available as backwards compatibility from the
initial API. Most commonly, there will only be top level values, since most
encounters are single-boss.
]]
-------------------------------------------------------------------------------
local function GetBossThresholds(optionalBossName)
    -- This can pick up spoofed bosses too, but this isn't a problem right now because the only spoofing
    -- in Crutch is on vOC titans and vAS minis, none of which would be the first boss tag
    local bossName = zo_strformat(SI_UNIT_NAME, optionalBossName or BHB.GetUnitNameIfExists(BHB.GetFirstValidBossTag()))
    local data
    local thresholdOverride = BHB.GetThresholdOverride(bossName)
    if (thresholdOverride) then
        -- Overrides for things like Z'Maja that need to be determined by code
        data = thresholdOverride
    elseif (GetZoneId(GetUnitZoneIndex("player")) == 1436) then
        -- Endless Archive has different boss thresholds
        data = BHB.eaThresholds[bossName]
    else
        data = BHB.thresholds[bossName]
    end

    -- Detect HM or vet or normal first based on boss health
    -- If not found, prioritize HM, then vet, and finally whatever data there is
    -- If there's no stages, do a default 75, 50, 25
    local _, powerMax, _ = BHB.GetUnitHealths(BHB.GetFirstValidBossTag())
    if (not data) then
        dbg(string.format("No data found for %s", bossName))
        -- Just return nil if no thresholds
    elseif (powerMax == data.hmHealth and data.Hardmode) then
        dbg(string.format("%s hp matched HARDMODE %d", bossName, powerMax))
        data = data.Hardmode
    elseif (powerMax == data.vetHealth and data.Veteran) then
        dbg(string.format("%s hp matched VETERAN %d", bossName, powerMax))
        data = data.Veteran
    elseif (powerMax == data.normHealth and data.Normal) then
        dbg(string.format("%s hp matched NORMAL %d", bossName, powerMax))
        data = data.Normal
    elseif (data.Hardmode) then
        dbg(string.format("No hp match for %s %d, but found Hardmode data", bossName, powerMax))
        data = data.Hardmode
    elseif (data.Veteran) then
        dbg(string.format("No hp match for %s %d, but found Veteran data", bossName, powerMax))
        data = data.Veteran
    elseif (data.Normal) then
        dbg(string.format("No hp match for %s %d, but found Normal data", bossName, powerMax))
        data = data.Normal
    else
        dbg(string.format("No difficulty data found for %s %d, using common data", bossName, powerMax))
    end

    return data
end
BHB.GetBossThresholds = GetBossThresholds


---------------------------------------------------------------------
-- Register for threshold changes here. It could be called even after
-- the health bar should no longer be shown. Maybe.
-- For Crutch, the listener simply calls RedrawStages(). You'll
-- probably want to call GetBossThresholds() to get the new ones
-- when receiving this event.
---------------------------------------------------------------------
local thresholdsChangeListeners = {}
BHB.thresholdsChangeListeners = thresholdsChangeListeners

----------------------------------------------------------------
-- CrutchAlerts.BossHealthBar.RegisterThresholdsChangeListener()
-- Register for thresholds changing
-- @param name - a unique string
-- @param listener - a function that will be called when thresholds change, with params (name: string, isAdded: bool)
local function RegisterThresholdsChangeListener(name, listener)
    thresholdsChangeListeners[name] = listener
end
BHB.RegisterThresholdsChangeListener = RegisterThresholdsChangeListener

------------------------------------------------------------------
-- CrutchAlerts.BossHealthBar.UnregisterThresholdsChangeListener()
local function UnregisterThresholdsChangeListener(name)
    thresholdsChangeListeners[name] = nil
end
BHB.UnregisterThresholdsChangeListener = UnregisterThresholdsChangeListener
