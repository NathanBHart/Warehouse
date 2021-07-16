extends Node2D

onready var doorCollision = $Door/CollisionShape2D
onready var button = $Button
onready var playerDetector = $Button/PlayerDetector

var mouse_detected = false

var MainInstances = ResourceLoader.MainInstances

func _process(_delta):
	if MainInstances.Player != null:
		playerDetector.cast_to = MainInstances.Player.global_position - button.global_position
	
	if playerDetector.is_colliding(): return
	
	if not mouse_detected: return
	
	if Input.is_action_just_pressed("interact"):
		doorCollision.disabled = !doorCollision.disabled

func _on_Button_mouse_entered():
	mouse_detected = true

func _on_Button_mouse_exited():
	mouse_detected = false
