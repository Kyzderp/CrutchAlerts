local Crutch = CrutchAlerts

SLASH_COMMANDS["/crutch"] = function(argString)
    local args = {}
    for word in string.gmatch(argString, "%S+") do
        table.insert(args, word)
    end

    if (#args == 0) then
        CrutchAlerts.msg("Usage: /crutch <icon>")
        return
    end

    if (args[1] == "icon") then
        if (#args ~= 3) then
            CrutchAlerts.msg("Usage: /crutch icon <@name> <texture path>")
            return
        end

        Crutch.savedOptions.drawing.attached.individualIcons[args[2]] = args[3]
    end

end