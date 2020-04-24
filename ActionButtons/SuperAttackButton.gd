extends "res://ActionButtons/BaseActionButton.gd"

const Slash = preload("res://Animations/Slash.tscn")
const SuperBattleField = preload("res://BattleFields/SuperBattleField.tscn")

func _on_pressed():
	var superBattleField = SuperBattleField.instance()
	superBattleField.connect("hit", self, "_on_superBattleField_hit")
	superBattleField.connect("miss", self, "_on_superBattleField_miss")
	superBattleField.connect("done", self, "_on_superBattleField_done")
	ActionBattle.start_small_field(superBattleField)

func _on_superBattleField_hit(hit_force):
	if(is_battle_ready()):
		animate_slash(enemy.global_position)
		play_sfx(hit_force)
		var damage = get_damage(player.power, hit_force)
		enemy.take_damage(damage, hit_force)

func _on_superBattleField_miss():
	if(is_battle_ready()):
		enemy.take_damage(0)

func _on_superBattleField_done():
	if(is_battle_ready()):
		finish_turn()

func get_damage(power, hit_force):
	match(hit_force):
		GameConstants.HIT_FORCE.CRIT: return ceil(power * 1.1)
		GameConstants.HIT_FORCE.STRONG: return ceil(power * 0.75)
		GameConstants.HIT_FORCE.NORMAL: return ceil(power * 0.5)
		_: return 0

func play_sfx(_hit_force):
	$SFXBlow.play()

func animate_slash(position):
	var slash = Slash.instance()
	var main = get_tree().current_scene
	main.add_child(slash)
	slash.global_position = position
