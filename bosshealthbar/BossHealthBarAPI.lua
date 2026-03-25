local Crutch = CrutchAlerts
local BHB = Crutch.BossHealthBar


local function dbg(msg)
    Crutch.dbgSpam(string.format("|c8888FF[BHB]|r %s", msg))
end


----------------
-- PUBLIC API --
----------------
-- CrutchAlerts.BossHealthBar.GetBossThresholds()
-- Gets boss stages from Thresholds.lua, based on the current first boss tag's name and HP
-- @param optionalBossName - if specified, uses the threshold data for that name instead of auto-detect boss1
-- @return a table containing threshold number -> mechanic name (see ___Thresholds.lua for data in the same format), or nil if there are no thresholds. Note that this can contain non-number keys or sub-tables with more info
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
