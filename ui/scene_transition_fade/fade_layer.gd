extends CanvasLayer

@onready var rect = $ColorRect

func _ready() -> void:
	rect.modulate.a = 0.0

func fade_out(duration := 0.3):
	
	var tween = create_tween()
	
	tween.tween_property(rect, "modulate:a", 1.0, duration)
	
	await tween.finished

func fade_in(duration:= 0.3):
	var tween = create_tween()
	
	tween.tween_property(rect, "modulate:a", 0.0, duration)
	
	await tween.finished
	
func tween_to(target_alpha: float, duration: float):
	var tween = create_tween()
	
	tween.tween_property(rect, "modulate.a", target_alpha, duration)
	tween.play()
	await tween.finished
	return tween.finished
