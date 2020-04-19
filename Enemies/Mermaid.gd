extends "res://Enemies/BaseEnemy.gd"

const BulletsDownBattleField = preload("res://BattleFields/EnemyBattleFields/BulletsDownBattleField.tscn")

func get_attack_pattern():
	return {
		"default_attack": 30,
		"sing_attack": 70,
	}

func sing_attack():
	DialogBox.show_timeout("SEA MELODY!", 1)
	yield(DialogBox, "done")
	var battleField = BulletsDownBattleField.instance()
	battleField.base_speed = 70
	battleField.total_bullets = 3
	battleField.stop_point = 20
	battleField.color = "2effff" # Light blue
	battleField.connect("hit", self, "on_BattleField_hit")
	battleField.connect("done", self, "on_BattleField_done")
	battleField.connect("fired", self, "on_BattleField_fired")
	ActionBattle.start_small_field(battleField)

func on_BattleField_fired():
	$SFXNeutral.play()

func on_BattleField_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func on_BattleField_done():
	emit_signal("end_turn")
