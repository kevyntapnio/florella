extends Node

var current_gold: int
var current_level: int
var current_exp: int

signal wallet_changed

func _ready() -> void:
	wallet_changed.emit(current_gold)

func get_current_gold():
	return current_gold
	
func add_to_wallet(amount):
	current_gold = current_gold + amount
	wallet_changed.emit(current_gold)

func remove_from_wallet(price):
	current_gold = max(0, current_gold - price)
	wallet_changed.emit(current_gold)

func get_save_data() -> Dictionary:
	var save_data = {
		"current_gold": current_gold,
		"current_level": current_level,
		"current_exp": current_exp
	}
	return save_data
	
func load_from_data(data: Dictionary):
	
	current_gold = data.get("current_gold", 0)
	current_level = data.get("current_level", 0)
	current_exp = data.get("current_exp", 0)
	
	wallet_changed.emit(current_gold)
