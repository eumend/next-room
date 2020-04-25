extends "res://Enemies/BaseEnemy.gd"

const BulletsDownBattleField = preload("res://BattleFields/EnemyBattleFields/BulletsDownBattleField.tscn")

func get_attack_pattern():
	if self.hp < round(self.max_hp / 2):
		return {
			"sing_attack": 20,
			"ink_attack": 20,
			"regenerate_attack": 60,
		}
	else:
		return {
			"default_attack": 20,
			"sing_attack": 40,
			"ink_attack": 40,
		}

func regenerate_attack():
	DialogBox.show_timeout("I'm tired...", 1)
	yield(DialogBox, "done")
	.heal_damage(round(self.max_hp / 3))
	emit_signal("end_turn")

func sing_attack():
	DialogBox.show_timeout("SEA MELODY!", 1)
	yield(DialogBox, "done")
	var battleField = BulletsDownBattleField.instance()
	battleField.base_speed = 80
	battleField.total_bullets = 5
	battleField.stop_point = 30
	battleField.stop_point_time = 1
	battleField.color = "2effff" # Light blue
	battleField.connect("hit", self, "on_BattleField_hit")
	battleField.connect("done", self, "on_BattleField_done")
	battleField.connect("fired", self, "on_BattleField_fired")
	ActionBattle.start_small_field(battleField)

func ink_attack():
	DialogBox.show_timeout("INK ATTACK!", 1)
	yield(DialogBox, "done")
	var battleField = BulletsDownBattleField.instance()
	battleField.base_speed = 90
	battleField.total_bullets = 6
	battleField.connect("hit", self, "on_BattleField_hit")
	battleField.connect("done", self, "on_BattleField_done")
	ActionBattle.start_small_field(battleField)

func on_BattleField_fired():
	$SFXNeutral.play()

func on_BattleField_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func on_BattleField_done():
	emit_signal("end_turn")
