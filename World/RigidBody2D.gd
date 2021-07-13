extends RigidBody2D

export var MOUSE_DETECTION_RADIUS = 20
export var SPEED = 500

var mouse_detected_still = false
var mouse_detected = false

var MainInstances = ResourceLoader.MainInstances

enum {
	MOVE,
	DO_NOT_MOVE
}

var state = DO_NOT_MOVE

func _physics_process(delta):
	match state:
		MOVE:
			
			var distance_scale_factor = position.distance_to(MainInstances.Player.position)/500
			
			gravity_scale = distance_scale_factor
			
			if (not Input.is_action_pressed("main_action") or not MainInstances.Player.idle):
				state = DO_NOT_MOVE
				
			var mouse_position = get_global_mouse_position()
			var direction = (mouse_position - position).normalized()
			
			apply_central_impulse(direction * delta * SPEED)
				
		DO_NOT_MOVE:
			
			gravity_scale = 1
			
			if (mouse_detected and Input.is_action_pressed("main_action") and MainInstances.Player.idle):
				state = MOVE

func _on_MouseDetectorLarge_mouse_entered():
	mouse_detected_still = true

func _on_MouseDetectorLarge_mouse_exited():
	mouse_detected_still = false

func _on_MouseDetectorSmall_mouse_entered():
	mouse_detected = true

func _on_MouseDetectorSmall_mouse_exited():
	mouse_detected = false
