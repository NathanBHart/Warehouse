extends Node

# warning-ignore-all:return_value_discarded

var MainInstances = ResourceLoader.MainInstances
var Settings = ResourceLoader.Settings

var player_just_died = false

onready var currentRoom = $Room1
onready var canvasModulate = $CanvasModulate
onready var brightnessController = $CanvasLayer/Sprite

func _ready():
	VisualServer.set_default_clear_color(Color.black)
	
	if SaverAndLoader.is_loading:
		SaverAndLoader.load_game()
		SaverAndLoader.is_loading = false
	MainInstances.Main = self

func _process(_delta):
	brightnessController.modulate.a = 1 - Settings.brightness/100

func change_rooms(door):
	var offset = currentRoom.position
	currentRoom.queue_free()
	var NewRoom = load(door.NEW_LEVEL_PATH)
	var newRoom = NewRoom.instance()
	add_child(newRoom)
	var newDoor = get_door_with_connection(door, door.CONNECTION)
	var exit_position = newDoor.position - offset
	newRoom.position = door.position - exit_position

func get_door_with_connection(not_door, connection):
	var doors = get_tree().get_nodes_in_group("Door")
	
	for door in doors:
		if door.CONNECTION == connection and door != not_door:
			return door
			
	return null

func _on_Player_hit_door(door):
	call_deferred("change_rooms", door)

func _on_Player_died():
	player_just_died = true
	yield(get_tree().create_timer(1), "timeout")
	if Settings.auto_load:
		SaverAndLoader.is_loading = true
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene("res://MenusAndUI/Menus/GameOverMenu.tscn")
