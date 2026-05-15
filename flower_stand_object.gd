class_name FlowerStandObject
extends GridObject

@export var variants: Array[FlowerBucketData]
@export var flower_stand_menu: FlowerStandMenu
@export var flower_stand_id: String

var flower_stand_container: FlowerStand
var flower_buckets: Array[FlowerBucket] = []

@onready var flower_bucket_parent = $FlowerBuckets


const DEFAULT_VARIANT = 0
const INTERACT_PRIORITY = 10

func _ready() -> void:
	super()
	flower_stand_container = FlowerStand.new()
	add_child(flower_stand_container)
	
	get_flower_buckets()
	
	flower_stand_container.setup(flower_buckets.size())
	
	flower_stand_container.slots_changed.connect(_on_slots_changed)
	
func setup(flower_stand_menu: FlowerStandMenu) -> void:
	self.flower_stand_menu = flower_stand_menu
	
func get_flower_buckets() -> void:

	flower_buckets.clear()
	
	var flower_bucket_nodes = flower_bucket_parent.get_children()
	
	for bucket in flower_bucket_nodes:
		flower_buckets.append(bucket)
		
func get_flower_stand() -> FlowerStand:
	return flower_stand_container
		
func _on_slots_changed():

	var flower_inventory = flower_stand_container.get_flower_inventory()
	
	assert(flower_inventory.size() == flower_buckets.size())
	
	for i in range(flower_buckets.size()):
		var bucket = flower_buckets[i]
		var stack = flower_inventory[i]
		
		var variant: FlowerBucketData = variants[DEFAULT_VARIANT]
		
		if stack != null:
			variant = get_variant(stack.item_data.id)
			
		bucket._display_variant(variant)
		
func get_variant(id: String) -> FlowerBucketData:
	
	if variants.is_empty():
		push_error("FlowerStand ERROR: no FlowerBucketData found in variants. Assign in Editor")
		return null
	
	for variant in variants:
		if variant.id == id:
			return variant
	
	return null

func interact(request: InteractionRequest) -> bool:
	if flower_stand_menu == null:
		push_warning("FlowerStandObject ERROR: flower_stand_menu not assigned")
		return false
		
	flower_stand_menu.initialize_flower_stand(flower_stand_container)
	
	return true
	
func get_interaction_zone() -> Array[Vector2i]:
	return occupied_tiles
	
func get_interaction_score(context) -> int: 
	return INTERACT_PRIORITY
		
func can_accept_item(item_data: ItemData) -> bool:
	return true
	
func is_currently_interactable() -> bool:
	return true
	
