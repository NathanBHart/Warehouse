extends Control

export var IN_MAIN = false

var pauseMenu = null

onready var colorRect = $ColorRect

# Sliders
onready var brightnessSlider = $MarginContainer/TabContainer/Video/MarginContainer2/HBoxContainer/VBoxContainer/BrightnessSlider
onready var soundEffectsSlider = $MarginContainer/TabContainer/Audio/MarginContainer/HBoxContainer/VBoxContainer/SoundEffectsSlider
onready var musicSlider = $MarginContainer/TabContainer/Audio/MarginContainer/HBoxContainer/VBoxContainer/MusicSlider
onready var difficultySlider = $MarginContainer/TabContainer/Gameplay/MarginContainer/HBoxContainer/VBoxContainer/DifficultySlider

func _ready():
	if IN_MAIN:
		colorRect.color = Color(0, 0, 0, 0.403922)
	call_deferred("set_settings")

func _process(_delta):
	Settings.brightness = brightnessSlider.value
	Settings.sound_effects = soundEffectsSlider.value
	Settings.music = musicSlider.value
	Settings.difficulty = difficultySlider.value
	
	if pauseMenu == null:
		return
	
	if pauseMenu.is_paused == false:
		visible = false

func set_settings():
	brightnessSlider.value = Settings.brightness
	soundEffectsSlider.value = Settings.sound_effects
	musicSlider.value = Settings.music
	difficultySlider.value = Settings.difficulty

func go_back():
	if IN_MAIN:
		visible = false
		pauseMenu.visible = true
		return
		
	yield(get_tree().create_timer(0.1), "timeout")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MenusAndUI/Menus/StartMenu.tscn")

func _on_BackButton1_pressed():
	go_back()

func _on_BackButton2_pressed():
	go_back()

func _on_BackButton3_pressed():
	go_back()
