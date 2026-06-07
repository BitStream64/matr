CMD:greenhouse(playerid) {
	// Одним циклом убиваем сразу двух зайцев: проверяем наличие теплицы и её удалённость от игрока
	new gid = Greenhouse_GetNear(playerid);

	if (gid == INVALID_GREENHOUSE_OWNER) {
		// TODO: диалог с предложением создать теплицу
		// 1. Dialog_Create(playerid, Dialog:Greenhouse_Create);
		// 2. response
		// 3. Greenhouse_Create(playerid);
		return;
	}

	if (gid == INVALID_GREENHOUSE_ID) {
		Player_Info(playerid, "Вы слишком далеко от своей теплицы");
		return;
	}
	
	// TODO: диалог с меню теплицы
	//Dialog_Create(playerid, Dialog:Greenhouse_Menu);
	return;
}