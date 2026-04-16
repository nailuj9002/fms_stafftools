FMSUtils = {}

if SERVER then
    function FMSUtils.PlayerFromName(plyName)
        local players = player.GetAll()
        for k, ply in ipairs(players) do
            if string.find(ply:Nick(),plyName) then
                return v
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

    function FMSUtils.LogMessage(string)
        file.CreateDir("fluffy-mod-suite/logs/"..os.date("%Y/%B"))

        local timeformat = os.date("%Y/%B/%B-%d")
        file.Append("fluffy-mod-suite/logs/"..timeformat.."-log.txt", os.date("[%H:%M:%S] ")..string.."\n")
    end
else

    --SingularPlayerNetColoredMessage
    net.Receive("NetColoredChatMsg", function(len,ply)
        local tbl = net.ReadTable()
        chat.AddText(unpack(tbl))
        chat.PlaySound()
    end)
end