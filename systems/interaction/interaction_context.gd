extends RefCounted

class_name InteractionContext

var player_tile: Vector2i
var target_tile: Vector2i

func _init(player_tile: Vector2i, target_tile: Vector2i):
	self.player_tile = player_tile
	self.target_tile = target_tile
