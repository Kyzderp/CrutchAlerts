CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

function Crutch.GetSquaredDistance(x1, y1, z1, x2, y2, z2)
  local dx = x1 - x2
  local dy = y1 - y2
  local dz = z1 - z2
  return dx * dx + dy * dy + dz * dz
end
