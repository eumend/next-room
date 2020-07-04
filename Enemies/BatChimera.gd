extends "res://Enemies/BaseEnemy.gd"

func get_attack_pattern():
	if self.hp < self.max_hp / 2:
		return {
			"leech_life": 30,
			"shield_attack": 10,
			"mermaid_attack": 15,
			"spectre_attack": 15,
			"bug_attack": 15,
			"ring_angel_attack": 15,
		}
	else:
		return {
			"leech_life": 10,
			"shield_attack": 10,
			"mermaid_attack": 20,
			"spectre_attack": 20,
			"bug_attack": 20,
			"ring_angel_attack": 20,
		}


# Bat

func leech_life():
	show_attack_text("It's showing its fangs!")
	animationPlayer.play("StatusAttack1")
	yield(animationPlayer, "animation_finished")
	emit_signal("end_turn")

# Skull

const FireAtackBattleField = preload("res://BattleFields/Enemy/GridGeyserBattleField.tscn")

var undead = true

func attack():
	if self.hp <= 0:
		undead_attack()
	else:
		.attack()

func undead_attack():
	var dialog = show_attack_text("It buried itself in the ground!?")
	yield(dialog, "done")
	var fireAttackBattleField = FireAtackBattleField.instance()
	fireAttackBattleField.init(4)
	fireAttackBattleField.connect("enemy_hit", self, "_on_fireAttackBattleField_enemy_hit")
	fireAttackBattleField.connect("done", self, "_on_fireAttackBattleField_done")
	ActionBattle.start_small_field(fireAttackBattleField)

func _on_fireAttackBattleField_enemy_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func _on_fireAttackBattleField_done():
	undead = false
	.on_death()

func is_dead():
	return .is_dead() and not undead

# Ancient Shield

const JanKenBattleField = preload("res://BattleFields/Enemy/JankenBattleField.tscn")

func shield_attack():
	show_attack_text("Its wings are transforming...")
	var jankenBattleField = JanKenBattleField.instance()
	jankenBattleField.choice_map = {
		jankenBattleField.CHOICES.SCISSORS: 20,
		jankenBattleField.CHOICES.PAPER: 0,
		jankenBattleField.CHOICES.ROCK: 80,
	}
	jankenBattleField.max_turns = 1
	jankenBattleField.connect("player_win", self, "_on_jankenBattleField_player_win")
	jankenBattleField.connect("player_lose", self, "_on_jankenBattleField_player_lose")
	jankenBattleField.connect("player_draw", self, "_on_jankenBattleField_player_draw")
	jankenBattleField.connect("done", self, "_on_jankenBattleField_done")
	ActionBattle.start_small_field(jankenBattleField)

func _on_jankenBattleField_player_draw():
	pass

func _on_jankenBattleField_player_lose():
	.heal_damage(ceil(self.max_hp / 5))

func _on_jankenBattleField_player_win():
	.take_damage(ceil(self.max_hp / 8))

func _on_jankenBattleField_done():
	if self.hp <= 0:
		undead_attack()
	else:
		emit_signal("end_turn")

# Mermaid

const BulletsDownBattleField = preload("res://BattleFields/Enemy/BulletsDownBattleField.tscn")
const noteSprite = preload("res://Images/BattleFields/BulletsDown/NoteBullet.png")

func mermaid_attack():
	show_attack_text("It's screeching!")
	var battleField = BulletsDownBattleField.instance()
	battleField.base_speed = 70
	battleField.total_bullets = 4
	battleField.stop_point = 30
	battleField.stop_point_time = 1
	battleField.sprite = noteSprite
	battleField.color = "2effff" # Light blue
	battleField.connect("hit", self, "on_bulletsDownBattleField_hit")
	battleField.connect("done", self, "on_bulletsDownBattleField_done")
	ActionBattle.start_small_field(battleField)

func on_bulletsDownBattleField_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func on_bulletsDownBattleField_done():
	emit_signal("end_turn")

# Spectre

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
			"id": ROULETTE_FACES.HIT_CRIT,
			"type": "bad"
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

func spectre_attack():
	show_attack_text("It has an ominous aura!")
	rouletteBattleField = RouletteBattleField.instance()
	rouletteBattleField.connect("face_selected", self, "on_rouletteBattleField_face_selected")
	rouletteBattleField.connect("face_displayed", self, "on_rouletteBattleField_face_displayed")
	ActionBattle.start_small_field(rouletteBattleField)
	current_roulette_index = 0
	roulette_selections = []
	start_roulette(current_roulette_index)

func start_roulette(roulette_index):
	var roulette_speed = 0.1 + (0.05 * roulette_index) # A bit slower as we go up
	var roulette_data = roulettes[roulette_index]
	rouletteBattleField.start_roulette(roulette_data, roulette_speed)

func on_rouletteBattleField_face_selected(index):
	roulette_selections.append(index)

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
		if selected_attack == "leech_life":
			var attack_power = max(ceil(power / 2), 1)
			.deal_damage(null, attack_power)
			.heal_damage(round(self.max_hp / 5))
		elif selected_attack == "spectre_attack":
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
					.deal_damage(null, 0)
		else:
			.deal_damage(hit_force)

# Bug

const ShootEmUpBattleField = preload("res://BattleFields/Enemy/ShootEmUpBattleField.tscn")

func bug_attack():
	show_attack_text("Shoot carefully!")
	var battleField = ShootEmUpBattleField.instance()
	var bullets = get_bullets()
	battleField.bullets = bullets
	battleField.shots_left = bullets.size() - 1
	battleField.connect("hit", self, "on_shootEmUpBattleField_hit")
	battleField.connect("done", self, "on_shootEmUpBattleField_done")
	ActionBattle.start_small_field(battleField)

func get_bullets():
	randomize()
	var qty = rand_range(3, 5)
	var bullets = []
	for _i in range(0, qty - 1):
		bullets.append(GameConstants.BOMB_BULLET_TYPES.COOLDOWN)
	bullets.append(GameConstants.BOMB_BULLET_TYPES.COUNTDOWN)
	bullets.shuffle()
	return bullets

func on_shootEmUpBattleField_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.CRIT)

func on_shootEmUpBattleField_done():
	emit_signal("end_turn")

# Ring Angel

const FalldownBattleField = preload("res://BattleFields/Enemy/FalldownBattleField.tscn")

func ring_angel_attack():
	show_attack_text("It flew to the sky!")
	var battleField = FalldownBattleField.instance()
	battleField.bullet_time = 1
	battleField.move_time = 6
	battleField.time_limit = 10
	battleField.ceil_data = {
		"can_kill": false,
		"time": 0.7,
		"force": 15,
	}
	battleField.floor_data = {
		"can_kill": false,
		"time": 0.7,
		"force": 15,
	}
	battleField.connect("hit_limit", self, "on_falldownBattleField_hit_limit")
	battleField.connect("hit_bullet", self, "on_falldownBattleField_hit_bullet")
	battleField.connect("done", self, "on_falldownBattleField_done")
	ActionBattle.start_small_field(battleField)

func on_falldownBattleField_hit_limit():
	.deal_damage(GameConstants.HIT_FORCE.CRIT)

func on_falldownBattleField_hit_bullet():
	.deal_damage(GameConstants.HIT_FORCE.NORMAL)

func on_falldownBattleField_done():
	emit_signal("end_turn")
