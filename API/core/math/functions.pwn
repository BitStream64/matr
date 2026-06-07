stock bool:Math_IsPlayerInRangeOfVector3D(playerid, const vector[Vector3D], Float:range) {
	new Float:playerX, Float:playerY;
	GetPlayerPos(playerid, playerX, playerY, _); // Z не важен

	new Float:distance = floatsqroot(floatsq(playerX - x) + floatsq(playerY - y));
	return distance <= range;
}