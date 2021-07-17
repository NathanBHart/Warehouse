extends Area2D

onready var playerDetector = $PlayerDetector
onready var sprite = $Sprite
onready var lightEffect = $Sprite/Light2D

var mouse_detected = false

var MainInstances = ResourceLoader.MainInstances

func _ready():
	lightEffect.energy = 0

func _process(_delta):
	
	var distance = 0
	
	if MainInstances.Player != null:
		playerDetector.cast_to = MainInstances.Player.global_position - global_position
		distance = global_position.distance_to(MainInstances.Player.global_position)
	
	if not mouse_detected or distance > 50 or playerDetector.is_colliding():
		sprite.frame = 0
		lightEffect.energy = 0
	else:
		sprite.frame = 1

		if not MainInstances.CurrentRoom.lights_on:
			lightEffect.energy = 0.65

		if Input.is_action_just_pressed("interact"):
			SaverAndLoader.save_game()
			print("Game saved")
			if MainInstances.Player != null:
				MainInstances.Player.is_hurt = false

func _on_SaveStation_mouse_entered():
	mouse_detected = true
	

func _on_SaveStation_mouse_exited():
	mouse_detected = false
