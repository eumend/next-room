extends "res://Enemies/BaseEnemy.gd"

const FireAtackBattleField = preload("res://BattleFields/EnemyBattleFields/GridGeyserBattleField.tscn")

var undead = true

func get_attack_pattern():
	return {
		"default_attack": 35,
		"fire_attack": 65,
	}

func attack():
	if self.hp <= 0:
		undead_attack()
	else:
		.attack()

func is_dead():
	return .is_dead() and not undead

func fire_attack():
	DialogBox.show_timeout("BURN!", 1)
	yield(DialogBox, "done")
	do_fire_attack(4)

func undead_attack():
	DialogBox.show_timeout("UNDEAD ATTACK!", 1)
	yield(DialogBox, "done")
	do_fire_attack(6)

func do_fire_attack(pillars):
	var fireAttackBattleField = FireAtackBattleField.instance()
	fireAttackBattleField.init(pillars)
	fireAttackBattleField.connect("enemy_hit", self, "_on_fireAttackBattleField_enemy_hit")
	fireAttackBattleField.connect("done", self, "_on_fireAttackBattleField_done")
	ActionBattle.start_small_field(fireAttackBattleField)

func _on_fireAttackBattleField_enemy_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.CRIT)

func _on_fireAttackBattleField_done():
	if self.hp <= 0:
		undead = false
		.on_death()
	else:
		emit_signal("end_turn")
