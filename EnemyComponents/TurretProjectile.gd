extends "res://EnemyComponents/Projectile.gd"

onready var startingPosition = position
onready var sprite = $Sprite

func summon_bullet_effect():
	queue_free()

func _on_Hitbox_body_entered(_body):
	summon_bullet_effect()
