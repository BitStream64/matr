stock bool:Greenhouse_IsValid(const this[GREENHOUSE]) {
	if (this[GREENHOUSE_PLAYER_ID] == INVALID_PLAYER_ID) {
		return false;
	}

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
	//dbg("Greenhouse_Update");
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
	//dbg("Greenhouse_Process");
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
	}

	if (this[GREENHOUSE_SEEDS] == 0) {
		Player_Info(playerid, "В одной из ваших теплиц закончились семена");
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

	dbg("Greenhouse_OnLoad");

	new rows = cache_num_rows();

	if (!rows) {
		dbg("Greenhouse_OnLoad | no rows");
		return;
	}
	
	for (new row_id = 0; row_id < rows; row_id++) { // читаем все строки, лимит установлен в запросе
		cache_get_value_name_int(row_id, "id", g_Greenhouse[playerid][row_id][GREENHOUSE_MYSQL_ID]);
		cache_get_value_name_int(row_id, "product", GREENHOUSE_PRODUCT_TYPE:g_Greenhouse[playerid][row_id][GREENHOUSE_PRODUCT]);
		cache_get_value_name_int(row_id, "seeds", g_Greenhouse[playerid][row_id][GREENHOUSE_SEEDS]);
		cache_get_value_name_int(row_id, "harvest", g_Greenhouse[playerid][row_id][GREENHOUSE_HARVEST]);
		
		new positionString[sizeof(String64)];
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
	this[GREENHOUSE_PRODUCT] 	= GREENHOUSE_PRODUCT_TYPE_NONE;
	return;
}

stock Greenhouse_GetPositionString(const vector[Vector3D], out[sizeof(String64)]) {
	for (new Vector3D:vec; vec < Vector3D; vec++) {
		format(out, sizeof(out), "%s%s%.2f", out, vec ? "," : "", vector[vec]);
	}

	return;
}

stock Greenhouse_Save(this[GREENHOUSE]) {

	if (this[GREENHOUSE_MYSQL_ID] != INVALID_MYSQL_ID) {
		new
			positionString[sizeof(String64)],
			position[Vector3D];
		memcpy(position, this[GREENHOUSE_POSITION], 0, sizeof(this[GREENHOUSE_POSITION]) * cellbytes);
		Greenhouse_GetPositionString(position, positionString);

		format(
			String4096,
			sizeof(String4096),
			"\
				UPDATE `%s` \
				SET\
					`product` = '%i', \
					`seeds` = '%i', \
					`harvest` = '%i', \
					`position` = '%s' \
				\
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

	dbg("Greenhouse unloaded with %i harvest", this[GREENHOUSE_HARVEST]);
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

public Greenhouse_OnCreated(playerid, key, slot) {
	dbg("Greenhouse_OnCreated");
	if (!Player_IsValid(playerid, key)) {
		return;
	}

	new id = cache_insert_id();

	if (!id) {
		dbg("Greenhouse_OnCreated | insert id is not valid");
		return;
	}

	g_Greenhouse[playerid][slot][GREENHOUSE_MYSQL_ID] = id;
	Greenhouse_Init(g_Greenhouse[playerid][slot], playerid, slot);
	Iter_Add(g_iGreenhousePlayer, playerid); // id is unique key in y_iterate
	return;
}

stock Greenhouse_Create(playerid) {
	dbg("Greenhouse_Create");
	new slot = Greenhouse_GetAvailableSlot(playerid);

	if (slot == INVALID_GREENHOUSE_ID) {
		Player_Info(playerid, "Вы не можете создать больше теплиц");
		return;
	}

	new position[Vector3D];
	Math_GetPlayerPos(playerid, position);

	new positionString[sizeof(String64)];
	Greenhouse_GetPositionString(position, positionString);

	format(
		String4096,
		sizeof(String4096),
		"\
			INSERT INTO `%s` \
				(`id`, `account_id`, `position`)\
			VALUES \
				(DEFAULT, %i, '%s')\
		",
		GREENHOUSE_TABLE_NAME,
		g_Player[playerid][PLAYER_ACCOUNT_ID],
		positionString
	);
	dbg("Greenhouse_Create | String4096 = %s", String4096);
	mysql_tquery(Database_Get(), String4096, __nameof(Greenhouse_OnCreated), "iii", playerid, Player_GetKey(playerid), slot);
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

stock Greenhouse_CreateTable() {
	dbg("Greenhouse_CreateTable");
	
	format(
		String4096,
		sizeof(String4096),
		"\
			CREATE TABLE IF NOT EXISTS `%s` (\
				`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,\
				`account_id` INT UNSIGNED NOT NULL,\
				`product` INT NOT NULL DEFAULT -1,\
				`seeds` INT UNSIGNED NOT NULL DEFAULT 0,\
				`harvest` INT UNSIGNED NOT NULL DEFAULT 0,\
				`position` VARCHAR(64) NOT NULL,\
				PRIMARY KEY (`id`)\
			) \
			ENGINE=InnoDB \
			DEFAULT CHARSET=utf8mb4 \
			COLLATE=utf8mb4_unicode_ci;\
		",
		GREENHOUSE_TABLE_NAME
	);
	mysql_query(Database_Get(), String4096);
	return;
}
