extends "res://Enemies/Enemy.gd"

onready var shootTimer = $ShootTimer
onready var collision = $CollisionShape2D

const TurretProjectile = preload("res://EnemyComponents/TurretProjectile.tscn")

var MainInstances = ResourceLoader.MainInstances

enum {
	DEACTIVATED,
	ACTIVATED
}

var state = ACTIVATED

var direction = Vector2.ZERO

func _physics_process(_delta):
	match state:
		DEACTIVATED:
			if not shootTimer.is_stopped():
				shootTimer.stop()
		ACTIVATED:
			if shootTimer.is_stopped():
				if MainInstances.Player != null:
					direction = (MainInstances.Player.global_position - global_position).normalized()
					direction.y += rand_range(-0.3, 0.3)
				else:
					state = DEACTIVATED
				# This will rotate gun instead.
				collision.rotation = direction.angle()
				shootTimer.start()

func shoot_at_player(shoot_direction):
	var turretProjectile = TurretProjectile.instance()
	get_tree().current_scene.add_child(turretProjectile)
	turretProjectile.global_position = global_position
	turretProjectile.velocity = shoot_direction * 300

func _on_ShootTimer_timeout():
	shoot_at_player(direction)
