stock bool:Config_Load() {
	new Node:node;
	if (JSON_ParseFile("scriptfiles/config/server.json", node) != 0) {
		dbg("Failed to parse configuration file [scriptfiles/config/server.json]");
		return false;
	}

	JSON_GetString(node, "NAME", g_Config[CONFIG_NAME], sizeof(g_Config[CONFIG_NAME]));

	new Node:databaseNode;
	JSON_GetObject(node, "DATABASE", databaseNode);

	JSON_GetString(databaseNode, "HOST", g_Config[CONFIG_DATABASE_HOST], sizeof(g_Config[CONFIG_DATABASE_HOST]));
	JSON_GetString(databaseNode, "USER", g_Config[CONFIG_DATABASE_USER], sizeof(g_Config[CONFIG_DATABASE_USER]));
	JSON_GetString(databaseNode, "PASSWORD", g_Config[CONFIG_DATABASE_PASSWORD], sizeof(g_Config[CONFIG_DATABASE_PASSWORD]));
	JSON_GetString(databaseNode, "TABLE", g_Config[CONFIG_DATABASE_TABLE], sizeof(g_Config[CONFIG_DATABASE_TABLE]));
	JSON_GetInt(databaseNode, "PORT", g_Config[CONFIG_DATABASE_PORT]);
	JSON_GetBool(databaseNode, "AUTORECONNECT", g_Config[CONFIG_DATABASE_AUTORECONNECT]);
	JSON_GetString(databaseNode, "CHARSET", g_Config[CONFIG_DATABASE_CHARSET], sizeof(g_Config[CONFIG_DATABASE_CHARSET]));

	return true;
}