extends "res://Enemies/BaseEnemy.gd"

func get_attack_pattern():
	if self.hp < round(self.max_hp / 2):
		return {
			"default_attack": 30,
			"regenerate_attack": 70,
		}
	else:
		return {
			"default_attack": 100,
		}

func regenerate_attack():
	var dialog = show_attack_text("**Slacks off**")
	yield(dialog, "done")
	.heal_damage(round(self.max_hp / 4))
	emit_signal("end_turn")
