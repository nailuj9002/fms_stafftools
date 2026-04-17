FMSUtils = {}

if SERVER then
    function FMSUtils.GetPlayer(plyName)
        local players = player.GetAll()
        for k, ply in ipairs(players) do
            if string.find(ply:Nick(),plyName) or ply:SteamID64() == plyName or ply:SteamID() == plyName then
                return ply
            else
                return plyname
            end
        end
    end

    function FMSUtils.NetColoredChatMsg(ply, ...)
        util.AddNetworkString("NetColoredChatMsg")
        net.Start("NetColoredChatMsg")
        net.WriteTable({...})
        net.Send(ply)
    end

    function FMSUtils.NickAndID64(ply)
        if IsValid(ply) then
            return(ply:Nick()..':'..ply:SteamID64())
        end
    end

    function FMSUtils.InstanceCount(tbl,value)
        local count = 0
        if isstring(value) then
            for k,v in pairs(tbl) do
                if string.find(v,value) then
                    count = count+1
                end
            end
        elseif isnumber(value) then
            for k,v in pairs(tbl) do
                if v == value then
                    count = count+1
                end
            end
        end
        return count
    end

    function FMSUtils.LogMessage(string)
        file.CreateDir("fluffy-mod-suite/logs/"..os.date("%Y/%B"))

        local timeformat = os.date("%Y/%B/%B-%d")
        file.Append("fluffy-mod-suite/logs/"..timeformat.."-log.txt", os.date("[%H:%M:%S] ")..string.."\n")
    end
else

    --ReceiveNetColoredMessage
    net.Receive("NetColoredChatMsg", function(len,ply)
        local tbl = net.ReadTable()
        chat.AddText(unpack(tbl))
        chat.PlaySound()
    end)
end