extends Node

const SAVE_PATH = "user://save.json"

func save_game():
	
	var data = {
		"farm": FarmSystem.get_save_data()
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
		
	FarmSystem.load_from_data(result["farm"])
	
	print("Game loaded")
