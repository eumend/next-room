extends "res://Enemies/BaseEnemy.gd"

func get_attack_pattern():
	return {
		"voodoo_atack": 50,
		"idle_attack": 50,
	}

func voodoo_atack():
	var dialog = show_attack_text("It's arm is tearing a bit...")
	yield(dialog, "done")
	take_damage(self.power)
	emit_signal("end_turn")

func idle_attack():
	var dialog = show_attack_text("It's staring at you...")
	yield(dialog, "done")
	emit_signal("end_turn")

func take_damage(amount, hit_force = null):
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		playerStats.take_damage(amount, hit_force)
		.take_damage(amount, hit_force)
