extends Node

func _input(_event):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func instance_scene_on_main(scene, position):
	var instance = scene.instance()
	get_tree().current_scene.add_child(instance)
	instance.global_position = position
	return instance
