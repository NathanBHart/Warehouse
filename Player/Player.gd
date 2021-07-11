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
export var ACCELERATED_WALL_SLIDE_SPEED = 60
export var WALL_BOOST_SPEED = 140

# Vectors
var velocity = Vector2.ZERO
var snap_vector = Vector2.ZERO

# Platforming Booleans
var just_jumped = false
var is_jumping = false
var just_boosted = false

# Timers
onready var coyoteTimer = $CoyoteTimer
onready var landingJumpTimer = $LandingJumpTimer
onready var wallClingTimer = $WallClingTimer

# Other Variables Created Onready
onready var max_speed_backup = MAX_SPEED

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
	if just_boosted:
		MAX_SPEED = move_toward(MAX_SPEED, max_speed_backup, ACCELERATION * delta)
		
		if MAX_SPEED == max_speed_backup:
			just_boosted = false
		
	if input_vector.x != 0:
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
	
	if Input.is_action_just_pressed("jump"):
		boost_of_wall(wall_axis)
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

func boost_of_wall(wall_axis):
	just_boosted = true
	MAX_SPEED = WALL_BOOST_SPEED
	velocity.x = MAX_SPEED * -wall_axis
	jump(JUMP_FORCE/3)

func wall_detach_check(wall_axis, delta):
	if Input.is_action_just_pressed("jump"):
		boost_of_wall(wall_axis)
		state = MOVE_STATE
		
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
	
	velocity = (move_and_slide_with_snap(velocity, snap_vector * 4, Vector2.UP, 
	true, 4, deg2rad(MAX_SLOPE_ANGLE)))
	
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
