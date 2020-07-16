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
	10: 220,
	11: 260,
	12: 320,
	13: 380,
	14: 450,
}

export var max_hp = 20 setget set_max_hp
var hp = max_hp setget set_hp
var exp_points = 0 setget set_exp_points
var level = 1 setget set_level
export var power = 3 setget set_power
var player_statuses = []
var player_buffs = []

var base_hp = max_hp
var base_power = power

signal hp_changed(value)
signal max_hp_changed(value)
signal power_changed(value)
signal level_changed(value)
signal status_changed(value)
signal debuff(buff)
signal status_healed(value)
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
	player_buffs = []
	emit_signal("status_changed", player_statuses)

func heal_status():
	if player_statuses.has(GameConstants.STATUS.POISON):
		player_statuses.erase(GameConstants.STATUS.POISON)
	emit_signal("status_healed", player_statuses)

func add_buff(buff, turns):
	if player_statuses.has(buff):
		var new_buffs = []
		for buff_pair in player_buffs:
			if buff_pair[0] == buff:
				new_buffs.append([buff, turns])
			else:
				new_buffs.append(buff_pair)
		player_buffs = new_buffs
	else:
		player_buffs.append([buff, turns])
	add_status(buff)

func clear_buffs():
	var new_buffs = []
	for buff_pairs in player_buffs:
		var buff = buff_pairs[0]
		var turns = buff_pairs[1]
		var turns_left = turns - 1
		if turns_left > 0:
			new_buffs.append([buff, turns_left])
		else:
			player_statuses.erase(buff)
			emit_signal("debuff", buff)
			emit_signal("status_changed", player_statuses)
	player_buffs = new_buffs

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

func set_max_hp(value):
	max_hp = value
	emit_signal("max_hp_changed", value)

func end_turn():
	emit_signal("end_turn")

func set_power(value):
	power = value
	emit_signal("power_changed", power)

func set_exp_points(value):
	exp_points = value
	if leveled_up():
		level_up(1)

func leveled_up():
	return level in level_chart and exp_points >= level_chart[level]

func level_up(lv_increase):
	var hp_increase = 2
	var power_increase = 1

	self.level += lv_increase
	self.max_hp += hp_increase
	self.hp += hp_increase
	self.power += power_increase
	
	last_level_up_summary = {
		"lv": lv_increase,
		"hp": hp_increase,
		"power": power_increase,
	}

func set_level(value):
	var old_level = level
	level = clamp(value, 0, 99)
	emit_signal("level_changed", level, old_level)

func _ready():
	BattleUnits.PlayerStats = self
#	load_save()

func reset_plus():
	self.hp = base_hp
	self.power = base_power
	self.level = 1
	self.exp_points = 0
	self.max_hp = 20
	self.hp = self.max_hp
	clear_status()

func reset():
	reset_plus()
	self.max_hp = 20

func load_save():
	var saved_state = SaveFile.load_save("player_stats")
	if saved_state:
		set_data_from_json(saved_state)

func save():
	var data = get_data_json()
	SaveFile.save("player_stats", data)

func get_data_json():
	return {
		"hp": self.hp,
		"power": self.power,
		"level": self.level,
		"exp": self.exp_points,
		"max_hp": self.max_hp,
		"status": self.player_statuses,
	}

func set_data_from_json(json):
	hp = int(json["hp"])
	power = int(json["power"])
	level = int(json["level"])
	exp_points = int(json["exp"])
	max_hp = int(json["max_hp"])
	player_statuses = json["status"]

func _exit_tree():
	BattleUnits.PlayerStats = null
