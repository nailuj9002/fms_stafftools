sql.Query("CREATE TABLE IF NOT EXISTS 'FMS-PlyData' (SteamID64 BIT(64) PRIMARY KEY, SteamName STRING, groups STRING DEFAULT 'user', joinCount INT DEFAULT 1)")
sql.Query("CREATE TABLE IF NOT EXISTS 'FMS-GroupData' (GroupName STRING UNIQUE, Rank BIT(8), Color BLOB, JoinNeeded INT)")
sql.Query("CREATE TABLE IF NOT EXISTS 'FMS-PunishmentData' (PlayerID64 BIT(64), StaffID BIT(64) DEFAULT 0, Date BIT(64), ExpireDate BIT(64), Type STRING, Reason STRING DEFAULT '')")

FMSGroups = {}

function FMSGroups.AddGroup(groupName, rank, color)
    colorStr = sql.SQLStr(utf8.char(color:ToHex(true)),true)
    sql.QueryTyped("INSERT OR REPLACE INTO 'FMS-GroupData' (GroupName, Rank, Color) VALUES (?,?,?)",groupName,rank,colorStr)
end

function FMSGroups.RemoveGroup(groupName)
    sql.QueryTyped("DELETE FROM 'FMS-GroupData' WHERE GroupName = ?",groupName)
end

function FMSGroups.GetGroups()
    return sql.Query("SELECT * FROM 'FMS-GroupData'")
end

function FMSGroups.GetGroupData(groupName)
    return sql.QueryTyped("SELECT * FROM 'FMS-GroupData' WHERE GroupName = ?",groupName)[1]
end

function FMSGroups.GetGroupMembers(groupName)
    if FMSGroups.GetGroupData(groupName) ~= nil then
        local rawPlayers = sql.Query("SELECT * FROM 'FMS-PlyData' ")
        local players = {}

        for k, v in ipairs(rawPlayers) do
            if string.find(v["groups"], groupName..",?%s?") then
                table.insert(players,v)
            end
        end

        rawPlayers = nil
        return players
    end
end

meta = FindMetaTable("Player")

function meta:GetPermLevel()
    local permLevel = 1
    local plyGroups = self:GetGroups()

    for k,v in ipairs(plyGroups) do
        if FMSGroups.GetGroupData(v) ~= nil and FMSGroups.GetGroupData(v)["Rank"] > permLevel then
            permLevel = FMSGroups.GetGroupData(v)["Rank"]
            
        else
            self:RemoveFromGroup(v)
        end
    end
    return permLevel
end

function meta:GetGroups()
    ply = sql.QueryTyped("SELECT * FROM 'FMS-PlyData' WHERE SteamID64 = ?", self:SteamID64())[1]
    
    if ply == false or ply.groups == nil then
        print(sql.QueryTyped("INSERT INTO 'FMS-PlyData' (SteamID64) VALUES ( ? )", self:SteamID64()))
        return {}
    else
        return string.Explode(", ", ply.groups)
    end
end

function meta:RemoveFromGroup(groupName)
    groups = self:GetGroups()
    table.RemoveByValue(groups, groupName)

    nGroups = table.concat(groups,', ')
    sql.QueryTyped("UPDATE 'FMS-PlyData' SET groups = ? WHERE SteamID64 = ?", nGroups, self:SteamID64())
end

function meta:AddToGroup(groupName)
    if FMSGroups.GetGroupData(groupName) ~= nil then
        groups = self:GetGroups()
        table.insert(groups, groupName)

        nGroups = table.concat(groups,', ')
        sql.QueryTyped("UPDATE 'FMS-PlyData' SET groups = ? WHERE SteamID64 = ?", nGroups, self:SteamID64())
    end
end


hook.Add("PlayerSpawn", "FMS-PlyManagementChecks", function(ply,mapTrans)
    --Give user group to player if they lack it on spawn
    if !table.HasValue(ply:GetGroups(),"user") then
        ply:AddToGroup("user")
    end
    --Remove non-existant groups from player data
    for k,v in pairs(ply:GetGroups())do
        if FMSGroups.GetGroupData(v) == nil then
            ply:RemoveFromGroup(v)
        end
    end
end)

gameevent.Listen("player_connect")
hook.Add("player_connect", "FMS-PlyDataRegister",function(data)
    local steamid = util.SteamIDTo64(data.networkid)
    local playerDat = sql.QueryTyped("SELECT * FROM 'FMS-PlyData' WHERE SteamID64 = ?",steamid)[1]

    if game.SinglePlayer() then steamid = player.GetAll()[1]:SteamID64() end
    if playerDat == nil then
        sql.QueryTyped("INSERT INTO 'FMS-PlyData' (SteamID64, SteamName) VALUES (?,?)",steamid, data.name) 
    end
end)

hook.Add("player_connect", "FMS-PlyDataNameUpdate",function(data)
    local steamid = util.SteamIDTo64(data.networkid) 
    local playerData = sql.QueryTyped("SELECT * FROM 'FMS-PlyData' WHERE SteamID64 = ?",steamid)[1]

    if game.SinglePlayer() then data.networkid = player.GetAll()[1]:SteamID64() end
    if playerData ~= nil and data.name ~= playerData.SteamName then
        sql.QueryTyped("UPDATE 'FMS-PlyData' SET SteamName = ? WHERE SteamID64 = ?",data.name,steamid)
    end
end)

hook.Add("player_connect","FMS-AutoKickBanned",function(data)
    local ID = util.SteamIDTo64(data.networkid)
    local lastBan = sql.QueryTyped("SELECT * FROM 'FMS-PunishmentData' WHERE PlayerID64 = ? AND ExpireDate = 0 OR ExpireDate > ? AND Type = 'BAN' LIMIT 1 ",ID,os.time())[1]

    FMSUtils.LogMessage(ID.."Connected")
    if lastBan ~= nil then
        local staffInfo = sql.QueryTyped("SELECT * FROM 'FMS-PlyData' WHERE SteamID64 = ? LIMIT 1",lastBan.StaffID)
        FMSUtils.LogMessage("Auto Kicked banned player with ID: "..ID)
        game.KickID(ID,
            "You were banned by: "..
		    staffInfo.SteamName..
            '. Expires: '..
            (function() if lastBan.ExpireDate == 0 then return "Never" else return os.date("", lastBan.ExpireDate)end end)()..
		    '.Provided reason: "'..
		    lastBan.Reason..
		    '". Appeal in Discord: https://discord.com/invite/QgWpfpw9F6'
		)
    end
end)
