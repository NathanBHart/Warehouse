extends Node

var sounds_path = "res://MusicAndSounds/"

var sounds = {
	# "Name": load(sounds_path + "Name.Extention")
}

onready var audio_players = get_children()

func play(sound_string):
	for audio_player in audio_players:
		if not audio_player.playing:
			audio_player.stream = sounds[sound_string]
			audio_player.play()
			return
