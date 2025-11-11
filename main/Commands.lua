local Crutch = CrutchAlerts

local function PrintUsage()
    CrutchAlerts.msg("Usage: /crutch <icon>")
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

    if (args[1] == "icon") then
        if (#args == 2) then
            Crutch.msg("Clearing individual icon for " .. args[2])
            Crutch.savedOptions.drawing.attached.individualIcons[args[2]] = nil
            Crutch.Drawing.RefreshGroup()
            return
        end

        if (#args ~= 3) then
            Crutch.msg("Usage: /crutch icon <@name> <texture path>")
            return
        end

        Crutch.msg(string.format("Setting icon for %s to |t100%%:100%%:%s|t", args[2], args[3]))
        Crutch.savedOptions.drawing.attached.individualIcons[args[2]] = args[3]
        Crutch.Drawing.RefreshGroup()

    else
        PrintUsage()
    end
end