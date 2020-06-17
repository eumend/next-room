extends "res://Enemies/BaseEnemy.gd"

const RouletteBattleField = preload("res://BattleFields/EnemyBattleFields/RouletteBattleField.tscn")
const HitSprite = preload("res://Images/Roulette/Hit1.png")
const PoisonHitSprite = preload("res://Images/Roulette/HitPoison.png")
const WinSprite = preload("res://Images/Roulette/Win.png")
const PoisonHitDoubleSprite = preload("res://Images/Roulette/Hit2Poison.png")

enum ROULETTE_FACES{HIT, POISON_HIT, POISON_HIT_DOUBLE, WIN}

const roulettes = [
	[
		{
			"sprite": HitSprite,
			"id": ROULETTE_FACES.HIT
		},
		{
			"sprite": PoisonHitSprite,
			"id": ROULETTE_FACES.POISON_HIT
		},
		{
			"sprite": WinSprite,
			"id": ROULETTE_FACES.WIN,
			"type": "good",
		},
		{
			"sprite": PoisonHitDoubleSprite,
			"id": ROULETTE_FACES.POISON_HIT_DOUBLE,
			"type": "bad"
		}
	],
	[
		{
			"sprite": HitSprite,
			"id": ROULETTE_FACES.HIT
		},
		{
			"sprite": PoisonHitSprite,
			"id": ROULETTE_FACES.POISON_HIT
		},
		{
			"sprite": WinSprite,
			"id": ROULETTE_FACES.WIN,
			"type": "good"
		},
		{
			"sprite": PoisonHitDoubleSprite,
			"id": ROULETTE_FACES.POISON_HIT_DOUBLE,
			"type": "bad"
		}
	]
]
var current_roulette_index = 0
var selected_roulette_index = 0
var rouletteBattleField = null

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
	rouletteBattleField = RouletteBattleField.instance()
	rouletteBattleField.connect("face_selected", self, "on_rouletteBattleField_face_selected")
	ActionBattle.start_small_field(rouletteBattleField)
	current_roulette_index = 0
	start_roulette(current_roulette_index)

func start_roulette(roulette_index):
	var roulette_speed = 0.09 + (0.01 * roulette_index) # A bit slower as we go up
	var roulette_data = roulettes[roulette_index]
	rouletteBattleField.start_roulette(roulette_data, roulette_speed)

func on_rouletteBattleField_face_selected(index):
	selected_roulette_index = index
	var current_roulette = roulettes[current_roulette_index]
	var selected_id = current_roulette[selected_roulette_index]["id"]
	match(selected_id):
		ROULETTE_FACES.POISON_HIT, ROULETTE_FACES.POISON_HIT_DOUBLE: return attackAnimationPlayer.play("StatusAttack1")
		ROULETTE_FACES.HIT, ROULETTE_FACES.WIN: return attackAnimationPlayer.play("Attack")

func on_attack_animation_finished(_animation_name):
	var playerStats = BattleUnits.PlayerStats
	if playerStats and not playerStats.is_dead():
		if current_roulette_index < roulettes.size() - 1:
			current_roulette_index += 1
			start_roulette(current_roulette_index)
		else:
			rouletteBattleField.done()
			emit_signal("end_turn")

func deal_damage(hit_force = null, _fixed_amount = null):
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		if selected_attack == "bite_attack":
			var current_roulette = roulettes[current_roulette_index]
			var selected_id = current_roulette[selected_roulette_index]["id"]
			match(selected_id):
				ROULETTE_FACES.POISON_HIT:
					.deal_damage(GameConstants.HIT_FORCE.STRONG)
					playerStats.add_status(GameConstants.STATUS.POISON)
				ROULETTE_FACES.POISON_HIT_DOUBLE:
					.deal_damage(GameConstants.HIT_FORCE.CRIT, power)
					playerStats.add_status(GameConstants.STATUS.POISON)
				ROULETTE_FACES.HIT:
					.deal_damage(GameConstants.HIT_FORCE.NORMAL)
				ROULETTE_FACES.WIN:
					.deal_damage(null, 0)
		else:
			.deal_damage(hit_force)
