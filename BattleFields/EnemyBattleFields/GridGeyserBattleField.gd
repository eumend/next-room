extends "res://BattleFields/BaseBattleField.gd"

const GeyserAnimation = preload("res://Animations/GeyserAnimation.tscn")

enum POSITIONS{TL, TR, BL, BR}
enum FIRING_STATUS{IDLE, ERUPTING, FIRING}
# w =72, h = 60
var player_coords = {
	POSITIONS.TL: Vector2(18, 15),
	POSITIONS.TR: Vector2(54, 15),
	POSITIONS.BL: Vector2(18, 45),
	POSITIONS.BR: Vector2(54, 45),
}

var enemy_coords = {
	POSITIONS.TL: Vector2(17, 0),
	POSITIONS.TR: Vector2(55, 0),
	POSITIONS.BL: Vector2(17, 31),
	POSITIONS.BR: Vector2(55, 31),
}

var enemy_z_index_post = {
	POSITIONS.TL: 0,
	POSITIONS.TR: 0,
	POSITIONS.BL: 1,
	POSITIONS.BR: 1,
}

var firing_status = {
	POSITIONS.TL: FIRING_STATUS.IDLE,
	POSITIONS.TR: FIRING_STATUS.IDLE,
	POSITIONS.BL: FIRING_STATUS.IDLE,
	POSITIONS.BR: FIRING_STATUS.IDLE,
}

export var geyser_amount = 4
var geysers_left = geyser_amount
var geysers_done = 0

onready var player = $Field/Player
var current_player_position = null

func _ready():
	var starting_position = [POSITIONS.TL, POSITIONS.TR, POSITIONS.BL, POSITIONS.BR][randi() % 4]
	change_player_position(starting_position)
	player.show()
	spawn_geysers(starting_position)

func init(new_amount = 4):
	geyser_amount = new_amount
	geysers_left = new_amount

func spawn_geysers(position = null):
	if position == null:
		var free_positions = []
		for s in firing_status:
			if firing_status[s] == FIRING_STATUS.IDLE:
				free_positions.append(s)
		position = free_positions[randi() % free_positions.size()]
	spawn_geyser(position)
	geysers_left -= 1
	if geysers_left > 0:
		var time = 1.0 if geysers_left > 2 else 0.8
		yield(get_tree().create_timer(time), "timeout")
		spawn_geysers()

func spawn_geyser(position):
	yield(get_tree().create_timer(0.5), "timeout")
	var new_geyser = GeyserAnimation.instance()
	new_geyser.set_time(1.2)
	$Field/Geysers.add_child(new_geyser)
	new_geyser.position = enemy_coords[position]
	new_geyser.z_index = enemy_z_index_post[position]
	firing_status[position] = FIRING_STATUS.ERUPTING
	new_geyser.connect("fired", self, "on_GeyserAnimation_fired", [position])
	new_geyser.connect("done", self, "on_GeyserAnimation_done", [position])

func on_GeyserAnimation_done(position):
	firing_status[position] = FIRING_STATUS.IDLE
	geysers_done += 1
	if geysers_done == geyser_amount:
		done()

func on_GeyserAnimation_fired(position):
	$SFXErupt.play()
	firing_status[position] = FIRING_STATUS.FIRING
	if current_player_position == position:
		enemy_hit(GameConstants.HIT_FORCE.CRIT)

func move(position):
	if is_next_to(position):
		change_player_position(position)
		if firing_status[position] == FIRING_STATUS.FIRING:
			enemy_hit(GameConstants.HIT_FORCE.NORMAL)

func change_player_position(position):
		current_player_position = position
		player.position = player_coords[position]

func _on_TL_pressed():
	move(POSITIONS.TL)


func _on_TR_pressed():
	move(POSITIONS.TR)


func _on_BL_pressed():
	move(POSITIONS.BL)


func _on_BR_pressed():
	move(POSITIONS.BR)

func is_next_to(position):
	match(position):
		POSITIONS.TL: return [POSITIONS.TR, POSITIONS.BL].has(current_player_position)
		POSITIONS.TR: return [POSITIONS.TL, POSITIONS.BR].has(current_player_position)
		POSITIONS.BL: return [POSITIONS.TL, POSITIONS.BR].has(current_player_position)
		POSITIONS.BR: return [POSITIONS.TR, POSITIONS.BL].has(current_player_position)
