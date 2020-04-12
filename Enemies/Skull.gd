extends "res://Enemies/BaseEnemy.gd"

const FireAtackBattleField = preload("res://BattleFields/EnemyBattleFields/GridGeyserBattleField.tscn")

var can_die = false

func attack():
	if self.hp <= 0:
		undead_attack()
	else:
		.attack()

func undead_attack():
	DialogBox.show_timeout("UNDEAD ATTACK!", 1)
	yield(DialogBox, "done")
	var fireAttackBattleField = FireAtackBattleField.instance()
	fireAttackBattleField.init(2)
	fireAttackBattleField.connect("enemy_hit", self, "_on_fireAttackBattleField_enemy_hit")
	fireAttackBattleField.connect("done", self, "_on_fireAttackBattleField_done")
	ActionBattle.start_small_field(fireAttackBattleField)

func _on_fireAttackBattleField_enemy_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func _on_fireAttackBattleField_done():
	can_die = true
	.take_damage(1) # Just to kill us off

func is_dead():
	return can_die and .is_dead()
