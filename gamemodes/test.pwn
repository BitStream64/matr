#define _console_included

#include <a_samp>
#include <a_mysql>
#include <json>
#include <sscanf2>
#include <streamer>

#if defined LINUX_BUILD
	#pragma compat 1
#endif
#include <YSI_Data\y_foreach>
#include <YSI_Coding\y_va>
#if defined LINUX_BUILD
	#pragma compat 0
#endif

#if defined MAX_PLAYERS
	#undef MAX_PLAYERS
#endif

#define MAX_PLAYERS 10
#define COLOR_INFO 0xFFCC00FF

const DEFAULT_INTERIOR_ID = 0;
const DEFAULT_WORLD_ID = 0;
const INVALID_MYSQL_ID = -1;

forward Main();
forward Second();
forward dbg(const message[], va_args<>);

new
	String64[64] 		= EOS,
	String256[256]		= EOS,
	String4096[4096] 	= EOS,
	unix;

#include "API/main.pwn"

public OnGameModeInit() {
	if (!Config_Load()) {
		dbg("Failed to load configuration [scriptfiles/config/server.json]");
		return 0;
	}

	if (!Database_Connect()) {
		dbg("Failed to connect to the database");
		return 0;
	}

	CreateAccountTable();

	Main(); // Гарантировано сервер готов к работе
	return 1;
}

public Second() {
	unix++;
	return;
}

stock Main() {
	dbg("Server %s completed initialization", g_Config[CONFIG_NAME]);

	unix = gettime(_, _, _);
	SetTimer(__nameof(Second), 1000, true);
	return 0;
}

stock dbg(const message[], va_args<>) {
	#if defined TEST_BUILD
		format(String256, sizeof(String256), message, va_start<1>);
        format(String256, sizeof(String256), "[%02i:%02i:%02i] %s", (unix / 3600) % 24, (unix / 60) % 60, unix % 60, String256);
		print(String256);
	#endif

	return;
}

main() {
	return 1;
}