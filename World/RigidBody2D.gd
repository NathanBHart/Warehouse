extends RigidBody2D

export var MOUSE_DETECTION_RADIUS = 20
export var SPEED = 50

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
			sleeping = true
			
			if (not mouse_detected_still or not Input.is_action_pressed("main_action") 
			or not MainInstances.Player.state == MainInstances.Player.IDLE_STATE):
				state = DO_NOT_MOVE
				
			var mouse_position = get_global_mouse_position()
			var direction = (mouse_position - position).normalized()
			
			if not (position.x > mouse_position.x - MOUSE_DETECTION_RADIUS 
			and position.x < mouse_position.x + MOUSE_DETECTION_RADIUS
			and position.y > mouse_position.y - MOUSE_DETECTION_RADIUS 
			and position.y < mouse_position.y + MOUSE_DETECTION_RADIUS):
				position += direction * delta * SPEED
		DO_NOT_MOVE:
			sleeping = false
			if (mouse_detected and Input.is_action_pressed("main_action") 
			and MainInstances.Player.state == MainInstances.Player.IDLE_STATE):
				state = MOVE

func _on_MouseDetectorLarge_mouse_entered():
	mouse_detected_still = true

func _on_MouseDetectorLarge_mouse_exited():
	mouse_detected_still = false

func _on_MouseDetectorSmall_mouse_entered():
	mouse_detected = true

func _on_MouseDetectorSmall_mouse_exited():
	mouse_detected = false
