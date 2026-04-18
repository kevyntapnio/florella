extends Node

const SAVE_PATH = "user://save.json"

func save_game():
	var player = get_tree().get_first_node_in_group("player")
	
	var data = {
		"time": TimeManager.get_save_data(),
		"farm": FarmSystem.get_save_data(),
		"player_stats": PlayerGlobalStats.get_save_data(),
		"player": player.get_save_data(),
		"inventory": InventorySystem.get_save_data()
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	file.store_string(JSON.stringify(data))
	file.close()
	
	print("Game saved")
	
func load_game():
	
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var result = JSON.parse_string(content)
	
	if result == null:
		push_error("Failed to parse save file")
		return
	
	## Load systems
	TimeManager.load_from_data(result.get("time", {}))
	FarmSystem.load_from_data(result.get("farm", {}))
	PlayerGlobalStats.load_from_data(result.get("player_stats", {}))
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.load_from_data(result.get("player", {}))
	else:
		push_error("SaveSystem ERROR: Player not found after scene load")
	
	InventorySystem.load_from_data(result.get("inventory"))
	
	print("Game loaded")
