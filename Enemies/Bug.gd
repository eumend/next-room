extends "res://Enemies/BaseEnemy.gd"

const ShootEmUpBattleField = preload("res://BattleFields/Enemy/ShootEmUpBattleField.tscn")
export var min_bullets = 3
export var max_bullets = 5

func get_attack_pattern():
	return {
		"default_attack": 20,
		"bug_attack": 80,
	}

func bug_attack():
	show_attack_text("... (shoot carefully!)")
	var battleField = ShootEmUpBattleField.instance()
	var bullets = get_bullets()
	battleField.bullets = bullets
	battleField.shots_left = bullets.size() - 1
	battleField.connect("hit", self, "on_BattleField_hit")
	battleField.connect("done", self, "on_BattleField_done")
	ActionBattle.start_small_field(battleField)

func get_bullets():
	randomize()
	var qty = rand_range(min_bullets, max_bullets)
	var bullets = []
	for _i in range(0, qty - 1):
		bullets.append(GameConstants.BOMB_BULLET_TYPES.COOLDOWN)
	bullets.append(GameConstants.BOMB_BULLET_TYPES.COUNTDOWN)
	bullets.shuffle()
	return bullets

func on_BattleField_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.CRIT)

func on_BattleField_done():
	emit_signal("end_turn")
