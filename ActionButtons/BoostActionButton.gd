extends "res://ActionButtons/BaseActionButton.gd"

signal hide_buttons

export var buff_duration = 3

func _on_pressed():
	var playerStats = BattleUnits.PlayerStats
	if playerStats != null:
		emit_signal("hide_buttons")
		# +1 because the turn it's cast on ticks it down without an attack
		playerStats.add_buff(GameConstants.STATUS.BOOST, buff_duration + 1)
		var text = "Power up for " + str(buff_duration) + " turns!"
		DialogBox.show_timeout(text, 1)
		yield(DialogBox, "done")
		finish_turn()

func pressed_sfx():
	$SFXBuff.play()
