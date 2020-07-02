extends Resource
class_name DialogBox

var TextBox = null
var Timer = null setget set_timer
var message_queue = []
var processing = false

signal done

func set_timer(new_timer):
	Timer = new_timer
	Timer.connect("timeout", self, "on_Timer_timeout")

func show_text(text):
	if TextBox:
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
	if Timer:
		Timer.stop()

func _show_text(text, time_seconds):
	if TextBox and Timer:
		# Process timed text, might have more types in the future
		TextBox.text = text
		Timer.wait_time = time_seconds
		Timer.start()
		
func on_Timer_timeout():
	TextBox.text = ""
	# Handle queue recursion
	if message_queue.size() > 0:
		var next = message_queue.pop_front()
		_show_text(next[0], next[1])
	else:
		emit_signal("done")
		reset_queue()
