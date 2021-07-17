extends Node2D

onready var door = $Door
onready var doorCollision = $Door/CollisionShape2D
onready var button = $Button
onready var animationPlayer = $AnimationPlayer
onready var lightOccluder = $LightOccluder2D
onready var area = $Area2D

func _on_Button_button_pressed():
	
	print(area.get_overlapping_bodies().has(door))
	
	if animationPlayer.is_playing(): return
	
	var bodies = area.get_overlapping_bodies()
	
	if bodies.has(door):
		if bodies.size() > 1:
			return
	elif bodies.size() > 0:
		return
	
	if doorCollision.disabled:
		animationPlayer.play("close")
	else:
		animationPlayer.play("open")
