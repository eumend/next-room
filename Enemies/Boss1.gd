extends "res://Enemies/BaseEnemy.gd"

const JanKenBattleField = preload("res://BattleFields/EnemyBattleFields/JankenBattleField.tscn")

func _init():
	attack_pattern = {
		"default_attack": 25,
		"janken_attack": 75,
	}

func janken_attack():
	DialogBox.show_timeout("JAN-KEN...", 1)
	yield(DialogBox, "done")
	var jankenBattleField = JanKenBattleField.instance()
	jankenBattleField.connect("enemy_heal", self, "_on_jankenBattleField_enemy_heal")
	jankenBattleField.connect("hit", self, "_on_jankenBattleField_hit")
	jankenBattleField.connect("done", self, "_on_jankenBattleField_done")
	ActionBattle.start_small_field(jankenBattleField)

func _on_jankenBattleField_enemy_heal(heal_amount):
	.heal_damage(heal_amount)

func _on_jankenBattleField_hit(amount):
	.take_damage(amount)

func _on_jankenBattleField_done():
	emit_signal("end_turn")
