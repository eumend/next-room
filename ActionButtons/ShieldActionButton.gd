extends "res://ActionButtons/BaseActionButton.gd"


func _on_pressed():
	var playerStats = BattleUnits.PlayerStats
	if playerStats != null:
		# TODO: Use buffs instead of status, OR better logic so this doesnt trigger the same things as poison
		playerStats.add_status(GameConstants.STATUS.SHIELDED)
		playerStats.ap -= ap_cost
		playerStats.mp += 2
