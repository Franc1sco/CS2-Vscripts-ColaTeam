-- Change the time in seconds on the next line
AFK_Seconds = 40



require("util.timers")

afkPos = {}
local connectedPlayers = {}

function AFKEHandleToHScript(iPawnId)
    return EntIndexToHScript(bit.band(iPawnId, 0x3FFF))
end

function table.AFKGetNameFromPawn(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i].pawn ~= nil then
            if AFKEHandleToHScript(tbl[i].pawn) == value then
                return tbl[i].name
            end
        end
    end
    return ""
end

function AFKOnPlayerSpawn(event)
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
    end
end

function AFKOnTeam(event)
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
    end
end

function AFKOnPlayerConnect(event)
	local playerData = {
		name = event.name,
		userid = event.userid,
		networkid = event.networkid,
		address = event.address,
        --pawn = EHandleToHScript(event.userid_pawn)
	}
    table.insert(connectedPlayers, playerData)
end

function AFKOnPlayerDisconnect(event)
    local usertableid = table.GetValue(connectedPlayers, event.userid)
    if usertableid ~= nil then
        table.RemoveValue(connectedPlayers, usertableid)
    end
end

function AFKOnRoundStart(event)

    Timers:RemoveTimer("AFK_Timer")

    for k, player in pairs(Entities:FindAllByClassname("player")) do
        if player:IsAlive() then
            afkPos[player] = player:GetAbsOrigin()
        else
            afkPos[player] = nil
        end
    end

    Check_AFK()
end

function Check_AFK()
    local AFK_Countdown = AFK_Seconds
    if not Timers:TimerExists(AFK_Timer) then
        Timers:CreateTimer("AFK_Timer", {
            callback = function()
                if AFK_Countdown <= 0 then
                    Timers:RemoveTimer("AFK_Timer")
                    Move_AFK() 
                end
                AFK_Countdown = AFK_Countdown - 1
                return 1
            end,
        })
    end
end

function Move_AFK() 
    for k, player in pairs(Entities:FindAllByClassname("player")) do
        if player:IsAlive() then
            if afkPos[player] ~= nil and CompareVectors(afkPos[player], player:GetAbsOrigin()) then
                player:SetTeam(1)
                ScriptPrintMessageChatAll(table.AFKGetNameFromPawn(connectedPlayers, player).. " was moved to spectator for be AFK.")
            end
        end
    end
end

function CompareVectors(v1, v2)
    if v1.x == v2.x and v1.y == v2.y then
        return true
    end
    return false
end

tListenerIds = {
    ListenToGameEvent("player_connect", AFKOnPlayerConnect, nil),
    ListenToGameEvent("player_disconnect", AFKOnPlayerDisconnect, nil),
    ListenToGameEvent("player_spawn", AFKOnPlayerSpawn, nil),
    ListenToGameEvent("player_team", AFKOnTeam, nil),
    ListenToGameEvent("round_start", AFKOnRoundStart, nil),
}