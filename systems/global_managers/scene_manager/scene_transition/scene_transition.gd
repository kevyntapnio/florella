extends Area2D

@export var target_scene: SceneManager.Scenes
@export var target_spawn_id: String

## add later
signal scene_switch

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneManager.request_change_scene(target_scene, {
			"spawn":{
				"type": "anchor",
				"id": target_spawn_id
			}
		})
