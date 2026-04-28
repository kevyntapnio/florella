class_name InteractionTarget
extends RefCounted

var target_object: Node2D
var interaction_zone: Array[Vector2i]
var interaction_score: float

func _init(target_object: Node2D, interaction_zone: Array[Vector2i], interaction_score: float) -> void:
	self.target_object = target_object
	self.interaction_zone = interaction_zone
	self.interaction_score = interaction_score
	
