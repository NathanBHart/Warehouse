extends Area2D

onready var playerDetector = $PlayerDetector
onready var sprite = $Sprite
onready var lightEffect = $Sprite/Light2D

var mouse_detected = false

var MainInstances = ResourceLoader.MainInstances

func _process(_delta):
	
	var distance = 0
	
	sprite.frame = MainInstances.CurrentRoom.lights_on
	
	if MainInstances.Player != null:
		playerDetector.cast_to = MainInstances.Player.global_position - global_position
		distance = global_position.distance_to(MainInstances.Player.global_position)
	
	if not mouse_detected or distance > 50 or playerDetector.is_colliding():
		
		lightEffect.energy = 0
		
	else:
		
		sprite.frame += 2
		
		if not MainInstances.CurrentRoom.lights_on:
			lightEffect.energy = 0.65

		if Input.is_action_just_pressed("interact"):
			MainInstances.CurrentRoom.flip_lights()
			lightEffect.energy = 0

func _on_LightSwitch_mouse_entered():
	mouse_detected = true

func _on_LightSwitch_mouse_exited():
	mouse_detected = false
