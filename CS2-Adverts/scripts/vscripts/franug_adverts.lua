--print("Starting Franug test!")
require("advertlist")
require("colorslist")
require("convars")
require("util.timers")

roundCounter = 0
advertTimer = Convars:GetInt("show_advert_timer_delay")
advertIndex = 1

Timers:CreateTimer("ADVERTISEMENT_TIMER", {
    callback = function()
        if Convars:GetInt("adverts_mode") == 1 then
            advertTimer = 0
            return 1
        end
        if advertTimer >= Convars:GetInt("show_advert_timer_delay") then
            advertTimer = 0
            PrintChatAll(AdvertList[advertIndex])
            advertIndex = advertIndex + 1
        end
        if advertIndex >= #AdvertList then
            advertIndex = 1
        end
        advertTimer = advertTimer + 1
        return 1
    end
})

function PrintChatAll(text)		
	ScriptPrintMessageChatAll(" " .. ReplaceColorCodes(text))
end


function OnRoundFreezeEnd(event)
    if Convars:GetInt("adverts_mode") == 0 then
        roundCounter = 0
        return
    end
    if roundCounter == 0 then
		PrintChatAll(AdvertList[advertIndex])
        advertIndex = advertIndex + 1
	end
    if advertIndex >= #AdvertList then
        advertIndex = 1
    end
    roundCounter = roundCounter + 1
    if roundCounter >= Convars:GetInt("show_advert_round_delay") then
        roundCounter = 0
    end
end

function OnMatchBegin(event)
	roundCounter = 0
    advertTimer = Convars:GetInt("show_advert_timer_delay")
    advertIndex = 1
end

tListenerIds = {
    ListenToGameEvent("round_freeze_end", OnRoundFreezeEnd, nil),
    ListenToGameEvent("begin_new_match", OnMatchBegin, nil)
}