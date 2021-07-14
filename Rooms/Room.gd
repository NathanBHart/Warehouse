extends Node2D

export (Color) var BASE_COLOR = Color.white

const MAIN = preload("res://World/Main.gd")

onready var topLeft = $Limits/TopLeft
onready var bottomRight = $Limits/BottomRight

var MainInstances = ResourceLoader.MainInstances

func _ready():
	call_deferred("set_camera_limits")
	var parent = get_parent()
	if parent is MAIN:
		parent.currentRoom = self
		
	call_deferred("set_modulate", BASE_COLOR)

func save():
	var save_dictionary = {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"position_x": position.x,
		"position_y": position.y
	}
	return save_dictionary

func set_camera_limits():
	var MainCamera = MainInstances.MainCamera
	if MainCamera != null:
		MainCamera.limit_top = topLeft.global_position.y
		MainCamera.limit_left = topLeft.global_position.x
		MainCamera.limit_bottom = bottomRight.global_position.y
		MainCamera.limit_right = bottomRight.global_position.x

func set_modulate(color):
	MainInstances.Main.canvasModulate.color = color
