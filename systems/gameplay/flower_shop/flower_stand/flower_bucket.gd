class_name FlowerBucket
extends Node2D

@onready var sprite = $Sprite2D

func _display_variant(data: FlowerBucketData) -> void:
	if data == null:
		return
		
	sprite.texture = data.texture
	
