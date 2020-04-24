extends "res://Enemies/BaseEnemy.gd"

const RouletteBattleField = preload("res://BattleFields/EnemyBattleFields/RouletteBattleField.tscn")
const HitSprite = preload("res://Images/Roulette/Hit1.png")
const PoisonHitSprite = preload("res://Images/Roulette/HitPoison.png")
const WinSprite = preload("res://Images/Roulette/Win.png")
const PoisonHitDoubleSprite = preload("res://Images/Roulette/Hit2Poison.png")

enum FACES{HIT, POISON_HIT, POISON_HIT_DOUBLE, WIN}

const roulettes = [
	[
		{
			"sprite": HitSprite,
			"id": FACES.HIT
		},
		{
			"sprite": PoisonHitSprite,
			"id": FACES.POISON_HIT
		},
		{
			"sprite": WinSprite,
			"id": FACES.WIN
		},
		{
			"sprite": PoisonHitDoubleSprite,
			"id": FACES.POISON_HIT_DOUBLE
		}
	],
	[
		{
			"sprite": HitSprite,
			"id": FACES.HIT
		},
		{
			"sprite": PoisonHitSprite,
			"id": FACES.POISON_HIT
		},
		{
			"sprite": WinSprite,
			"id": FACES.WIN
		},
		{
			"sprite": PoisonHitDoubleSprite,
			"id": FACES.POISON_HIT_DOUBLE
		}
	]
]
var current_roulette_index = 0
var selected_index = 0
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
	var faces = []
	for option in roulette_data:
		faces.append(option["sprite"])
	rouletteBattleField.start_roulette(faces, roulette_speed)

func on_rouletteBattleField_face_selected(index, _texture):
	selected_index = index
	var current_roulette = roulettes[current_roulette_index]
	var selected_id = current_roulette[selected_index]["id"]
	match(selected_id):
		FACES.POISON_HIT, FACES.POISON_HIT_DOUBLE: return attackAnimationPlayer.play("StatusAttack1")
		FACES.HIT, FACES.WIN: return attackAnimationPlayer.play("Attack")

func on_rouletteBattleField_face_displayed(_index, _texture):
	pass

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
			var selected_id = current_roulette[selected_index]["id"]
			match(selected_id):
				FACES.POISON_HIT:
					.deal_damage(GameConstants.HIT_FORCE.STRONG)
					playerStats.add_status(GameConstants.STATUS.POISON)
				FACES.POISON_HIT_DOUBLE:
					.deal_damage(GameConstants.HIT_FORCE.CRIT, power)
					playerStats.add_status(GameConstants.STATUS.POISON)
				FACES.HIT:
					.deal_damage(GameConstants.HIT_FORCE.NORMAL)
				FACES.WIN:
					.deal_damage(null, 0)
		else:
			.deal_damage(hit_force)
