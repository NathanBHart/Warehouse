extends KinematicBody2D

# Warning Ignores
# warning-ignore-all:unused_signal
# warning-ignore-all:return_value_discarded

# Export Constants
export var MAX_SLOPE_ANGLE = 46
export var JUMP_FORCE = 180
export var GRAVITY = 800
export var FRICTION = 0.25
export var AIR_RESISTANCE = 0.02
export var ACCELERATION = 500
export var AIR_ACCELERATION = 200
export var MAX_SPEED = 55
export var AIR_MAX_SPEED = 120
export var WALL_SLIDE_SPEED = 30
export var ACCELERATED_WALL_SLIDE_SPEED = 60
export var WALL_BOOST_SPEED = 140
export var INERTIA = 25

# Vectors
var velocity = Vector2.ZERO
var snap_vector = Vector2.ZERO

# Platforming Booleans
var just_jumped = false
var is_jumping = false
var just_boosted = false
var idle = false
var is_hurt = false

# Platforming Controllers
onready var coyoteTimer = $CoyoteTimer
onready var landingJumpTimer = $LandingJumpTimer
onready var wallClingTimer = $WallClingTimer
onready var clingArea = $ClingArea
onready var cameraFollow = $CameraFollow

# Animation Controllers
onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var turnTimer = $AnimationTimers/TurnTimer
onready var jumpTimer = $AnimationTimers/JumpTimer
onready var flashlight = $Sprite/Flashlight

# Collisions
onready var hurtbox = $Hurtbox

var turning = false
var turn_to = 1
var holding = true

# Preload Resources
var MainInstances = ResourceLoader.MainInstances

# Export Constant Backups
onready var jump_force_backup = JUMP_FORCE
onready var max_speed_backup = MAX_SPEED
onready var air_max_speed_backup = AIR_MAX_SPEED

# States
enum {
	MOVE_STATE,
	WALL_STATE,
	JUMPING,
}

var state = MOVE_STATE

# Signals
signal hit_door(door)
signal died

func _ready():
	MainInstances.Player = self
	clingArea.monitoring = true
	call_deferred("assign_camera")
	call_deferred("connect_signals")

func queue_free():
	MainInstances.Player = null
	.queue_free()

func _physics_process(delta):
	
	#holding = flashlight.flashlight_on
	
	match state:
		
		MOVE_STATE:
			var input_vector = get_input_vector()
			
			if is_hurt:
				JUMP_FORCE = jump_force_backup * 0.85
				MAX_SPEED = max_speed_backup * 0.75
				AIR_MAX_SPEED = air_max_speed_backup * 0.75
			else:
				JUMP_FORCE = jump_force_backup
				
				if not just_boosted:
					MAX_SPEED = max_speed_backup
				
				AIR_MAX_SPEED = air_max_speed_backup
				
			reset_wall_cling_timer()
			apply_horizontal_force(input_vector, delta)
			apply_friction(input_vector)
			update_snap_vector()
			jump_check()
			apply_gravity(delta)
			move()
			
			if not is_hurt:
				wall_check()
				
			update_animations(input_vector)
			
		WALL_STATE:
			if animationPlayer.is_playing():
				animationPlayer.stop()
			if holding:
				sprite.frame = 39
			else:
				sprite.frame = 19
			
			var wall_axis = get_wall_axis()
			
			if wall_axis == 0:
				sprite.scale.x = 1
			else:
				sprite.scale.x = -wall_axis
				
			wall_cling_check(wall_axis)
			move()
			wall_detach_check(wall_axis, delta)
			
		JUMPING:
			jump_animating()

func save():
	var save_dictionary = {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"position_x": position.x,
		"position_y": position.y
	}
	return save_dictionary

func assign_camera():
	cameraFollow.remote_path = MainInstances.MainCamera.get_path()

func connect_signals():
	connect("hit_door", MainInstances.Main, "_on_Player_hit_door")
	connect("died", MainInstances.Main, "_on_Player_died")

func apply_gravity(delta):
	if is_on_floor(): return
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, JUMP_FORCE)
	if velocity.y > 0:
		is_jumping = false

func apply_friction(input_vector):
	if input_vector.x != 0: 
		idle = false
		return
	
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, FRICTION)
		idle = true
	else:
		velocity.x = lerp(velocity.x, 0, AIR_RESISTANCE)

func apply_horizontal_force(input_vector, delta):
	if just_boosted:
		MAX_SPEED = move_toward(MAX_SPEED, max_speed_backup, ACCELERATION * delta)
		
		if MAX_SPEED == max_speed_backup:
			just_boosted = false
		
	if input_vector.x != 0:
		if is_on_floor():
			velocity.x += ACCELERATION * input_vector.x * delta
		else:
			velocity.x += AIR_ACCELERATION * input_vector.x * delta
	
	if is_on_floor():
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	else:
		velocity.x = clamp(velocity.x, -AIR_MAX_SPEED, AIR_MAX_SPEED)

func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")
	return input_vector

func get_wall_axis():
	var is_wall_right = test_move(transform, Vector2.RIGHT)
	var is_wall_left = test_move(transform, Vector2.LEFT)
	return int(is_wall_right) - int(is_wall_left)

func jump(force = JUMP_FORCE):
	just_jumped = true
	is_jumping = true
	velocity.y = -force
	snap_vector = Vector2.ZERO

func jump_check():
	if is_on_floor():
		just_jumped = false
		
		if Input.is_action_just_pressed("jump"):
			state = JUMPING
			
		if landingJumpTimer.is_stopped(): return
		
		if Input.is_action_pressed("jump"): state = JUMPING
		else: state = JUMPING
		
		just_jumped = true
		
		return
		
	if not Input.is_action_just_pressed("jump"):
		if Input.is_action_just_released("jump") and velocity.y < -JUMP_FORCE/2:
			velocity.y = -JUMP_FORCE/2
			
		return
		
	if not coyoteTimer.is_stopped():
		if Input.is_action_just_pressed("jump"):
			jump(JUMP_FORCE)
			
	landingJumpTimer.start()

func update_snap_vector():
	if is_on_floor():
		snap_vector = Vector2.DOWN

func wall_check():
	if is_on_floor() and clingArea.monitoring == false:
		clingArea.monitoring = true
	
	if not is_on_floor() and clingArea.get_overlapping_bodies().size() > 0 and not is_jumping:
		state = WALL_STATE
		wallClingTimer.start()
		wallClingTimer.set_paused(true)

func wall_cling_check(wall_axis):
	
	if clingArea.get_overlapping_bodies().size() == 0:
		state = MOVE_STATE
		return
	
	if is_on_floor():
		state = MOVE_STATE
		return
	
	if Input.is_action_just_pressed("jump"):
		boost_off_wall(wall_axis)
		state = MOVE_STATE
		
	if Input.is_action_pressed("slide_faster"):
		slide_down_wall()
		return
	
	match wall_axis:
		1:
			if Input.is_action_pressed("walk_right") and not wallClingTimer.is_stopped():
				wallClingTimer.set_paused(false)
				velocity = Vector2.ZERO
			else:
				wallClingTimer.set_paused(true)
				slide_down_wall()
		-1:
			if Input.is_action_pressed("walk_left") and not wallClingTimer.is_stopped():
				wallClingTimer.set_paused(false)
				velocity = Vector2.ZERO
			else:
				wallClingTimer.set_paused(true)
				slide_down_wall()

func reset_wall_cling_timer():
	wallClingTimer.stop()
	wallClingTimer.wait_time = 3

func slide_down_wall():
	if Input.is_action_pressed("slide_faster"):
		velocity.y = ACCELERATED_WALL_SLIDE_SPEED
	else:
		velocity.y = WALL_SLIDE_SPEED

func boost_off_wall(wall_axis):
	just_boosted = true
	MAX_SPEED = WALL_BOOST_SPEED
	velocity.x = MAX_SPEED * -wall_axis
	jump(JUMP_FORCE/3)

func wall_detach_check(wall_axis, delta):
	if Input.is_action_just_pressed("jump"):
		boost_off_wall(wall_axis)
		state = MOVE_STATE
		
	match wall_axis:
		1:
			if Input.is_action_pressed("walk_left"):
				velocity.x = -ACCELERATION * delta
				state = MOVE_STATE
				clingArea.monitoring = false
		-1:
			if Input.is_action_pressed("walk_right"):
				velocity.x = ACCELERATION * delta
				state = MOVE_STATE
				clingArea.monitoring = false

func move():
	var was_on_floor = is_on_floor()
	var was_in_air = not is_on_floor()
	var last_velocity = velocity
	var last_position = position
	
	# Changed "Infinite inertia" parameter to false (default was true)
	velocity = (move_and_slide_with_snap(velocity, snap_vector * 4, Vector2.UP, 
	true, 4, deg2rad(MAX_SLOPE_ANGLE), false))
	
	# After moving and stuff, we can now apply forces to collided objects.
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_class("RigidBody2D"):
			
			var normal = Vector2(-collision.normal)
			
			#**DISABLED FOR NOW**
			# Check to see if the applied force is basically right or left
			# Round it to that, plus a slight upward lift...
			# This prevents weird floor jitter/rolling of cubes
#			if normal.angle_to(Vector2.RIGHT) < PI/16:
#				normal = Vector2.RIGHT
#			elif normal.angle_to_point(Vector2.LEFT) < PI/16:
#				normal = Vector2.LEFT
			
			collision.collider.apply_central_impulse(normal * INERTIA)
	
	# Just landed
	if was_in_air and is_on_floor():
		velocity.x = last_velocity.x
		is_jumping = false
	
	# Just left ground (and didn't jump)
	if was_on_floor and not is_on_floor() and not just_jumped: 
		coyoteTimer.start()
	
	# Prevents sliding down slopes
	if (is_on_floor() and 
	get_floor_velocity().length() == 0 and abs(velocity.x) < 1): 
		position.x = last_position.x


func update_animations(input_vector):
	
	if holding:
		flashlight.show()
	else:
		flashlight.hide()
		
	var current_anim = animationPlayer.current_animation
	
	if animationPlayer.is_playing() and (current_anim == "jump" or current_anim == "jump-holding"):
		return
	
	if input_vector.x != 0:
		if sprite.scale.x != sign(input_vector.x) and turnTimer.is_stopped():
			turning = true
			turn_to = sign(input_vector.x)
			turnTimer.start()
		elif sprite.scale.x == sign(input_vector.x) and turnTimer.time_left > 0:
			turnTimer.stop()
			turning = false
			
		if not turning:
			if holding:
				animationPlayer.play("run-holding")
			else:
				animationPlayer.play("run")
		else:
			if animationPlayer.is_playing():
				animationPlayer.stop()
			if holding:
				sprite.frame = 32
			else:
				sprite.frame = 12

	else:
		if holding:
				animationPlayer.play("idle-holding")
		else:
			animationPlayer.play("idle")
	
	if not is_on_floor():
		
		if animationPlayer.is_playing():
			animationPlayer.stop()
		
		if velocity.y > 0:
			if holding:
				sprite.frame = 37
			else:
				sprite.frame = 17
		else:
			if holding:
				sprite.frame = 38
			else:
				sprite.frame = 18

func jump_animating():
	
	var current_anim = animationPlayer.current_animation
	
	if not animationPlayer.is_playing() or not (current_anim == "jump" or current_anim == "jump-holding"):
		if holding:
			animationPlayer.play("jump-holding")
		else:
			animationPlayer.play("jump")
		jumpTimer.start()

func _on_TurnTimer_timeout():
	sprite.scale.x = turn_to
	turning = false

func _on_JumpTimer_timeout():
	jump(JUMP_FORCE)
	velocity.x = AIR_MAX_SPEED * sign(sprite.scale.x) * abs(velocity.x/MAX_SPEED)
	just_jumped = true
	state = MOVE_STATE
	move()

func die():
	emit_signal("died")
	queue_free()
