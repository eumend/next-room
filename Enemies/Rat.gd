extends "res://Enemies/BaseEnemy.gd"

func get_hit_force_pattern():
	return {
		GameConstants.HIT_FORCE.NORMAL: 40,
		GameConstants.HIT_FORCE.STRONG: 35,
		GameConstants.HIT_FORCE.CRIT: 25,
	}
