extends Node
class_name SellingBin

var size: int = 5
var slots: Array = []

func _ready():
	for i in range(size):
		slots.append(null)
		
	print(slots)
