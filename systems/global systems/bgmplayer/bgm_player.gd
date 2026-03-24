extends Node

var music_player 

func _ready():
	music_player = $AudioStreamPlayer2D
	music_player.play()
	
func play_music(stream):
		if music_player.stream == stream:
			return
			
		music_player.stream = stream
		music_player.play()
