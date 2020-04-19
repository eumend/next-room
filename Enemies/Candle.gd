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
	DialogBox.show_timeout("A wind blows!", 1)
	yield(DialogBox, "done")
	.take_damage(self.hp)
	emit_signal("end_turn")

func warm_light_attack():
	DialogBox.show_timeout("It emits a warm light...", 1)
	yield(DialogBox, "done")
	.heal_damage(1)
	emit_signal("end_turn")
