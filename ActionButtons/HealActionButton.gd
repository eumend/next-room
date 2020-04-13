extends "res://ActionButtons/BaseActionButton.gd"

const HealBattleField = preload("res://BattleFields/HealBattleField.tscn")

func _on_pressed():
	var healBattleField = HealBattleField.instance()
	healBattleField.connect("heal", self, "_on_HealBattleField_heal")
	healBattleField.connect("miss", self, "_on_HealBattleField_miss")
	healBattleField.connect("done", self, "_on_HealBattleField_done")
	ActionBattle.start_small_field(healBattleField)

func _on_HealBattleField_heal(hit_force = null):
	if(is_battle_ready()):
		play_sfx(hit_force)
		var base_amount = round(player.max_hp / 10)
		var heal_amount = get_heal_amount(base_amount, hit_force)
		player.hp += heal_amount

func _on_HealBattleField_miss():
	if(is_battle_ready()):
		pass

func _on_HealBattleField_done():
	if(is_battle_ready()):
		player.ap -= ap_cost

func play_sfx(_hit_force):
	$SFXHeal.play()

func get_heal_amount(amount, hit_force):
	match(hit_force):
		GameConstants.HIT_FORCE.CRIT: return amount * 2
		GameConstants.HIT_FORCE.STRONG: return amount + max(ceil(amount / 4), 1)
		_: return amount

func is_disabled():
	player = BattleUnits.PlayerStats
	return .is_disabled() or player.hp >= player.max_hp
