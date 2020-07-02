extends "res://Enemies/BaseEnemy.gd"

const FalldownBattleField = preload("res://BattleFields/Enemy/FalldownBattleField.tscn")
export(float) var bullet_interval = 1
export(float) var wall_interval = 6
export(int) var total_time = 10

var last_attack = "falldown_attack"
var next_attack_pattern = {
	"falldown_attack": { "bullet_attack": 100 },
	"bullet_attack": { "wall_attack": 100 },
	"wall_attack": { "falldown_attack": 100 },
}

func get_attack_pattern():
	var pattern = next_attack_pattern[last_attack]
	last_attack = pattern.keys()[0]
	return pattern

func bullet_attack():
	show_attack_text("THOU SHALT NOT...")
	var battleField = FalldownBattleField.instance()
	battleField.bullet_time = bullet_interval * 0.75
	battleField.move_time = wall_interval * 1.8
	battleField.time_limit = total_time
	battleField.connect("hit_limit", self, "on_BattleField_hit_limit")
	battleField.connect("hit_bullet", self, "on_BattleField_hit_bullet")
	battleField.connect("done", self, "on_BattleField_done")
	ActionBattle.start_small_field(battleField)

func wall_attack():
	show_attack_text("...COME ANY CLOSER...")
	var battleField = FalldownBattleField.instance()
	battleField.bullet_time = bullet_interval
	battleField.move_time = wall_interval * 0.5
	battleField.time_limit = total_time * 0.8
	battleField.ceil_data = {
		"can_kill": false,
		"time": 0.5,
		"force": 20,
	}
	battleField.floor_data = {
		"can_kill": false,
		"time": 0.5,
		"force": 20,
	}
	battleField.connect("hit_limit", self, "on_BattleField_hit_limit")
	battleField.connect("hit_bullet", self, "on_BattleField_hit_bullet")
	battleField.connect("done", self, "on_BattleField_done")
	ActionBattle.start_small_field(battleField)


func falldown_attack():
	show_attack_text("...I WON'T ALLOW IT")
	var battleField = FalldownBattleField.instance()
	battleField.bullet_time = bullet_interval * 0.75
	battleField.move_time = wall_interval * 0.75
	battleField.time_limit = total_time * 0.9
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
	battleField.connect("hit_limit", self, "on_BattleField_hit_limit")
	battleField.connect("hit_bullet", self, "on_BattleField_hit_bullet")
	battleField.connect("done", self, "on_BattleField_done")
	ActionBattle.start_small_field(battleField)

func on_BattleField_hit_limit():
	.deal_damage(GameConstants.HIT_FORCE.CRIT)

func on_BattleField_hit_bullet():
	.deal_damage(GameConstants.HIT_FORCE.NORMAL, self.power / 2 if last_attack != "wall_attack" else null)

func on_BattleField_done():
	emit_signal("end_turn")
