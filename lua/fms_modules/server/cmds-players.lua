include("autorun/server/fms-cmds.lua")
include("autorun/fms-utils.lua")

local argTable = {"Player","OptionalVar"}
FMSCmds:registerCommand("kick", argTable, 255, function(ply, args)
    if IsValid(args[1]) then
        if #args == 1 then
            args[1]:Kick()
            FMSUtils.LogMessage(FMSUtils.NickAndID64(ply)..' Kicked '..FMSUtils.NickAndID64(args[1]))
        else
            args[1]:Kick(table.concat(args," ",3))
            FMSUtils.LogMessage(FMSUtils.NickAndID64(ply)..' Kicked '..FMSUtils.NickAndID64(args[1]).."\nReason: "..args[2])
        end
    end
end)