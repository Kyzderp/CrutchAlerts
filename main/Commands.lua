local Crutch = CrutchAlerts


---------------------------------------------------------------------
local function ToggleGeneralAlerts()
    Crutch.savedOptions.general.showGeneralAlerts = not Crutch.savedOptions.general.showGeneralAlerts
    Crutch.msg("General alerts (begin, gained, others) are now turned " .. (Crutch.savedOptions.general.showGeneralAlerts and "|c00FF00ON" or "|cFF0000OFF"))
end
Crutch.ToggleGeneralAlerts = ToggleGeneralAlerts


---------------------------------------------------------------------
local function PrintUsage()
    if (IsConsoleUI()) then
        CrutchAlerts.msg([[Usage:
|cAAAAAA/crutch printskills
|cAAAAAA/crutch circle [radius]
|cAAAAAA/crutch xoryn - temporarily toggle Tempest icons]])
    else
        CrutchAlerts.msg([[Usage:
|cAAAAAA/crutch printskills
|cAAAAAA/crutch circle [radius]
|cAAAAAA/crutch lock
|cAAAAAA/crutch unlock
|cAAAAAA/crutch toggle general
|cAAAAAA/crutch xoryn - temporarily toggle Tempest icons]])
    end

    if (Crutch.savedOptions.experimental) then
        CrutchAlerts.msg([[EXPERIMENTAL / HIDDEN:
|cAAAAAA/crutch jet
|cAAAAAA/crutch meme
|cAAAAAA/crutch dump
|cAAAAAA/crutch dumpbhb
|cAAAAAA/crutch healthdebug]])
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
    elseif (cmd == "toggle") then
        if (#args ~= 2) then
            PrintUsage()
            return
        end

        if (args[2] == "general") then
            Crutch.ToggleGeneralAlerts()
        else
            PrintUsage()
        end
        return

    --------------------
    elseif (cmd == "jet") then
        Crutch.savedOptions.cc.jet = not Crutch.savedOptions.cc.jet
        Crutch.msg("Jets now " .. (Crutch.savedOptions.cc.jet and "ON" or "OFF"))

    --------------------
    elseif (cmd == "healthdebug") then
        Crutch.ToggleHealthDebug()

    --------------------
    elseif (cmd == "dump") then
        Crutch.Drawing.DumpUnitIcons()

    --------------------
    elseif (cmd == "dumpbhb") then
        Crutch.BossHealthBar.DumpMechanicControls()

    --------------------
    elseif (cmd == "circle") then
        if (#args ~= 2) then
            Crutch.msg("Clearing circle and poops")
            Crutch.Drawing.ClearPoop()
            return
        end

        local radius = tonumber(args[2])
        if (radius) then
            Crutch.msg("Drawing circle with radius " .. args[2])
            Crutch.Drawing.TestPoop(radius)
            return
        end

        Crutch.msg(args[2] .. " is not a number!")

    --------------------
    elseif (cmd == "meme") then
        if (#args ~= 2) then
            Crutch.msg([[Usage:
|cAAAAAA/crutch meme scorejets]])
            return
        end

        if (args[2] == "scorejets") then
            local prev = Crutch.savedOptions.memes.scoreJets or false
            Crutch.savedOptions.memes.scoreJets = not prev
            Crutch.msg("Score Jets now " .. (Crutch.savedOptions.memes.scoreJets and "ON" or "OFF"))
        elseif (args[2] == "alertnames") then
            local prev = Crutch.savedOptions.memes.alertNames or false
            Crutch.savedOptions.memes.alertNames = not prev
            Crutch.msg("Alert Names now " .. (Crutch.savedOptions.memes.alertNames and "ON" or "OFF"))
        else
            Crutch.msg("These are not the memes you're looking for.")
        end
        return

    --------------------
    else
        PrintUsage()
    end
end
