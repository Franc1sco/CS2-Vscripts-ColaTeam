--print("Starting Franug test!")
require("advertlist")
require("colorslist")

function PrintChatAll(text)		
	ScriptPrintMessageChatAll(" " .. ReplaceColorCodes(text))
end


function OnRoundFreezeEnd(event)
    for _, v in pairs(AdvertList) do
        PrintChatAll(v)
    end
end

tListenerIds = {
    ListenToGameEvent("round_freeze_end", OnRoundFreezeEnd, nil)
}