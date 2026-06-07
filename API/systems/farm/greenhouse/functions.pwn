stock bool:Greenhouse_IsValid(const this[GREENHOUSE]) {
	if (this[GREENHOUSE_ID] == INVALID_GREENHOUSE_ID) {
		return false;
	}

	if (this[GREENHOUSE_PRODUCT] == GREENHOUSE_PRODUCT_TYPE_NONE) {
		return false; // Не выбран продукт
	}

	if (this[GREENHOUSE_SEEDS] == 0) {
		return false; // Нечему расти
	}

	return true;
}

stock Greenhouse_Update(this[GREENHOUSE]) {
	if (!Greenhouse_IsValid(this)) {
		return;
	}

	//new 
		//slot = random(MAX_GREENHOUSE_PLANTS)

	// Гарантируем, что все доступные растения вырастут за GREENHOUSE_HARVEST_INTERVAL секунд
	new	slot = GreenhousePlant_GetLessGrowed(this);

	if (slot == INVALID_GREENHOUSE_PLANT_ID) {
		return;
	}
	
	new
		playerid = this[GREENHOUSE_PLAYER_ID],
		gid = this[GREENHOUSE_ID];

	GreenhousePlant_Update(g_Greenhouse_Plant[playerid][gid][slot], this);
	return;
}

public Greenhouse_Process() {
	foreach (new playerid : g_iGreenhousePlayer) {
		for (new gid = 0; gid < MAX_PLAYER_GREENHOUSE; gid++) {
			Greenhouse_Update(g_Greenhouse[playerid][gid]);
		}
	}

	return;
}

stock Greenhouse_Init(this[GREENHOUSE], playerid, gid) {
	if (this[GREENHOUSE_PRODUCT] == GREENHOUSE_PRODUCT_TYPE_NONE) {
		Player_Info(playerid, "В одной из ваших теплиц не выбран тип продукта для выращивания");
		return;
	}

	if (this[GREENHOUSE_SEEDS] == 0) {
		Player_Info(playerid, "В одной из ваших теплиц закончились семена");
		return;
	}

	this[GREENHOUSE_ID] = gid;
	this[GREENHOUSE_PLAYER_ID] = playerid;

	for (new plantid = 0; plantid < MAX_GREENHOUSE_PLANTS; plantid++) {
		GreenhousePlant_Init(g_Greenhouse_Plant[playerid][gid][plantid], this, plantid);
	}

	return;
}

public Greenhouse_OnLoad(playerid, key) {
	if (!Player_IsValid(playerid, key)) {
		return;
	}

	new rows = cache_num_rows();

	if (!rows) {
		return;
	}
	
	for (new row_id = 0; row_id < rows; row_id++) { // читаем все строки, лимит установлен в запросе
		cache_get_value_name_int(row_id, "id", g_Greenhouse[playerid][row_id][GREENHOUSE_MYSQL_ID]);
		cache_get_value_name_int(row_id, "product", GREENHOUSE_PRODUCT_TYPE:g_Greenhouse[playerid][row_id][GREENHOUSE_PRODUCT]);
		cache_get_value_name_int(row_id, "seeds", g_Greenhouse[playerid][row_id][GREENHOUSE_SEEDS]);
		cache_get_value_name_int(row_id, "harvest", g_Greenhouse[playerid][row_id][GREENHOUSE_HARVEST]);
		
		new positionString[64];
		cache_get_value_name(row_id, "position", positionString, sizeof(positionString));
		sscanf(positionString, "p<,>a<f>[*]", _:Vector3D, g_Greenhouse[playerid][row_id][GREENHOUSE_POSITION]);

		Greenhouse_Init(g_Greenhouse[playerid][row_id], playerid, row_id);
	}

	Iter_Add(g_iGreenhousePlayer, playerid);
	return;
}

stock Greenhouse_Load(playerid) {
	// можем юзать обычный format, так как нет input'a извне
	format(
		String4096,
		sizeof(String4096),
		"\
			SELECT * FROM `%s` WHERE `account_id` = %i LIMIT %i\
		",
		GREENHOUSE_TABLE_NAME,
		g_Player[playerid][PLAYER_ACCOUNT_ID],
		MAX_PLAYER_GREENHOUSE
	);
	mysql_tquery(Database_Get(), String4096, __nameof(Greenhouse_OnLoad), "ii", playerid, Player_GetKey(playerid));

	return;
}

stock Greenhouse_Clear(this[GREENHOUSE]) {
	new 
		playerid = this[GREENHOUSE_PLAYER_ID],
		gid = this[GREENHOUSE_ID];

	for (new plantid = 0; plantid < MAX_GREENHOUSE_PLANTS; plantid++) {
		GreenhousePlant_Clear(g_Greenhouse_Plant[playerid][gid][plantid]);
	}

	this[GREENHOUSE_ID] 		= INVALID_GREENHOUSE_ID;
	this[GREENHOUSE_PLAYER_ID] 	= INVALID_PLAYER_ID;
	this[GREENHOUSE_MYSQL_ID]	= INVALID_MYSQL_ID;
	return;
}

stock Greenhouse_Save(this[GREENHOUSE]) {

	if (this[GREENHOUSE_MYSQL_ID] != INVALID_MYSQL_ID) {
		new positionString[64] = EOS;
		for (new Vector3D:v; v < Vector3D; v++) {
			format(
				positionString,
				sizeof(positionString),
				"%s%s%.2f",
				positionString,
				v ? "," : "",
				this[GREENHOUSE_POSITION][v]
			);
		}

		format(
			String4096,
			sizeof(String4096),
			"\
				UPDATE `%s` \
				SET (\
				`product` = '%i', \
				`seeds` = '%i', \
				`harvest` = '%i', \
				`position` = '%s' \
				) \
				WHERE `id` = '%i'\
			",
			GREENHOUSE_TABLE_NAME,
			_:this[GREENHOUSE_PRODUCT],
			this[GREENHOUSE_SEEDS],
			this[GREENHOUSE_HARVEST],
			positionString,
			// WHERE
			this[GREENHOUSE_MYSQL_ID]
		);

		mysql_tquery(Database_Get(), String4096);
	}

	Greenhouse_Clear(this);
	return;
}

stock Greenhouse_Unload(playerid) {
	for (new gid = 0; gid < MAX_PLAYER_GREENHOUSE; gid++) {
		Greenhouse_Save(g_Greenhouse[playerid][gid]);
	}

	Iter_Remove(g_iGreenhousePlayer, playerid);
	return;
}

stock Greenhouse_GetAvailableSlot(playerid) {
	for (new gid = 0; gid < MAX_PLAYER_GREENHOUSE; gid++) {
		if (g_Greenhouse[playerid][gid][GREENHOUSE_PLAYER_ID] != INVALID_PLAYER_ID) {
			continue;
		}

		return gid;
	}

	return INVALID_GREENHOUSE_ID;
}

stock Greenhouse_Create(playerid) {
	new slot = Greenhouse_GetAvailableSlot(playerid);

	if (slot == INVALID_GREENHOUSE_ID) {
		Player_Info(playerid, "Вы не можете создать больше теплиц");
		return;
	}

	Greenhouse_Init(g_Greenhouse[playerid][slot]);
	return;
}

stock Greenhouse_GetNear(playerid) {
	new bool:isOwner = false;

	for (new gid = 0; gid < MAX_PLAYER_GREENHOUSE; gid++) {
		if (g_Greenhouse[playerid][gid][GREENHOUSE_PLAYER_ID] == INVALID_PLAYER_ID) {
			continue;
		}

		isOwner = true;

		if (!Math_IsPlayerInRangeOfVector3D(
			playerid,
			g_Greenhouse[playerid][gid][GREENHOUSE_POSITION],
			GREENHOUSE_ZONE_DISTANCE
		)) {
			continue;
		}

		return gid;
	}

	return isOwner ? INVALID_GREENHOUSE_ID : INVALID_GREENHOUSE_OWNER;
}

