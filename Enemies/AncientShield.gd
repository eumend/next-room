extends "res://Enemies/BaseEnemy.gd"

const JanKenBattleField = preload("res://BattleFields/Enemy/JankenBattleField.tscn")

func get_attack_pattern():
	if self.hp == self.max_hp:
		return {
			"default_attack": 100,
		}
	else:
		return {
			"default_attack": 40,
			"janken_attack": 60,
		}

func janken_attack():
	show_attack_text("PON-JAN...")
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
	.heal_damage(ceil(self.max_hp / 3))

func _on_jankenBattleField_player_win():
	.take_damage(1)

func _on_jankenBattleField_done():
	emit_signal("end_turn")
