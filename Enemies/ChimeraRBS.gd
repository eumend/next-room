extends "res://Enemies/BaseEnemy.gd"

func get_attack_pattern():
	var playerStats = BattleUnits.PlayerStats
	if turn_count < 2:
		return {
			"default_attack": 100,
		}
	elif not playerStats.has_status(GameConstants.STATUS.POISON):
		return {
			"poison_attack": 70,
			"default_attack": 30,
		}
	elif self.hp <= round(self.max_hp / 2):
		return {
			"leech_life": 60,
			"default_attack": 40,
		}
	else:
		return {
			"default_attack": 80,
			"leech_life": 20,
		}

func poison_attack():
	DialogBox.show_timeout("POISON ATTACK!", 0.5)
	animationPlayer.play("StatusAttack1")
	yield(animationPlayer, "animation_finished")
	emit_signal("end_turn")

func leech_life():
	DialogBox.show_timeout("LEECH LIFE!", 2)
	animationPlayer.play("StatusAttack1")
	yield(animationPlayer, "animation_finished")
	emit_signal("end_turn")

func deal_damage(hit_force = null, _fixed_amount= null):
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		if selected_attack == "poison_attack":
			var attack_power = max(ceil(power / 2), 1)
			.deal_damage(null, attack_power)
			playerStats.add_status(GameConstants.STATUS.POISON)
		elif selected_attack == "leech_life":
			var attack_power = max(ceil(power / 3), 3)
			.deal_damage(null, attack_power)
			.heal_damage(attack_power - 1)
		else:
			.deal_damage(hit_force)

func get_hit_force_pattern():
	return {
		GameConstants.HIT_FORCE.NORMAL: 50,
		GameConstants.HIT_FORCE.STRONG: 30,
		GameConstants.HIT_FORCE.CRIT: 20,
	}
