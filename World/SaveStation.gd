extends Node2D

onready var playerDetector = $PlayerDetector

var mouse_detected = false

var MainInstances = ResourceLoader.MainInstances

func _process(_delta):
	if MainInstances.Player != null:
		playerDetector.cast_to = MainInstances.Player.global_position - global_position
	
	if playerDetector.is_colliding(): return
	
	if not mouse_detected: return
	
	if Input.is_action_just_pressed("interact"):
		SaverAndLoader.save_game()
		print("Game saved")
		if MainInstances.Player != null:
			MainInstances.Player.is_hurt = false

func _on_SaveStation_mouse_entered():
	mouse_detected = true

func _on_SaveStation_mouse_exited():
	mouse_detected = false
