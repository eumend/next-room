extends "res://Enemies/BaseEnemy.gd"

func get_attack_pattern():
	var playerStats = BattleUnits.PlayerStats
	if not playerStats.has_status(GameConstants.STATUS.POISON):
		return {
			"slime_attack": 50,
			"tome_attack": 10,
			"starfish_attack": 10,
			"voodoo_attack": 10,
			"saucer_attack": 10,
			"face_angel_battle_field": 10,
		}
	elif not voodoo:
		return {
			"tome_attack": 15,
			"starfish_attack": 15,
			"voodoo_attack": 20,
			"saucer_attack": 25,
			"face_angel_battle_field": 25,
		}
	else:
		return {
			"tome_attack": 25,
			"starfish_attack": 10,
			"saucer_attack": 25,
			"face_angel_battle_field": 30,
		}

# Slime

func slime_attack():
	DialogBox.show_timeout("It's... secreting ooze?", 0.5)
	animationPlayer.play("StatusAttack1")
	yield(animationPlayer, "animation_finished")
	emit_signal("end_turn")

func deal_damage(hit_force = null, _fixed_amount= null):
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		if selected_attack == "slime_attack":
			var attack_power = max(ceil(power / 2), 1)
			.deal_damage(null, attack_power)
			playerStats.add_status(GameConstants.STATUS.POISON)
		else:
			.deal_damage(hit_force)

# Candle

func attack():
	if self.hp <= round(self.max_hp / 5):
		candle_attack()
	else:
		.attack()

func candle_attack():
	DialogBox.show_timeout("It's... melting!?", 2)
	yield(DialogBox, "done")
	.take_damage(self.hp)
	emit_signal("end_turn")

# Ancient tome

const JanKenBattleField = preload("res://BattleFields/EnemyBattleFields/JankenBattleField.tscn")

func tome_attack():
	DialogBox.show_timeout("Janken again!", 1)
	yield(DialogBox, "done")
	var jankenBattleField = JanKenBattleField.instance()
	jankenBattleField.choice_map = {
		jankenBattleField.CHOICES.SCISSORS: 0,
		jankenBattleField.CHOICES.PAPER: 80,
		jankenBattleField.CHOICES.ROCK: 20,
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
	.take_damage(ceil(self.max_hp / 5))

func _on_jankenBattleField_done():
	emit_signal("end_turn")

# Starfish

func starfish_attack():
	DialogBox.show_timeout("It's... laying down...", 1)
	yield(DialogBox, "done")
	.heal_damage(round(self.max_hp / 4))
	emit_signal("end_turn")

# Voodoo doll
var voodoo = false

func on_start_turn():
	voodoo = false
	.attack()

func voodoo_attack():
	voodoo = true
	DialogBox.show_timeout("It took a menacing stance...", 2)
	yield(DialogBox, "done")
	emit_signal("end_turn")

func take_damage(amount, hit_force = null):
	if voodoo and amount > 0:
		var playerStats = BattleUnits.PlayerStats
		if playerStats:
			playerStats.take_damage(amount, hit_force)
			.take_damage(amount, hit_force)
	else:
		.take_damage(amount, hit_force)

# Saucer

const ShootBossBattleField = preload("res://BattleFields/EnemyBattleFields/ShootBossBattleField.tscn")

func saucer_attack():
	DialogBox.show_timeout("Shoot it down!", 1)
	yield(DialogBox, "done")
	var battleField = ShootBossBattleField.instance()
	battleField.initial_bullets = 1
	battleField.bullet_time = 2
	battleField.connect("hit", self, "on_shootBossBattleField_hit")
	battleField.connect("done", self, "on_shootBossBattleField_done")
	battleField.connect("boss_hit", self, "on_shootBossBattleField_boss_hit")
	ActionBattle.start_small_field(battleField)

func on_shootBossBattleField_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG, round(self.power * 0.8))

func on_shootBossBattleField_boss_hit():
	.take_damage(round(self.max_hp * 0.1))

func on_shootBossBattleField_done():
	emit_signal("end_turn")

# Face Angel

const FalldownBattleField = preload("res://BattleFields/EnemyBattleFields/FalldownBattleField.tscn")

func face_angel_battle_field():
	DialogBox.show_timeout("The earth and sky are trembling!", 1)
	yield(DialogBox, "done")
	var battleField = FalldownBattleField.instance()
	battleField.bullet_time = 1
	battleField.move_time = 6
	battleField.time_limit = 10
	battleField.ceil_data = {
		"can_kill": true,
		"time": 0.7,
		"force": 15,
	}
	battleField.floor_data = {
		"can_kill": true,
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
	.deal_damage(GameConstants.HIT_FORCE.NORMAL, self.power / 3)

func on_falldownBattleField_done():
	emit_signal("end_turn")
