extends Area2D

export(String, MULTILINE) var TEXT = ""
export(Texture) var IMAGE = null

onready var playerDetector = $PlayerDetector
onready var lightEffect = $Light2D

var mouse_detected = false

var MainInstances = ResourceLoader.MainInstances

func _process(_delta):
	if MainInstances.Main == null: return
	
	var distance = 0
	
	if MainInstances.Player != null:
		playerDetector.cast_to = MainInstances.Player.global_position - global_position
		distance = global_position.distance_to(MainInstances.Player.global_position)
	
	if not mouse_detected or distance > 50 or playerDetector.is_colliding():
		if distance < 50:
			lightEffect.energy = lerp(lightEffect.energy, 0.75, 0.05)
		else:
			lightEffect.energy = lerp(lightEffect.energy, 0, 0.05)
	else:
		lightEffect.energy = 1

		if Input.is_action_just_pressed("interact"):
			MainInstances.Main.dialogBox.create_dialog(TEXT, IMAGE)

func _on_DialogArea_mouse_entered():
	mouse_detected = true

func _on_DialogArea_mouse_exited():
	mouse_detected = false
