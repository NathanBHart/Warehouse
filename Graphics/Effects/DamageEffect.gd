extends Sprite

onready var animationPlayer = $AnimationPlayer

var MainInstances = ResourceLoader.MainInstances

var player_is_hurt = false

func _process(_delta):
	
	if MainInstances.Player != null:
		
		if MainInstances.Player.is_hurt and player_is_hurt != true:
			frame = 1
			animationPlayer.play("blast")
			show()
		elif not MainInstances.Player.is_hurt:
			player_is_hurt = MainInstances.Player.is_hurt
			animationPlayer.stop()
			hide()
		
		
		if player_is_hurt:
			frame = 0
			animationPlayer.play("flash")
			show()

func update_hurt():
	if MainInstances.Player != null:
		player_is_hurt = MainInstances.Player.is_hurt
