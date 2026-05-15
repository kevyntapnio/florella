extends ItemData

class_name FlowerData

enum CoreMeaning {
	Joy,
	Friendship,
	Comfort,
	Gratitude,
	Forgiveness,
	Romance
}

enum Attributes {
	Wild,
	Rustic,
	Elegant,
	Bold,
	Soft,
	Vibrant,
	Delicate,
	Calm,
	Fragrant
}

enum FlowerColor {
	Pink,
	White,
	Purple,
	Blue,
	Yellow,
	Red,
	Orange
}

@export var core_meaning: Array[CoreMeaning]
@export var attributes: Array[Attributes]
@export var colors: Array[FlowerColor]
@export var rarity: int = 1
