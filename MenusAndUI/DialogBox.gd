extends NinePatchRect

onready var textureRect = $MarginContainer/HBoxContainer/TextureRect
onready var richTextLabel = $MarginContainer/HBoxContainer/RichTextLabel
onready var marginContainer = $MarginContainer/HBoxContainer

func create_dialog(text, texture_path = null):
	if texture_path != null:
		textureRect.texture = load(texture_path.get_path())
	richTextLabel.text = text
	rect_size.y = marginContainer.rect_size.y + 4
	visible = true

func _input(_event):
	if not self.visible: return
	
	if Input.is_action_just_pressed("next"):
		self.visible = false
