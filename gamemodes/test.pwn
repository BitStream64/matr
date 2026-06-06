#define _console_included

#include <a_samp>
#include <a_mysql>
#include <json>

#if defined LINUX_BUILD
	#pragma compat 1
#endif
#include <YSI_Data\y_foreach>
#if defined LINUX_BUILD
	#pragma compat 0
#endif

#if defined MAX_PLAYERS
	#undef MAX_PLAYERS
#endif

#define MAX_PLAYERS 10

forward Main();
new String4096[4096] = EOS;

#include "API/main.pwn"

public OnGameModeInit() {
	if (!Config_Load()) {
		printf("Failed to load configuration [scriptfiles/config/server.json]");
		return 0;
	}

	if (!Database_Connect()) {
		printf("Failed to connect to the database");
		return 0;
	}

	Main(); // Гарантировано сервер готов к работе
	return 1;
}

stock Main() {
	printf("Server %s completed initialization", g_Config[CONFIG_NAME]);
	return 0;
}

main() {
	return 1;
}