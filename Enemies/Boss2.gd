extends "res://Enemies/BaseEnemy.gd"

const FireAtackBattleField = preload("res://BattleFields/EnemyBattleFields/GridGeyserBattleField.tscn")

func _init():
	attack_pattern = {
		"default_attack": 25,
		"fire_attack": 75,
	}

func fire_attack():
	DialogBox.show_timeout("BURN!", 1)
	yield(DialogBox, "done")
	var fireAttackBattleField = FireAtackBattleField.instance()
	fireAttackBattleField.connect("enemy_hit", self, "_on_fireAttackBattleField_enemy_hit")
	fireAttackBattleField.connect("done", self, "_on_fireAttackBattleField_done")
	ActionBattle.start_small_field(fireAttackBattleField)

func _on_fireAttackBattleField_enemy_hit(hit_force):
	.deal_damage()

func _on_fireAttackBattleField_done():
	emit_signal("end_turn")
