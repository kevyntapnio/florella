extends Node2D

@onready var sprite = $Sprite2D

var interaction_action = "Harvest"

func on_interact():
	print("flower harvested")
	
func interact():
	on_interact()

func get_interaction_action():
	return interaction_action
	
func on_focus_entered():
	sprite.modulate = Color(1.2, 1.2, 1.2)
	
func on_focus_exited():
	sprite.modulate = Color(1, 1, 1)
	
