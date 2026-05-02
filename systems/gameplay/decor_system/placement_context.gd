extends RefCounted
class_name PlacementContext

var data: DecorData
var occupied_cells: Array[Vector2i]
var anchor_cell: Vector2i
var placement_behavior: DecorData.PlacementBehavior

func _init() -> void:
	self.data = data
	self.occupied_cells = occupied_cells
	self.anchor_cell = anchor_cell
	self.placement_behavior = placement_behavior
