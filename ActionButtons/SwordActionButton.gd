extends "res://ActionButtons/BaseActionButton.gd"

const Slash = preload("res://Animations/Slash.tscn")
const SingleHitBattleField = preload("res://BattleFields/Player/SingleHitBattleField.tscn")

var battlefield_done = false

func _on_pressed():
	var singleHitBattleField = SingleHitBattleField.instance()
	singleHitBattleField.connect("hit", self, "_on_SingleHitBattleField_hit")
	singleHitBattleField.connect("miss", self, "_on_SingleHitBattleField_miss")
	singleHitBattleField.connect("done", self, "_on_SingleHitBattleField_done")
	ActionBattle.start_small_field(singleHitBattleField)

func _on_SingleHitBattleField_hit(hit_force):
	if(is_battle_ready()):
		animate_slash(enemy.global_position)
		play_sfx(hit_force)
		var damage = get_damage(player.power, hit_force)
		enemy.take_damage(damage, hit_force)

func _on_SingleHitBattleField_miss():
	if(is_battle_ready()):
		enemy.take_damage(0)
		finish_turn()

func _on_SingleHitBattleField_done():
	battlefield_done = true

func get_damage(power, hit_force):
	match(hit_force):
		GameConstants.HIT_FORCE.CRIT: return power + ceil(power / 2)
		GameConstants.HIT_FORCE.STRONG: return power
		GameConstants.HIT_FORCE.NORMAL: return max(power - 1, 1)
		_: return 0

func play_sfx(_hit_force):
	$SFXBlow.play()

func animate_slash(position):
	var slash = Slash.instance()
	var main = get_tree().current_scene
	main.add_child(slash)
	slash.connect("done", self, "_on_Slash_animation_finished")
	slash.global_position = position

func _on_Slash_animation_finished():
	if battlefield_done:
		finish_turn()
