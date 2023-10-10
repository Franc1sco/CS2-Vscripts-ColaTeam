-- Change the time in seconds on the next line
AFK_Seconds = 40



require("util.timers")

afkPos = {}

function OnRoundStartAFK(event)

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
    ListenToGameEvent("round_start", OnRoundStartAFK, nil),
}