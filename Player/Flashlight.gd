extends Sprite

onready var light = $Light2D
onready var powerAnimator = $PowerAnimator
onready var powerLight = $PowerLight

export var flashlight_on = false

var MainInstances = ResourceLoader.MainInstances

func _physics_process(_delta):
	
	var holding = MainInstances.Player.holding
	
	if holding != 1:
		show()
	else:
		hide()
		flashlight_on = false
		return
		
	if holding == 2:
		frame = 0
	else:
		flashlight_on = false
		
	if holding == 3:
		powerLight.enabled = true
		if Input.is_action_pressed("use") and MainInstances.Player.idle:
			powerAnimator.play("powered-on")
		else:
			powerAnimator.play("powered-off")
	else:
		powerLight.enabled = false
	
	var mouse_difference = get_global_mouse_position().y - global_position.y
	
	mouse_difference = clamp(mouse_difference, -50, 50)
	
	rotation = PI/3 / (50/mouse_difference)
	
	if Input.is_action_just_pressed("use"):
		
		if holding == 2:
			flashlight_on = !flashlight_on
		if holding == 3:
			pass
	
	light.enabled = flashlight_on
		
