extends "res://Enemies/Enemy.gd"

const LIGHT_UP_LERP = 0.1

export (float, 0, 250) var RANGE = 200
export (float, 0.01, 5) var SPEED = 1
export (float, 0, 1) var ACCURACY = 0.2
export (float, 0.01, 10) var WAIT_DELAY = 1
export (int, "Standard", "Always") var TARGETING_MODE = 0

enum {
	STANDARD,
	ALWAYS
}

onready var shootTimer = $ShootTimer
onready var windUpTimer = $WindUpTimer
onready var aimingTimer = $AimingTimer
onready var collision = $CollisionShape2D
onready var animationPlayer = $AnimationPlayer
onready var aim = $Aim
onready var fire = $Fire

onready var head = $Head
onready var glow = $Head/Glow
onready var spotlight = $Head/Glow/Spotlight

const bulletSpray = preload("res://Graphics/Effects/BulletHitSpray.tscn")
const bulletImpact = preload("res://Graphics/Effects/BulletImpact.tscn")

enum {
	IDLE,
	ACTIVE
}

var MainInstances = ResourceLoader.MainInstances

var state = ACTIVE
var shooting = false
var winding_up = false
var direction = Vector2.ZERO


func _ready():
	aim.global_rotation = 0
	fire.global_rotation = 0
	randomize()
	
	glow.visible = true

func _physics_process(_delta):
	match state:
		IDLE:
			go_idle()
			
			if check_for_player() and check_lights():
				state = ACTIVE

		ACTIVE:
			
			var player_pos = check_for_player()
			
			if not player_pos:
				state = IDLE
				return
				
			else:
				rotate_towards_absolute(player_pos - global_position, 15, head)
				
				if shooting:
					if shootTimer.is_stopped():
						direction = (player_pos - global_position).normalized()
						# Gets perpendicular vector and distributes it across the perpendicular
						direction += Vector2(1, -(direction.x/direction.y)).normalized() * rand_range(-1,1) * ACCURACY
						
						var wait_delay = rand_range(SPEED-SPEED/5,SPEED+SPEED/5)
						
						shootTimer.wait_time = wait_delay
						shootTimer.start()
						fire.cast_to = direction * RANGE
						
					if not MainInstances.CurrentRoom.lights_on:
						spotlight_power_up()
					else:
						spotlight_power_down()
				
				elif winding_up:
					if windUpTimer.is_stopped():
						windUpTimer.start()
					animationPlayer.play("winding-up")
					
					if not MainInstances.CurrentRoom.lights_on:
						spotlight_power_up()
					else:
						spotlight_power_down()
					
				else:
					if aimingTimer.is_stopped():
						aimingTimer.wait_time = WAIT_DELAY
						aimingTimer.start()
					animationPlayer.play("targeting")

func go_idle():
	if not shootTimer.is_stopped():
		shootTimer.stop()
				
	animationPlayer.play("idle")
	shooting = false
	winding_up = false
	
	rotate_towards_absolute(get_direction_vector(global_rotation), 15, head)
	
	spotlight_power_down()


func spotlight_power_up():
	glow.energy = lerp(glow.energy, 3, LIGHT_UP_LERP)
	spotlight.energy = lerp(spotlight.energy, 2, LIGHT_UP_LERP)
	
	
func spotlight_power_down():
	glow.energy = lerp(glow.energy, 0, LIGHT_UP_LERP)
	spotlight.energy = lerp(spotlight.energy, 0, LIGHT_UP_LERP)


func check_for_player():
	var player_pos = Vector2.ZERO
			
	if MainInstances.Player != null:
		player_pos = MainInstances.Player.global_position + Vector2(0, -16)
	else:
		return false
	
	aim.cast_to = player_pos - global_position
	
	if aim.is_colliding() or global_position.distance_to(player_pos) > RANGE:
		return false
	else:
		return player_pos


func check_lights():
	
	if TARGETING_MODE == ALWAYS:
		return true
	else:
		return MainInstances.CurrentRoom.lights_on or MainInstances.Player.flashlight.flashlight_on


func shoot_at_player():
	animationPlayer.stop()
	animationPlayer.play("fire")
	
	#get_collider seems to take a moment after casting the ray to work, so
	#I put the casting before the delay.
	
	var collider = fire.get_collider()
	
	if collider == MainInstances.Player.hurtbox or collider == null:
		return

	var hit_area = fire.get_collision_point()
	var normal = fire.get_collision_normal()
	
	var spray_effect = bulletSpray.instance()
	spray_effect.global_position = hit_area
	spray_effect.direction = normal
	
	var impact_effect = bulletImpact.instance()
	impact_effect.global_position = hit_area
	
	get_tree().current_scene.add_child(spray_effect)
	
	if not collider is RigidBody2D:
		get_tree().current_scene.add_child(impact_effect)
		impact_effect.look_at(hit_area + normal)

# I borrowed these two functions from another project I did because it's really
# tedious to recode.
func get_direction_vector(obj_direction):
	return Vector2(cos(obj_direction), sin(obj_direction)).normalized()


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
	direction_vector += direction_delta / speed_modifier
	direction_vector.normalized()
	
	# If the adjusted and normalized direction vector is the same,
	# Then the direction vector moved inwards, towards the player, which
	# Is not helpful. We shall correct by moving the direction vector
	# (displacing it)
	
	entity.look_at(direction_vector + entity.global_position)
	return entity.global_rotation


func _on_ShootTimer_timeout():
	shoot_at_player()


func _on_WindUpTimer_timeout():
	shooting = true


func _on_AimingTimer_timeout():
	winding_up = true
