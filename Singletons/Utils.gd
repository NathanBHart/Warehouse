extends Node

var fullscreen_just_pressed = false

var Settings = ResourceLoader.Settings

func _input(_event):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		fullscreen_just_pressed = true

func instance_scene_on_main(scene, position):
	var instance = scene.instance()
	get_tree().current_scene.add_child(instance)
	instance.global_position = position
	return instance
