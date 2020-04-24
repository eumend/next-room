extends "res://BattleFields/BaseBattleField.gd"

enum {LEFT, RIGHT}

const PlayerBumper = preload("res://BattleFields/Players/PlayerBumper.tscn")
onready var bumperTimer = $BumperTimer
onready var hitZone = $Field/HitZone

const min_y = 13
const max_y = 44
const left_x = -2
const rigth_x = 72
const number_of_bumpers = 8
var fired_bumpers = 0
var last_side = null

func _ready():
	bumperTimer.connect("timeout", self, "_on_bumperTimer_timeout")

func fire_bumper():
	var side = pick_bullet_side()
	var bumper_x = left_x if side == LEFT else rigth_x
	var bumper_y = rand_range(min_y, max_y)
	var starting_position = Vector2(bumper_x, bumper_y)
	var direction = 1 if side == LEFT else -1
	
	var playerBumper = PlayerBumper.instance()
	playerBumper.position = starting_position
	playerBumper.direction = direction
	playerBumper.speed = 120
	add_child(playerBumper)
	playerBumper.add_to_group("bumpers")
	playerBumper.connect("hit", self, "on_playerBumper_hit")

func on_playerBumper_hit():
	emit_signal("hit", GameConstants.HIT_FORCE.NORMAL)

func _on_FieldButton_pressed():
	var overlapping = hitZone.get_overlapping_areas()
	if overlapping.size() > 0:
		get_tree().call_group("bumpers", "check_overlap", hitZone)
	else:
		emit_signal("miss")
		get_tree().call_group("bumpers", "disappear")

func _on_bumperTimer_timeout():
	if fired_bumpers < number_of_bumpers:
		fire_bumper()
		fired_bumpers += 1
	else:
		bumperTimer.stop()
		yield(get_tree().create_timer(1), "timeout") # FIXME: We just wait for all bumpers to be done, this is enough for now
		done()

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
