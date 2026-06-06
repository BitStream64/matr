#if defined LINUX_BUILD
	#pragma compat 1
#endif
#include <YSI_Coding\y_hooks>
#if defined LINUX_BUILD
	#pragma compat 0
#endif

hook OnPlayerConnect(playerid) {
	Player_BuildUniqueID(playerid);
	Player_Auth(playerid);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDisconnect(playerid) {
	Iter_Remove(g_iPlayer, playerid);
	g_Player[playerid] = PLAYER_EOS;
	return Y_HOOKS_CONTINUE_RETURN_1;
}