stock bool:Database_Connect() {
	new MySQLOpt:options = mysql_init_options();

    mysql_set_option(options, AUTO_RECONNECT, g_Config[CONFIG_DATABASE_AUTORECONNECT]);
    mysql_set_option(options, SERVER_PORT, g_Config[CONFIG_DATABASE_PORT]);
    mysql_log(ERROR | WARNING);

    g_Database = mysql_connect(
        g_Config[CONFIG_DATABASE_HOST],
       	g_Config[CONFIG_DATABASE_USER],
        g_Config[CONFIG_DATABASE_PASSWORD],
        g_Config[CONFIG_DATABASE_TABLE],
        options
    );

    if (g_Database == MYSQL_INVALID_HANDLE) {
        dbg("MySQL connection failed.");
        return false;
    }

    if (mysql_errno(g_Database) != 0) {
        dbg("MySQL connection error");
        return false;
    }

    mysql_set_charset(g_Config[CONFIG_DATABASE_CHARSET], g_Database);
    dbg("MySQL connected");
	return true;
}

stock Database_Disconnect() {
    if (g_Database != MYSQL_INVALID_HANDLE) {
        mysql_close(g_Database);
        g_Database = MYSQL_INVALID_HANDLE;
        dbg("MySQL disconnected");
    }

    return;
}

stock MySQL:Database_Get() {
    return g_Database;
}