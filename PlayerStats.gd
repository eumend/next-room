extends Node2D

const BattleUnits = preload("res://BattleUnits.tres")
const level_chart = {
	1: 2,
	2: 12,
	3: 20,
	4: 33,
	5: 50,
	6: 75,
	7: 105,
	8: 140,
	9: 180,
	10: 210,
}

export var max_hp = 20
var hp = max_hp setget set_hp
export var max_ap = 3
var ap = max_ap setget set_ap
export var max_mp = 10
var mp = max_mp setget set_mp
var exp_points = 0 setget set_exp_points
var level = 1 setget set_level
export var power = 3 setget set_power
var player_statuses = []

var base_hp = max_hp
var base_power = power

signal hp_changed(value)
signal ap_changed(value)
signal mp_changed(value)
signal power_changed(value)
signal level_changed(value)
signal status_changed(value)
signal took_damage(value)
signal heal_damage(value)
signal died
signal end_turn

var last_level_up_summary = {}

func is_dead():
	return self.hp <= 0

func heal_all():
	self.hp = self.max_hp
	clear_status()

func reset_plus():
	self.hp = base_hp
	self.power = base_power
	self.level = 1
	self.exp_points = 0
	clear_status()
	self.max_hp = 20 # TODO: Once we enable restart+, this should be removed so the player keeps its current max hp

func reset():
	reset_plus()
	self.max_hp = 20

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

func heal_status():
	if player_statuses.has(GameConstants.STATUS.POISON):
		player_statuses.erase(GameConstants.STATUS.POISON)
		emit_signal("status_changed", player_statuses)

func clear_buffs():
	if player_statuses.has(GameConstants.STATUS.SHIELDED):
		player_statuses.erase(GameConstants.STATUS.SHIELDED)
		emit_signal("status_changed", player_statuses)

func take_status_damage(damage):
	_take_damage(damage, null)

func take_damage(damage, hit_force = null):
	if self.has_status(GameConstants.STATUS.SHIELDED):
		damage = round(damage / 2)
	_take_damage(damage, hit_force)

func _take_damage(damage, hit_force):
	var old_hp = self.hp
	self.hp -= damage
	var damage_amount = old_hp - self.hp
	emit_signal("took_damage", damage_amount, hit_force)

func heal_damage(amount):
	var old_hp = self.hp
	self.hp += amount
	var healed_amount = self.hp - old_hp
	if healed_amount > 0:
		emit_signal("heal_damage", healed_amount)

func set_hp(value):
	hp = clamp(value, 0, max_hp)
	emit_signal("hp_changed", hp)
	if hp == 0:
		emit_signal("died")

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
	emit_signal("power_changed", power)

func set_exp_points(value):
	exp_points = value
	if leveled_up():
		level_up(1) # TODO: Find the real next level? Might be multiple levels!

func leveled_up():
	return level in level_chart and exp_points >= level_chart[level]

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
#	self.hp += self.max_hp
#	self.mp = self.max_mp
	
	last_level_up_summary = {
		"lv": lv_increase,
		"hp": hp_increase,
		"mp": mp_increase,
		"power": power_increase,
	}

func set_level(value):
	var old_level = level
	level = clamp(value, 0, 99)
	emit_signal("level_changed", level, old_level)

func _ready():
	BattleUnits.PlayerStats = self

func _exit_tree():
	BattleUnits.PlayerStats = null
