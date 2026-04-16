include("autorun/server/fms-cmds.lua")
include("autorun/fms-utils.lua")

local argTable = {"Player"}
FMSCmds:registerCommand("kick", argTable, 255, function(ply, args)
    PrintTable(args)
    if IsValid(args[1]) then
        args[1]:Kick()
        FMSUtils.LogMessage(FMSUtils.NickAndID64(ply)..' Kicked '..FMSUtils.NickAndID64(args[1]))
    end
end)