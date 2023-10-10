# franug-cs2-admin

### Installation

* Download first vscript patch for linux ( https://mega.nz/file/WZNFTRZZ#cOMajt4J25z0zlGlOKfZExPkc1DRdTXTYF65_gg02pQ ) or windows ( https://mega.nz/file/aUtTXJjA#8dooPA-U7d6a8tHEPZCQqplvhZMzZ9F37kzyIuTbkuc )
* Put into your /game/bin/win64 or /game/bin/linuxsteamrt64 directory
* Put the .lua file into /game/csgo/scripts/vscripts
* Add **sv_cheats 1; script_reload_code franug_admin; sv_cheats 0** to the bottom of your server.cfg
* Restart your server

### Configuration

* Set your admin password into the .lua file on the first line "yourpassword"
* Join to your server and put in your console: adminlogin "yourpassword"
* Now you have access to the admin commands
* Also you can add admins by steamid into the adminlist.lua file, so you will dont need a password.

### Admin commands

* sm_kick "userid or partial name to kick"
* sm_rcon "rcon command"
* sm_say "what you say as admin"
* sm_map "map name to change"
* sm_slay "userid or partial name to slay"
* sm_hp "userid or partial name" "hp amount to set"
* sm_fakesay "userid or partial name" "text to fake say as this player"
* sm_team "userid or partial name" "team number to set" (1 = spect, 2 = tt, 3 = ct)
* sm_rr (restart the game)
  
