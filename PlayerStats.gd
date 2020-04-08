extends Node2D

const BattleUnits = preload("res://BattleUnits.tres")
const level_chart = {
	1: 5,
	2: 12,
	3: 25
}

export var max_hp = 25
var hp = max_hp setget set_hp
export var max_ap = 3
var ap = max_ap setget set_ap
export var max_mp = 10
var mp = max_mp setget set_mp
var exp_points = 0 setget set_exp_points
var level = 1 setget set_level
var power = 4 setget set_power
var player_statuses = []

signal hp_changed(value)
signal ap_changed(value)
signal mp_changed(value)
signal level_changed(value)
signal level_up(value)
signal get_status(value)
signal end_turn

func is_under_status():
	return player_statuses.size() > 0

func has_status(status):
	return player_statuses.has(status)

func add_status(new_status):
	if not player_statuses.has(new_status):
		player_statuses.append(new_status)
		emit_signal("status_changed", player_statuses)

func clear_status():
	player_statuses = []
	emit_signal("status_changed", player_statuses)

func take_damage(damage):
	self.hp -= damage

func set_hp(value):
	hp = clamp(value, 0, max_hp)
	emit_signal("hp_changed", hp)

func set_ap(value):
	ap = clamp(value, 0, max_ap)
	emit_signal("ap_changed", ap)
	if ap == 0:
		emit_signal("end_turn")

func set_mp(value):
	mp = clamp(value, 0, max_mp)
	emit_signal("mp_changed", mp)

func set_power(value):
	power = value
#	emit_signal("power_changed", power)

func set_exp_points(value):
	exp_points = value
	if leveled_up():
		level_up(1) # TODO: Find the real next level? Might be multiple levels!

func leveled_up():
	return exp_points >= level_chart[level]

func level_up(lv_increase):
	# get increments, TODO: Make them depend on level?
	var hp_increase = 2
	var mp_increase = 2
	var power_increase = 1
	
	# Increase stats
	self.level += lv_increase
	self.max_hp += hp_increase
	self.max_mp += mp_increase
	self.power += power_increase
	
	# Heal
	self.hp = self.max_hp
	self.mp = self.max_mp
	
	emit_signal("level_up", {
		"lv": lv_increase,
		"hp": hp_increase,
		"mp": mp_increase,
		"power": power_increase,
	})

func set_level(value):
	level = clamp(value, 0, 99)
	emit_signal("level_changed", level)

func _ready():
	BattleUnits.PlayerStats = self

func _exit_tree():
	BattleUnits.PlayerStats = null
