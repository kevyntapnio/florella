extends CharacterBody2D

const SPEED = 120
var facing_direction = "down"

func _physics_process(delta):

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity = direction * SPEED
	move_and_slide()

	if velocity.x > 0:
		facing_direction = "right"

		if $AnimatedSprite2D.animation != "walk_right":
			$AnimatedSprite2D.play("walk_right")

	elif velocity.x < 0:
		facing_direction = "left"

		if $AnimatedSprite2D.animation != "walk_left":
			$AnimatedSprite2D.play("walk_left")

	elif velocity.y < 0:
		facing_direction = "up"

		if $AnimatedSprite2D.animation != "walk_up":
			$AnimatedSprite2D.play("walk_up")

	elif velocity.y > 0:
		facing_direction = "down"

		if $AnimatedSprite2D.animation != "walk_down":
			$AnimatedSprite2D.play("walk_down")

	else:
		$AnimatedSprite2D.play("idle_down")
