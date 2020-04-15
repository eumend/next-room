extends Resource
class_name BattleUnits

var PlayerStats = null
var Enemy = null
var current_turn = null

func set_current_turn(unit):
	current_turn = unit

func is_player_turn():
	return current_turn == GameConstants.UNITS.PLAYER

func is_enemy_turn():
	return current_turn == GameConstants.UNITS.ENEMY
