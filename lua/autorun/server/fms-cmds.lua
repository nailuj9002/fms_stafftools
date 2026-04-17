include("autorun/server/fms-player-management.lua")
include("autorun/fms-utils.lua")

local cmdPrefix = "$"

FMSCmds = {}

function FMSCmds:registerCommand(cmdString, argTable, permLevel, func)
    self[cmdPrefix..cmdString]={}
    self[cmdPrefix..cmdString].func = func
    self[cmdPrefix..cmdString].argTable = argTable
    self[cmdPrefix..cmdString].permLevel = permLevel

end

function FMSCmds:removeCommand(cmdString)
    if self[cmdPrefix..cmdstring] ~= nil then
        self[cmdPrefix..cmdString] = nil
    end
end

function FMSCmds.InferStringToType(StringType,Value)
    FMSCmds.StringTypes = {}
    FMSCmds.StringTypes["Player"] = FMSUtils.GetPlayer
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

        if (#args-1) < (#command.argTable-FMSUtils.InstanceCount(command.argTable,"Optional")) or (#args-1) > #command.argTable and (!table.HasValue(command.argTable,"OptionalVar")) then
            FMSUtils.NetColoredChatMsg(ply,Color(170,0,255),'The argument length for the command "'..cmdName..'" differs from the expected length.\nExpected '..(#FMSCmds[cmdName].argTable-FMSUtils.InstanceCount(command.argTable,"Optional"))..' arguments got '..#args-1)
        else
            FMSUtils.LogMessage("Player "..FMSUtils.NickAndID64(ply).." attempted to use command: "..cmdName.."\nArguments\n[\n\t"..table.concat(args,"\n\t").."\n]")
            if ply:GetPermLevel() >= command.permLevel then
                local inferedArgs = {}

                for k,v in ipairs(command.argTable) do
                    if !string.find(v,"Optional") then
                        table.insert(inferedArgs,FMSCmds.InferStringToType(v,args[k+1]))
                    else
                        if v == "OptionalVar" then
                            table.insert(inferedArgs,table.concat(args,' ',k+1))
                        else
                            table.insert(inferedArgs,v)
                        end
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

