extends Control

onready var buttonBlocker = $ButtonBlocker

func _on_NewGameButton_pressed():
	buttonBlocker.visible = true
	yield(get_tree().create_timer(0.1), "timeout")
# warning-ignore-all:return_value_discarded
	get_tree().change_scene("res://World/Main.tscn")

func _on_LoadGameButton_pressed():
	buttonBlocker.visible = true
	yield(get_tree().create_timer(0.1), "timeout")
	SaverAndLoader.is_loading = true
	get_tree().change_scene("res://World/Main.tscn")
	

func _on_SettingsButton_pressed():
	buttonBlocker.visible = true
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().change_scene("res://MenusAndUI/Menus/SettingsMenu.tscn")

func _on_QuitButton_pressed():
	buttonBlocker.visible = true
	yield(get_tree().create_timer(0.05), "timeout")
	get_tree().quit()
