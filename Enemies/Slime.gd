extends "res://Enemies/BaseEnemy.gd"

func get_attack_pattern():
	var playerStats = BattleUnits.PlayerStats
	if playerStats.has_status(GameConstants.STATUS.POISON):
		return {
			"default_attack": 100,
		}
	else:
		return {
			"default_attack": 10,
			"poison_attack": 90,
		}

func poison_attack():
	DialogBox.show_timeout("POISON ATTACK!", 0.5)
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
		else:
			.deal_damage(hit_force)
