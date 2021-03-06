extends "res://Enemies/BaseEnemy.gd"

const FireAtackBattleField = preload("res://BattleFields/Enemy/GridGeyserBattleField.tscn")
const Explosion = preload("res://Animations/Explosion1Animation.tscn")

var undead = true

func take_damage(amount, hit_force = null):
	.take_damage(amount, hit_force)
	if self.hp <= floor(self.max_hp / 4):
		$Sprite.self_modulate = "ff0000"

func get_attack_pattern():
	var playerStats = BattleUnits.PlayerStats
	if playerStats.hp <= round(self.power * 2):
		return {
			"default_attack": 100,
		}
	else:
		return {
			"default_attack": 20,
			"fire_attack": 80,
		}

func attack():
	if self.hp <= round(self.max_hp / 5):
		undead_attack()
	else:
		.attack()

func is_dead():
	return .is_dead() and not undead

func fire_attack():
	show_attack_text("BURN!")
	if self.hp <= round(self.max_hp / 3):
		do_fire_attack(5)
	elif self.hp <= round(self.max_hp / 2):
		do_fire_attack(4)
	else:
		do_fire_attack(3)

func suicide_attack():
	var dialog = show_attack_text("DIE!")
	yield(dialog, "done")
	animate_explosion()

func undead_attack():
	suicide_attack()

func _on_Explosion_animation_finished():
	undead = false
	self.hp = 0 # We can get here on very low health
	.on_death()

func _on_Explosion_animation_boom():
	self.hide()
	.deal_damage(GameConstants.HIT_FORCE.CRIT, self.power * 2)

func animate_explosion():
	var explosion = Explosion.instance()
	var main = get_tree().current_scene
	main.add_child(explosion)
	explosion.connect("boom", self, "_on_Explosion_animation_boom")
	explosion.connect("done", self, "_on_Explosion_animation_finished")
	explosion.global_position = $Sprite.global_position

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
