extends Control

@onready var slots = $GridContainer.get_children()

func update_ui():

	var data = InventorySystem.get_inventory()a
	
	for i in range(slots.size()):
		if i <data.size():
			var item = data[i]
			
			slots[i].set_item(item["id"], item["quantity"])
			
		else:
			slots[i].clear()
		
func _ready(): 

	InventorySystem.inventory_changed.connect(_on_inventory_changed)

func _on_inventory_changed():

	update_ui()
	
