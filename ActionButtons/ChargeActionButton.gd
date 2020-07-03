extends "res://ActionButtons/BaseActionButton.gd"

signal charge

func _on_pressed():
	emit_signal("charge", 1)
	DialogBox.show_timeout("Charging for next turn!", 1)
	yield(DialogBox, "done")
	finish_turn()

func pressed_sfx():
	$SFXCharge.play()
