#if defined LINUX_BUILD
	#pragma compat 1
#endif
#include <YSI_Coding\y_hooks>
#if defined LINUX_BUILD
	#pragma compat 0
#endif

hook stock Main() {
	new playerid = random(MAX_PLAYERS);

	//GreenhouseTest_CreatePlayer(playerid, "Matr_Dev", "987654321"); // -- INSERT PLAYER IN DB
	GreenhouseTest_LoginPlayer(playerid, "Matr_Dev", "987654321"); // -- LOG IN AS PLAYER
	return continue();
}

hook stock Player_OnLogged(playerid) {
	// Greenhouse_Load(playerid); // -- LOAD EXISTED GREENHOUSES

	//new gid_max = random(MAX_PLAYER_GREENHOUSE);
	//gid_max = gid_max ? gid_max : ++gid_max;
	new gid_max = 1;

	for (new gid = 0; gid < gid_max; gid++) {
		Greenhouse_Create(playerid); // -- CREATE GREENHOUSE
	}

	SetTimer(__nameof(GreenhouseTest_Process), 1000, true);
	SetTimerEx(__nameof(OnPlayerDisconnect), GREENHOUSE_HARVEST_INTERVAL * 1000, false, "i", playerid);

	return continue(playerid);
}