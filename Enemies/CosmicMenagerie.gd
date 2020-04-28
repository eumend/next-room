extends "res://Enemies/BaseEnemy.gd"

const ShootBossBattleField = preload("res://BattleFields/EnemyBattleFields/ShootBossBattleField.tscn")
const ShootEmUpBattleField = preload("res://BattleFields/EnemyBattleFields/ShootEmUpBattleField.tscn")
const BossSprite = preload("res://Images/ShootEmUp/ufo_2.png")

export var min_bullets = 3
export var max_bullets = 5

func get_attack_pattern():
	return {
		"saucer_attack": 70,
		"shoot_em_attack": 30,
	}

func saucer_attack():
	DialogBox.show_timeout("- - -", 1)
	yield(DialogBox, "done")
	var battleField = ShootBossBattleField.instance()
	battleField.initial_bullets = 2
	battleField.bullet_time = 2
	battleField.boss_sprite = BossSprite
	battleField.boss_hp = 5
	battleField.connect("hit", self, "on_bossBattleField_hit")
	battleField.connect("done", self, "on_BattleField_done")
	battleField.connect("boss_hit", self, "on_BattleField_boss_hit")
	ActionBattle.start_small_field(battleField)

func shoot_em_attack():
	DialogBox.show_timeout(". . .", 1)
	yield(DialogBox, "done")
	var battleField = ShootEmUpBattleField.instance()
	var bullets = get_bullets()
	battleField.bullets = bullets
	battleField.shots_left = bullets.size()
	battleField.connect("hit", self, "on_shootBattleField_hit")
	battleField.connect("done", self, "on_BattleField_done")
	ActionBattle.start_small_field(battleField)

func get_bullets():
	randomize()
	var qty = rand_range(min_bullets, max_bullets)
	var bullets = []
	for _i in range(0, qty):
		var bullet_type = [GameConstants.BOMB_BULLET_TYPES.COUNTDOWN, GameConstants.BOMB_BULLET_TYPES.COOLDOWN][randi() % 2]
		bullets.append(bullet_type)
	return bullets

func on_BattleField_boss_hit():
	.take_damage(round(self.max_hp * 0.05))

func on_bossBattleField_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG, round(self.power * 0.8))

func on_shootBattleField_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func on_BattleField_done():
	emit_signal("end_turn")
