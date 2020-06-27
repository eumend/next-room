extends "res://Enemies/BaseEnemy.gd"

const FalldownBattleField = preload("res://BattleFields/Enemy/FalldownBattleField.tscn")
export(float) var bullet_interval = 1
export(int) var wall_interval = 6
export(int) var total_time = 10


func get_attack_pattern():
	return {
		"default_attack": 20,
		"falldown_attack": 80,
	}

func falldown_attack():
	DialogBox.show_timeout(". . . T H O U . . . F A L L . . .", 1)
	yield(DialogBox, "done")
	var battleField = FalldownBattleField.instance()
	battleField.bullet_time = bullet_interval
	battleField.move_time = wall_interval
	battleField.time_limit = total_time
	battleField.connect("hit_limit", self, "on_BattleField_hit_limit")
	battleField.connect("hit_bullet", self, "on_BattleField_hit_bullet")
	battleField.connect("done", self, "on_BattleField_done")
	ActionBattle.start_small_field(battleField)

func on_BattleField_hit_limit():
	.deal_damage(GameConstants.HIT_FORCE.CRIT)

func on_BattleField_hit_bullet():
	.deal_damage(GameConstants.HIT_FORCE.NORMAL, self.power / 2)

func on_BattleField_done():
	emit_signal("end_turn")
