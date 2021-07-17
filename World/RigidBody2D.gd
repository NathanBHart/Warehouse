extends RigidBody2D

export var MOUSE_DETECTION_RADIUS = 20
export var SPEED = 500

onready var pivot = $Pivot
onready var floorDetector = $Pivot/FloorDetector

var mouse_detected_still = false
var mouse_detected = false


var MainInstances = ResourceLoader.MainInstances

enum {
	MOVE,
	DO_NOT_MOVE
}

var state = DO_NOT_MOVE

func _physics_process(delta):
	
	pivot.global_rotation = 0
	
	match state:
		MOVE:
			
			set_collision_mask_bit(4, false)
			
			if MainInstances.Player == null:
				state = DO_NOT_MOVE
				return
				
			var distance_scale_factor = Vector2.ZERO
			distance_scale_factor = position.distance_to(MainInstances.Player.position)/(SPEED*2)
			
			gravity_scale = distance_scale_factor
			
			if (not Input.is_action_pressed("use") or not MainInstances.Player.idle):
				state = DO_NOT_MOVE
				
			var mouse_position = get_global_mouse_position()
			var direction = (mouse_position - global_position).normalized()
			
			apply_central_impulse(direction * delta * SPEED)
				
		DO_NOT_MOVE:
			
			if on_floor():
				set_collision_mask_bit(4, true)
			
			gravity_scale = 1
			
			if MainInstances.Player == null: return
			
			if (mouse_detected and Input.is_action_pressed("use") and MainInstances.Player.idle):
				state = MOVE

func _on_MouseDetectorLarge_mouse_entered():
	mouse_detected_still = true

func _on_MouseDetectorLarge_mouse_exited():
	mouse_detected_still = false

func _on_MouseDetectorSmall_mouse_entered():
	mouse_detected = true

func _on_MouseDetectorSmall_mouse_exited():
	mouse_detected = false


func on_floor():
	return floorDetector.get_overlapping_bodies().size() > 0
		
