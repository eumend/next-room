extends Resource
class_name DialogBox

var TextBox = null
var DialogTimer = null setget set_timer
var message_queue = []
var processing = false

signal done

func set_timer(new_timer):
	# A new text box panel took over (new scene), drop anything left from the old one
	message_queue = []
	processing = false
	DialogTimer = new_timer
	DialogTimer.connect("timeout", self, "on_Timer_timeout")

func is_ui_ready():
	return is_instance_valid(TextBox) and is_instance_valid(DialogTimer) and DialogTimer.is_inside_tree()

func show_text(text):
	if is_ui_ready():
		reset_queue()
		TextBox.text = text

func show_timeout(text, time_seconds = 1, overrun = false):
	show_timeouts([[text, time_seconds]], overrun)

func show_timeouts(timeout_list, overrun = false):
	if overrun:
		reset_queue()
	message_queue += timeout_list
	process_queue()

func process_queue():
	if not processing and message_queue.size() > 0:
		processing = true
		var next = message_queue.pop_front()
		_show_text(next[0], next[1])

func reset_queue():
	if message_queue.size() > 0:
		message_queue = []
	processing = false
	if is_instance_valid(DialogTimer):
		DialogTimer.stop()

func _show_text(text, time_seconds):
	if is_ui_ready():
		# Process timed text, might have more types in the future
		TextBox.text = text
		DialogTimer.wait_time = time_seconds
		DialogTimer.start()
	else:
		# Nowhere to show it: don't leave callers waiting on "done" forever
		message_queue = []
		processing = false
		call_deferred("emit_signal", "done")

func on_Timer_timeout():
	if is_instance_valid(TextBox):
		TextBox.text = ""
	# Handle queue recursion
	if message_queue.size() > 0:
		var next = message_queue.pop_front()
		_show_text(next[0], next[1])
	else:
		# Go idle before notifying, so "done" listeners can queue new text
		processing = false
		emit_signal("done")
