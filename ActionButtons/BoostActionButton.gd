extends "res://ActionButtons/BaseActionButton.gd"

signal hide_buttons

func _on_pressed():
	var playerStats = BattleUnits.PlayerStats
	if playerStats != null:
		emit_signal("hide_buttons")
		playerStats.add_buff(GameConstants.STATUS.BOOST, 3)
		DialogBox.show_timeout("Power up!!!", 1)
		yield(DialogBox, "done")
		finish_turn()
