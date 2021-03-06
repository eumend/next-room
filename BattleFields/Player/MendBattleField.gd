extends "res://BattleFields/BaseBattleField.gd"

const Bullet = preload("res://BattleFields/Enemy/Utils/Bullet.tscn")

onready var player = $Field/Player
onready var bulletTimer = $Field/BulletTimer

const TOTAL_WIDTH = 72
const MARGIN = 15

# Player
var min_starting_x = 0 + MARGIN
var max_starting_x = TOTAL_WIDTH - MARGIN
var starting_y = 50

# Bullets
var total_bullets = 8
var bullets_left = total_bullets
var bullets_that_hit = 0
var fired_bullets = 0
var base_speed = 85
var bullet_starting_y = -4 # Above the screen


func _ready():
	bulletTimer.connect("timeout", self, "on_bulletTimer_timeout")
	start_player_bumper()
	fire_bullet()

func start_player_bumper():
	randomize()
	var middle_of_field = min_starting_x + (max_starting_x - min_starting_x) / 2
	var starting_direction = 1
	player.position = Vector2(middle_of_field, starting_y)
	player.direction = starting_direction
	player.speed = 200
	player.start()

func fire_bullet():
	fired_bullets += 1
#	bulletTimer.wait_time = get_bullet_wait_time()
#	bulletTimer.start()

func _fire_bullet():
	var new_bullet = Bullet.instance()
	new_bullet.position = Vector2(rand_range(min_starting_x, max_starting_x), bullet_starting_y)
	new_bullet.speed = get_bullet_speed()
	if is_special(fired_bullets):
		new_bullet.color = "00ffed" # Blue
	add_child(new_bullet)
	new_bullet.connect("hit", self, "on_Bullet_hit")

func on_Bullet_hit(target, bullet):
	bullets_that_hit += 1
	if target.name == "Player":
		if is_special(bullets_that_hit):
			heal(GameConstants.HIT_FORCE.CRIT)
			heal_status()
		else:
			bullet.color = "05fa14" # Green
			heal()
		bullet.explode()
	else:
		bullet.disappear()
		miss()
	if bullets_that_hit == total_bullets:
		doneTimer.start()

func is_special(bullet_count):
	return bullet_count == total_bullets or bullet_count == ceil(total_bullets / 2)

func get_bullet_speed():
	match(bullets_left):
		1: return base_speed * 1.5
		2: return base_speed * 1.3
		3: return base_speed * 1.1
		_: return base_speed

func get_bullet_wait_time():
	match(bullets_left):
		1: return 0.6
		_: return 0.7

func on_bulletTimer_timeout():
	if bullets_left > 0:
		_fire_bullet()
		bullets_left -= 1
		fire_bullet()

func _on_FieldButton_pressed():
	if player.paused:
		player.start()
	else:
		player.change_direction()

func _on_BorderL_area_entered(area):
	if area.name == "Player":
		player.stop()
		player.direction = 1


func _on_BorderR_area_entered(area):
	if area.name == "Player":
		player.stop()
		player.direction = -1


func _on_BorderB_area_entered(_area):
	pass # Replace with function body.
