local Crutch = CrutchAlerts

local function PrintUsage()
    CrutchAlerts.msg([[Usage:
/crutch printskills]])
end

SLASH_COMMANDS["/crutch"] = function(argString)
    local args = {}
    for word in string.gmatch(argString, "%S+") do
        table.insert(args, word)
    end

    if (#args == 0) then
        PrintUsage()
        return
    end
    local cmd = string.lower(args[1])

    --------------------
    if (cmd == "printskills") then
        local text = "Slotted ability IDs:"
        for i = 3, 8 do
            local abilityId = Crutch.GetSlotTrueBoundId(i, HOTBAR_CATEGORY_PRIMARY)
            text = string.format("%s\n%d - %s", text, abilityId, GetAbilityName(abilityId) or "")
        end
        text = text .. "\n--------"
        for i = 3, 8 do
            local abilityId = Crutch.GetSlotTrueBoundId(i, HOTBAR_CATEGORY_BACKUP)
            text = string.format("%s\n%d - %s", text, abilityId, GetAbilityName(abilityId) or "")
        end
        Crutch.msg(text)

    --------------------
    else
        PrintUsage()
    end
end
