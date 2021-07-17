extends NinePatchRect

onready var textureRect = $MarginContainer/HBoxContainer/TextureRect
onready var richTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/RichTextLabel
onready var marginContainer = $MarginContainer/HBoxContainer
onready var label = $MarginContainer/HBoxContainer/VBoxContainer/Label

var current_page_index = null
var pages = []

func _process(_delta):
	if not self.visible: return
	
	rect_size.y = marginContainer.rect_size.y + 4
	
	if Input.is_action_just_pressed("next"):
		if current_page_index == len(pages) - 1:
			self.visible = false
			current_page_index = null
			pages = []
		else:
			current_page_index += 1
			richTextLabel.text = pages[current_page_index]
			if current_page_index == len(pages) - 1:
				label.text = "Press enter to exit"
			else:
				label.text = "Press enter to continue"

func create_dialog(text, texture_path = null):
	pages = text.split("|")
	if texture_path != null:
		
		var new_texture = load(texture_path.get_path())
		textureRect.texture = new_texture
		textureRect.rect_size = Vector2(40, 40)
		
	richTextLabel.text = pages[0]
	current_page_index = 0
	if len(pages) == 0:
		label.text = "Press enter to exit"
	else:
		label.text = "Press enter to continue"
	visible = true
