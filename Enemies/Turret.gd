extends "res://Enemies/Enemy.gd"

onready var shootTimer = $ShootTimer
onready var windUpTimer = $WindUpTimer
onready var aimingTimer = $AimingTimer
onready var collision = $CollisionShape2D
onready var animationPlayer = $AnimationPlayer
onready var raycast = $RayCast2D

onready var head = $Head

const TurretProjectile = preload("res://EnemyComponents/TurretProjectile.tscn")

var MainInstances = ResourceLoader.MainInstances

enum {
	DEACTIVATED,
	ACTIVATED
}

var state = ACTIVATED
var shooting = false
var winding_up = false
var direction = Vector2.ZERO


func _ready():
	raycast.global_rotation = 0


func _physics_process(_delta):
	match state:
		DEACTIVATED:
			if not shootTimer.is_stopped():
				shootTimer.stop()
				
			animationPlayer.play("idle")
			shooting = false
			winding_up = false

		ACTIVATED:
			
			var player_pos = Vector2.ZERO
			
			if MainInstances.Player != null:
				player_pos = MainInstances.Player.global_position + Vector2(0, -8)
			else:
				state = DEACTIVATED
			
			raycast.cast_to = player_pos - global_position
			
			if raycast.is_colliding() or global_position.distance_to(player_pos) > 250:
				animationPlayer.play("idle")
				shooting = false
				winding_up = false
				
			else:
				
				rotate_towards_absolute(player_pos - global_position, 5, head)
				
				if shooting:
					if shootTimer.is_stopped():
						direction = (player_pos - global_position).normalized()
						# Gets perpendicular vector and distributes it across the perpendicular
						direction += Vector2(-direction.y/30, direction.x/30) * rand_range(-1,1)
						
						shootTimer.start()
				
				elif winding_up:
					if windUpTimer.is_stopped():
						windUpTimer.start()
					animationPlayer.play("winding-up")
					
				else:
					if aimingTimer.is_stopped():
						aimingTimer.wait_time = rand_range(0.7,1.2)
						aimingTimer.start()
					animationPlayer.play("targeting")

func shoot_at_player(shoot_direction):
	animationPlayer.stop()
	animationPlayer.play("fire")
	var turretProjectile = TurretProjectile.instance()
	get_tree().current_scene.add_child(turretProjectile)
	turretProjectile.global_position = position
	turretProjectile.velocity = shoot_direction * 300


# I borrowed these two functions from another project I did because it's really
# tedious to recode.
func get_direction_vector(direction):
	return Vector2(cos(direction), sin(direction)).normalized()


func rotate_towards_absolute(relative_point: Vector2, speed_modifier: int, entity: Node2D = self):
	# Get the target direction as a vector point
	var target_vector = relative_point.normalized()
	# Get the current direction as a vector point (normalized using trig)
	var direction_vector = get_direction_vector(entity.global_rotation)
	
	# If ~approximately~ the direction vector is the inverse of the target vector
	# then displace it slightly so that it rotates correctly
	if Vector2(round(target_vector[0]*100)/100, round(target_vector[1]*100)/100) \
	== -Vector2(round(direction_vector[0]*100)/100, round(direction_vector[1]*100)/100) :
		var displace = Vector2(direction_vector[1], -direction_vector[0])
		direction_vector += displace / 10
		direction_vector = direction_vector.normalized()
	
	# Move move the direction vector towards the target vector, and then
	# nomalize it.
	var direction_delta = target_vector - direction_vector
	var temp = direction_vector
	direction_vector += direction_delta / speed_modifier
	direction_vector.normalized()
	
	# If the adjusted and normalized direction vector is the same,
	# Then the direction vector moved inwards, towards the player, which
	# Is not helpful. We shall correct by moving the direction vector
	# (displacing it)
	
	entity.look_at(direction_vector + entity.global_position)
	return entity.global_rotation


func _on_ShootTimer_timeout():
	shoot_at_player(direction)


func _on_WindUpTimer_timeout():
	shooting = true


func _on_AimingTimer_timeout():
	winding_up = true
