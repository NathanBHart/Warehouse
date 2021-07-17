extends Control

onready var brightnessController = $Sprite

var Settings = ResourceLoader.Settings

# warning-ignore-all:return_value_discarded

func _ready():
	Music.list_play()

func _process(_delta):
	brightnessController.modulate.a = 1 - Settings.brightness/100

func _on_NewGameButton_pressed():
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().change_scene("res://World/Main.tscn")

func _on_LoadGameButton_pressed():
	yield(get_tree().create_timer(0.1), "timeout")
	SaverAndLoader.is_loading = true
	get_tree().change_scene("res://World/Main.tscn")

func _on_SettingsButton_pressed():
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().change_scene("res://MenusAndUI/Menus/SettingsMenu.tscn")

func _on_QuitButton_pressed():
	yield(get_tree().create_timer(0.05), "timeout")
	get_tree().quit()
