extends Sprite

onready var light = $Light2D

export var flashlight_on = false

func _physics_process(delta):
	var mouse_difference = get_global_mouse_position().y - global_position.y
	
	mouse_difference = clamp(mouse_difference, -50, 50)
	
	rotation = PI/3 / (50/mouse_difference)
	
	if Input.is_action_just_pressed("use"):
		flashlight_on = !flashlight_on
	
	light.enabled = flashlight_on
		
