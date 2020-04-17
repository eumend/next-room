extends "res://Enemies/BaseEnemy.gd"

const JanKenBattleField = preload("res://BattleFields/EnemyBattleFields/JankenBattleField.tscn")

func get_attack_pattern():
	if self.hp < round(self.max_hp / 4):
		return {
			"vengeance_attack": 100,
		}
	elif self.hp < round(self.max_hp / 2):
		return {
			"default_attack": 20,
			"janken_attack": 80,
		}
	elif self.hp > round(self.max_hp * 0.75):
		return {
			"default_attack": 100,
		}
	else:
		return {
			"default_attack": 50,
			"janken_attack": 50,
		}

func vengeance_attack():
	$Sprite.modulate = "ff0000"
	DialogBox.show_timeout("VENGEANCE!", 1)
	yield(DialogBox, "done")
	var jankenBattleField = JanKenBattleField.instance()
	jankenBattleField.play_until = [jankenBattleField.OUTCOMES.LOSE]
	jankenBattleField.connect("enemy_heal", self, "_on_jankenBattleField_enemy_heal")
	jankenBattleField.connect("enemy_hit", self, "_on_jankenBattleField_enemy_hit")
	jankenBattleField.connect("hit", self, "_on_jankenBattleField_hit")
	jankenBattleField.connect("done", self, "_on_jankenBattleField_done")
	ActionBattle.start_small_field(jankenBattleField)

func janken_attack():
	DialogBox.show_timeout("JAN-KEN...", 1)
	yield(DialogBox, "done")
	var jankenBattleField = JanKenBattleField.instance()
	jankenBattleField.connect("enemy_heal", self, "_on_jankenBattleField_enemy_heal")
	jankenBattleField.connect("enemy_hit", self, "_on_jankenBattleField_enemy_hit")
	jankenBattleField.connect("hit", self, "_on_jankenBattleField_hit")
	jankenBattleField.connect("done", self, "_on_jankenBattleField_done")
	ActionBattle.start_small_field(jankenBattleField)

func _on_jankenBattleField_enemy_heal(_hit_force):
	.heal_damage(ceil(self.max_hp / 5))

func _on_jankenBattleField_enemy_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func _on_jankenBattleField_hit(_hit_force):
	.take_damage(max(ceil(self.max_hp / 8), 2))

func _on_jankenBattleField_done():
	$Sprite.modulate = "ffffff"
	emit_signal("end_turn")
