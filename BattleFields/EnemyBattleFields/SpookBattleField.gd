extends "res://BattleFields/BaseBattleField.gd"

enum STATES{HIDDEN, PEEKING, SHOWING, HIT, MISS}

var hide_time_range = [1, 4]
var peek_time = 0.3
var number_of_peeks = 2
var peek_count = 0
var state = STATES.HIDDEN
var sprites = {
	STATES.HIDDEN: preload("res://Images/SpookSprites/Hood1/Hidden.png"),
	STATES.PEEKING: preload("res://Images/SpookSprites/Hood1/Peeking.png"),
	STATES.SHOWING: preload("res://Images/SpookSprites/Hood1/Showing.png"),
	STATES.HIT: preload("res://Images/SpookSprites/Hood1/Hit.png"),
	STATES.MISS: preload("res://Images/SpookSprites/Hood1/Miss.png"),
}

onready var peekTimer = $Field/PeekTimer
onready var attackTimer = $Field/AttackTimer
onready var doneTimer = $Field/DoneTimer
onready var afterHitTimer = $Field/AfterHitTimer
onready var sprite = $Field/Sprite

func _ready():
	var hide_time = Utils.value_from_float_range(hide_time_range[0], hide_time_range[1])
	peekTimer.wait_time = hide_time
	attackTimer.wait_time = peek_time
	peekTimer.connect("timeout", self, "on_peekTimer_timeout")
	attackTimer.connect("timeout", self, "on_attackTimer_timeout")
	afterHitTimer.connect("timeout", self, "on_afterHitTimer_timeout")
	doneTimer.connect("timeout", self, "on_doneTimer_timeout")
	start()

func update_state(new_state):
	state = new_state
	sprite.texture = sprites[state]

func start():
	update_state(STATES.HIDDEN)
	peek_count += 1
	peekTimer.start()

func on_peekTimer_timeout():
	self.peek()

func peek():
	update_state(STATES.PEEKING)
	attackTimer.start()

func on_attackTimer_timeout():
	update_state(STATES.SHOWING)
	hit()
	afterHitTimer.start()

func on_pressed():
	attackTimer.stop()
	peekTimer.stop()
	if state == STATES.PEEKING:
		update_state(STATES.HIT)
		hit()
	else:
		update_state(STATES.MISS)
		enemy_hit()
	afterHitTimer.start()

func on_doneTimer_timeout():
	done()

func on_afterHitTimer_timeout():
	if peek_count >= number_of_peeks:
		doneTimer.start()
	else:
		start()
