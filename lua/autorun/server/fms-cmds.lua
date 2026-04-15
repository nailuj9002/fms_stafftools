include("autorun/server/fms-player-management.lua")
include("autorun/fms-utils.lua")

local cmdPrefix = "$"

FMSCmds = {}

function FMSCmds:registerCommand(cmdString, argTable, permLevel, func)
    self[cmdPrefix..cmdString]={}
    self[cmdPrefix..cmdString].func = func
    self[cmdPrefix..cmdString].argTable = argTable
    self[cmdPrefix..cmdString].permsLevel = permLevel

end

function FMSCmds:removeCommand(cmdString)
    if self[cmdPrefix..cmdstring] ~= nil then
        self[cmdPrefix..cmdString] = nil
    end
end

function FMSCmds.InferStringToType(StringType,Value)
    FMSCmds.StringTypes = {}
    FMSCmds.StringTypes["Player"] = FMSUtils.PlayerFromName or player.GetBySteamID64 or player.GetBySteamID
    FMSCmds.StringTypes["String"] = tostring
    FMSCmds.StringTypes["Int"] = tonumber

    return FMSCmds.StringTypes[StringType](Value)
end

RegisterMetaTable("FMS-Commands",FMSCmds)
hook.Add("PlayerSay", "FMS CommandCheck", function(ply,text)
    local FMSCmds = FindMetaTable("FMS-Commands")
    local args = string.Split(text," ")
    local cmdName = args[1]

    if FMSCmds[cmdName] ~= nil then
        local command = FMSCmds[cmdName]

        if (#args-1) < #command.argTable or (#args-1) > #command.argTable then
            FMSUtils.NetColoredChatMsg(ply,Color(170,0,255),'The argument length for the command "'..cmdName..'" differs from the expected length.\nExpected '..#FMSCmds[cmdName].argTable..' arguments got '..#args-1)
        else
            if ply:GetPermLevel() >= command.permLevel then
                local inferedArgs = {}

                for k,v in ipairs(command.argTable) do
                    if k == 1 then
                    else
                        table.insert(inferedArgs,FMSCmds.InferStringToType(v,args[k]))
                    end
                end

                command.func(ply,inferedArgs)
            else
                FMSUtils.NetColoredChatMsg(ply,Color(170,0,255),'You do not have permission to use '..cmdName)
            end
        end
        return ""
    else
        return text
    end
end)

