CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

function Crutch.DebugUI(text)
    if (not Crutch.savedOptions.debugUi) then return end
    CrutchAlertsDebug:SetText(text)
end

function Crutch.InitializeDebug()
    CrutchAlertsDebug:SetHidden(not Crutch.savedOptions.debugUi)
end
