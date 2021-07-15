extends CPUParticles2D

onready var animationPlayer = $AnimationPlayer


func _ready():
	animationPlayer.play("bullet_effect")
