local Crutch = CrutchAlerts
local C = Crutch.Constants


---------------------------------------------------------------------
--[[
use control pool
option to move up instead of remain in same spot
support effects + interrupting
key using abilityid + source unit id?
]]
---------------------------------------------------------------------
-- Structs
---------------------------------------------------------------------
--[[
{
    [?] = {
        endTime = 12345,
        interrupted = false,
        abilityId = 13243,
        sourceUnitId = 12314,
        targetUnitId = 132124,
        key = 1,
    }
}
]]
local alerts = {}

local displaySlots = {} -- {[1] = nil, [2] = ?}


---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
local controlPool

local function UpdateDisplay()
end

local function UpdateAllAnchors()
end


---------------------------------------------------------------------
-- Model
---------------------------------------------------------------------
local function Poll()
end

local function RemoveAlert()
end

local function DisplayAlert()
    -- TODO: return a key?
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Crutch.InitializeCore()
    controlPool = ZO_ControlPool:New("CrutchAlerts_Line_Template", CrutchAlertsContainer)
end
