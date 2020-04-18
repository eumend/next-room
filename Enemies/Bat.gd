extends "res://Enemies/BaseEnemy.gd"

func get_attack_pattern():
	if self.hp < self.max_hp:
		return {
			"default_attack": 30,
			"leech_life": 70,
		}
	else:
		return {
			"default_attack": 90,
			"leech_life": 10,
		}

func leech_life():
	DialogBox.show_timeout("LEECH LIFE!", 2)
	animationPlayer.play("StatusAttack1")
	yield(animationPlayer, "animation_finished")
	emit_signal("end_turn")

func deal_damage(hit_force = null, _fixed_amount= null):
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		if selected_attack == "leech_life":
			var attack_power = max(ceil(power / 2), 1)
			.deal_damage(null, attack_power)
			.heal_damage(round(self.max_hp / 3))
		else:
			.deal_damage(hit_force)
