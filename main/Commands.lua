local Crutch = CrutchAlerts

local function PrintUsage()
    if (IsConsoleUI()) then
        CrutchAlerts.msg([[Usage:
|cAAAAAA/crutch printskills
|cAAAAAA/crutch xoryn - temporarily toggle Tempest icons]])
    else
        CrutchAlerts.msg([[Usage:
|cAAAAAA/crutch printskills
|cAAAAAA/crutch lock
|cAAAAAA/crutch unlock
|cAAAAAA/crutch xoryn - temporarily toggle Tempest icons]])
    end
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
        local text = "Slotted ability IDs:\n"
        for i = 3, 8 do
            local abilityId = Crutch.GetSlotTrueBoundId(i, HOTBAR_CATEGORY_PRIMARY)
            text = string.format("%s  ||  %d - %s", text, abilityId, GetAbilityName(abilityId) or "")
        end
        text = text .. "\n--------\n"
        for i = 3, 8 do
            local abilityId = Crutch.GetSlotTrueBoundId(i, HOTBAR_CATEGORY_BACKUP)
            text = string.format("%s  ||  %d - %s", text, abilityId, GetAbilityName(abilityId) or "")
        end
        Crutch.msg(text)

    --------------------
    elseif (cmd == "lock" and not IsConsoleUI()) then
        Crutch.UnlockUI(false)

    --------------------
    elseif (cmd == "unlock" and not IsConsoleUI()) then
        Crutch.UnlockUI(true)

    --------------------
    elseif (cmd == "xoryn") then
        Crutch.ToggleTempestIcons()

    --------------------
    else
        PrintUsage()
    end
end
