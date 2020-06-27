extends "res://Enemies/BaseEnemy.gd"

const RouletteBattleField = preload("res://BattleFields/Enemy/RouletteBattleField.tscn")
const HitSprite = preload("res://Images/BattleFields/Roulette/Hit1.png")
const HitDoubleSprite = preload("res://Images/BattleFields/Roulette/Hit2.png")
const HitTripleSprite = preload("res://Images/BattleFields/Roulette/Hit3.png")
const PowerUpSprite = preload("res://Images/BattleFields/Roulette/PowerUp.png")
const DrainLifeSprite = preload("res://Images/BattleFields/Roulette/DrainLife.png")
const SurpriseSprite = preload("res://Images/BattleFields/Roulette/Surprise.png")
const WinSprite = preload("res://Images/BattleFields/Roulette/Win.png")

enum ROULETTE_FACES{HIT, HIT_STRONG, HIT_CRIT, POWER_UP, DRAIN_LIFE, SURPRISE, WIN}

const roulettes = [
	[
		{
			"sprite": HitSprite,
			"id": ROULETTE_FACES.HIT
		},
		{
			"sprite": HitDoubleSprite,
			"id": ROULETTE_FACES.HIT_STRONG
		},
		{
			"sprite": HitTripleSprite,
			"id": ROULETTE_FACES.HIT_CRIT
		},
	],
	[
		{
			"sprite": PowerUpSprite,
			"id": ROULETTE_FACES.POWER_UP
		},
		{
			"sprite": SurpriseSprite,
			"id": ROULETTE_FACES.SURPRISE,
			"type": "bad"
		},
		{
			"sprite": DrainLifeSprite,
			"id": ROULETTE_FACES.DRAIN_LIFE
		},
		{
			"sprite": WinSprite,
			"id": ROULETTE_FACES.WIN,
			"type": "good"
		}
	]
]
var current_roulette_index = 0
var selected_index = 0
var roulette_selections = []
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
			"roulette_attack": 90,
		}
#
func roulette_attack():
	DialogBox.show_timeout("GHOST TRICK!", 1)
	yield(DialogBox, "done")
	rouletteBattleField = RouletteBattleField.instance()
	rouletteBattleField.connect("face_selected", self, "on_rouletteBattleField_face_selected")
	rouletteBattleField.connect("face_displayed", self, "on_rouletteBattleField_face_displayed")
	ActionBattle.start_small_field(rouletteBattleField)
	current_roulette_index = 0
	roulette_selections = []
	start_roulette(current_roulette_index)
#
func start_roulette(roulette_index):
	var roulette_speed = 0.1 + (0.05 * roulette_index) # A bit slower as we go up
	var roulette_data = roulettes[roulette_index]
	rouletteBattleField.start_roulette(roulette_data, roulette_speed)
#
func on_rouletteBattleField_face_selected(index):
	roulette_selections.append(index)
#
func on_rouletteBattleField_face_displayed(_index):
	if current_roulette_index < roulettes.size() - 1:
		current_roulette_index += 1
		start_roulette(current_roulette_index)
	else:
		rouletteBattleField.done()
		attackAnimationPlayer.play("StatusAttack1")

func on_attack_animation_finished(_animation_name):
	emit_signal("end_turn")

func deal_damage(hit_force = null, _fixed_amount= null):
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		if selected_attack == "roulette_attack":
			var first_id = roulettes[0][roulette_selections[0]]["id"]
			var second_id = roulettes[1][roulette_selections[1]]["id"]
			var roulette_hit_force = null
			# First id
			if first_id == ROULETTE_FACES.HIT:
				roulette_hit_force =  GameConstants.HIT_FORCE.NORMAL
			elif first_id == ROULETTE_FACES.HIT_STRONG:
				roulette_hit_force =  GameConstants.HIT_FORCE.STRONG
			elif first_id == ROULETTE_FACES.HIT_CRIT:
				roulette_hit_force =  GameConstants.HIT_FORCE.CRIT
			var damage_amount = get_attack_damage_amount(self.power, roulette_hit_force)
			# Second id
			match(second_id):
				ROULETTE_FACES.POWER_UP:
					.deal_damage(null, ceil(damage_amount * 1.5))
				ROULETTE_FACES.DRAIN_LIFE:
					.deal_damage(roulette_hit_force, damage_amount)
					.heal_damage(damage_amount)
				ROULETTE_FACES.SURPRISE:
					.deal_damage(null, playerStats.hp - 1)
				ROULETTE_FACES.WIN:
					.deal_damage(roulette_hit_force)
		else:
			.deal_damage(hit_force)
