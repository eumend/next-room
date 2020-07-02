extends "res://Enemies/BaseEnemy.gd"

const BulletsDownBattleField = preload("res://BattleFields/Enemy/BulletsDownBattleField.tscn")
const noteSprite = preload("res://Images/BattleFields/BulletsDown/NoteBullet.png")

func get_attack_pattern():
	return {
		"default_attack": 30,
		"sing_attack": 70,
	}

func sing_attack():
	show_attack_text("SEA MELODY!")
	var battleField = BulletsDownBattleField.instance()
	battleField.base_speed = 60
	battleField.total_bullets = 4
	battleField.stop_point = 30
	battleField.stop_point_time = 1
	battleField.sprite = noteSprite
	battleField.connect("hit", self, "on_BattleField_hit")
	battleField.connect("done", self, "on_BattleField_done")
	battleField.connect("fired", self, "on_BattleField_fired")
	ActionBattle.start_small_field(battleField)

func on_BattleField_fired():
	$SFXNeutral.play()

func on_BattleField_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func on_BattleField_done():
	emit_signal("end_turn")
