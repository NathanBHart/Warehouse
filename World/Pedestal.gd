extends Node2D

onready var playerDetector = $PlayerDetector
onready var sprite = $Sprite
onready var lightEffect = $Light2D

var mouse_detected = false

var MainInstances = ResourceLoader.MainInstances

signal button_pressed

func _ready():
	lightEffect.energy = 0
	sprite.frame = 0

func _process(_delta):
	
	if sprite.frame == 1:
		return
	
	var distance = 0
	
	if MainInstances.Player != null:
		playerDetector.cast_to = MainInstances.Player.global_position - global_position
		distance = global_position.distance_to(MainInstances.Player.global_position)
	
	if not mouse_detected or distance > 50 or playerDetector.is_colliding():
		sprite.frame = 0
		lightEffect.energy = 0
	else:
		sprite.frame = 2

		if not MainInstances.CurrentRoom.lights_on:
			lightEffect.energy = 0.65

		if Input.is_action_just_pressed("interact"):
			if MainInstances.Player != null:
				MainInstances.Player.unlocked_GFM = true
				sprite.frame = 1

func _on_Pedestal_mouse_entered():
	mouse_detected = true


func _on_Pedestal_mouse_exited():
	mouse_detected = false
