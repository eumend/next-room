extends "res://ActionButtons/BaseActionButton.gd"

const Slash = preload("res://Animations/Slash.tscn")
const SingleHitBattleField = preload("res://BattleFields/SingleHitBattleField.tscn")

func _on_pressed():
	var singleHitBattleField = SingleHitBattleField.instance()
	singleHitBattleField.connect("hit", self, "_on_SingleHitBattleField_hit")
	singleHitBattleField.connect("miss", self, "_on_SingleHitBattleField_miss")
	singleHitBattleField.connect("done", self, "_on_SingleHitBattleField_done")
	ActionBattle.start_small_field(singleHitBattleField)

func _on_SingleHitBattleField_hit(hit_force):
	var enemy = BattleUnits.Enemy
	var playerStats = BattleUnits.PlayerStats
	if enemy != null and playerStats != null:
		animate_slash(enemy.global_position)
		var damage = get_damage(playerStats.power, hit_force)
		enemy.take_damage(damage, hit_force)

func _on_SingleHitBattleField_miss():
	var enemy = BattleUnits.Enemy
	var playerStats = BattleUnits.PlayerStats
	if enemy != null and playerStats != null:
		enemy.take_damage(0)

func _on_SingleHitBattleField_done():
	var enemy = BattleUnits.Enemy
	var playerStats = BattleUnits.PlayerStats
	if enemy != null and playerStats != null:
		playerStats.mp += 2
		playerStats.ap -= ap_cost

func get_damage(power, hit_force):
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
