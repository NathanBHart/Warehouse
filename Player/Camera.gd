extends Camera2D

var MainInstances = ResourceLoader.MainInstances

func _ready():
	MainInstances.MainCamera = self

func _process(_delta):
	player_at_edge_check()

func player_at_edge_check():
	var Player = MainInstances.Player
	if Player != null:
		if Player.global_position.x < limit_left:
			Player.global_position.x = limit_left
		elif Player.global_position.x > limit_right:
			Player.global_position.x = limit_right
