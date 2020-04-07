extends Control

export (String, MULTILINE) var description = ""
const DialogBox = preload("res://DialogBox.tres")

func _on_HoverInfo_mouse_entered():
	DialogBox.show_text(description)


func _on_HoverInfo_mouse_exited():
	DialogBox.show_text(description)
