extends Area2D

export(Resource) var CONNECTION = null
export(String, FILE, "*.tscn") var NEW_LEVEL_PATH = ""

var is_active = true

func _on_Door_body_entered(player):
	print("hi")
	if is_active:
		player.emit_signal("hit_door", self)
		is_active = false
