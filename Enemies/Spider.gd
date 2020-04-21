extends "res://Enemies/BaseEnemy.gd"

const RouletteBattleField = preload("res://BattleFields/EnemyBattleFields/RouletteBattleField.tscn")

const roulette_data = {
	0: {
		"sprite": preload("res://Images/Roulette/Hit1.png"),
		"id": "hit",
	},
	1: {
		"sprite": preload("res://Images/Roulette/HitPoison.png"),
		"id": "poison_hit",
	},
	2: {
		"sprite": preload("res://Images/Roulette/Hit2Poison.png"),
		"id": "poison_hit_double",
	},
	3: {
		"sprite": preload("res://Images/Roulette/Win.png"),
		"id": "win",
	}
}

var selected_face = 0

func get_selected_id():
	return roulette_data[selected_face]["id"]

func get_attack_pattern():
	var playerStats = BattleUnits.PlayerStats
	if playerStats.has_status(GameConstants.STATUS.POISON):
		return {
			"default_attack": 100,
		}
	else:
		return {
			"default_attack": 10,
			"bite_attack": 90,
		}

func bite_attack():
	DialogBox.show_timeout("SPIDER BITE!", 1)
	yield(DialogBox, "done")
	var faces = []
	for i in roulette_data:
		faces.append(roulette_data[i]["sprite"])
	var rouletteBattleField = RouletteBattleField.instance()
	rouletteBattleField.faces = faces
	rouletteBattleField.timer_speed = 0.15
	rouletteBattleField.connect("face_selected", self, "on_rouletteBattleField_face_selected")
	rouletteBattleField.connect("done", self, "on_rouletteBattleField_done")
	ActionBattle.start_small_field(rouletteBattleField)

func on_rouletteBattleField_face_selected(index, _texture):
	selected_face = index
	var selected_id = get_selected_id()
	match(selected_id):
		"poison_hit", "poison_hit_double": return attackAnimationPlayer.play("StatusAttack1")
		"hit", "win": return attackAnimationPlayer.play("Attack")

func on_player_wins():
	emit_signal("end_turn")

func on_rouletteBattleField_done():
	pass # We do other things according to the selection

func on_attack_animation_finished(_animation_name):
	emit_signal("end_turn")

func deal_damage(hit_force = null, _fixed_amount= null):
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		if selected_attack == "bite_attack":
			var selected_id = get_selected_id()
			match(selected_id):
				"poison_hit":
					.deal_damage(GameConstants.HIT_FORCE.STRONG)
					playerStats.add_status(GameConstants.STATUS.POISON)
				"poison_hit_double":
					.deal_damage(GameConstants.HIT_FORCE.CRIT, power)
					playerStats.add_status(GameConstants.STATUS.POISON)
				"hit":
					.deal_damage(GameConstants.HIT_FORCE.NORMAL)
				"win":
					.deal_damage(null, 0)
		else:
			.deal_damage(hit_force)
