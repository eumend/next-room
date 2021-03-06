extends "res://Enemies/BaseEnemy.gd"

const FireAtackBattleField = preload("res://BattleFields/Enemy/GridGeyserBattleField.tscn")

var undead = true

func attack():
	if self.hp <= 0:
		undead_attack()
	else:
		.attack()

func undead_attack():
	var dialog = show_attack_text("UNDEAD ATTACK!")
	yield(dialog, "done")
	var fireAttackBattleField = FireAtackBattleField.instance()
	fireAttackBattleField.init(2)
	fireAttackBattleField.connect("enemy_hit", self, "_on_fireAttackBattleField_enemy_hit")
	fireAttackBattleField.connect("done", self, "_on_fireAttackBattleField_done")
	ActionBattle.start_small_field(fireAttackBattleField)

func _on_fireAttackBattleField_enemy_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func _on_fireAttackBattleField_done():
	undead = false
	.on_death()

func is_dead():
	return .is_dead() and not undead
