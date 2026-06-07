forward GreenhouseTest_Process();
public GreenhouseTest_Process() {
    //dbg("GreenhouseTest_Process");

    foreach (new playerid : g_iGreenhousePlayer) {
        //dbg("GreenhouseTest_Process | playerid = %i", playerid);

        for (new gid = 0; gid < MAX_PLAYER_GREENHOUSE; gid++) {
            if (Greenhouse_IsValid(g_Greenhouse[playerid][gid])) {
                continue;
            }

            dbg("GreenhouseTest_Process | init gid = %i", gid);
            g_Greenhouse[playerid][gid][GREENHOUSE_PRODUCT] = g_Greenhouse_Test[GREENHOUSE_TEST_PRODUCT];
            g_Greenhouse[playerid][gid][GREENHOUSE_SEEDS] = g_Greenhouse_Test[GREENHOUSE_TEST_SEEDS];
            memcpy(g_Greenhouse[playerid][gid][GREENHOUSE_IMPROVEMENTS], g_Greenhouse_Test[GREENHOUSE_TEST_IMPROVEMENTS], 0, _:GREENHOUSE_IMPROVEMENTS * cellbytes);

            for (new plantid = 0; plantid < MAX_GREENHOUSE_PLANTS; plantid++) {
                g_Greenhouse_Plant[playerid][gid][plantid][GREENHOUSE_PLANT_OBJECT_STATUS] = GREENHOUSE_OBJECT_STATUS_SEED;
            }
        }
    }

    return;
}

forward GreenhouseTest_OnPlayerCreated(playerid, key);
public GreenhouseTest_OnPlayerCreated(playerid, key) {
    new id = cache_insert_id();

    if (!id) {
        Player_Auth(playerid);
        dbg("GreenhouseTest_OnPlayerCreated id < 1");
        return;
    }

    dbg("Player inserted id %i", id);
    Player_Auth(playerid);
    return;
}

stock GreenhouseTest_LoginPlayer(playerid, const name[MAX_PLAYER_NAME], const password[sizeof(String64)]) {
    dbg("GreenhouseTest_LoginPlayer");
    Player_BuildUniqueID(playerid);

    strcpy(g_Player[playerid][PLAYER_NAME], name);
    strcpy(g_Player[playerid][PLAYER_TEMP_PASSWORD], password);

    Player_Auth(playerid);
    return;
}

stock GreenhouseTest_CreatePlayer(playerid, const name[MAX_PLAYER_NAME], const password[sizeof(String64)]) {
    dbg("GreenhouseTest_CreatePlayer");
    Player_BuildUniqueID(playerid);

    strcpy(g_Player[playerid][PLAYER_NAME], name);
    strcpy(g_Player[playerid][PLAYER_TEMP_PASSWORD], password);
    
    mysql_format(
        Database_Get(),
        String4096,
        sizeof(String4096),
        "INSERT INTO `%e` (`id`, `nickname`, `password`) VALUES (DEFAULT, '%e', '%e')",
        PLAYER_TABLE_NAME,
        name,
        password // no hashed
    );
    mysql_tquery(Database_Get(), String4096, __nameof(GreenhouseTest_OnPlayerCreated), "ii", playerid, Player_GetKey(playerid));
    return;
}