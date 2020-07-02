extends Panel

const DialogBox = preload("res://DialogBox.tres")

func _ready():
	DialogBox.TextBox = $TextBox
	DialogBox.Timer = $Timer
