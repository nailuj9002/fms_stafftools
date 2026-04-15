print("====================")
print("=     Fluffy's     =")
print("= Moderation Stuff =")
print("=====================")

if SERVER then
    local files = file.Find("fms_modules/server/*.lua", "LUA")
    for _,filename in ipairs(files) do
        print("[FMS Server] Loading module: server/"..filename)
        include("fms_modules/server/"..filename)
    end
    local files = file.Find("fms_modules/client/*.lua", "LUA")
    for _,filename in ipairs(files) do
        print("[FMS Client] Sending module: client/"..filename)
        AddCSLuaFile("fms_modules/client/"..filename)
    end
elseif CLIENT then
    local files = file.Find("fms_modules/client/*.lua", "LUA")
    for _,filename in ipairs(files) do
        print("[FMS Client] Loading module: "..filename)
        include("fms_modules/client/"..filename)
    end
end

local files = file.Find("fms_modules/shared/*.lua", "LUA")
for _,filename in ipairs(files) do
    print("[FMS Shared] Loading module: shared/"..filename)
    include("fms_modules/shared/"..filename)
end


