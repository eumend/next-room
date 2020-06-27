extends "res://Enemies/BaseEnemy.gd"

const ShootBossBattleField = preload("res://BattleFields/Enemy/ShootBossBattleField.tscn")

func get_attack_pattern():
	return {
		"default_attack": 20,
		"saucer_attack": 80,
	}

func saucer_attack():
	DialogBox.show_timeout("---", 1)
	yield(DialogBox, "done")
	var battleField = ShootBossBattleField.instance()
	battleField.initial_bullets = 1
	battleField.bullet_time = 2
	battleField.connect("hit", self, "on_BattleField_hit")
	battleField.connect("done", self, "on_BattleField_done")
	battleField.connect("boss_hit", self, "on_BattleField_boss_hit")
	ActionBattle.start_small_field(battleField)

func on_BattleField_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG, round(self.power * 0.8))

func on_BattleField_boss_hit():
	.take_damage(round(self.max_hp * 0.1))

func on_BattleField_done():
	emit_signal("end_turn")
