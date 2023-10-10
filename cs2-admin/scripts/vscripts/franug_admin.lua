local adminpassword = "yourpassword"


require("adminlist")

local connectedPlayers = {}
local activeAdmins = {}

function tableContains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function GetPlayerName(userid)
    local playerData = connectedPlayers[userid]
    if playerData then
        return playerData.name
    else
        return "unknown"
    end
end

function ExistPlayer(userid)
    local playerData = connectedPlayers[userid]
    if playerData then
        return true
    else
        return false
    end
end

-- removes all instances of a given value
-- from a given table
function table.RemoveValue(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i] == value then
            table.remove(tbl, i)
        end
    end
end

function table.GetValue(tbl, value)
    for i = #tbl, 1, -1 do
        --print("lista con numero "..i.. " id es "..tbl[i].userid.. " buscando id "..value)
        if tbl[i].userid == value then
            return tbl[i]
        end
    end
    return nil
end

function table.GetValueByName(tbl, value)
    for i, name in ipairs(tbl) do
        --print("lista con numero "..i.. "name es "..tbl[i].name.. " buscando name "..value)
        if string.find(string.lower(tbl[i].name), string.lower(value), 1, true) then
            return tbl[i]
        end
    end
    return nil
end

function table.GetUserIdFromPawn(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i].pawn ~= nil then
            --print("lista con numero "..i.. "pawn es ")
            --print(EHandleToHScript(tbl[i].pawn))
            --print("buscando pawn ")
            --print(value)
            if EHandleToHScript(tbl[i].pawn) == value then
                --print("encontrado con userid "..tbl[i].userid)
                return tbl[i].userid
            end
        end
    end
    return nil
end

function IsAdmin(user)
    local steamid = table.GetSteamIdFromPawn(connectedPlayers, user)
    if steamid ~= nil then
        if tableContains(AdminList, steamid) then
            return true
        end
    end
    return false
end

function table.GetSteamIdFromPawn(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i].pawn ~= nil then
            --print("lista con numero "..i.. "pawn es ")
            --print(EHandleToHScript(tbl[i].pawn))
            --print("buscando pawn ")
            --print(value)
            if EHandleToHScript(tbl[i].pawn) == value then
                --print("encontrado con userid "..tbl[i].userid)
                return tbl[i].networkid
            end
        end
    end
    return nil
end

function EHandleToHScript(iPawnId)
    return EntIndexToHScript(bit.band(iPawnId, 0x3FFF))
end

function addAdmin(activeAdmins, admin)
    for _, existingAdmin in ipairs(activeAdmins) do
        if existingAdmin == admin then
            print("admin already logged in")
            return
        end
    end

    table.insert(activeAdmins, admin)
end

--Convars:RegisterConvar("franugadmin_password", "yourpassword", "Put here the password that you want for admin login", FCVAR_DONTRECORD)

Convars:RegisterCommand( "adminlogin" , function (_, pw)
    local password = tostring (pw) or  30
    --print("pass introducida es "..password)
    --print("pass correcta "..Convars:GetStr("franugadmin_password"))
    --if password == Convars:GetStr("franugadmin_password") then
    if password == adminpassword then
        local admin = Convars:GetCommandClient()
        addAdmin(activeAdmins, admin)
        --local userid = table.GetUserIdFromPawn(connectedPlayers, admin)
        --if userid ~= nil then
            --UTIL_MessageText(userid, "Admin login sucess", 0, 255, 0, 255)
        --end
        print("admin logged in")
    end
end, nil , FCVAR_PROTECTED)

Convars:RegisterCommand( "sm_kick" , function (_, args)
    local user = Convars:GetCommandClient()

    if IsAdmin(user) or tableContains(activeAdmins, user) then
        --local msg = tonumber(args) or 0
        local msg = tostring(args)
        --print(msg)
        --local msgfix = msg + 1 
        -- TODO
        --local usertableid = table.GetValue(connectedPlayers, msg)
        local userid = table.GetValueByName(connectedPlayers, msg)
        if userid == nil then
            userid = table.GetValue(connectedPlayers, tonumber(msg))
        end
        if userid == nil then
            return
        end
        --local usertablepawn = UserIDToControllerHScript(userid.userid)
        local usertablepawn = EHandleToHScript(userid.pawn)
        --print(usertablepawn)
        if usertablepawn ~= nil then
            --local target = usertablepawn:GetPawn()
            --if target ~= nil and target:IsAlive() then
            --if usertablepawn:IsAlive() then
                --print("pasado")
                --local username = table.GetValue(connectedPlayers, msg).name
                local username = userid.name
                --print("pasado y encontrado")
                ScriptPrintMessageChatAll(" \x05[ADMIN]: kicked player "..username)
                SendToServerConsole("kickid " .. userid.userid .. " kicked by server admin")
                --table.RemoveValue(connectedPlayers, usertableid)
            --end
        end
    end
end, nil , FCVAR_PROTECTED)

Convars:RegisterCommand( "sm_rcon" , function (_, args)
    local user = Convars:GetCommandClient()

    if IsAdmin(user) or tableContains(activeAdmins, user) then
        local msg = tostring(args)
        SendToServerConsole(msg)
    end
end, nil , FCVAR_PROTECTED)

Convars:RegisterCommand( "sm_say" , function (_, args)
    local user = Convars:GetCommandClient()
    --print(msg)
    --user.GetEntityIndex()

    if IsAdmin(user) or tableContains(activeAdmins, user) then
        local msg = tostring(args)
        --print("hecho con "..msg)
        ScriptPrintMessageChatAll(" \x05ADMIN: "..msg)
        ScriptPrintMessageCenterAll("ADMIN: "..msg)
    end
end, nil , FCVAR_PROTECTED)

Convars:RegisterCommand( "sm_map" , function (_, args)
    local user = Convars:GetCommandClient()
    --print(msg)
    --user.GetEntityIndex()

    if IsAdmin(user) or tableContains(activeAdmins, user) then
        local msg = tostring(args)
        --print("hecho con "..msg)
        ScriptPrintMessageChatAll(" \x05ADMIN: changing map to "..msg)
        ScriptPrintMessageCenterAll("ADMIN: changing map to "..msg)
        SendToServerConsole("map "..msg)
    end
end, nil , FCVAR_PROTECTED)

Convars:RegisterCommand( "sm_slay" , function (_, args)
    local user = Convars:GetCommandClient()
    --print(msg)
    --user.GetEntityIndex()

    if IsAdmin(user) or tableContains(activeAdmins, user) then
        --local msg = tonumber(args) or 0
        local msg = tostring(args)
        --print(msg)
        --local msgfix = msg + 1 
        -- TODO
        --local usertableid = table.GetValue(connectedPlayers, msg)
        local userid = table.GetValueByName(connectedPlayers, msg)
        if userid == nil then
            userid = table.GetValue(connectedPlayers, tonumber(msg))
        end
        if userid == nil then
            return
        end
        --local usertablepawn = UserIDToControllerHScript(userid.userid)
        local usertablepawn = EHandleToHScript(userid.pawn)
        --print(usertablepawn)
        if usertablepawn ~= nil then
            --local target = usertablepawn:GetPawn()
            --if target ~= nil and target:IsAlive() then
            --if usertablepawn:IsAlive() then
                --print("pasado")
                --local username = table.GetValue(connectedPlayers, msg).name
                local username = userid.name
                --print("pasado y encontrado")
                DoEntFireByInstanceHandle(usertablepawn, "SetHealth", "0", 0.1, nil, nil)
                ScriptPrintMessageChatAll(" \x05[ADMIN]: slayed player "..username)
                --table.RemoveValue(connectedPlayers, usertableid)
            --end
        end
    end
end, nil , FCVAR_PROTECTED)

Convars:RegisterCommand( "sm_hp" , function (_, args, args2)
    local user = Convars:GetCommandClient()

    if IsAdmin(user) or tableContains(activeAdmins, user) then
        local msg = tostring(args)
        local msg2 = tonumber(args2) or 100

        local userid = table.GetValueByName(connectedPlayers, msg)

        if userid == nil then
            userid = table.GetValue(connectedPlayers, tonumber(msg))
        end
        if userid == nil then
            return
        end

        local usertablepawn = EHandleToHScript(userid.pawn)
        if usertablepawn ~= nil then
            local username = userid.name
            --DoEntFireByInstanceHandle(usertablepawn, "SetHealth", msg2, 0.1, nil, nil)
            usertablepawn:SetHealth(msg2)
            ScriptPrintMessageChatAll(" \x05[ADMIN]: set "..msg2.." hp on player "..username)
        end
    end
end, nil , FCVAR_PROTECTED)

Convars:RegisterCommand( "sm_burn" , function (_, args, args2)
    local user = Convars:GetCommandClient()

    if IsAdmin(user) or tableContains(activeAdmins, user) then
        local msg = tostring(args)

        local userid = table.GetValueByName(connectedPlayers, tonumber(msg))

        if userid == nil then
            userid = table.GetValue(connectedPlayers, msg)
        end
        if userid == nil then
            return
        end

        local usertablepawn = EHandleToHScript(userid.pawn)
        if usertablepawn ~= nil then
            local username = userid.name
            DoEntFireByInstanceHandle(usertablepawn, "Ignite", "", 0.1, usertablepawn, usertablepawn)
            ScriptPrintMessageChatAll(" \x05[ADMIN]: Ignite player "..username)
        end
    end
end, nil , FCVAR_PROTECTED)

Convars:RegisterCommand( "sm_fakesay" , function (_, args, args2)
    local user = Convars:GetCommandClient()

    if IsAdmin(user) or tableContains(activeAdmins, user) then
        local msg = tostring(args)
        local msg2 = tostring(args2) or "xd"

        local userid = table.GetValueByName(connectedPlayers, msg)

        if userid == nil then
            userid = table.GetValue(connectedPlayers, tonumber(msg))
        end
        if userid == nil then
            return
        end

        local usertablepawn = EHandleToHScript(userid.pawn)
        if usertablepawn ~= nil then
            --local username = userid.name
            --DoEntFireByInstanceHandle(usertablepawn, "SetHealth", msg2, 0.1, nil, nil)
            Say(usertablepawn, msg2, false)
            --ScriptPrintMessageChatAll(" \x05[FRANUG ADMIN]: set "..msg2.." hp on player "..username)
        end
    end
end, nil , FCVAR_PROTECTED)

Convars:RegisterCommand( "sm_team" , function (_, args, args2)
    local user = Convars:GetCommandClient()

    if IsAdmin(user) or tableContains(activeAdmins, user) then
        local msg = tostring(args)
        local msg2 = tonumber(args2) or 1

        local userid = table.GetValueByName(connectedPlayers, msg)

        if userid == nil then
            userid = table.GetValue(connectedPlayers, tonumber(msg))
        end
        if userid == nil then
            return
        end

        local usertablepawn = EHandleToHScript(userid.pawn)
        if usertablepawn ~= nil then
            local username = userid.name
            --DoEntFireByInstanceHandle(usertablepawn, "SetHealth", msg2, 0.1, nil, nil)
            usertablepawn:SetTeam(msg2)
            ScriptPrintMessageChatAll(" \x05[ADMIN]: set team "..msg2.." on player "..username)
        end
    end
end, nil , FCVAR_PROTECTED)

Convars:RegisterCommand( "sm_rr" , function (_, args)
    local user = Convars:GetCommandClient()

    if IsAdmin(user) or tableContains(activeAdmins, user) then
        SendToServerConsole("mp_restartgame 2")
        ScriptPrintMessageChatAll(" \x05[ADMIN]: restarting game...")
    end
end, nil , FCVAR_PROTECTED)

Convars:RegisterCommand( "sm_respawn" , function (_, args)
    local user = Convars:GetCommandClient()

    if IsAdmin(user) or tableContains(activeAdmins, user) then
        ScriptCoopMissionRespawnDeadPlayers() -- no funciona :(
        ScriptPrintMessageChatAll(" \x05[ADMIN]: respawned dead players")
    end
end, nil , FCVAR_PROTECTED)

function AdminOnPlayerConnect(event)
	local playerData = {
		name = event.name,
		userid = event.userid,
		networkid = event.networkid,
		address = event.address,
        --pawn = EHandleToHScript(event.userid_pawn)
	}
    table.insert(connectedPlayers, playerData)
    --print("conectado")
	--connectedPlayers[event.userid] = playerData
end

function AdminOnPlayerDisconnect(event)
    local usertableid = table.GetValue(connectedPlayers, event.userid)
    if usertableid ~= nil then
        table.RemoveValue(connectedPlayers, usertableid)
    end
    --print("desconectado")
	--connectedPlayers[event.userid] = nil
end

function AdminOnPlayerSpawn(event)
    local usertableid = table.GetValue(connectedPlayers, event.userid)
    if usertableid ~= nil then
        table.RemoveValue(connectedPlayers, usertableid)
        local playerData = {
            name = usertableid.name,
            userid = event.userid,
            networkid = usertableid.networkid,
            address = usertableid.address,
            pawn = event.userid_pawn
        }
        table.insert(connectedPlayers, playerData)
        --print("re spawned con pawn "..event.userid_pawn)
    end
	--connectedPlayers[event.userid] = nil
end

function AdminOnTeam(event)
    local usertableid = table.GetValue(connectedPlayers, event.userid)
    if usertableid ~= nil then
        table.RemoveValue(connectedPlayers, usertableid)
        local playerData = {
            name = usertableid.name,
            userid = event.userid,
            networkid = usertableid.networkid,
            address = usertableid.address,
            pawn = event.userid_pawn
        }
        table.insert(connectedPlayers, playerData)
        --print("re spawned con pawn "..event.userid_pawn)
    end
	--connectedPlayers[event.userid] = nil
end


--if tListenerIds then
    --for k, v in ipairs(tListenerIds) do
        --StopListeningToGameEvent(v)
    --end
--end

tListenerIds = {
    ListenToGameEvent("player_connect", AdminOnPlayerConnect, nil),
    ListenToGameEvent("player_disconnect", AdminOnPlayerDisconnect, nil),
    ListenToGameEvent("player_spawn", AdminOnPlayerSpawn, nil),
    ListenToGameEvent("player_team", AdminOnTeam, nil)
}