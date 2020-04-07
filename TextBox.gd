extends RichTextLabel

const DialogBox = preload("res://DialogBox.tres")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	DialogBox.TextBox = self
