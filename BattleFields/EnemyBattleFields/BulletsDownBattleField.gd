extends "res://BattleFields/BaseBattleField.gd"

enum {LEFT, RIGHT}
var current_pos = LEFT
var movement = Vector2(30, 0)
var base_bullet_position = Vector2(20, -4) # right above the screen
var base_bullet_direction = Vector2(0, 1)

var total_bullets = 4
var bullets_left = total_bullets
var bullets_that_hit = 0
var last_side = null
const Bullet = preload("res://BattleFields/Bullets/Bullet.tscn")
onready var player = $Field/Player

func _ready():
	player.position = Vector2(20, 50)
	yield(get_tree().create_timer(0.5), "timeout")
	randomize()
	fire_bullets()

func fire_bullets():
	if bullets_left > 0:
		fire_bullet()
		bullets_left -= 1
		yield(get_tree().create_timer(0.5), "timeout")
		fire_bullets()

func fire_bullet():
	var side = pick_bullet_side()
	var x_offset = movement if side == RIGHT else Vector2(0,0)
	var bullet_position = base_bullet_position + x_offset
	var bullet_speed_multiplier = 1
	if bullets_left == 2:
		bullet_speed_multiplier = 2
		yield(get_tree().create_timer(0.4), "timeout")
	elif bullets_left == 1:
		bullet_speed_multiplier = 3
		yield(get_tree().create_timer(0.2), "timeout")
	var new_bullet = Bullet.instance()
	new_bullet.stop_point = 25
	new_bullet.color = "ffffff"
	new_bullet.position = bullet_position
	new_bullet.direction = base_bullet_direction
	new_bullet.base_speed = 150
	new_bullet.speed_multiplier = bullet_speed_multiplier
	add_child(new_bullet)
	new_bullet.connect("hit", self, "on_Bullet_hit")
	new_bullet.connect("point_reached", self, "on_Bullet_point_reached")

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

func on_Bullet_hit(target, _bullet_position):
	bullets_that_hit += 1
	if target.name == "Player":
		hit()
	if bullets_that_hit == total_bullets:
		yield(get_tree().create_timer(2), "timeout")
		done()

func on_Bullet_point_reached(bullet):
	bullet.pause()
	yield(get_tree().create_timer(0.8), "timeout")
	bullet.unpause()

func _on_FieldButton_pressed():
	if current_pos == LEFT:
		current_pos = RIGHT
		player.position += movement
	else:
		current_pos = LEFT
		player.position += movement * -1
