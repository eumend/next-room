extends "res://Enemies/BaseEnemy.gd"

const JanKenBattleField = preload("res://BattleFields/EnemyBattleFields/JankenBattleField.tscn")
const death_sfx = preload("res://Music/SFX/explosion_1.wav")

func _init():
	attack_pattern = {
		"default_attack": 65,
		"janken_attack": 35,
	}
	death_animation_name = "ShakeFade"

func janken_attack():
	DialogBox.show_timeout("JAN-KEN...", 1)
	yield(DialogBox, "done")
	var jankenBattleField = JanKenBattleField.instance()
	jankenBattleField.connect("enemy_heal", self, "_on_jankenBattleField_enemy_heal")
	jankenBattleField.connect("hit", self, "_on_jankenBattleField_hit")
	jankenBattleField.connect("done", self, "_on_jankenBattleField_done")
	ActionBattle.start_small_field(jankenBattleField)

func _on_jankenBattleField_enemy_heal(_hit_force):
	.heal_damage(round(self.max_hp / 4))

func _on_jankenBattleField_hit(_hit_force):
	.take_damage(round(self.max_hp / 10))

func _on_jankenBattleField_done():
	emit_signal("end_turn")

func on_dead():
	play_sfx(death_sfx)
	.on_dead()
