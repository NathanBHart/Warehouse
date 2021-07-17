extends Area2D

onready var playerDetector = $PlayerDetector

var mouse_detected = false

var MainInstances = ResourceLoader.MainInstances

func _process(_delta):
	
	if 	MainInstances.Player == null:
		return
	
	playerDetector.cast_to = (MainInstances.Player.global_position + Vector2(0, -16)) - global_position
	
	if playerDetector.is_colliding(): return
	
	if not mouse_detected: return
	
	if Input.is_action_just_pressed("interact"):
		MainInstances.CurrentRoom.flip_lights()

func _on_LightSwitch_mouse_entered():
	mouse_detected = true

func _on_LightSwitch_mouse_exited():
	mouse_detected = false
