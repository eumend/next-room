extends "res://ActionButtons/BaseActionButton.gd"

const Slash = preload("res://Animations/Slash.tscn")
const MultiHitBattleField = preload("res://BattleFields/MultiHitBattleField.tscn")

func _on_pressed():
	var multiHitBattleField = MultiHitBattleField.instance()
	multiHitBattleField.connect("hit", self, "_on_MultiHitBattleField_hit")
	multiHitBattleField.connect("miss", self, "_on_MultiHitBattleField_miss")
	multiHitBattleField.connect("done", self, "_on_MultiHitBattleField_done")
	ActionBattle.start_small_field(multiHitBattleField)

func _on_MultiHitBattleField_hit(hit_force):
	if(is_battle_ready()):
		animate_slash(enemy.global_position)
		var damage = get_damage(player.power, hit_force)
		enemy.take_damage(damage, hit_force)

func _on_MultiHitBattleField_miss():
	if(is_battle_ready()):
		enemy.take_damage(0)

func _on_MultiHitBattleField_done():
	if(is_battle_ready()):
		player.mp += 2
		player.ap -= ap_cost

func get_damage(player_power, hit_force):
	var power = round(player_power / 2)
	match(hit_force):
		GameConstants.HIT_FORCE.CRIT: return power + 2
		GameConstants.HIT_FORCE.STRONG: return power + 1
		GameConstants.HIT_FORCE.NORMAL: return power
		_: return 0

func animate_slash(position):
	var slash = Slash.instance()
	var main = get_tree().current_scene
	main.add_child(slash)
	slash.global_position = position