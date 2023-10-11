--print("Starting Franug test!")
require("advertlist")
require("colorslist")

-- Necesario para poder editar la cvar por la consola.
FCVAR_RELEASE = bit.lshift(1, 19)
Convars:RegisterConvar("show_advert_round_delay", "0", "How many rounds will pass before broadasting the adverts again. (Default is 0)", FCVAR_RELEASE)

roundCounter = 0

function PrintChatAll(text)		
	ScriptPrintMessageChatAll(" " .. ReplaceColorCodes(text))
end


function OnRoundFreezeEnd(event)
    print(Convars:GetInt("show_advert_round_delay") .. " SHOW ADVERT CVAR")
    if roundCounter == 0 then
		for _, v in pairs(AdvertList) do
			PrintChatAll(v)
		end
	end
    roundCounter = roundCounter + 1
    if roundCounter >= Convars:GetInt("show_advert_round_delay") then
        roundCounter = 0
    end
end

function OnMatchBegin(event)
	roundCounter = 0
end

tListenerIds = {
    ListenToGameEvent("round_freeze_end", OnRoundFreezeEnd, nil),
    ListenToGameEvent("begin_new_match", OnMatchBegin, nil)
}