print("Starting Franug test!")
require("util.timers")

local stageId = 0

--local first_stage = false

local DMconnectedPlayers = {}


function dmtableContains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function dmGetPlayerName(userid)
    local playerData = DMconnectedPlayers[userid]
    if playerData then
        return playerData.name
    else
        return "unknown"
    end
end

-- removes all instances of a given value
-- from a given table
function table.dmRemoveValue(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i] == value then
            table.remove(tbl, i)
        end
    end
end

function table.dmGetValue(tbl, value)
    for i = #tbl, 1, -1 do
        --print("lista con numero "..i.. " id es "..tbl[i].userid.. " buscando id "..value)
        if tbl[i].userid == value then
            return tbl[i]
        end
    end
    return nil
end

function table.dmGetValueByName(tbl, value)
    for i, name in ipairs(tbl) do
        --print("lista con numero "..i.. "name es "..tbl[i].name.. " buscando name "..value)
        if string.find(string.lower(tbl[i].name), string.lower(value), 1, true) then
            return tbl[i]
        end
    end
    return nil
end

function table.dmGetUserIdFromPawn(tbl, value)
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

function table.dmGetTeamFromPawn(tbl, value)
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

function table.dmGetNameFromPawn(tbl, value)
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

function table.dmGetSteamIdFromPawn(tbl, value)
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

function DMOnRoundStart(event)
    -- Make sure point_clientcommand exists
    clientcmd = Entities:FindByClassname(nil, "point_clientcommand")

    if clientcmd == nil then
        clientcmd = SpawnEntityFromTableSynchronous("point_clientcommand", { targetname = "vscript_clientcommand" })
    end

    --Here we force some cvars that are essential for the scripts to work
    Convars:SetInt("mp_weapons_allow_pistols", -1)
    Convars:SetInt("mp_weapons_allow_smgs", -1)
    Convars:SetInt("mp_weapons_allow_heavy", -1)
    Convars:SetInt("mp_weapons_allow_rifles", -1)
    Convars:SetInt("mp_weapons_allow_rifles", -1)
    --Convars:SetInt("cash_player_respawn_amount", 16000)
    --Convars:SetInt("mp_give_player_c4", 0)
    --Convars:SetInt("mp_friendlyfire", 0)
    --Convars:SetInt("mp_respawn_on_death_t", 1)
    --Convars:SetInt("mp_respawn_on_death_ct", 1)
    Convars:SetInt("mp_roundtime", 40)
    Convars:SetInt("mp_dm_time_between_bonus_min", 999)
    Convars:SetInt("mp_dm_time_between_bonus_max", 999)
    
    --Convars:SetInt("mp_buy_anywhere", 1)
    --Convars:SetInt("mp_buytime", 99999)
    --Convars:SetInt("mp_maxmoney", 100000)
    --Convars:SetInt("mp_startmoney ", 100000)
    --Convars:SetInt("mp_afterroundmoney ", 100000)
    --Convars:SetInt('mp_ignore_round_win_conditions', 1)

    ScriptPrintMessageChatAll("The game is \x05DM MULTI-CFG\x01")

    Timers:RemoveTimer("DM_Timer")

    setupStage()
    DM_ChangeStage()
end



function DM_ChangeStage()
    local DM_Countdown = RandomInt(60, 300)
    if not Timers:TimerExists(DM_Timer) then
        Timers:CreateTimer("DM_Timer", {
            callback = function()
                if DM_Countdown <= 0 then
                    Timers:RemoveTimer("DM_Timer")
                    stageId = stageId + 1
                    setupStage()
                    DM_ChangeStage()
                else
                    if DM_Countdown == 1 then
                        ScriptPrintMessageCenterAll("Current Stage: " .. getStage(stageId) .. "\nNext stage ".. getStage(stageId + 1) .. " in \x071 second\x01!")
                    else
                        local formatted_time = secondsToTimeFormat(DM_Countdown)
                        ScriptPrintMessageCenterAll("Current Stage: " .. getStage(stageId) .. "\nNext stage ".. getStage(stageId + 1) .. " in \x07" .. formatted_time .. " \x01!")
                    end
                end
                DM_Countdown = DM_Countdown - 1
                return 1
            end,
        })
    end
end

function secondsToTimeFormat(segundos)
    --local hours = math.floor(segundos / 3600)
    local minutes = math.floor((segundos % 3600) / 60)
    local seconds = segundos % 60

    if minutes == 0 then
        return string.format("%02d seconds", seconds)
    end
    
    return string.format("%02d:%02d", minutes, seconds)
  end

function getStage(stage)
    if (stage == 0) then
        return string.format("Pistols")
    elseif (stage == 1) then
        return string.format("SMGs")
    elseif (stage == 2) then
        return string.format("Rifles")
    elseif (stage == 3) then
        return string.format("Shotguns")
    else
        return string.format("Pistols")
    end
end

function setupStage()
    for i = 1, 64 do
        local hController = EntIndexToHScript(i)

        if hController ~= nil and hController:GetPawn() ~= nil then
            --I have absolutely no idea why, but this has to be delayed now
            RemoveWeapons(hController:GetPawn())
            --GiveWeapons(hController:GetPawn())
            --local player = hController:GetPawn()
            --DoEntFireByInstanceHandle(player, "SetHealth", "0", 0.01, nil, nil)
            --DoEntFireByInstanceHandle(player, "SetHealth", "100", 0.02, nil, nil)
        end
    end
    if (stageId == 0) then
        Convars:SetInt("mp_weapons_allow_pistols", -1)
        Convars:SetInt("mp_weapons_allow_smgs", 0)
        Convars:SetInt("mp_weapons_allow_heavy", 0)
        Convars:SetInt("mp_weapons_allow_rifles", 0)
        --Convars:SetStr("mp_ct_default_primary", "")
        --Convars:SetStr("mp_t_default_primary", "")
        SendToServerConsole("sm_give @t glock")
        SendToServerConsole("sm_give @ct hkp2000")
    elseif (stageId == 1) then
        Convars:SetInt("mp_weapons_allow_pistols", 0)
        Convars:SetInt("mp_weapons_allow_smgs", -1)
        Convars:SetInt("mp_weapons_allow_heavy", 0)
        Convars:SetInt("mp_weapons_allow_rifles", 0)
        --Convars:SetStr("mp_ct_default_primary", "weapon_p90")
        --Convars:SetStr("mp_t_default_primary", "weapon_p90")
        SendToServerConsole("sm_give @all p90")
    elseif (stageId == 2) then
        Convars:SetInt("mp_weapons_allow_pistols", 0)
        Convars:SetInt("mp_weapons_allow_smgs", 0)
        Convars:SetInt("mp_weapons_allow_heavy", 0)
        Convars:SetInt("mp_weapons_allow_rifles", -1)
        --Convars:SetStr("mp_t_default_primary", "weapon_ak47")
        --Convars:SetStr("mp_ct_default_primary", "weapon_m4a1")
        SendToServerConsole("sm_give @t ak47")
        SendToServerConsole("sm_give @ct m4a1")
    elseif (stageId == 3) then
        Convars:SetInt("mp_weapons_allow_pistols", 0)
        Convars:SetInt("mp_weapons_allow_smgs", 0)
        Convars:SetInt("mp_weapons_allow_heavy", -1)
        Convars:SetInt("mp_weapons_allow_rifles", 0)
        --Convars:SetStr("mp_t_default_primary", "weapon_nova")
        --Convars:SetStr("mp_ct_default_primary", "weapon_nova")
        SendToServerConsole("sm_give @all nova")
    else
        stageId = 0
        Convars:SetInt("mp_weapons_allow_pistols", -1)
        Convars:SetInt("mp_weapons_allow_smgs", 0)
        Convars:SetInt("mp_weapons_allow_heavy", 0)
        Convars:SetInt("mp_weapons_allow_rifles", 0)
        --Convars:SetStr("mp_ct_default_primary", "")
        --Convars:SetStr("mp_t_default_primary", "")
        SendToServerConsole("sm_give @t glock")
        SendToServerConsole("sm_give @ct hkp2000")
    end
    --DoEntFireByInstanceHandle(nil, "runscriptcode", "ScriptCoopMissionSetNextRespawnIn(0.01, 0.01)", 0.03, nil, nil)
    --DoEntFireByInstanceHandle(nil, "runscriptcode", "ScriptCoopMissionSetDeadPlayerRespawnEnabled(true)", 0.03, nil, nil)
    --DoEntFireByInstanceHandle(nil, "runscriptcode", "ScriptCoopMissionRespawnDeadPlayers()", 0.1, nil, nil)
    --DoEntFire()
    --ScriptCoopMissionRespawnDeadPlayers()
end

function RemoveWeapons(hPlayer)
    local tInventory = hPlayer:GetEquippedWeapons()

    for key, value in ipairs(tInventory) do
        if value:GetClassname() ~= "weapon_knife" then
            value:Destroy()
            --DoEntFireByInstanceHandle(clientcmd, "command", "lastinv", 0.1, hPlayer, hPlayer)
        end
    end
end



function CheckWeapons(hPlayer)
    local tInventory = hPlayer:GetEquippedWeapons()
    local haveweapons = false
    for key, value in ipairs(tInventory) do
        if value:GetClassname() ~= "weapon_knife" then
            haveweapons = true
        end
    end

    if haveweapons == false then
        GiveWeapons(hPlayer)
        --DoEntFireByInstanceHandle(hPlayer, "runscriptcode", "CheckWeapons(thisEntity)", 0.2, nil, nil)
    end
end

function GiveWeapons(hPlayer)
    --DoEntFireByInstanceHandle(hPlayer, "SetMoney", "15000", 0.01, nil, nil)
    if (stageId == 0) then
        --DoEntFireByInstanceHandle(hPlayer, "weapon_p250", "", 0, nil, nil)
        --GivePlayerItem(hPlayer, "p250")
        if table.dmGetTeamFromPawn(DMconnectedPlayers, hPlayer) == 3 then
            GivePlayerItem(hPlayer, "hkp2000")
        elseif table.dmGetTeamFromPawn(DMconnectedPlayers, hPlayer) == 2 then
            GivePlayerItem(hPlayer, "glock")
        end
    elseif (stageId == 1) then
        --DoEntFireByInstanceHandle(hPlayer, "weapon_p90", "", 0, nil, nil)
        GivePlayerItem(hPlayer, "p90")
    elseif (stageId == 2) then
        --DoEntFireByInstanceHandle(hPlayer, "weapon_awp", "", 0, nil, nil)
        --GivePlayerItem(hPlayer, "awp")
        if table.dmGetTeamFromPawn(DMconnectedPlayers, hPlayer) == 3 then
            GivePlayerItem(hPlayer, "m4a1")
        elseif table.dmGetTeamFromPawn(DMconnectedPlayers, hPlayer) == 2 then
            GivePlayerItem(hPlayer, "ak47")
        end
    elseif (stageId == 3) then
        --DoEntFireByInstanceHandle(hPlayer, "weapon_nova", "", 0, nil, nil)
        GivePlayerItem(hPlayer, "nova")
    else
        if table.dmGetTeamFromPawn(DMconnectedPlayers, hPlayer) == 3 then
            GivePlayerItem(hPlayer, "hkp2000")
        elseif table.dmGetTeamFromPawn(DMconnectedPlayers, hPlayer) == 2 then
            GivePlayerItem(hPlayer, "glock")
        end
        --DoEntFireByInstanceHandle(hPlayer, "weapon_p250", "", 0, nil, nil)
    end
end

function GivePlayerItem(hPlayer, Weapon)
    SendToServerConsole("sm_give "..table.dmGetUserIdFromPawn(DMconnectedPlayers, hPlayer).. " "..Weapon)
end

function GivePlayerItem3(hPlayer, Weapon)
    local weapon = Entities:CreateByClassname("weapon_" ..Weapon)
    weapon:SetAbsOrigin(hPlayer:EyePosition())
    weapon:SetOwner(hPlayer)
    weapon:ValidatePrivateScriptScope()
    --DoEntFireByInstanceHandle( weapon, "Use", "", 0, hPlayer, nil )
    --EntFireByHandle( hPlayer, "weapon_" ..Weapon, "", 0, hPlayer, hPlayer )
    --DoEntFire("weapon_" ..Weapon, "weapon_" ..Weapon, "", 0, hPlayer, hPlayer)
    --local hEnt = SpawnEntityFromTableSynchronous(Weapon, {
        --origin = hPlayer:EyePosition(),
    --})
    --DoEntFireByInstanceHandle(hEnt, "InitializeSpawnFromWorld", "", 0, nil, nil);
    --DoEntFireByInstanceHandle(hPlayer, "ent_create weapon_p250", "", 0, hPlayer, hPlayer)
end

function GivePlayerItem4(hPlayer, Weapon)
    --local weapon = Entities:CreateByClassname("weapon_" ..Weapon)
    --weapon:SetAbsOrigin(hPlayer:EyePosition())
    --DoEntFireByInstanceHandle( weapon, "Use", "", 0, hPlayer, nil )
    --EntFireByHandle( hPlayer, "weapon_" ..Weapon, "", 0, hPlayer, hPlayer )
    --DoEntFire("weapon_" ..Weapon, "weapon_" ..Weapon, "", 0, hPlayer, hPlayer)
    --local hEnt = SpawnEntityFromTableSynchronous(Weapon, {
        --origin = hPlayer:EyePosition(),
    --})
    --DoEntFireByInstanceHandle(hEnt, "InitializeSpawnFromWorld", "", 0, nil, nil);
    --DoEntFireByInstanceHandle(hPlayer, "ent_create weapon_p250", "", 0, hPlayer, hPlayer)
end

function GivePlayerItem5(hPlayer, Weapon)
    ScriptPrintMessageChatAll("arma dada "..Weapon)
    local equipper = SpawnEntityFromTableSynchronous("game_player_equip", {
        spawnflags = 5,
        weapon_awp = 0,
    })
    DoEntFireByInstanceHandle(equipper, "InitializeSpawnFromWorld", "", 0, nil, nil)
    -- set flags and keyvalues
    --equipper:Attribute_SetIntValue( "spawnflags", 5) --// "Use Only" and "Only Strip Same Weapon Type"
    --equipper:Attribute_SetIntValue("weapon_"..Weapon, 0)
    --equipper.__KeyValueFromInt( "weapon_knife", 0 )
    --equipper.__KeyValueFromInt( "item_kevlar", 0 )

    --equipper:ValidatePrivateScriptScope()

    DoEntFireByInstanceHandle( equipper, "Use", "", 0, hPlayer, nil ) --// each player "Use"s the equipper
    DoEntFireByInstanceHandle( equipper, "Kill", "", 0.1, nil, nil )

    --equipper:Kill()
end

function GivePlayerItem6(hPlayer, Weapon)
    --local equipper = Entities:CreateByClassname("game_player_equip")
    local equipper = SpawnEntityFromTableSynchronous("game_player_equip", {
        spawnflags = 5,
        weapon_awp = 0,
    })
    
    equipper:Attribute_SetIntValue( "spawnflags", 5) --// "Use Only" and "Only Strip Same Weapon Type"
    equipper:Attribute_SetIntValue("weapon_"..Weapon, 0)
    DoEntFireByInstanceHandle(equipper, "InitializeSpawnFromWorld", "", 0, nil, nil)
    
    equipper:ValidatePrivateScriptScope()
    
    DoEntFireByInstanceHandle( equipper, "Use", "", 0, hPlayer, nil ) --// each player "Use"s the equipper
    DoEntFireByInstanceHandle( equipper, "Kill", "", 0.1, nil, nil )
end

function GivePlayerItem7(hPlayer, Weapon)
    --local equipper = Entities:CreateByClassname("game_player_equip")
    local equipper = SpawnEntityFromTableSynchronous("weapon_deagle", {
    })
    
    --equipper:Attribute_SetIntValue( "spawnflags", 5) --// "Use Only" and "Only Strip Same Weapon Type"
    --equipper:Attribute_SetIntValue("weapon_"..Weapon, 0)
    equipper:ValidatePrivateScriptScope()
    DoEntFireByInstanceHandle(equipper, "InitializeSpawnFromWorld", "", 0, nil, nil)
    
    --equipper:ValidatePrivateScriptScope()
    
    DoEntFireByInstanceHandle( equipper, "Use", "", 0, hPlayer, nil ) --// each player "Use"s the equipper
end

if tListenerIds then
    for k, v in ipairs(tListenerIds) do
        StopListeningToGameEvent(v)
    end
end

function DMOnPlayerSpawn(event)
    --__DumpScope(0, event)
    local hPlayer = EHandleToHScript(event.userid_pawn)
    --DoEntFireByInstanceHandle(hPlayer, "runscriptcode", "GiveWeapons(thisEntity)", 0.01, nil, nil)

    local usertableid = table.dmGetValue(DMconnectedPlayers, event.userid)
    if usertableid ~= nil then
        table.dmRemoveValue(DMconnectedPlayers, usertableid)
        local playerData = {
            name = usertableid.name,
            userid = event.userid,
            networkid = usertableid.networkid,
            address = usertableid.address,
            team = usertableid.team,
            pawn = event.userid_pawn
        }
        table.insert(DMconnectedPlayers, playerData)
        --print("re spawned con pawn "..event.userid_pawn)
    end

    --RemoveWeaponsSpawn(hPlayer)
    DoEntFireByInstanceHandle(hPlayer, "runscriptcode", "CheckWeapons(thisEntity)", 0.2, nil, nil)
    --DoEntFireByInstanceHandle(hPlayer, "runscriptcode", "GiveWeapons(thisEntity)", 0.01, nil, nil)
    --GiveWeapons(hPlayer)
end

function GiveWeapons2(hPlayer)
    local tInventory = hPlayer:GetEquippedWeapons()

    local haveweapons = false
    for key, value in ipairs(tInventory) do
        if value:GetClassname() ~= "weapon_knife" then
            haveweapons = true
        end
    end

    if haveweapons == false then
        GiveWeapons(hPlayer)
    end
end

function AdminOnPlayerConnect(event)
	local playerData = {
		name = event.name,
		userid = event.userid,
		networkid = event.networkid,
		address = event.address,
        --pawn = EHandleToHScript(event.userid_pawn)
	}
    table.insert(DMconnectedPlayers, playerData)
    --print("conectado")
	--connectedPlayers[event.userid] = playerData
end

function DMOnPlayerDisconnect(event)
    local usertableid = table.GetValue(DMconnectedPlayers, event.userid)
    if usertableid ~= nil then
        table.dmRemoveValue(DMconnectedPlayers, usertableid)
    end
    --print("desconectado")
	--connectedPlayers[event.userid] = nil
end

function DMOnTeam(event)
    local usertableid = table.dmGetValue(DMconnectedPlayers, event.userid)
    if usertableid ~= nil then
        table.dmRemoveValue(DMconnectedPlayers, usertableid)
        local playerData = {
            name = usertableid.name,
            userid = event.userid,
            networkid = usertableid.networkid,
            address = usertableid.address,
            pawn = event.userid_pawn,
            team = event.team,
        }
        table.insert(DMconnectedPlayers, playerData)
        --print("re spawned con pawn "..event.userid_pawn)
    end
	--connectedPlayers[event.userid] = nil
end

function DMOnPlayerConnect(event)
	local playerData = {
		name = event.name,
		userid = event.userid,
		networkid = event.networkid,
		address = event.address,
        team = 0,
        --pawn = EHandleToHScript(event.userid_pawn)
	}
    table.insert(DMconnectedPlayers, playerData)
    --print("conectado")
	--connectedPlayers[event.userid] = playerData
end

function DMOnPlayerDisconnect(event)
    local usertableid = table.dmGetValue(DMconnectedPlayers, event.userid)
    if usertableid ~= nil then
        table.dmRemoveValue(DMconnectedPlayers, usertableid)
    end
    --print("desconectado")
	--connectedPlayers[event.userid] = nil
end

tListenerIds = {
    ListenToGameEvent("round_start", DMOnRoundStart, nil),
    ListenToGameEvent("player_spawn", DMOnPlayerSpawn, nil),
    ListenToGameEvent("player_connect", DMOnPlayerConnect, nil),
    ListenToGameEvent("player_disconnect", DMOnPlayerDisconnect, nil),
    ListenToGameEvent("player_team", DMOnTeam, nil)
}