print("Starting Franug test!")
require("util.timers")

local stageId = 0

--local first_stage = false

function OnRoundStart(event)
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
    Convars:SetInt("cash_player_respawn_amount", 16000)
    --Convars:SetInt("mp_give_player_c4", 0)
    --Convars:SetInt("mp_friendlyfire", 0)
    Convars:SetInt("mp_respawn_on_death_t", 1)
    Convars:SetInt("mp_respawn_on_death_ct", 1)
    Convars:SetInt("mp_roundtime", 40)
    
    Convars:SetInt("mp_buy_anywhere", 1)
    Convars:SetInt("mp_buytime", 99999)
    Convars:SetInt("mp_maxmoney", 100000)
    Convars:SetInt("mp_startmoney ", 100000)
    Convars:SetInt("mp_afterroundmoney ", 100000)
    --Convars:SetInt('mp_ignore_round_win_conditions', 1)

    ScriptPrintMessageChatAll("The game is \x05DM MULTI-CFG\x01")

    Timers:RemoveTimer("DM_Timer")

    setupStage()
    DM_ChangeStage()
end



function DM_ChangeStage()
    local DM_Countdown = RandomInt(6, 30)
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
    if (stageId == 0) then
        Convars:SetInt("mp_weapons_allow_pistols", -1)
        Convars:SetInt("mp_weapons_allow_smgs", 0)
        Convars:SetInt("mp_weapons_allow_heavy", 0)
        Convars:SetInt("mp_weapons_allow_rifles", 0)
        Convars:SetStr("mp_ct_default_primary", "")
        Convars:SetStr("mp_t_default_primary", "")
    elseif (stageId == 1) then
        Convars:SetInt("mp_weapons_allow_pistols", 0)
        Convars:SetInt("mp_weapons_allow_smgs", -1)
        Convars:SetInt("mp_weapons_allow_heavy", 0)
        Convars:SetInt("mp_weapons_allow_rifles", 0)
        Convars:SetStr("mp_ct_default_primary", "weapon_p90")
        Convars:SetStr("mp_t_default_primary", "weapon_p90")
    elseif (stageId == 2) then
        Convars:SetInt("mp_weapons_allow_pistols", 0)
        Convars:SetInt("mp_weapons_allow_smgs", 0)
        Convars:SetInt("mp_weapons_allow_heavy", 0)
        Convars:SetInt("mp_weapons_allow_rifles", -1)
        Convars:SetStr("mp_t_default_primary", "weapon_ak47")
        Convars:SetStr("mp_ct_default_primary", "weapon_m4a1")
    elseif (stageId == 3) then
        Convars:SetInt("mp_weapons_allow_pistols", 0)
        Convars:SetInt("mp_weapons_allow_smgs", 0)
        Convars:SetInt("mp_weapons_allow_heavy", -1)
        Convars:SetInt("mp_weapons_allow_rifles", 0)
        Convars:SetStr("mp_t_default_primary", "weapon_nova")
        Convars:SetStr("mp_ct_default_primary", "weapon_nova")
    else
        stageId = 0
        Convars:SetInt("mp_weapons_allow_pistols", -1)
        Convars:SetInt("mp_weapons_allow_smgs", 0)
        Convars:SetInt("mp_weapons_allow_heavy", 0)
        Convars:SetInt("mp_weapons_allow_rifles", 0)
        Convars:SetStr("mp_ct_default_primary", "")
        Convars:SetStr("mp_t_default_primary", "")
    end

    for i = 1, 64 do
        local hController = EntIndexToHScript(i)

        if hController ~= nil and hController:GetPawn() ~= nil then
            --I have absolutely no idea why, but this has to be delayed now
            RemoveWeapons(hController:GetPawn())
            --GiveWeapons(hController:GetPawn())
            --local player = hController:GetPawn()
            --DoEntFireByInstanceHandle(player, "SetHealth", "0", 0.01, nil, nil)
        end
    end
end

function RemoveWeapons(hPlayer)
    local tInventory = hPlayer:GetEquippedWeapons()

    for key, value in ipairs(tInventory) do
        if value:GetClassname() ~= "weapon_knife" then
            value:Destroy()
            DoEntFireByInstanceHandle(clientcmd, "command", "lastinv", 0.1, hPlayer, hPlayer)
        end
    end
end

function GiveWeapons(hPlayer)
    --DoEntFireByInstanceHandle(hPlayer, "SetMoney", "15000", 0.01, nil, nil)
    if (stage == 0) then
        --DoEntFireByInstanceHandle(hPlayer, "weapon_p250", "", 0, nil, nil)
        GivePlayerItem(hPlayer, "p250")
    elseif (stage == 1) then
        --DoEntFireByInstanceHandle(hPlayer, "weapon_p90", "", 0, nil, nil)
        GivePlayerItem(hPlayer, "p90")
    elseif (stage == 2) then
        --DoEntFireByInstanceHandle(hPlayer, "weapon_awp", "", 0, nil, nil)
        GivePlayerItem(hPlayer, "awp")
    elseif (stage == 3) then
        --DoEntFireByInstanceHandle(hPlayer, "weapon_nova", "", 0, nil, nil)
        GivePlayerItem(hPlayer, "nova")
    else
        GivePlayerItem(hPlayer, "p250")
        --DoEntFireByInstanceHandle(hPlayer, "weapon_p250", "", 0, nil, nil)
    end
end

function GivePlayerItem(hPlayer, Weapon)
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

function GivePlayerItem2(hPlayer, Weapon)
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

function GivePlayerItem3(hPlayer, Weapon)
    local equipper = Entities:CreateByClassname("game_player_equip")
    -- set flags and keyvalues
    equipper:Attribute_SetIntValue( "spawnflags", 5) --// "Use Only" and "Only Strip Same Weapon Type"
    equipper:Attribute_SetIntValue("weapon_"..Weapon, 0)
    --equipper.__KeyValueFromInt( "weapon_knife", 0 )
    --equipper.__KeyValueFromInt( "item_kevlar", 0 )

    equipper:ValidatePrivateScriptScope()

    DoEntFireByInstanceHandle( equipper, "Use", "", 0, hPlayer, nil ) --// each player "Use"s the equipper
    DoEntFireByInstanceHandle( equipper, "Kill", "", 0.1, nil, nil )

    --equipper:Kill()
end

function GivePlayerItem5(hPlayer, Weapon)
        local equipper = Entities:CreateByClassname( "game_player_equip" )
    
        -- set flags and keyvalues
        equipper:__KeyValueFromInt( "spawnflags", 5 )
        equipper:__KeyValueFromInt( Weapon, 0 )
        equipper:__KeyValueFromInt( "weapon_knife", 0 )
        equipper:__KeyValueFromInt( "item_kevlar", 0 )
    
        equipper:ValidatePrivateScriptScope()
    
        EntFireByHandle( equipper, "Use", "", 0, hPlayer, nil )
        
        EntFireByHandle( equipper, "Kill", "", 0.1, hPlayer, nil )
end

if tListenerIds then
    for k, v in ipairs(tListenerIds) do
        StopListeningToGameEvent(v)
    end
end

tListenerIds = {
    ListenToGameEvent("round_start", OnRoundStart, nil)
}