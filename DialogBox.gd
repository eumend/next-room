extends Resource
class_name DialogBox

var TextBox = null
signal done
signal _done

func show_text(text):
	if TextBox:
		TextBox.text = text

func show_timeout(text, time_seconds = 1):
	if TextBox:
		if typeof(text) == TYPE_ARRAY:
			for t in text:
				_show_timeout(t[0], t[1])
				yield(self, "_done")
			emit_signal("done")
		else:
			_show_timeout(text, time_seconds)
			emit_signal("done")

func _show_timeout(text, time_seconds):
	if TextBox:
		TextBox.text = text
		yield(TextBox.get_tree().create_timer(time_seconds), "timeout")
		TextBox.text = ""
		emit_signal("_done")
