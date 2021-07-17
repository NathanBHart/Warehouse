extends Control

var difficulties = {
	1: "Easy",
	2: "Normal",
	3: "Hard"
}

export var IN_MAIN = false

var pauseMenu = null

var Settings = ResourceLoader.Settings

onready var colorRect = $ColorRect
onready var brightnessController = $Sprite

# Check Boxes
onready var fullscreenCheckBox = $MarginContainer/TabContainer/Video/MarginContainer2/HBoxContainer/VBoxContainer/FullscreenCheckBox
onready var autoLoadCheckBox = $MarginContainer/TabContainer/Gameplay/MarginContainer/HBoxContainer/VBoxContainer/AutoLoadCheckBox

# Sliders
onready var brightnessSlider = $MarginContainer/TabContainer/Video/MarginContainer2/HBoxContainer/VBoxContainer/BrightnessSlider
onready var soundEffectsSlider = $MarginContainer/TabContainer/Audio/MarginContainer/HBoxContainer/VBoxContainer/SoundEffectsSlider
onready var musicSlider = $MarginContainer/TabContainer/Audio/MarginContainer/HBoxContainer/VBoxContainer/MusicSlider
onready var difficultySlider = $MarginContainer/TabContainer/Gameplay/MarginContainer/HBoxContainer/VBoxContainer/DifficultySlider

# Labels
onready var difficultyLabel = $MarginContainer/TabContainer/Gameplay/MarginContainer/HBoxContainer/VBoxContainer/Label
onready var brightnessLabel = $MarginContainer/TabContainer/Video/MarginContainer2/HBoxContainer/VBoxContainer/Label
onready var soundEffectsLabel = $MarginContainer/TabContainer/Audio/MarginContainer/HBoxContainer/VBoxContainer/Label
onready var musicLabel = $MarginContainer/TabContainer/Audio/MarginContainer/HBoxContainer/VBoxContainer/Label2

# warning-ignore-all:return_value_discarded

func _ready():
	Utils.fullscreen_just_pressed = false
	if IN_MAIN:
		colorRect.color = Color(0, 0, 0, 0.403922)
	call_deferred("set_settings")

func _process(_delta):
	set_Settings_values()
	set_label_text()
	
	if pauseMenu == null and IN_MAIN: return
	
	if Input.is_action_just_pressed("pause"):
		go_back()
	
	if IN_MAIN: return
	
	brightnessController.modulate.a = 1 - Settings.brightness/100
	
	if Utils.fullscreen_just_pressed:
		fullscreenCheckBox.pressed = !fullscreenCheckBox.pressed
		Utils.fullscreen_just_pressed = false
	
	if fullscreenCheckBox.pressed:
		OS.window_fullscreen = true
	else:
		OS.window_fullscreen = false

func set_settings():
	fullscreenCheckBox.pressed = OS.window_fullscreen
	autoLoadCheckBox.pressed = Settings.auto_load
	brightnessSlider.value = Settings.brightness
	soundEffectsSlider.value = Settings.sound_effects
	musicSlider.value = Settings.music
	difficultySlider.value = Settings.difficulty

func set_Settings_values():
	Settings.auto_load = autoLoadCheckBox.pressed
	Settings.brightness = brightnessSlider.value
	Settings.sound_effects = soundEffectsSlider.value
	Settings.music = musicSlider.value
	Settings.difficulty = difficultySlider.value

func set_label_text():
	difficultyLabel.text = "Difficulty: " + difficulties[int(difficultySlider.value)]
	brightnessLabel.text = "Brightness: " + str(brightnessSlider.value)
	soundEffectsLabel.text = "Sound Effects: " + str(soundEffectsSlider.value)
	musicLabel.text = "Music: " + str(musicSlider.value)

func go_back():
	if IN_MAIN:
		visible = false
		pauseMenu.visible = true
		return
		
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().change_scene("res://MenusAndUI/Menus/StartMenu.tscn")

func _on_BackButton1_pressed():
	go_back()

func _on_BackButton2_pressed():
	go_back()

func _on_BackButton3_pressed():
	go_back()
