stock bool:GreenhousePlant_IsValid(const this[GREENHOUSE_PLANT]) {
	if (this[GREENHOUSE_PLANT_OBJECT_STATUS] == GREENHOUSE_OBJECT_STATUS_NONE) {
		return false;
	}

	return true;
}

stock GreenhousePlant_UpdateRender(this[GREENHOUSE_PLANT]) {
	dbg("GreenhousePlant_UpdateRender");
	new objectid = this[GREENHOUSE_PLANT_OBJECT_ID];
	if (objectid != INVALID_STREAMER_ID) {
		DestroyDynamicObject(objectid);
	}
	
	if (!GreenhousePlant_IsValid(this)) {
		return;
	}

	new GREENHOUSE_OBJECT_STATUS:status = this[GREENHOUSE_PLANT_OBJECT_STATUS];

	objectid = CreateDynamicObject(
		g_Greenhouse_ObjectConfig[status][GREENHOUSE_OBJECT_MODEL_ID],
		this[GREENHOUSE_PLANT_POSITION][x],
		this[GREENHOUSE_PLANT_POSITION][y],
		this[GREENHOUSE_PLANT_POSITION][z],
		g_Greenhouse_ObjectConfig[status][GREENHOUSE_OBJECT_ROTATION][x],
		g_Greenhouse_ObjectConfig[status][GREENHOUSE_OBJECT_ROTATION][y],
		g_Greenhouse_ObjectConfig[status][GREENHOUSE_OBJECT_ROTATION][z],
		DEFAULT_WORLD_ID,
		DEFAULT_INTERIOR_ID,
		.streamdistance = MAX_GREENHOUSE_PLANTS_STREAM,
		.drawdistance = MAX_GREENHOUSE_PLANTS_DRAW
	);

	if (objectid == INVALID_STREAMER_ID) {
		dbg("[WARNING] Greenhouse_UpdateRender | objectid == INVALID_STREAMER_ID");
		return;
	}

	this[GREENHOUSE_PLANT_OBJECT_ID] = objectid;
	return;
}

stock GreenhousePlant_Init(this[GREENHOUSE_PLANT], green_house[GREENHOUSE], slot) {
	new
		offsetX = GREENHOUSE_PLANTS_DISTANCE * slot,
		offsetY = GREENHOUSE_PLANTS_DISTANCE;
	
	this[GREENHOUSE_PLANT_POSITION][x] = slot % MAX_GREENHOUSE_ROWS != 0 ? green_house[GREENHOUSE_POSITION][x] + offsetX : green_house[GREENHOUSE_POSITION][x],
	this[GREENHOUSE_PLANT_POSITION][y] = slot % MAX_GREENHOUSE_ROWS == 0 ? green_house[GREENHOUSE_POSITION][y] + offsetY : green_house[GREENHOUSE_POSITION][y];
	this[GREENHOUSE_PLANT_POSITION][z] = green_house[GREENHOUSE_POSITION][z];

	if (green_house[GREENHOUSE_SEEDS] >= GREENHOUSE_SEEDS_ONE_PLANT) {
		this[GREENHOUSE_PLANT_OBJECT_STATUS] = GREENHOUSE_OBJECT_STATUS_SEED;
		green_house[GREENHOUSE_SEEDS] -= GREENHOUSE_SEEDS_ONE_PLANT;
	}
	return;
}

stock GreenhousePlant_Finish(this[GREENHOUSE_PLANT], green_house[GREENHOUSE]) {
	dbg("GreenhousePlant_Finish");

	++green_house[GREENHOUSE_HARVEST];

	if (green_house[GREENHOUSE_SEEDS] >= GREENHOUSE_SEEDS_ONE_PLANT) {
		this[GREENHOUSE_PLANT_OBJECT_STATUS] = GREENHOUSE_OBJECT_STATUS_SEED;
		green_house[GREENHOUSE_SEEDS] -= GREENHOUSE_SEEDS_ONE_PLANT;
	} else {
		this[GREENHOUSE_PLANT_OBJECT_STATUS] = GREENHOUSE_OBJECT_STATUS_NONE;
	}
	
	return;
}

stock GreenhousePlant_Update(this[GREENHOUSE_PLANT], green_house[GREENHOUSE]) {
	if (!GreenhousePlant_IsValid(this)) {
		return;
	}

	if (this[GREENHOUSE_PLANT_OBJECT_STATUS] == GREENHOUSE_OBJECT_STATUS_HARV) {
		GreenhousePlant_Finish(this, green_house);
	} else {
		this[GREENHOUSE_PLANT_OBJECT_STATUS]++;
	}

	dbg("GreenhousePlant_Update | status = %i", _:this[GREENHOUSE_PLANT_OBJECT_STATUS]);
	GreenhousePlant_UpdateRender(this);
	return;
}

stock GreenhousePlant_GetLessGrowed(const green_house[GREENHOUSE]) {
	new
		gid = green_house[GREENHOUSE_ID],
		this[GREENHOUSE_PLANT];

	new
		GREENHOUSE_OBJECT_STATUS:max_status = GREENHOUSE_OBJECT_STATUS_HARV,
		playerid = green_house[GREENHOUSE_PLAYER_ID];

	for (new plantid = 0; plantid < MAX_GREENHOUSE_PLANTS; plantid++) {
		this = g_Greenhouse_Plant[playerid][gid][plantid]; // COPY OF ORIGINAL ARRAY
		if (!GreenhousePlant_IsValid(this)) {
			continue;
		}

		if (this[GREENHOUSE_PLANT_OBJECT_STATUS] > max_status) {
			continue;
		}

		return plantid;
	}

	return INVALID_GREENHOUSE_PLANT_ID;
}

stock GreenhousePlant_Clear(this[GREENHOUSE_PLANT]) {
	new objectid = this[GREENHOUSE_PLANT_OBJECT_ID];
	if (objectid != INVALID_STREAMER_ID) {
		DestroyDynamicObject(objectid);
	}

	this[GREENHOUSE_PLANT_OBJECT_ID] 		= INVALID_STREAMER_ID;
	this[GREENHOUSE_PLANT_OBJECT_STATUS] 	= GREENHOUSE_OBJECT_STATUS_NONE;
	return;
}