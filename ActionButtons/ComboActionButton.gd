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
		play_sfx(hit_force)
		var damage = get_damage(player.power, hit_force)
		enemy.take_damage(damage, hit_force)

func _on_MultiHitBattleField_miss():
	if(is_battle_ready()):
		enemy.take_damage(0)

func _on_MultiHitBattleField_done():
	if(is_battle_ready()):
		finish_turn()

func get_damage(power, hit_force):
	match(hit_force):
		GameConstants.HIT_FORCE.CRIT: return ceil(power * 0.8)
		GameConstants.HIT_FORCE.STRONG: return ceil(power * 0.5)
		GameConstants.HIT_FORCE.NORMAL: return ceil(power * 0.3)
		_: return 0

func play_sfx(_hit_force):
	$SFXBlow.play()

func animate_slash(position):
	var slash = Slash.instance()
	var main = get_tree().current_scene
	main.add_child(slash)
	slash.global_position = position
