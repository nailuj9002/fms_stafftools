include("autorun/server/fms-cmds.lua")
include("autorun/fms-utils.lua")

--Player Utils
local argTable = {"Player"}
FMSCmds:registerCommand("goto", argTable, 5, function(ply, args)
    if IsValid(args[1]) then
       ply:SetPos(args[1]:GetPos()+args[1]:GetAimVector()*Vector(100,100,0))

       FMSUtils.NetColoredChatMsg(ply, '[FMS] You teleported to '..args[1]:Nick())
       FMSUtils.NetColoredChatMsg(args[1], '[FMS] '..ply:Nick()..' teleported to You')
       
       FMSUtils.LogMessage(FMSUtils.NickAndID64(ply)..' Went to '..FMSUtils.NickAndID(args[1]))
    end
end)

local argTable = {"Player", "OptionalVar"}
FMSCmds:registerCommand("p", argTable, 5, function(ply, args)
    if #args[2] > 1 then
        FMSUtils.NetColoredChatMsg(ply, '')
        FMSUtils.NetColoredChatMsg(ply, '')
    end
end)

local argTable = {}
FMSCmds:registerCommand("build", argTable, 5, function(ply, args)
    if ply:GetDimension() == "jail" then
        ply:Kick("100 IQ Genius move mate.")
    end
    ply:SetNW2Bool("FMS-BuildMode", true)
    ply:Spawn()

    FMSUtils.NetColoredChatMsg(ply,'')
    FMSUtils.LogMessage(FMSUtils.NickAndID64(ply)..' Entered buildmode.')
end)

local argTable = {}
FMSCmds:registerCommand("pvp", argTable, 5, function(ply, args)
    if ply:GetDimension() == "jail" then
        ply:Kick("100 IQ Genius move mate.")
    end
    ply:SetNW2Bool("FMS-BuildMode", true)
    ply:Spawn()

    FMSUtils.NetColoredChatMsg(ply,'')
    FMSUtils.LogMessage(FMSUtils.NickAndID64(ply)..' Exited buildmode.')
end)

local argTable = {}
FMSCmds:registerCommand("votemap",argTable, 5, function(ply, args)
    FMSUtils.NetColoredChatMsg(tonumber(sql.Query("SELECT * FROM map_circuit")[1].currentmap),32)
end)

--Staff Utils
local argTable = {"Player","OptionalVar"}
FMSCmds:registerCommand("kick", argTable, 255, function(ply, args)
    if IsValid(args[1]) then
        local NickAndID = FMSUtils.NickAndID64(args[1])
        if #args == 1 then
            args[1]:Kick()
            FMSUtils.LogMessage(FMSUtils.NickAndID64(ply)..' Kicked '..NickAndID)
        else
            args[1]:Kick(args[2])
            FMSUtils.LogMessage(FMSUtils.NickAndID64(ply)..' Kicked '..NickAndID.."\nReason: "..args[2])
        end
    end
end)

local argTable = {"Player","optional","OptionalVar"}
FMSCmds:registerCommand("ban", argTable, 255, function(ply, args)
    if args[1]:SteamID64() ~= nil then
        ID = args[1]:SteamID64()
        for _, ent in ents.Iterator() do
            if ent:GetOwner() == args[1] then
                ent:Remove()
            end
        end

    elseif string.find(args[1],"STEAM_0:")then
        util.SteamIDTo64(args[1])
    else
        ID = args[1]
    end

    if #args == 1 then
         
        game.KickID(ID)
        FMSUtils.LogMessage(FMSUtils.NickAndID64(ply)..' Banned '..ID..' permanently.')
        sql.QueryTyped("INSERT INTO 'FMS-PunishmentData' (PlayerID, StaffID, Date, Type) VALUES(?,?,?,?)",ID,ply:SteamID64(),os.time(),0,'BAN')
    elseif #args == 2 then
        local time = FMSUtils.StringToUnix(args[2])
        
        if args[3] ~= nil then

            game.KickID(ID)
            FMSUtils.LogMessage(FMSUtils.NickAndID64(ply)..' Banned '..ID..' for '..time..'.')
            sql.QueryTyped("INSERT INTO 'FMS-PunishmentData' (PlayerID, StaffID, Date, ExpireDate, Type) VALUES(?,?,?,?,?)",ID,ply:SteamID64(),os.time(),os.time()+time,'BAN')
        else

            game.KickID(ID,args[3])
            FMSUtils.LogMessage(FMSUtils.NickAndID64(ply)..' Banned '..ID..' for '..time..'.\nReason: '..args[3])
            sql.QueryTyped("INSERT INTO 'FMS-PunishmentData' (PlayerID, StaffID, Date, ExpireDate, Type, Reason) VALUES(?,?,?,??)",ID,ply:SteamID64(),os.time(),os.time()+time,'BAN',args[3])
        end
    end
end)