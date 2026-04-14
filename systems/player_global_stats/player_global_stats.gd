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
	current_gold = current_gold - price
	print(current_gold, "-", price, "=", current_gold)
	wallet_changed.emit(current_gold)
