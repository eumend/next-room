extends "res://ActionButtons/BaseActionButton.gd"

const HealBattleField = preload("res://BattleFields/HealBattleField.tscn")

func _on_pressed():
	var healBattleField = HealBattleField.instance()
	healBattleField.connect("heal", self, "_on_HealBattleField_heal")
	healBattleField.connect("miss", self, "_on_HealBattleField_miss")
	healBattleField.connect("done", self, "_on_HealBattleField_done")
	ActionBattle.start_small_field(healBattleField)
#	if(is_player_ready()):
#		if player.mp >= 8:
#			player.hp += 5
#			player.mp -= 8
#			player.ap -= ap_cost
#

func _on_HealBattleField_heal(amount):
	if(is_battle_ready()):
		player.hp += amount

func _on_HealBattleField_miss():
	if(is_battle_ready()):
		pass

func _on_HealBattleField_done():
	if(is_battle_ready()):
		player.ap -= ap_cost

#extends "res://ActionButtons/BaseActionButton.gd"
#
#const Slash = preload("res://Animations/Slash.tscn")
#const healBattleField = preload("res://BattleFields/healBattleField.tscn")
#
#func _on_pressed():
#	var healBattleField = healBattleField.instance()
#	healBattleField.connect("hit", self, "_on_healBattleField_hit")
#	healBattleField.connect("miss", self, "_on_healBattleField_miss")
#	healBattleField.connect("done", self, "_on_healBattleField_done")
#	ActionBattle.start_small_field(healBattleField)
#
#func _on_HealBattleField_hit(hit_force):
#	if(is_battle_ready()):
#		animate_slash(enemy.global_position)
#		var damage = get_damage(player.power, hit_force)
#		enemy.take_damage(damage, hit_force)
#
#func _on_HealBattleField_miss():
#	if(is_battle_ready()):
#		enemy.take_damage(0)
#
#func _on_HealBattleField_done():
#	if(is_battle_ready()):
#		player.mp += 2
#		player.ap -= ap_cost
#
#func get_damage(power, hit_force):
#	match(hit_force):
#		GameConstants.HIT_FORCE.CRIT: return power + 2
#		GameConstants.HIT_FORCE.STRONG: return power + 1
#		GameConstants.HIT_FORCE.NORMAL: return power
#		_: return 0
#
#func animate_slash(position):
#	var slash = Slash.instance()
#	var main = get_tree().current_scene
#	main.add_child(slash)
#	slash.global_position = position
