extends "res://BattleFields/BaseBattleField.gd"

const BombBullet = preload("res://BattleFields/Enemy/Utils/BombBullet.tscn")
onready var bulletTimer = $Field/BulletTimer
onready var shooter = $Field/Shooter
onready var shotsLeft = $Field/ShotsLeftBar
enum {TL, TR, BL, BR}
var bullets = [GameConstants.BOMB_BULLET_TYPES.COUNTDOWN]
var min_x = 10
var max_x = 30
var min_y = 10
var max_y = 50
var total_bullets = 0
var bullets_done = 0
var shots_left = 5

func _ready():
	start_battlefield()

func start_battlefield():
	bulletTimer.connect("timeout", self, "_on_bulletTimer_timeout")
	shotsLeft.max_value = shots_left
	shotsLeft.value = shots_left
	total_bullets = bullets.size()
	fire_bullet()

func _on_FieldButton_pressed():
	if shots_left > 0:
		fire_laser()

func fire_laser():
	shooter.fire()
	shots_left -= 1
	shotsLeft.value -= 1

func fire_bullet():
#	bulletTimer.wait_time = get_bullet_wait_time()
	bulletTimer.start()

func _on_bulletTimer_timeout():
	if bullets.size() > 0:
		var next_bullet = bullets.pop_front()
		var bullet_position = get_bullet_position()
		_fire_bullet(next_bullet, bullet_position)
		fire_bullet()

func _fire_bullet(bullet_type, bullet_position):
	$SFXLaser.play()
	var bullet = BombBullet.instance()
	bullet.direction = get_bullet_direction()
	bullet.bullet_type = bullet_type
	bullet.time_seconds = 5
	bullet.position = bullet_position
#	bullet.speed = get_bullet_speed()
	add_child(bullet)
	bullet.connect("hit", self, "on_bombBullet_hit")
	bullet.connect("explode", self, "on_bombBullet_explode")
	bullet.connect("disappear", self, "on_bombBullet_disappear")

func on_bombBullet_hit(target, bullet):
	match(target.name):
		"BorderL", "BorderR":
			bullet.direction = Vector2(bullet.direction.x * -1, bullet.direction.y)
			return
		"BorderT", "BorderB":
			bullet.direction = Vector2(bullet.direction.x, bullet.direction.y * -1)
			return
		"Laser":
			if bullet.bullet_type == GameConstants.BOMB_BULLET_TYPES.COUNTDOWN:
				bullet.disappear()
			else:
				bullet.explode()
			return

func get_bullet_position():
	randomize()
	var bullet_x = rand_range(min_x, max_x)
	var bullet_y = rand_range(min_y, max_y)
	return Vector2(bullet_x, bullet_y)

func get_bullet_direction():
	randomize()
	var side = [TL, TR, BL, BR][randi() % 4]
	match(side):
		TL: return Vector2(rand_range(-1, -sqrt(2) / 2), rand_range(0, sqrt(2) / 2))
		TR: return Vector2(rand_range(sqrt(2) / 2, 1), rand_range(0, sqrt(2) / 2))
		BL: return Vector2(rand_range(-1, -sqrt(2) / 2), rand_range(-sqrt(2) / 2, 0))
		BR: return Vector2(rand_range(sqrt(2) / 2, 1), rand_range(-sqrt(2) / 2, 0))

func on_bombBullet_explode():
	handle_bullet_explode()

func handle_bullet_explode():
	bullets_done += 1
	hit()
	check_finished()

func on_bombBullet_disappear(bullet_type):
	handle_bullet_disappeared(bullet_type)

func handle_bullet_disappeared(bullet_type):
	bullets_done += 1
	if bullet_type == GameConstants.BOMB_BULLET_TYPES.COOLDOWN:
		heal()
	check_finished()

func check_finished():
	if bullets_done == total_bullets:
		doneTimer.start()
