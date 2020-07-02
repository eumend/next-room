extends "res://Enemies/BaseEnemy.gd"

func get_attack_pattern():
	if self.hp <= round(self.max_hp / 3):
		return {
			"suicide_attack": 100,
		}
	else:
		return {
			"warm_light_attack": 100,
		}

func attack():
	if self.hp <= round(self.max_hp / 3):
		suicide_attack()
	else:
		.attack()

func suicide_attack():
	var dialog = show_attack_text("You can feel the wind blowing")
	yield(dialog, "done")
	.take_damage(self.hp)
	emit_signal("end_turn")

func warm_light_attack():
	var dialog = show_attack_text("It's emitting a warm light...")
	yield(dialog, "done")
	.heal_damage(1)
	emit_signal("end_turn")
