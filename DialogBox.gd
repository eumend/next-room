extends Resource
class_name DialogBox

var TextBox = null

func show_text(text):
	if TextBox:
		TextBox.text = text
