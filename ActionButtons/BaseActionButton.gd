extends Button

const BattleUnits = preload("res://BattleUnits.tres")
const ActionBattle = preload("res://ActionBattle.tres")
var player = null
var enemy = null

export(int) var ap_cost = 1

func _on_pressed():
	pass # Replace with function body.
	
func is_battle_ready():
	enemy = BattleUnits.Enemy
	player = BattleUnits.PlayerStats
	return enemy != null and player != null

func is_player_ready():
	player = BattleUnits.PlayerStats
	return player != null
