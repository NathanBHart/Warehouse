extends Area2D

func _on_SaveStation_body_entered(body):
	SaverAndLoader.save_game()
