extends "res://Enemies/BaseEnemy.gd"

const JanKenBattleField = preload("res://BattleFields/EnemyBattleFields/JankenBattleField.tscn")

func get_attack_pattern():
	return {
		"janken_attack": 100,
	}

func janken_attack():
	DialogBox.show_timeout("KEN-PON...", 1)
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
	.heal_damage(ceil(self.max_hp / 4))

func _on_jankenBattleField_player_lose():
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func _on_jankenBattleField_player_win():
	.take_damage(ceil(self.max_hp / 4))

func _on_jankenBattleField_done():
	emit_signal("end_turn")
