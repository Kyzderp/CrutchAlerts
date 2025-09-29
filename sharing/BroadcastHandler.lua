local Crutch = CrutchAlerts
Crutch.Broadcast = {}
local BC = Crutch.Broadcast

local rgProtocol

---------------------------------------------------------------------
-- Rockgrove
---------------------------------------------------------------------
local HEADING_PRECISION = 10000

local function OnCurseHeading(unitTag, data)
    Crutch.dbgOther(string.format("Received data from %s: {%d, %d, %d} %f", GetUnitDisplayName(unitTag), data.x, data.y, data.z, data.heading / HEADING_PRECISION))

    Crutch.OnGroupMemberCurseReceived(unitTag, data.x, data.y, data.z, data.heading / HEADING_PRECISION)
end

local function SendCurseExplosion()
    if (not rgProtocol) then
        Crutch.dbgSpam("Can't send heading because no LibGroupBroadcast")
        return
    end

    local _, x, y, z = GetUnitRawWorldPosition("player")
    local _, _, heading = GetMapPlayerPosition("player")

    rgProtocol:Send({
        x = x,
        y = y,
        z = z,
        heading = heading * HEADING_PRECISION
    })
end
BC.SendCurseExplosion = SendCurseExplosion
-- /script CrutchAlerts.Broadcast.SendCurseExplosion()


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local TRIAL_PROTOCOL_ID_1 = 210

function Crutch.InitializeBroadcast()
    local LGB = LibGroupBroadcast

    if (not LGB) then
        Crutch.dbgSpam("No LibGroupBroadcast for data sharing.")
        return
    end

    local handler = LGB:RegisterHandler("CrutchAlerts")
    handler:SetDisplayName("CrutchAlerts")
    handler:SetDescription("'Tis a crutch.")

    -- Death Touch
    rgProtocol = handler:DeclareProtocol(TRIAL_PROTOCOL_ID_1, "CurseExplosionProtocol")
    rgProtocol:AddField(LGB.CreateNumericField("x"))
    rgProtocol:AddField(LGB.CreateNumericField("y"))
    rgProtocol:AddField(LGB.CreateNumericField("z"))
    rgProtocol:AddField(LGB.CreateNumericField("heading"))

    rgProtocol:OnData(OnCurseHeading)

    rgProtocol:Finalize({
        isRelevantInCombat = true
    })
end