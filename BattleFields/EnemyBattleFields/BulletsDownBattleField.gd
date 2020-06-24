extends "res://BattleFields/BaseBattleField.gd"

enum {LEFT, RIGHT}
signal fired
var current_pos = LEFT
var movement = Vector2(30, 0)
var base_bullet_position = Vector2(20, -4) # right above the screen
var last_side = null

var total_bullets = 4 setget set_total_bullets
var bullets_left = total_bullets
var bullets_that_hit = 0
var fired_bullets = 0
var stop_point = null
var stop_point_time = null
var base_speed = 50
var color = "ffffff"
var sprite = null
const Bullet = preload("res://BattleFields/Bullets/StopBullet.tscn")
onready var bulletTimer = $FireBulletTimer
onready var player = $Field/Player

func _ready():
	player.position = Vector2(20, 50)
	bulletTimer.connect("timeout", self, "on_bulletTimer_timeout")
	fire_bullet()

func fire_bullet():
	fired_bullets += 1
	bulletTimer.wait_time = get_bullet_wait_time()
	bulletTimer.start()

func on_bulletTimer_timeout():
	if bullets_left > 0:
		_fire_bullet()
		bullets_left -= 1
		fire_bullet()

func _fire_bullet():
	$SFXLaser.play()
	var side = pick_bullet_side()
	var x_offset = movement if side == RIGHT else Vector2(0,0)
	var bullet_position = base_bullet_position + x_offset
	var new_bullet = Bullet.instance()
	if stop_point and stop_point_time:
		new_bullet.stop_point = stop_point
		new_bullet.stop_point_time = stop_point_time
	if sprite:
		new_bullet.sprite = sprite
	new_bullet.color = color
	new_bullet.position = bullet_position
	new_bullet.speed = get_bullet_speed()
	new_bullet.connect("hit", self, "on_Bullet_hit")
	add_child(new_bullet)
	emit_signal("fired")

func get_bullet_speed():
	var fired_bullets_left = total_bullets - fired_bullets
	match(fired_bullets_left):
		0: return base_speed * 2
		1: return base_speed * 1.5
		_: return base_speed

func get_bullet_wait_time():
	var fired_bullets_left = total_bullets - fired_bullets
	match(fired_bullets_left):
		0: return 0.6
		1: return 0.5
		_: return 0.4

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
		bullet.color = "ff0000" # Red
		bullet.explode()
		hit()
	else:
		bullet.disappear()
	if bullets_that_hit == total_bullets:
		doneTimer.start()

func _on_FieldButton_pressed():
	if current_pos == LEFT:
		current_pos = RIGHT
		$Field/Player.position += movement
	else:
		current_pos = LEFT
		$Field/Player.position += movement * -1

func set_total_bullets(new_total_bullets):
	total_bullets = new_total_bullets
	bullets_left = new_total_bullets
