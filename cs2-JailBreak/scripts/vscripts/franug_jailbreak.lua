local JailconnectedPlayers = {}

-- removes all instances of a given value
-- from a given table
function table.jailRemoveValue(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i] == value then
            table.remove(tbl, i)
        end
    end
end

function table.jailGetValue(tbl, value)
    for i = #tbl, 1, -1 do
        --print("lista con numero "..i.. " id es "..tbl[i].userid.. " buscando id "..value)
        if tbl[i].userid == value then
            return tbl[i]
        end
    end
    return nil
end

function table.jailGetValueByName(tbl, value)
    for i, name in ipairs(tbl) do
        --print("lista con numero "..i.. "name es "..tbl[i].name.. " buscando name "..value)
        if string.find(string.lower(tbl[i].name), string.lower(value), 1, true) then
            return tbl[i]
        end
    end
    return nil
end

function table.jailGetUserIdFromPawn(tbl, value)
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

function table.jailGetTeamFromPawn(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i].pawn ~= nil then
            --print("lista con numero "..i.. "pawn es ")
            --print(EHandleToHScript(tbl[i].pawn))
            --print("buscando pawn ")
            --print(value)
            if EHandleToHScript(tbl[i].pawn) == value then
                --print("encontrado con userid "..tbl[i].userid)
                return tbl[i].team
            end
        end
    end
    return nil
end

function table.jailGetNameFromPawn(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i].pawn ~= nil then
            --print("lista con numero "..i.. "pawn es ")
            --print(EHandleToHScript(tbl[i].pawn))
            --print("buscando pawn ")
            --print(value)
            if EHandleToHScript(tbl[i].pawn) == value then
                --print("encontrado con userid "..tbl[i].userid)
                return tbl[i].name
            end
        end
    end
    return nil
end

function table.jailGetSteamIdFromPawn(tbl, value)
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

function CheckWeapons(hPlayer)
    RemoveWeapons(hPlayer)
    if table.jailGetTeamFromPawn(JailconnectedPlayers, hPlayer) == 3 then
        GivePlayerItem(hPlayer, "hkp2000")
        GivePlayerItem(hPlayer, "m4a1")
    end
end

function RemoveWeapons(hPlayer)
    local tInventory = hPlayer:GetEquippedWeapons()

    for key, value in ipairs(tInventory) do
        if value:GetClassname() ~= "weapon_knife" then
            value:Destroy()
        end
    end
end

function GivePlayerItem(hPlayer, Weapon)
    SendToServerConsole("sm_give "..table.dmGetUserIdFromPawn(JailconnectedPlayers, hPlayer).. " "..Weapon)
end

if tListenerIds then
    for k, v in ipairs(tListenerIds) do
        StopListeningToGameEvent(v)
    end
end

function JailOnPlayerSpawn(event)
    local hPlayer = EHandleToHScript(event.userid_pawn)

    local usertableid = table.jailGetValue(JailconnectedPlayers, event.userid)
    if usertableid ~= nil then
        table.jailRemoveValue(JailconnectedPlayers, usertableid)
        local playerData = {
            name = usertableid.name,
            userid = event.userid,
            networkid = usertableid.networkid,
            address = usertableid.address,
            team = usertableid.team,
            pawn = event.userid_pawn
        }
        table.insert(JailconnectedPlayers, playerData)
    end

    CheckWeapons(hPlayer)
end


function JailOnPlayerConnect(event)
	local playerData = {
		name = event.name,
		userid = event.userid,
		networkid = event.networkid,
		address = event.address,
	}
    table.insert(JailconnectedPlayers, playerData)
end

function JailOnPlayerDisconnect(event)
    local usertableid = table.jailGetValue(JailconnectedPlayers, event.userid)
    if usertableid ~= nil then
        table.jailRemoveValue(JailconnectedPlayers, usertableid)
    end
    --print("desconectado")
	--connectedPlayers[event.userid] = nil
end

function JailOnTeam(event)
    local usertableid = table.jailGetValue(JailconnectedPlayers, event.userid)
    if usertableid ~= nil then
        table.jailRemoveValue(JailconnectedPlayers, usertableid)
        local playerData = {
            name = usertableid.name,
            userid = event.userid,
            networkid = usertableid.networkid,
            address = usertableid.address,
            pawn = event.userid_pawn,
            team = event.team,
        }
        table.insert(JailconnectedPlayers, playerData)
    end
end

function JailOnPlayerConnect(event)
	local playerData = {
		name = event.name,
		userid = event.userid,
		networkid = event.networkid,
		address = event.address,
        team = 0,
	}
    table.insert(JailconnectedPlayers, playerData)
end

function JailOnPlayerDisconnect(event)
    local usertableid = table.jailGetValue(JailconnectedPlayers, event.userid)
    if usertableid ~= nil then
        table.jailRemoveValue(JailconnectedPlayers, usertableid)
    end
end

tListenerIds = {
    ListenToGameEvent("player_spawn", JailOnPlayerSpawn, nil),
    ListenToGameEvent("player_connect", JailOnPlayerConnect, nil),
    ListenToGameEvent("player_disconnect", JailOnPlayerDisconnect, nil),
    ListenToGameEvent("player_team", JailOnTeam, nil)
}