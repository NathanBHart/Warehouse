extends Node

var MainInstances = ResourceLoader.MainInstances

onready var currentRoom = $Room1

func _ready():
	MainInstances.Player.connect("hit_door", self, "_on_Player_hit_door")

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