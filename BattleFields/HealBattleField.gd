extends "res://BattleFields/BaseBattleField.gd"

enum {LEFT, RIGHT}
var current_pos = LEFT
var movement = Vector2(30, 0)
var base_bullet_position = Vector2(20, -4) # right above the screen
var last_side = null

var total_bullets = 4
var bullets_left = total_bullets
var bullets_that_hit = 0
var base_speed = 70
const Bullet = preload("res://BattleFields/Bullets/Bullet.tscn")
onready var bulletTimer = $FireBulletTimer
onready var doneTimer = $DoneTimer

func _ready():
	bulletTimer.connect("timeout", self, "on_bulletTimer_timeout")
	doneTimer.connect("timeout", self, "on_doneTimer_timeout")
	fire_bullet()

func fire_bullet():
	bulletTimer.wait_time = get_bullet_wait_time()
	bulletTimer.start()

func on_bulletTimer_timeout():
	if bullets_left > 0:
		_fire_bullet()
		bullets_left -= 1
		fire_bullet()

func _fire_bullet():
	var side = pick_bullet_side()
	var x_offset = movement if side == RIGHT else Vector2(0,0)
	var bullet_position = base_bullet_position + x_offset
	var new_bullet = Bullet.instance()
	new_bullet.position = bullet_position
	new_bullet.speed = get_bullet_speed()
	add_child(new_bullet)
	new_bullet.connect("hit", self, "on_Bullet_hit")

func get_bullet_speed():
	match(bullets_left):
		1: return base_speed * 2
		2: return base_speed * 1.5
		_: return base_speed

func get_bullet_wait_time():
	match(bullets_left):
		1: return 0.8
		_: return 0.5

func pick_bullet_side():
	if last_side != null:
		if last_side == LEFT:
			last_side = Utils.pick_from_weighted({ LEFT: 25, RIGHT: 75 })
			return last_side
		else:
			last_side = Utils.pick_from_weighted({ LEFT: 75, RIGHT: 25 })
			return last_side
	else:
		last_side = [LEFT, RIGHT][randi() % 2]
		return last_side

func on_Bullet_hit(target, bullet):
	bullets_that_hit += 1
	if target.name == "Player":
		bullet.color = "05fa14" # Green
		bullet.explode()
		if bullets_that_hit == total_bullets:
			heal(GameConstants.HIT_FORCE.CRIT)
		else:
			heal()
	else:
		bullet.disappear()
		miss()
	if bullets_that_hit == total_bullets:
		doneTimer.start()

func on_doneTimer_timeout():
	done()

func _on_FieldButton_pressed():
	if current_pos == LEFT:
		current_pos = RIGHT
		$Field/Player.position += movement
	else:
		current_pos = LEFT
		$Field/Player.position += movement * -1
