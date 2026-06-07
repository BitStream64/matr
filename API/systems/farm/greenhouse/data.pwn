new const GREENHOUSE_TABLE_NAME[] 				= "green_house";
const MAX_PLAYER_GREENHOUSE 					= 5;
const Float:GREENHOUSE_ZONE_DISTANCE 			= 5.0; 	// max distance to greenhouse for interaction
const MAX_GREENHOUSE_OBJECTS 					= 30; 	// Кол-во объектов для визуализации роста урожая
const MAX_GREENHOUSE_PLANTS 					= 10; 	// Максимальное количество растений в одной теплице
const MAX_GREENHOUSE_ROWS 						= 2; 	// Кол-во рядов для растений в теплице (render)
const GREENHOUSE_PLANTS_DISTANCE 				= 5;	// Расстояние между растениями
const Float:MAX_GREENHOUSE_PLANTS_STREAM 		= 50.0;
const Float:MAX_GREENHOUSE_PLANTS_DRAW 			= 25.0;
const GREENHOUSE_SEEDS_ONE_PLANT				= 1; 	// Количество семян для выращивания одного растения
const GREENHOUSE_HARVEST_INTERVAL				= 10 * 60; // seconds

enum {
	INVALID_GREENHOUSE_ID 		= -1,
	INVALID_GREENHOUSE_OWNER 	= -2
}

enum GREENHOUSE_PRODUCT_TYPE {
	GREENHOUSE_PRODUCT_TYPE_NONE = -1,
	GREENHOUSE_PRODUCT_TYPE_TOMATO
}

// Объекты под разные стадии роста урожая для визуализации
enum GREENHOUSE_OBJECT_STATUS {
	GREENHOUSE_OBJECT_STATUS_NONE = -1, 	// пустой слот, нет объекта
	GREENHOUSE_OBJECT_STATUS_SEED, 			// маленькое семечко еле-заметное
	GREENHOUSE_OBJECT_STATUS_SPLANT, 		// уже заметный росток, но ещё не растение
	GREENHOUSE_OBJECT_STATUS_PLANT, 		// полноценное растение, но ещё не плодоносящее
	GREENHOUSE_OBJECT_STATUS_HARV 			// созревший урожай, готовый к сбору
}

enum GREENHOUSE_OBJECT_CONFIG {
	GREENHOUSE_OBJECT_MODEL_ID,
	Float:GREENHOUSE_OBJECT_ROTATION[Vector3D]
}

new const g_Greenhouse_ObjectConfig[GREENHOUSE_OBJECT_STATUS][GREENHOUSE_OBJECT_CONFIG] = {
	// GREENHOUSE_OBJECT_STATUS_SEED
	{	
		9987,	
		{ 0.00, 0.00, 340.34 }
	},
	// GREENHOUSE_OBJECT_STATUS_SEMI_PLANT
	{
		9986,	
		{ 0.00, 0.00, 112.34 }
	},
	// GREENHOUSE_OBJECT_STATUS_PLANT
	{
		9985,	
		{ 0.00, 0.00, 338.34 }
	},
	// GREENHOUSE_OBJECT_STATUS_HARVEST
	{
		9984,
		{ 0.00, 0.00, 554.34 }
	}
};

enum GREENHOUSE {
	GREENHOUSE_MYSQL_ID,														// MySQL id
	GREENHOUSE_ID,																// id																
	GREENHOUSE_PLAYER_ID,														// id игрока
	GREENHOUSE_PRODUCT_TYPE:GREENHOUSE_PRODUCT,									// Продукт
	GREENHOUSE_SEEDS,															// количество семян (шт.)
	GREENHOUSE_HARVEST,															// количество готового урожая (шт.)
	GREENHOUSE_POSITION[Vector3D]												// позиция теплицы
}

new g_Greenhouse[MAX_PLAYERS][MAX_PLAYER_GREENHOUSE][GREENHOUSE];

new Iterator:g_iGreenhousePlayer<MAX_PLAYERS>;

forward Greenhouse_Process();
forward Greenhouse_OnLoad(playerid, key);
