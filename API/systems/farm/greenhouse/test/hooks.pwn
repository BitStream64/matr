#if defined LINUX_BUILD
	#pragma compat 1
#endif
#include <YSI_Coding\y_hooks>
#if defined LINUX_BUILD
	#pragma compat 0
#endif

hook stock Main() {
	new playerid = random(MAX_PLAYERS);

	if (g_Greenhouse_Test[GREENHOUSE_TEST_REGISTERED]) {
		GreenhouseTest_LoginPlayer(playerid, "Matr_Dev", "987654321"); // -- LOG IN AS PLAYER
	} else {
		GreenhouseTest_CreatePlayer(playerid, "Matr_Dev", "987654321"); // -- INSERT PLAYER IN DB
	}
	
	return continue();
}

hook stock Player_OnLogged(playerid) {
	// Greenhouse_Load(playerid); // -- LOAD EXISTED GREENHOUSES

	new gid_max = random(MAX_PLAYER_GREENHOUSE);
	gid_max = gid_max ? gid_max : ++gid_max;

	for (new gid = 0; gid < gid_max; gid++) {
		Greenhouse_Create(playerid); // -- CREATE GREENHOUSE
	}

	SetTimer(__nameof(GreenhouseTest_Process), g_Greenhouse_Test[GREENHOUSE_TEST_PROC_INTERVAL], true);
	SetTimerEx(__nameof(OnPlayerDisconnect), g_Greenhouse_Test[GREENHOUSE_TEST_DISC_INTERVAL], false, "i", playerid);

	return continue(playerid);
}