extends Control

@onready var slots = $GridContainer.get_children()

func update_ui():
	print("UPDATE UI RUNNING")
	var data = InventorySystem.get_inventory()
	
	print("DATA IN UI:", data)
	
	for i in range(slots.size()):
		if i <data.size():
			var item = data[i]			
			print("SETTING SLOT", i, item)
			slots[i].set_item(item["id"], item["quantity"])
		else:
			slots[i].clear()
		
func _ready(): 
	print("UI READY")
	print("CONNECTING SIGNAL")
	InventorySystem.inventory_changed.connect(_on_inventory_changed)

func _on_inventory_changed():
	print("SIGNAL RECEIVED IN UI")
	update_ui()
	
