CrutchAlerts = CrutchAlerts or {}
local Crutch = CrutchAlerts

Crutch.messages = {}
function Crutch.msg(msg)
    if (not msg) then return end
    msg = "|c3bdb5e[CrutchAlerts] |caaaaaa" .. tostring(msg) .. "|r"
    if (CHAT_SYSTEM.primaryContainer) then
        CHAT_SYSTEM:AddMessage(msg)
    else
        Crutch.messages[#Crutch.messages + 1] = msg
    end
end
