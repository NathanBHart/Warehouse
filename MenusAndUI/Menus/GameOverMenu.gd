extends Control

onready var brightnessController = $Sprite

var Settings = ResourceLoader.Settings

# warning-ignore-all:return_value_discarded

func _process(_delta):
	brightnessController.modulate.a = 1 - Settings.brightness/100

func _on_LoadGame_pressed():
	yield(get_tree().create_timer(0.1), "timeout")
	SaverAndLoader.is_loading = true
	get_tree().change_scene("res://World/Main.tscn")

func _on_QuitToStartButton_pressed():
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().change_scene("res://MenusAndUI/Menus/StartMenu.tscn")
