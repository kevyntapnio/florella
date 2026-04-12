extends Resource
class_name ShopEntry

@export var item: ItemData
@export var has_override: bool = false
@export var override_price: int = 0

func get_price() -> int:
	if has_override:
		return override_price
	return item.price
