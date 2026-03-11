extends CharacterBody2D

const SPEED = 120
var facing_direction = "down"

@onready var sprite = $AnimatedSprite2D

var nearby_interactables = []
var closest_interactable = null

func _physics_process(delta):
	
	find_closest_interactable()

	# Movement
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

		if sprite.animation != "walk_down":
			sprite.play("walk_down")

	else:
		sprite.play("idle_down")
		
	# Object interaction
	if Input.is_action_just_pressed("interact"):
		if closest_interactable:
			closest_interactable.interact()


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		nearby_interactables.append(body)
		
func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		nearby_interactables.erase(body)
		
func find_closest_interactable():
	var closest_object = null
	var current_smallest_distance = INF
	
	for object in nearby_interactables:
		var distance = global_position.distance_to(object.global_position)
		
		if distance < current_smallest_distance:
			current_smallest_distance = distance
			closest_object = object
			
	closest_interactable = closest_object
