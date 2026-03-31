extends Resource

class_name ItemData

enum ItemCategory {
	SEED,
	FLOWER,
	TOOL,
	MATERIAL,
	BUNDLE
}

@export var id: String
@export var name: String
@export var icon: Texture2D
@export var description: String = ""

@export var category: ItemCategory = ItemCategory.MATERIAL
@export var max_stack: int = 99

@export var tags: Array[String] = []

func use(player_tile, context):
	pass
