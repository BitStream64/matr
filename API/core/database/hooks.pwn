#if defined LINUX_BUILD
	#pragma compat 1
#endif
#include <YSI_Coding\y_hooks>
#if defined LINUX_BUILD
	#pragma compat 0
#endif

hook OnGameModeExit() {
	Database_Disconnect();
	return Y_HOOKS_CONTINUE_RETURN_1;
}