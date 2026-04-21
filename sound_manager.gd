extends Node

var sounds = {
	"ui_hover": preload("res://assets/audio/sfx/pop.mp3"),
	"slot_hover": preload("res://assets/audio/sfx/wood_block.wav"),
	"walk_grass": preload("res://assets/audio/sfx/walk_grass.wav"),
	"coin": preload("res://assets/audio/sfx/coin3.mp3")
}

func play(sound_id: String):
	
	if not sounds.has(sound_id):
		return
		
	var player = AudioStreamPlayer.new()
	add_child(player)
	
	player.stream = sounds[sound_id]
	player.pitch_scale = randf_range(0.85, 1.15)
	player.volume_db = -15
	player.play()
	
	player.finished.connect(player.queue_free)
