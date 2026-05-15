class_name RequestData
extends Resource

@export_multiline var request_message: String
@export var request_meanings: Array[FlowerData.CoreMeaning]
@export var preferred_attributes: Array[FlowerData.Attributes]
@export var preferred_colors: Array[FlowerData.FlowerColor]
@export var preferred_flowers: Array[FlowerData]
@export var min_size: int
@export var max_size: int
@export var request_weight: int
@export var request_level: int
@export var requester_npc: String ## TODO: change this later to NPCData
@export var allow_random_preferences:= false
