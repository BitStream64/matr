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

stock Player_LogIn(playerid, Cache:cache) {
	// TODO: insert, compare password

	cache_set_active(cache);

	// if password does not compare Kick(playerid)
	
	// name = unique key, а значит запрос на поиск аккаунта всегда вернёт 0 или 1 строк
	cache_get_value_name_int(0, "id", g_Player[playerid][PLAYER_ACCOUNT_ID]);

	Player_OnLogged(playerid);
	return;
}

stock Player_SignIn(playerid) {
	Kick(playerid); // Регистрация не написана :)
	return;
}

public Player_OnAuth(playerid, key) {
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
	new name[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, name, sizeof(name));

	mysql_format(
		Database_Get(),
		String4096,
		sizeof(String4096),
		"\
			SELECT * FROM `%e` WHERE `name` = 'e'\
		",
		PLAYER_TABLE_NAME,
		name
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
	printf("[dbg] player %i successfully logged to server", playerid);
	return;
}