extends "res://BattleFields/BaseBattleField.gd"

enum {LEFT, RIGHT}
var current_pos = LEFT
var movement = Vector2(30, 0)
var base_bullet_position = Vector2(20, -4) # right above the screen
var base_bullet_direction = Vector2(0, 1)

var total_bullets = 4
var bullets_left = total_bullets
var bullets_that_hit = 0
const Bullet = preload("res://BattleFields/Bullets/Bullet.tscn")

func _ready():
	randomize()
	fire_bullets()

func fire_bullets():
	if bullets_left > 0:
		fire_bullet()
		bullets_left -= 1
		yield(get_tree().create_timer(0.5), "timeout")
		fire_bullets()

func fire_bullet():
	var start_x = [0, 1][randi() % 2] * movement # We want either 0 or the "movement"
	var bullet_position = base_bullet_position + start_x
	var bullet_speed_multiplier = 1
	if bullets_left == 1:
		bullet_speed_multiplier = 2
		yield(get_tree().create_timer(0.4), "timeout")
	var new_bullet = Bullet.instance()
	new_bullet.color = "05fa14"
	new_bullet.position = bullet_position
	new_bullet.direction = base_bullet_direction
	new_bullet.base_speed = 50
	new_bullet.speed_multiplier = bullet_speed_multiplier
	add_child(new_bullet)
	new_bullet.connect("hit", self, "on_Bullet_hit")

func on_Bullet_hit(target, _bullet_position):
	# TODO: Use position to show some animation?
	bullets_that_hit += 1
	if target.name == "Player":
		if bullets_that_hit == total_bullets:
			heal(GameConstants.HIT_FORCE.CRIT)
		else:
			heal()
	else:
		miss()
	if bullets_that_hit == total_bullets:
		yield(get_tree().create_timer(0.3), "timeout")
		done()

func _on_FieldButton_pressed():
	if current_pos == LEFT:
		current_pos = RIGHT
		$Field/Player.position += movement
	else:
		current_pos = LEFT
		$Field/Player.position += movement * -1
