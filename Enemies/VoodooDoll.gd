extends "res://Enemies/BaseEnemy.gd"

func get_attack_pattern():
	return {
		"voodoo_atack": 50,
		"idle_attack": 50,
	}

func voodoo_atack():
	DialogBox.show_timeout("It's arm is tearing a bit...", 1.5)
	yield(DialogBox, "done")
	take_damage(self.power)
	emit_signal("end_turn")

func idle_attack():
	DialogBox.show_timeout("It's staring at you...", 1.5)
	yield(DialogBox, "done")
	emit_signal("end_turn")

func take_damage(amount, hit_force = null):
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		playerStats.take_damage(amount, hit_force)
		.take_damage(amount, hit_force)
