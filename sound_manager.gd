extends Node

var last_played_times: Dictionary = {}
var global_cooldown: float = 0.1

var sounds = {
	"ui_hover": preload("res://assets/audio/sfx/pop.mp3"),
	"ui_cancel": preload("res://assets/audio/sfx/ui_cancel.wav"),
	"slot_hover": preload("res://assets/audio/sfx/wood_block.wav"),
	"walk_grass": preload("res://assets/audio/sfx/walk_grass.wav"),
	"coin": preload("res://assets/audio/sfx/coin3.mp3"),
	"wood_placed": preload("res://assets/audio/sfx/wood_placed.wav"),
	"grass_rustle": preload("res://assets/audio/sfx/soft_grass.mp3")
}

func play(sound_id: String):
	
	if not sounds.has(sound_id):
		return
		
	var current_time = Time.get_ticks_msec() / 1000.0
	if last_played_times.has(sound_id):
		if current_time - last_played_times[sound_id] < global_cooldown:
			return
		
	var player = AudioStreamPlayer.new()
	add_child(player)
	
	player.stream = sounds[sound_id]
	player.pitch_scale = randf_range(0.85, 1.15)
	player.volume_db = -20
	player.play()
	
	player.finished.connect(player.queue_free)
