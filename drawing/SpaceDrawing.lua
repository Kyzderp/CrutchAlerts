local Crutch = CrutchAlerts
local Draw = Crutch.Drawing

---------------------------------------------------------------------
-- x, z origin seems to be right where the player is when first loading game,
-- or on player activated (when going to a diff zone, or through a door in a zone)
-- but it doesn't snap to player when just reloading
-- y seems to be raw position / 100
function Crutch.InitializeSpaceDrawing()

end
--[[
/script
local _, x, y, z = GetUnitRawWorldPosition("player")
CrutchAlertsDrawingSpaceOrient:SetTransformOffset(x, y, z)
CrutchAlertsDrawingSpaceOrient:SetTransformRotation(0, 0, 0)

/script CrutchAlertsSpaceOrient:SetTransformOffset(0, 320, 0)
/script CrutchAlertsSpaceOrient:SetTransformOffset(920, 320, 0)
]]