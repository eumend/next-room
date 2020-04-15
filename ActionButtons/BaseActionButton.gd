extends Button

const BattleUnits = preload("res://BattleUnits.tres")
const ActionBattle = preload("res://ActionBattle.tres")
var player = null
var enemy = null

export(int) var ap_cost = 1
export(int) var level_required = 1

func is_learned():
	player = BattleUnits.PlayerStats
	return player and player.level >= level_required

func is_disabled():
	return false

func _on_pressed():
	pass # Replace with function body.
	
func is_battle_ready():
	enemy = BattleUnits.Enemy
	player = BattleUnits.PlayerStats
	return enemy != null and player != null

func is_player_ready():
	player = BattleUnits.PlayerStats
	return player != null

func finish_turn():
	if(is_battle_ready()):
		player.ap -= player.max_ap
