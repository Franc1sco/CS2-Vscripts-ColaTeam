-- Necesario para poder editar la cvar por la consola.
FCVAR_RELEASE = bit.lshift(1, 19)

-- CVARS
Convars:RegisterConvar("adverts_mode", "0", "Define when should the adverts be displayd (0 = timer based, 1 = rounds based)", FCVAR_RELEASE)
Convars:RegisterConvar("show_advert_timer_delay", "60", "How many seconds will pass before broadasting the adverts again. (Default is 60)", FCVAR_RELEASE)
Convars:RegisterConvar("show_advert_round_delay", "0", "How many rounds will pass before broadasting the adverts again. (Default is 0)", FCVAR_RELEASE)