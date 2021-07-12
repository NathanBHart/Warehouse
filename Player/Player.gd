extends KinematicBody2D

# Export Constants
export var MAX_SLOPE_ANGLE = 46
export var JUMP_FORCE = 100
export var GRAVITY = 225
export var FRICTION = 0.25
export var AIR_RESISTANCE = 0.02
export var ACCELERATION = 500
export var AIR_ACCELERATION = 200
export var MAX_SPEED = 70
export var WALL_SLIDE_SPEED = 30
export var ACCELERATED_WALL_SLIDE_SPEED = 50

# Added force of Inertia
export var INERTIA = 25

# Vectors
var velocity = Vector2.ZERO
var snap_vector = Vector2.ZERO

# Platforming Booleans
var just_jumped = false
var is_jumping = false

# Timers
onready var coyoteTimer = $CoyoteTimer
onready var landingJumpTimer = $LandingJumpTimer
onready var wallClingTimer = $WallClingTimer

# States
enum {
	MOVE_STATE,
	WALL_STATE
}

var state = MOVE_STATE

func _physics_process(delta):
	match state:
		MOVE_STATE:
			var input_vector = get_input_vector()
			reset_wall_cling_timer()
			apply_horizontal_force(input_vector, delta)
			apply_friction(input_vector)
			update_snap_vector()
			jump_check()
			apply_gravity(delta)
			move()
			wall_check()
		WALL_STATE:
			var wall_axis = get_wall_axis()
			wall_cling_check(wall_axis)
			move()
			wall_detach_check(wall_axis, delta)
			
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func apply_gravity(delta):
	if is_on_floor(): return
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, JUMP_FORCE)
	if velocity.y > 0:
		is_jumping = false

func apply_friction(input_vector):
	if input_vector.x != 0: return
	
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, FRICTION)
	else:
		velocity.x = lerp(velocity.x, 0, AIR_RESISTANCE)

func apply_horizontal_force(input_vector, delta):
	if input_vector.x == 0: return
	
	if is_on_floor():
		velocity.x += ACCELERATION * input_vector.x * delta
	else:
		velocity.x += AIR_ACCELERATION * input_vector.x * delta
		
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		

func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")
	return input_vector

func get_wall_axis():
	var is_wall_right = test_move(transform, Vector2.RIGHT)
	var is_wall_left = test_move(transform, Vector2.LEFT)
	return int(is_wall_right) - int(is_wall_left)

func jump(force):
	is_jumping = true
	velocity.y = -force
	snap_vector = Vector2.ZERO

func jump_check():
	if is_on_floor():
		just_jumped = false
		
		if Input.is_action_just_pressed("jump"):
			jump(JUMP_FORCE)
			just_jumped = true
			
		if landingJumpTimer.is_stopped(): return
		
		if Input.is_action_pressed("jump"): jump(JUMP_FORCE)
		else: jump(JUMP_FORCE/2)
		
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
	if not is_on_floor() and is_on_wall() and not is_jumping:
		state = WALL_STATE
		wallClingTimer.start()
		wallClingTimer.set_paused(true)

func wall_cling_check(wall_axis):
	if is_on_floor():
		state = MOVE_STATE
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

func wall_detach_check(wall_axis, delta):
	match wall_axis:
		1:
			if Input.is_action_pressed("walk_left"):
				velocity.x = -ACCELERATION * delta
				state = MOVE_STATE
		-1:
			if Input.is_action_pressed("walk_right"):
				velocity.x = ACCELERATION * delta
				state = MOVE_STATE

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
