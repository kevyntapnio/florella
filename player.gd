extends CharacterBody2D

const SPEED = 120
var facing_direction = "down"

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity = direction * SPEED
	move_and_slide()

	if velocity.x > 0:
		facing_direction = "right"

		if sprite.animation != "walk_right":
			sprite.play("walk_right")

	elif velocity.x < 0:
		facing_direction = "left"

		if sprite.animation != "walk_left":
			sprite.play("walk_left")

	elif velocity.y < 0:
		facing_direction = "up"

		if sprite.animation != "walk_up":
			sprite.play("walk_up")

	elif velocity.y > 0:
		facing_direction = "down"

		if $AnimatedSprite2D.animation != "walk_down":
			$AnimatedSprite2D.play("walk_down")

	else:
		$AnimatedSprite2D.play("idle_down")
