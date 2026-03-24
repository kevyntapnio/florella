extends Interactable

@onready var sprite = $AnimatedSprite2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if sprite.animation != "tail_wag":
			sprite.play("tail_wag")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite.play("idle")
		
