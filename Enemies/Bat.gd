extends "res://Enemies/BaseEnemy.gd"

func _init():
	attack_pattern = {
		"default_attack": 25,
		"poison_attack": 75,
	}

func poison_attack():
	animationPlayer.play("StatusAttack1")
	yield(animationPlayer, "animation_finished")
	emit_signal("end_turn")

func deal_damage(hit_force = null):
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		if selected_attack == "poison_attack":
			$SFXBlow.play()
			var attack_power = max(ceil(power / 2), 1)
			playerStats.take_damage(attack_power)
			playerStats.add_status(GameConstants.STATUS.POISON)
		else:
			.deal_damage(hit_force)
