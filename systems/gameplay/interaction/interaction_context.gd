extends RefCounted

class_name InteractionContext

var player_tile: Vector2i
var target_tile: Array[Vector2i]
var target_cell: Vector2i

var tool = null

func _init(player_tile: Vector2i, target_tile: Array[Vector2i], target_cell: Vector2i):
	self.player_tile = player_tile
	self.target_tile = target_tile
	self.target_cell = target_cell
