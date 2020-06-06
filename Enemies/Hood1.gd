extends "res://Enemies/BaseEnemy.gd"

var turns_passed = 0
var undead = true

const PeekabooBattleField = preload("res://BattleFields/EnemyBattleFields/PeekabooBattleField.tscn")

func get_attack_pattern():
	# Controlled programatically
	return {}

func peekaboo_attack():
	var peekabooBattleField = PeekabooBattleField.instance()
	peekabooBattleField.connect("hit", self, "_on_peekabooBattleField_hit")
	peekabooBattleField.connect("enemy_hit", self, "_on_peekabooBattleField_enemy_hit")
	peekabooBattleField.connect("miss", self, "_on_peekabooBattleField_miss")
	peekabooBattleField.connect("done", self, "_on_peekabooBattleField_done")
	ActionBattle.start_small_field(peekabooBattleField)

# For invincibility
func take_damage(_amount, hit_force = null):
	if hit_force == GameConstants.HIT_FORCE.CRIT:
		.take_damage(1, hit_force)
	else:
		.take_damage(0, hit_force)

func _on_peekabooBattleField_hit(_hit_force):
	.take_damage(1)

func _on_peekabooBattleField_enemy_hit(_hit_force):
	.deal_damage()

func _on_peekabooBattleField_miss():
	.take_damage(0)

func _on_peekabooBattleField_done():
	emit_signal("end_turn")

func is_dead():
	return .is_dead() and not undead

func on_start_turn():
	if .is_dead():
		undead = false
		DialogBox.show_timeout("Hehe, you won!", 2)
		yield(DialogBox, "done")
		animationPlayer.play("Flee")
		yield(animationPlayer, "animation_finished")
		emit_signal("end_turn")
	else:
		var turns_before = turns_passed
		turns_passed += 1
		match(turns_before):
			0:
				DialogBox.show_timeout("Try to catch me!", 2)
				yield(DialogBox, "done")
				peekaboo_attack()
			1:
				DialogBox.show_timeout("Hehe...", 2)
				yield(DialogBox, "done")
				peekaboo_attack()
			2:
				DialogBox.show_timeout("I'm done!", 2)
				yield(DialogBox, "done")
				flee()
