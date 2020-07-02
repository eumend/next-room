extends "res://Enemies/BaseEnemy.gd"

const JanKenBattleField = preload("res://BattleFields/Enemy/JankenBattleField.tscn")

func get_attack_pattern():
	return {
		"default_attack": 40,
		"janken_attack": 60,
	}

func janken_attack():
	show_attack_text("JAN-KEN...")
	var jankenBattleField = JanKenBattleField.instance()
	jankenBattleField.choice_map = {
		jankenBattleField.CHOICES.SCISSORS: 80,
		jankenBattleField.CHOICES.PAPER: 20,
		jankenBattleField.CHOICES.ROCK: 0,
	}
	jankenBattleField.max_turns = 1
	jankenBattleField.connect("player_win", self, "_on_jankenBattleField_player_win")
	jankenBattleField.connect("player_lose", self, "_on_jankenBattleField_player_lose")
	jankenBattleField.connect("player_draw", self, "_on_jankenBattleField_draw")
	jankenBattleField.connect("done", self, "_on_jankenBattleField_done")
	ActionBattle.start_small_field(jankenBattleField)

func _on_jankenBattleField_draw():
	pass

func _on_jankenBattleField_player_lose():
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func _on_jankenBattleField_player_win():
	.take_damage(ceil(self.max_hp / 2))

func _on_jankenBattleField_done():
	emit_signal("end_turn")
