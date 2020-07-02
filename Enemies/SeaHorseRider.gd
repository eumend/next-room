extends "res://Enemies/BaseEnemy.gd"

const BulletsDownBattleField = preload("res://BattleFields/Enemy/BulletsDownBattleField.tscn")
const noteSprite = preload("res://Images/BattleFields/BulletsDown/NoteBullet.png")

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
	var dialog = show_attack_text("I'M TIRED...")
	yield(dialog, "done")
	.heal_damage(round(self.max_hp / 3))
	emit_signal("end_turn")

func sing_attack():
	show_attack_text("SEA MELODY!")
	var battleField = BulletsDownBattleField.instance()
	battleField.base_speed = 70
	battleField.total_bullets = 5
	battleField.stop_point = 30
	battleField.stop_point_time = 1
	battleField.sprite = noteSprite
	battleField.color = "2effff" # Light blue
	battleField.connect("hit", self, "on_BattleField_hit")
	battleField.connect("done", self, "on_BattleField_done")
	battleField.connect("fired", self, "on_BattleField_fired")
	ActionBattle.start_small_field(battleField)

func ink_attack():
	show_attack_text("INK ATTACK!")
	var battleField = BulletsDownBattleField.instance()
	battleField.base_speed = 52
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
