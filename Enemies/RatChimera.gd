extends "res://Enemies/BaseEnemy.gd"

func get_attack_pattern():
	return {
		"default_attack": 20,
		"sword_janken_attack": 10,
		"seahorse_ink_attack": 20,
		"spider_bite_attack": 20,
		"worm_attack": 15,
		"feather_angel_attack": 15,
	}

### Rat

func get_hit_force_pattern():
	return {
		GameConstants.HIT_FORCE.NORMAL: 40,
		GameConstants.HIT_FORCE.STRONG: 35,
		GameConstants.HIT_FORCE.CRIT: 25,
	}

### Flame head

const Explosion = preload("res://Animations/Explosion1Animation.tscn")

var undead = true

func take_damage(amount, hit_force = null):
	.take_damage(amount, hit_force)
	if self.hp <= floor(self.max_hp / 4):
		$Sprite.self_modulate = "ff0000"

func attack():
	if self.hp <= 0:
		undead_attack() 
	else:
		.attack()

func undead_attack():
	var dialog = show_attack_text("It's blowing up!?")
	yield(dialog, "done")
	animate_explosion()

func is_dead():
	return .is_dead() and not undead

func _on_Explosion_animation_finished():
	undead = false
	.on_death()

func _on_Explosion_animation_boom():
	self.hide()
	.deal_damage(GameConstants.HIT_FORCE.CRIT, self.power * 1.5)

func animate_explosion():
	var explosion = Explosion.instance()
	var main = get_tree().current_scene
	main.add_child(explosion)
	explosion.connect("boom", self, "_on_Explosion_animation_boom")
	explosion.connect("done", self, "_on_Explosion_animation_finished")
	explosion.global_position = $Sprite.global_position

# Ancient Sword

const JanKenBattleField = preload("res://BattleFields/Enemy/JankenBattleField.tscn")

func sword_janken_attack():
	show_attack_text("Jan-Ken... but how?")
	var jankenBattleField = JanKenBattleField.instance()
	jankenBattleField.choice_map = {
		jankenBattleField.CHOICES.SCISSORS: 80,
		jankenBattleField.CHOICES.PAPER: 20,
		jankenBattleField.CHOICES.ROCK: 0,
	}
	jankenBattleField.max_turns = 3
	jankenBattleField.play_until = []
	jankenBattleField.connect("player_win", self, "_on_jankenBattleField_player_win")
	jankenBattleField.connect("player_lose", self, "_on_jankenBattleField_player_lose")
	jankenBattleField.connect("player_draw", self, "_on_jankenBattleField_player_draw")
	jankenBattleField.connect("done", self, "_on_jankenBattleField_done")
	ActionBattle.start_small_field(jankenBattleField)

func _on_jankenBattleField_player_draw():
	.heal_damage(ceil(self.max_hp / 5))

func _on_jankenBattleField_player_lose():
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func _on_jankenBattleField_player_win():
	take_damage(ceil(self.max_hp / 6))

func _on_jankenBattleField_done():
	if self.hp <= 0:
		undead_attack()
	else:
		emit_signal("end_turn")

### Sea Horse

const BulletsDownBattleField = preload("res://BattleFields/Enemy/BulletsDownBattleField.tscn")

func seahorse_ink_attack():
	show_attack_text("It's shooting gunk!")
	var battleField = BulletsDownBattleField.instance()
	battleField.base_speed = 55
	battleField.total_bullets = 5
	battleField.connect("hit", self, "on_bulletsDownBattleField_hit")
	battleField.connect("done", self, "on_bulletsDownBattleField_done")
	ActionBattle.start_small_field(battleField)

func on_bulletsDownBattleField_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func on_bulletsDownBattleField_done():
	emit_signal("end_turn")

# Spider

const RouletteBattleField = preload("res://BattleFields/Enemy/RouletteBattleField.tscn")
const HitSprite = preload("res://Images/BattleFields/Roulette/Hit1.png")
const PoisonHitSprite = preload("res://Images/BattleFields/Roulette/HitPoison.png")
const WinSprite = preload("res://Images/BattleFields/Roulette/Win.png")
const PoisonHitDoubleSprite = preload("res://Images/BattleFields/Roulette/Hit2Poison.png")

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
			"type": "good"
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

func spider_bite_attack():
	show_attack_text("It's ready to bite!")
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
		if selected_attack == "spider_bite_attack":
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

## Worm

const ShootEmUpBattleField = preload("res://BattleFields/Enemy/ShootEmUpBattleField.tscn")

func worm_attack():
	show_attack_text("It's sending projectiles!")
	var battleField = ShootEmUpBattleField.instance()
	var bullets = get_bullets()
	battleField.bullets = bullets
	battleField.shots_left = bullets.size() - 1
	battleField.connect("hit", self, "on_shootEmUpBattleField_hit")
	battleField.connect("done", self, "on_shootEmUpBattleField_done")
	ActionBattle.start_small_field(battleField)

func get_bullets():
	randomize()
	var qty = rand_range(4, 6)
	var bullets = []
	for _i in range(0, qty):
		bullets.append(GameConstants.BOMB_BULLET_TYPES.COUNTDOWN)
	return bullets

func on_shootEmUpBattleField_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func on_shootEmUpBattleField_done():
	emit_signal("end_turn")

# Feather Angel

const FalldownBattleField = preload("res://BattleFields/Enemy/FalldownBattleField.tscn")

func feather_angel_attack():
	show_attack_text("The earth is shaking!")
	var battleField = FalldownBattleField.instance()
	battleField.bullet_time = 1
	battleField.move_time = 6
	battleField.time_limit = 10
	battleField.connect("hit_limit", self, "on_falldownBattleField_hit_limit")
	battleField.connect("hit_bullet", self, "on_falldownBattleField_hit_bullet")
	battleField.connect("done", self, "on_falldownBattleField_done")
	ActionBattle.start_small_field(battleField)

func on_falldownBattleField_hit_limit():
	.deal_damage(GameConstants.HIT_FORCE.CRIT)

func on_falldownBattleField_hit_bullet():
	.deal_damage(GameConstants.HIT_FORCE.NORMAL, self.power / 2)

func on_falldownBattleField_done():
	emit_signal("end_turn")
