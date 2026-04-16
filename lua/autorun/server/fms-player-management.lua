sql.Query("CREATE TABLE IF NOT EXISTS 'FMS-PlyData' (SteamID64 BIT(64) PRIMARY KEY, groups STRING)")
sql.Query("CREATE TABLE IF NOT EXISTS 'FMS-GroupData' (GroupName STRING UNIQUE, Rank BIT(8), Color BLOB)")

FMSGroups = {}

function FMSGroups.AddGroup(groupName, rank, color)
    colorStr = sql.SQLStr(utf8.char(color:Unpack()),true)
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
    PrintMessage(HUD_PRINTTALK,permLevel)
    return permLevel
end

function meta:GetGroups()
    ply = sql.QueryTyped("SELECT * FROM 'FMS-PlyData' WHERE SteamID64 = ?", self:SteamID64())

    
    if ply == nil or ply["groups"] == nil then
        sql.QueryTyped("INSERT INTO 'FMS-PlyData' (SteamID64) VALUES (?)", self:SteamID64())
        return {}
    else
        groups = string.Explode(", ", ply["groups"])
        PrintTable(groups)
        return groups
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
        PrintTable(groups)
        table.insert(groups, groupName)
        PrintTable(groups)

        nGroups = table.concat(groups,', ')
        print(nGroups)
        sql.QueryTyped("UPDATE 'FMS-PlyData' SET groups = ? WHERE SteamID64 = ?", nGroups, self:SteamID64())
    end
end

hook.Add("PlayerSpawn", "FMS-PlyManagementChecks", function(ply,mapTrans)
    if !table.HasValue(ply:GetGroups(),"user") then
        ply:AddToGroup("user")
    end
    for k,v in pairs(ply:GetGroups())do
        if FMSGroups.GetGroupData(v) == nil then
            ply:RemoveFromGroup(v)
        end
    end
end)