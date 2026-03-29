extends StaticBody2D

@export var tree_data: TreeData

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	if tree_data:
		apply_tree_data()
	else:
		print("TREE ERROR: TreeData not found")
		
func apply_tree_data():
	
		sprite.texture = tree_data.texture
		
		var shape = RectangleShape2D.new()
		shape.size = tree_data.collision_size
		
		collision.shape = shape
		collision.position = tree_data.collision_offset
		
