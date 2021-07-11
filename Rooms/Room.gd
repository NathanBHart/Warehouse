extends Node2D

const MAIN = preload("res://World/Main.gd")

onready var topLeft = $Limits/TopLeft
onready var bottomRight = $Limits/BottomRight

var MainInstances = ResourceLoader.MainInstances

func _ready():
	call_deferred("set_camera_limits")
	var parent = get_parent()
	if parent is MAIN:
		parent.currentRoom = self

func set_camera_limits():
	MainInstances.MainCamera.topLeftPosition = topLeft.global_position
	MainInstances.MainCamera.bottomRightPosition = bottomRight.global_position
	MainInstances.MainCamera.set_limits()
