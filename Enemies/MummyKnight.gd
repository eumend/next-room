extends "res://Enemies/BaseEnemy.gd"

const JanKenBattleField = preload("res://BattleFields/Enemy/JankenBattleField.tscn")

func get_attack_pattern():
	if self.hp < round(self.max_hp / 4):
		return {
			"vengeance_attack": 100,
		}
	elif self.hp < round(self.max_hp / 2):
		return {
			"default_attack": 20,
			"janken_attack": 80,
		}
	elif self.hp > round(self.max_hp * 0.75):
		return {
			"default_attack": 100,
		}
	else:
		return {
			"default_attack": 50,
			"janken_attack": 50,
		}

func vengeance_attack():
	DialogBox.show_timeout("VENGEANCE!", 1)
	yield(DialogBox, "done")
	var jankenBattleField = JanKenBattleField.instance()
	jankenBattleField.play_until = [jankenBattleField.OUTCOMES.LOSE]
	jankenBattleField.max_turns = 5
	jankenBattleField.connect("player_win", self, "_on_jankenBattleField_player_win")
	jankenBattleField.connect("player_lose", self, "_on_jankenBattleField_player_lose")
	jankenBattleField.connect("player_draw", self, "_on_jankenBattleField_player_draw")
	jankenBattleField.connect("done", self, "_on_jankenBattleField_done")
	ActionBattle.start_small_field(jankenBattleField)

func janken_attack():
	DialogBox.show_timeout("JAN-KEN-PON!", 1)
	yield(DialogBox, "done")
	var jankenBattleField = JanKenBattleField.instance()
	jankenBattleField.connect("player_draw", self, "_on_jankenBattleField_player_draw")
	jankenBattleField.connect("player_lose", self, "_on_jankenBattleField_player_lose")
	jankenBattleField.connect("player_win", self, "_on_jankenBattleField_player_win")
	jankenBattleField.connect("done", self, "_on_jankenBattleField_done")
	ActionBattle.start_small_field(jankenBattleField)

func _on_jankenBattleField_player_draw():
	.heal_damage(ceil(self.max_hp / 6))

func _on_jankenBattleField_player_lose():
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func _on_jankenBattleField_player_win():
	.take_damage(max(ceil(self.max_hp / 8), 2))

func _on_jankenBattleField_done():
	emit_signal("end_turn")
