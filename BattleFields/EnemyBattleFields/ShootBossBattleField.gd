extends "res://BattleFields/EnemyBattleFields/ShootEmUpBattleField.gd"

signal boss_hit

onready var bossBullet = $Field/BossBullet
onready var bossHP = $Field/BossHP

var bullet_pattern = {
	GameConstants.BOMB_BULLET_TYPES.COOLDOWN: 50,
	GameConstants.BOMB_BULLET_TYPES.COUNTDOWN: 50,
}

var bullet_time = 2
var pause = false
var initial_bullets = 0
var boss_sprite = null
var boss_hp = null

func _ready():
	bulletTimer.wait_time = bullet_time
	bossBullet.position = get_bullet_position()
	bossBullet.direction = get_bullet_direction()
	if boss_sprite:
		bossBullet.boss_sprite = boss_sprite
	if boss_hp:
		bossBullet.hp = boss_hp
	bossHP.max_value = bossBullet.hp
	bossHP.value = bossBullet.hp
	bossBullet.connect("hit", self, "on_bossBullet_hit")
	bossBullet.connect("hp_changed", self, "on_bossBullet_hp_changed")
	bossBullet.connect("died", self, "on_bossBullet_hp_died")
	shotsLeft.max_value = shots_left
	shotsLeft.value = shots_left
	bulletTimer.connect("timeout", self, "_on_bulletTimer_timeout")
	bulletTimer.start()
	fire_initial()

func fire_initial():
	for _i in range(0, initial_bullets):
		fire_bullet()

func fire_bullet():
	var bullet_type = Utils.pick_from_weighted(bullet_pattern)
	var bullet_position = bossBullet.position
	_fire_bullet(bullet_type, bullet_position)

func _on_bulletTimer_timeout():
	if not pause:
		fire_bullet()
		bulletTimer.start()

func fire_laser():
	shooter.fire()

func start_battlefield():
	pass

func handle_bullet_explode():
	if not pause:
		.handle_bullet_explode()

func handle_bullet_disappeared():
	if not pause:
		.handle_bullet_disappeared()

func on_bossBullet_hit(target, bullet):
	match(target.name):
		"BorderL", "BorderR":
			bullet.direction = Vector2(bullet.direction.x * -1, bullet.direction.y)
			return
		"BorderT", "BorderB":
			bullet.direction = Vector2(bullet.direction.x, bullet.direction.y * -1)
			return
		"Laser":
			bullet.take_hit()
			emit_signal("boss_hit")
			return

func on_bossBullet_hp_changed(hp):
	bossHP.value = hp
	if hp <= 0: # We want to pause already when the death animation starts
		pause = true

func on_bossBullet_hp_died():
	doneTimer.start()

