extends Camera2D

onready var topLeftPosition = null
onready var bottomRightPosition = null

var MainInstances = ResourceLoader.MainInstances

func _ready():
	MainInstances.MainCamera = self

func _process(_delta):
	player_at_edge_check()

func set_limits():
	if topLeftPosition != null:
		limit_left = topLeftPosition.x
		limit_top = topLeftPosition.y
		
	if bottomRightPosition != null:
		limit_right = bottomRightPosition.x
		limit_bottom = bottomRightPosition.y

func player_at_edge_check():
	if MainInstances.Player != null:
		if MainInstances.Player.global_position.x < limit_left:
			MainInstances.Player.global_position.x = limit_left
		elif MainInstances.Player.global_position.x > limit_right:
			MainInstances.Player.global_position.x = limit_right
