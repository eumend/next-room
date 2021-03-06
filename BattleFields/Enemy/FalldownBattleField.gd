extends "res://BattleFields/BaseBattleField.gd"

enum {TOP, BOTTOM, LEFT, RIGHT}
const Bullet = preload("res://BattleFields/Enemy/Utils/FallingDownBullet.tscn")

var force = Vector2(0, -3)
#var y_range = [10, 30]
var x_left = -10
var x_right = 82
export var bullet_time = 3

export var move_time = 3
var move_limit_mapping = {
	TOP: 50,
	BOTTOM: 50,
}
export var time_limit = 10
export var ceil_data = {
	"can_kill": true,
	"time": 1,
	"force": 10,
}
export var floor_data = {
	"can_kill": true,
	"time": 1,
	"force": 10,
}

onready var field = $Field
onready var player = $Field/Player
onready var bfFloor = $Field/BFFloor
onready var bfCeil =  $Field/BFCeiling
onready var closeInTimer = $Field/CloseInTimer
onready var bulletTimer = $Field/BulletTimer
onready var touchLimitSFX = $Field/TouchLimitSFX
onready var playerAnimation = $Field/Player/playerAnimation
onready var doneCooldownTimer = $DoneCooldownTimer

signal hit_limit
signal hit_bullet

var in_done = false

func _ready():
	bfFloor.can_kill = floor_data["can_kill"]
	bfCeil.can_kill = ceil_data["can_kill"]
	player.connect("body_entered", self, "on_player_body_entered")
	closeInTimer.connect("timeout", self, "on_close_in_timer_timeout")
	bulletTimer.connect("timeout", self, "on_bulletTimer_timeout")
	doneCooldownTimer.connect("timeout", self, "on_doneCooldownTimer_timeout")
	if move_time > 0:
		closeInTimer.wait_time = move_time
		closeInTimer.start()
	if bullet_time > 0:
		bulletTimer.wait_time = bullet_time
		bulletTimer.start()
	if time_limit > 0:
		doneCooldownTimer.wait_time = time_limit
		doneCooldownTimer.start()

func on_doneCooldownTimer_timeout():
	done_with_cooldown()

func done_with_cooldown(): # We want a tiny bit of buffer between the BF hiding and finishing the turn, since the player is probably still pressing down
	if not in_done:
		in_done = true
		self.hide()
		field.queue_free()
		doneTimer.start()

func on_bulletTimer_timeout():
	var bullet = Bullet.instance()
	var side = Utils.pick_from_list([LEFT, RIGHT])
	bullet.direction = Vector2(1, 0) if side == LEFT else Vector2(-1, 0)
	var bullet_x = x_left if side == LEFT else x_right
#	var bullet_y = rand_range(y_range[0], y_range[1])
	var bullet_y = player.position.y
	bullet.connect("hit", self, "on_bullet_hit")
	bullet.position = Vector2(bullet_x, bullet_y)
	add_child(bullet)

func on_bullet_hit():
	playerAnimation.play("Hit")
	emit_signal("hit_bullet")

func on_close_in_timer_timeout():
	$SFXCrack.play()
	var side = Utils.pick_from_weighted(move_limit_mapping)
	if side == TOP:
		bfCeil.move(ceil_data["force"], ceil_data["time"])
	elif side == BOTTOM:
		bfFloor.move(floor_data["force"], floor_data["time"])

func on_player_body_entered(node):
	if (floor_data["can_kill"] and node.name == "BFFloor") or (ceil_data["can_kill"] and node.name == "BFCeiling"):
		emit_signal("hit_limit")
		touchLimitSFX.play()
		done_with_cooldown()

func _on_FieldButton_pressed():
	player.apply_impulse(Vector2(), force)
