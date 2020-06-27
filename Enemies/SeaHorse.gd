extends "res://Enemies/BaseEnemy.gd"

const BulletsDownBattleField = preload("res://BattleFields/Enemy/BulletsDownBattleField.tscn")

func get_attack_pattern():
	return {
		"default_attack": 30,
		"ink_attack": 70,
	}

func ink_attack():
	DialogBox.show_timeout("INK ATTACK!", 1)
	yield(DialogBox, "done")
	var battleField = BulletsDownBattleField.instance()
	battleField.base_speed = 55
	battleField.total_bullets = 4
	battleField.connect("hit", self, "on_BattleField_hit")
	battleField.connect("done", self, "on_BattleField_done")
	ActionBattle.start_small_field(battleField)

func on_BattleField_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func on_BattleField_done():
	emit_signal("end_turn")
