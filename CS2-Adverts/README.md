# Franug-CS2-Adverts

### Installation

* Download first vscript patch for linux ( https://mega.nz/file/WZNFTRZZ#cOMajt4J25z0zlGlOKfZExPkc1DRdTXTYF65_gg02pQ ) or windows ( https://mega.nz/file/aUtTXJjA#8dooPA-U7d6a8tHEPZCQqplvhZMzZ9F37kzyIuTbkuc )
* Put into your /game/bin/win64 or /game/bin/linuxsteamrt64 directory
* Put the .lua files into /game/csgo/scripts/vscripts
* Add **sv_cheats 1; script_reload_code franug_adverts; sv_cheats 0** to the bottom of your server.cfg
* Configure the way your adverts will be displayed with **adverts_mode 0/1** 0 = timer, 1 = rounds
* Configure the amount of rounds you want to wait before displaying the messages again, add this below the previous step: **show_advert_round_delay 5**.
* Configure the amount of time you want to wait before displaying the messages again, add this below the previous step: **show_advert_timer_delay 5**.
* Restart your server

### Configuration

* Add your messages into advertlist.lua
* You have available the colors listed on the colorslist.lua
