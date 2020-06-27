extends "res://ActionButtons/BaseActionButton.gd"


func _on_pressed():
	var playerStats = BattleUnits.PlayerStats
	if playerStats != null:
		playerStats.add_status(GameConstants.STATUS.SHIELDED)
		finish_turn()
