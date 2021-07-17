extends Control

var settings = null
var is_paused = false setget set_is_paused

var MainInstances = ResourceLoader.MainInstances
var Settings = ResourceLoader.Settings

func _process(_delta):
	MainInstances.Main.brightnessController.modulate.a = 1 - Settings.brightness/100

func _input(_event):
	if MainInstances.Main.player_just_died: return
	
	if settings != null:
		if settings.visible: return
	
	if Input.is_action_just_pressed("pause"):
		self.is_paused = !is_paused

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused

func _on_ResumeGameButton_pressed():
	self.is_paused = false

func _on_SettingsButton_pressed():
	settings = get_tree().get_root().find_node("SettingsMenu", true, false)
	if settings != null:
		visible = false
		settings.pauseMenu = self
		settings.visible = true

func _on_QuitToStartButton_pressed():
	self.is_paused = false
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MenusAndUI/Menus/StartMenu.tscn")
