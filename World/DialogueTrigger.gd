extends Area2D

export(String, MULTILINE) var TEXT = ""
export(Texture) var IMAGE = null

var mouse_detected = false

var MainInstances = ResourceLoader.MainInstances

func _ready():
	
	if MainInstances.DialoguesRead.has(TEXT):
		queue_free()
		return
	else:
		MainInstances.DialoguesRead.append(TEXT)
	
	if get_overlapping_bodies().size() > 0:
		MainInstances.Main.dialogBox.create_dialog(TEXT, IMAGE)
		queue_free()

func _on_DialogArea_body_entered(body):
	MainInstances.Main.dialogBox.create_dialog(TEXT, IMAGE)
	queue_free()
