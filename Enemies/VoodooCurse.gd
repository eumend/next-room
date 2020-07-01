extends "res://Enemies/BaseEnemy.gd"

const RouletteBattleField = preload("res://BattleFields/Enemy/RouletteBattleField.tscn")
const HitSprite = preload("res://Images/BattleFields/Roulette/Hit1.png")
const HitDoubleSprite = preload("res://Images/BattleFields/Roulette/Hit2.png")
const HitTripleSprite = preload("res://Images/BattleFields/Roulette/Hit3.png")
const PoisonHitSprite = preload("res://Images/BattleFields/Roulette/HitPoison.png")
const PoisonHitDoubleSprite = preload("res://Images/BattleFields/Roulette/Hit2Poison.png")
const PoisonHitTripleSprite = preload("res://Images/BattleFields/Roulette/Hit3Poison.png")
const PowerUpSprite = preload("res://Images/BattleFields/Roulette/PowerUp.png")
const DrainLifeSprite = preload("res://Images/BattleFields/Roulette/DrainLife.png")
const SurpriseSprite = preload("res://Images/BattleFields/Roulette/Surprise.png")
const WinSprite = preload("res://Images/BattleFields/Roulette/Win.png")

enum FACES{HIT, HIT_STRONG, HIT_CRIT, HIT_POISON, HIT_POISON_2, HIT_POISON_3, POWER_UP, DRAIN_LIFE, SURPRISE, WIN}

const triple_attack_roulettes = [
	[
		{
			"sprite": HitSprite,
			"id": FACES.HIT
		},
		{
			"sprite": HitDoubleSprite,
			"id": FACES.HIT_STRONG
		},
		{
			"sprite": HitTripleSprite,
			"id": FACES.HIT_CRIT
		},
		{
			"sprite": WinSprite,
			"id": FACES.WIN
		},
	],
	[
		{
			"sprite": HitSprite,
			"id": FACES.HIT
		},
		{
			"sprite": PoisonHitSprite,
			"id": FACES.HIT_POISON
		},
		{
			"sprite": HitDoubleSprite,
			"id": FACES.HIT_STRONG
		},
		{
			"sprite": PoisonHitDoubleSprite,
			"id": FACES.HIT_POISON_2
		},
		{
			"sprite": HitTripleSprite,
			"id": FACES.HIT_CRIT,
			"type": "bad"
		},
		{
			"sprite": PoisonHitTripleSprite,
			"id": FACES.HIT_POISON_3,
			"type": "bad"
		},
		{
			"sprite": WinSprite,
			"id": FACES.WIN,
			"type": "good"
		},
	],
	[
		{
			"sprite": HitDoubleSprite,
			"id": FACES.HIT_STRONG
		},
		{
			"sprite": PoisonHitDoubleSprite,
			"id": FACES.HIT_POISON_2
		},
		{
			"sprite": HitTripleSprite,
			"id": FACES.HIT_CRIT
		},
		{
			"sprite": PoisonHitTripleSprite,
			"id": FACES.HIT_POISON_3
		},
		{
			"sprite": HitDoubleSprite,
			"id": FACES.HIT_STRONG
		},
		{
			"sprite": PoisonHitDoubleSprite,
			"id": FACES.HIT_POISON_2
		},
		{
			"sprite": HitTripleSprite,
			"id": FACES.HIT_CRIT,
			"type": "bad"
		},
		{
			"sprite": PoisonHitTripleSprite,
			"id": FACES.HIT_POISON_3,
			"type": "bad"
		},
		{
			"sprite": WinSprite,
			"id": FACES.WIN,
			"type": "good"
		},
	],
]

const secondary_attack_roulettes = [
	[
		{
			"sprite": HitSprite,
			"id": FACES.HIT
		},
		{
			"sprite": HitDoubleSprite,
			"id": FACES.HIT_STRONG
		},
		{
			"sprite": HitTripleSprite,
			"id": FACES.HIT_CRIT,
			"type": "bad"
		},
	],
	[
		{
			"sprite": PowerUpSprite,
			"id": FACES.POWER_UP
		},
		{
			"sprite": DrainLifeSprite,
			"id": FACES.DRAIN_LIFE
		},
		{
			"sprite": SurpriseSprite,
			"id": FACES.SURPRISE,
			"type": "bad"
		},
		{
			"sprite": PowerUpSprite,
			"id": FACES.POWER_UP
		},
		{
			"sprite": DrainLifeSprite,
			"id": FACES.DRAIN_LIFE
		},
		{
			"sprite": WinSprite,
			"id": FACES.WIN,
			"type": "good"
		},
	],
]

var on_voodoo = false
var current_roulette_index = 0
var selected_index = 0
var selections = []
var rouletteBattleField = null

func get_attack_pattern():
	var playerStats = BattleUnits.PlayerStats
	if self.hp <= round(self.max_hp / 3):
		return {
			"voodoo_atack": 65,
			"triple_hit_roulette_attack": 35,
		}
	elif not playerStats.has_status(GameConstants.STATUS.POISON):
		return {
			"triple_hit_roulette_attack": 75,
			"secondary_effect_roulette_attack": 25,
		}
	else:
		return {
			"secondary_effect_roulette_attack": 40,
			"triple_hit_roulette_attack": 30,
			"default_attack": 30,
		}

func on_start_turn():
	on_voodoo = false
	.on_start_turn()

func voodoo_atack():
	DialogBox.show_timeout("It's stares at you with a grudge... be careful!", 1.5)
	yield(DialogBox, "done")
	on_voodoo = true
	emit_signal("end_turn")

func take_damage(amount, hit_force = null):
	if on_voodoo:
		var playerStats = BattleUnits.PlayerStats
		if playerStats:
			playerStats.take_damage(amount, hit_force)
	.take_damage(amount, hit_force)

func triple_hit_roulette_attack():
	DialogBox.show_timeout("...", 1)
	yield(DialogBox, "done")
	rouletteBattleField = RouletteBattleField.instance()
	rouletteBattleField.connect("face_selected", self, "on_tripleRouletteBattleField_face_selected")
	ActionBattle.start_small_field(rouletteBattleField)
	current_roulette_index = 0
	start_triple_roulette(current_roulette_index)

func start_triple_roulette(roulette_index):
	var roulette_speed = 0.12 - (0.01 * roulette_index) # Faster as we go up
	var roulette_data = triple_attack_roulettes[roulette_index]
	rouletteBattleField.start_roulette(roulette_data, roulette_speed)

func on_tripleRouletteBattleField_face_selected(index):
	selected_index = index
	var current_roulette_data = triple_attack_roulettes[current_roulette_index]
	var selected_id = current_roulette_data[selected_index]["id"]
	match(selected_id):
		FACES.HIT_POISON, FACES.HIT_POISON_2, FACES.HIT_POISON_3: return attackAnimationPlayer.play("StatusAttack1")
		FACES.HIT, FACES.HIT_STRONG, FACES.HIT_CRIT, FACES.WIN: return attackAnimationPlayer.play("Attack")

func on_attack_animation_finished(_animation_name):
	var playerStats = BattleUnits.PlayerStats
	if playerStats and not playerStats.is_dead():
		if selected_attack == "triple_hit_roulette_attack":
			if current_roulette_index < triple_attack_roulettes.size() - 1:
				current_roulette_index += 1
				start_triple_roulette(current_roulette_index)
			else:
				rouletteBattleField.done()
				emit_signal("end_turn")
		elif selected_attack == "secondary_effect_roulette_attack":
			emit_signal("end_turn")

func deal_damage(hit_force = null, _fixed_amount = null):
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		if selected_attack == "triple_hit_roulette_attack":
			var current_roulette = triple_attack_roulettes[current_roulette_index]
			var selected_id = current_roulette[selected_index]["id"]
			match(selected_id):
				FACES.HIT:
					.deal_damage(GameConstants.HIT_FORCE.NORMAL)
				FACES.HIT_STRONG:
					.deal_damage(GameConstants.HIT_FORCE.STRONG)
				FACES.HIT_CRIT:
					.deal_damage(GameConstants.HIT_FORCE.CRIT)
				FACES.HIT_POISON:
					.deal_damage(GameConstants.HIT_FORCE.NORMAL)
					playerStats.add_status(GameConstants.STATUS.POISON)
				FACES.HIT_POISON_2:
					.deal_damage(GameConstants.HIT_FORCE.STRONG)
					playerStats.add_status(GameConstants.STATUS.POISON)
				FACES.HIT_POISON_3:
					.deal_damage(GameConstants.HIT_FORCE.CRIT)
					playerStats.add_status(GameConstants.STATUS.POISON)
				FACES.WIN:
					.deal_damage(null, 0)
		elif selected_attack == "secondary_effect_roulette_attack":
			var first_id = secondary_attack_roulettes[0][selections[0]]["id"]
			var second_id = secondary_attack_roulettes[1][selections[1]]["id"]
			var roulette_hit_force = null
			# First id
			if first_id == FACES.HIT:
				roulette_hit_force =  GameConstants.HIT_FORCE.NORMAL
			elif first_id == FACES.HIT_STRONG:
				roulette_hit_force =  GameConstants.HIT_FORCE.STRONG
			elif first_id == FACES.HIT_CRIT:
				roulette_hit_force =  GameConstants.HIT_FORCE.CRIT
			var damage_amount = get_attack_damage_amount(self.power, roulette_hit_force)
			# Second id
			match(second_id):
				FACES.POWER_UP:
					.deal_damage(null, ceil(damage_amount * 1.5))
				FACES.DRAIN_LIFE:
					.deal_damage(roulette_hit_force, damage_amount)
					.heal_damage(damage_amount)
				FACES.SURPRISE:
					var surprise_damage = playerStats.hp - 1
					if playerStats.has_status(GameConstants.STATUS.POISON):
						var poison_damage = round(playerStats.max_hp / 8)
						var bufferForPoison = poison_damage if playerStats.hp > poison_damage else 0 # If player can survive poison next turn, we want him to survive with 1 HP
						surprise_damage -= bufferForPoison
					.deal_damage(null, surprise_damage)
				FACES.WIN:
					.deal_damage(null, 0)
			
		else:
			.deal_damage(hit_force)

func secondary_effect_roulette_attack():
	DialogBox.show_timeout("!!!", 1)
	yield(DialogBox, "done")
	rouletteBattleField = RouletteBattleField.instance()
	rouletteBattleField.connect("face_selected", self, "on_secondaryRouletteBattleField_face_selected")
	rouletteBattleField.connect("face_displayed", self, "on_secondaryRouletteBattleField_face_displayed")
	ActionBattle.start_small_field(rouletteBattleField)
	current_roulette_index = 0
	selections = []
	start_secondary_roulette(current_roulette_index)

func start_secondary_roulette(roulette_index):
	var roulette_speed = 0.1 + (0.05 * roulette_index) # Slower as we go up
	var roulette_data = secondary_attack_roulettes[roulette_index]
	rouletteBattleField.start_roulette(roulette_data, roulette_speed)

func on_secondaryRouletteBattleField_face_selected(index):
	selections.append(index)

func on_secondaryRouletteBattleField_face_displayed(_index):
	if current_roulette_index < secondary_attack_roulettes.size() - 1:
		current_roulette_index += 1
		start_secondary_roulette(current_roulette_index)
	else:
		rouletteBattleField.done()
		attackAnimationPlayer.play("StatusAttack1")
