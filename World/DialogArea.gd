extends Area2D

export(String, MULTILINE) var TEXT = ""
export(Texture) var IMAGE = null

onready var playerDetector = $PlayerDetector

var mouse_detected = false

var MainInstances = ResourceLoader.MainInstances

func _process(_delta):
	if MainInstances.Player != null:
		playerDetector.cast_to = MainInstances.Player.global_position - global_position
	
	if playerDetector.is_colliding(): return
	
	if MainInstances.Main == null: return
	
	if not mouse_detected: return
	
	if Input.is_action_just_pressed("interact"):
		MainInstances.Main.dialogBox.create_dialog(TEXT, IMAGE)

func _on_DialogArea_mouse_entered():
	mouse_detected = true

func _on_DialogArea_mouse_exited():
	mouse_detected = false
