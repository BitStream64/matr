forward Player_OnAuth(playerid, key);

stock Player_GetKey(playerid) {
	return g_Player[playerid][PLAYER_UNIQUE_ID];
}

stock bool:Player_IsValid(playerid, key) {
	new unique_id = Player_GetKey(playerid);

	if (unique_id == INVALID_PLAYER_UNIQUE_ID) {
		return false;
	}

	if (unique_id != key) {
		return false;
	}

	return true;
}

stock CreateAccountTable() {
	dbg("CreateAccountTable");

	format(
		String4096,
		sizeof(String4096),
		"\
			CREATE TABLE IF NOT EXISTS `%s` (\
				`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,\
				`nickname` VARCHAR(24) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,\
				`password` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,\
				`level` INT UNSIGNED NOT NULL DEFAULT 1,\
				`exp` INT UNSIGNED NOT NULL DEFAULT 0,\
				PRIMARY KEY (`id`),\
				UNIQUE KEY uk_name (`nickname`)\
			) \
			ENGINE=InnoDB DEFAULT \
			CHARSET=utf8mb4 \
			COLLATE=utf8mb4_unicode_ci;\
		",
		PLAYER_TABLE_NAME
	);
	mysql_query(Database_Get(), String4096);

	return;
}

stock Player_Info(playerid, const message[], va_args<>) {
	static str[sizeof(String256)];
	format(str, sizeof(str), "[Информация] %s", message, va_start<2>);
	SendClientMessage(playerid, COLOR_INFO, str);
	return;
}

stock Player_LogIn(playerid, Cache:cache) {
	dbg("Player_LogIn");
	cache_set_active(cache);

	new password[sizeof(String64)];
	
	// name = unique key, а значит запрос на поиск аккаунта всегда вернёт 0 или 1 строк
	cache_get_value_name(0, "password", password);

	if (strcmp(g_Player[playerid][PLAYER_TEMP_PASSWORD], password) != 0) {
		dbg("Player_LogIn | invalid password for player %s", g_Player[playerid][PLAYER_NAME]);
		Kick(playerid);
		return;
	}
	
	cache_get_value_name_int(0, "id", g_Player[playerid][PLAYER_ACCOUNT_ID]);
	cache_get_value_name_int(0, "level", g_Player[playerid][PLAYER_LEVEL]);
	cache_get_value_name_int(0, "exp", g_Player[playerid][PLAYER_EXP]);

	Player_OnLogged(playerid);
	return;
}

stock Player_SignIn(playerid) {
	Kick(playerid); // Регистрация не написана :)
	return;
}

public Player_OnAuth(playerid, key) {
	dbg("Player_OnAuth");
	if (!Player_IsValid(playerid, key)) {
		Kick(playerid);
		return;
	}

	new rows = cache_num_rows();

	if (rows) {
		Player_LogIn(playerid, cache_save());
	} else {
		Player_SignIn(playerid);
	}

	return;
}

stock Player_Auth(playerid) {
	if (g_Player[playerid][PLAYER_NAME] == EOS) {
		GetPlayerName(playerid, g_Player[playerid][PLAYER_NAME], MAX_PLAYER_NAME);
	}
	dbg("Player_Auth name = %s", g_Player[playerid][PLAYER_NAME]);

	mysql_format(
		Database_Get(),
		String4096,
		sizeof(String4096),
		"\
			SELECT * FROM `%e` WHERE `nickname` = '%e'\
		",
		PLAYER_TABLE_NAME,
		g_Player[playerid][PLAYER_NAME]
	);

	mysql_tquery(
		Database_Get(),
		String4096,
		__nameof(Player_OnAuth),
		"ii",
		playerid,
		Player_GetKey(playerid)
	);
	return;
}

stock Player_BuildUniqueID(playerid) {
	// Не гарантирует 100% уникальности, но лучше, чем ничего :)
	g_Player[playerid][PLAYER_UNIQUE_ID] = random(999_999_999);
	return;
}

stock Player_OnLogged(playerid) {
	Iter_Add(g_iPlayer, playerid);
	dbg("Player_OnLogged | player %s[%i] successfully logged to server", g_Player[playerid][PLAYER_NAME], playerid);
	return 1;
}