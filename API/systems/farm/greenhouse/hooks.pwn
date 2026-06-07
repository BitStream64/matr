#if defined LINUX_BUILD
	#pragma compat 1
#endif
#include <YSI_Coding\y_hooks>
#if defined LINUX_BUILD
	#pragma compat 0
#endif

hook stock Player_OnLogged(playerid) {
	/* 	
		Загружаем сразу при заходе, а не при взаимодействии, 
		так как важен независимый рост от местоположения игрока
	*/
	Greenhouse_Load(playerid);
	return continue(playerid);
}

hook OnPlayerDisconnect(playerid) {
	Greenhouse_Unload(playerid);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook stock Main() {
	for (new playerid = 0; playerid < MAX_PLAYERS; playerid++) {
		for (new gid = 0; gid < MAX_PLAYER_GREENHOUSE; gid++) {
			g_Greenhouse[playerid][gid][GREENHOUSE_PLAYER_ID] = playerid;
			g_Greenhouse[playerid][gid][GREENHOUSE_ID] = gid;
			Greenhouse_Clear(g_Greenhouse[playerid][gid]);
		}
	}

	Greenhouse_CreateTable();

	new interval = floatround(GREENHOUSE_HARVEST_INTERVAL / MAX_GREENHOUSE_PLANTS / _:GREENHOUSE_OBJECT_STATUS);
	SetTimer(__nameof(Greenhouse_ProcessAll), interval * 1000, true);
	dbg("Greenhouse_ProcessAll has been created");
	return continue();
}