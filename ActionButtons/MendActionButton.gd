extends "res://ActionButtons/BaseActionButton.gd"

const MendBattleField = preload("res://BattleFields/MendBattleField.tscn")

func _on_pressed():
	var mendBattleField = MendBattleField.instance()
	mendBattleField.connect("heal", self, "_on_MendBattleField_heal")
	mendBattleField.connect("heal_status", self, "_on_MendBattleField_heal_status")
	mendBattleField.connect("miss", self, "_on_MendBattleField_miss")
	mendBattleField.connect("done", self, "_on_MendBattleField_done")
	ActionBattle.start_small_field(mendBattleField)

func _on_MendBattleField_heal(hit_force = null):
	if(is_battle_ready()):
		play_sfx(hit_force)
		var base_amount = ceil(player.max_hp / 10) + round(player.level / 5)
		var heal_amount = get_heal_amount(base_amount, hit_force)
		player.heal_damage(heal_amount)

func _on_MendBattleField_heal_status():
	if(is_battle_ready()):
		player.heal_status()

func _on_MendBattleField_miss():
	if(is_battle_ready()):
		pass

func _on_MendBattleField_done():
	if(is_battle_ready()):
		finish_turn()

func play_sfx(_hit_force):
	$SFXHeal.play()

func get_heal_amount(amount, hit_force):
	match(hit_force):
		GameConstants.HIT_FORCE.CRIT: return amount * 2
		GameConstants.HIT_FORCE.STRONG: return amount + max(ceil(amount / 4), 1)
		_: return amount
