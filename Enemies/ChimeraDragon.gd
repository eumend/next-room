extends "res://Enemies/BaseEnemy.gd"

const SpinesBattleField = preload("res://BattleFields/EnemyBattleFields/SpinesBattleField.tscn")

func get_attack_pattern():
	return {
		"spines_attack": 100,
	}


func spines_attack():
	var dialogues = get_dialogues()
	DialogBox.show_timeouts(dialogues)
	yield(DialogBox, "done")
	var spinesBattleField = SpinesBattleField.instance()
	config_spines_battlefield(spinesBattleField)
	spinesBattleField.connect("hit", self, "_on_spinesBattleField_player_hit")
	spinesBattleField.connect("miss", self, "_on_spinesBattleField_player_miss")
	spinesBattleField.connect("done", self, "_on_spinesBattleField_player_done")
	ActionBattle.start_small_field(spinesBattleField)

func get_dialogues():
	return [
		["...", 1]
	]

func config_spines_battlefield(spinesBattleField):
	if self.hp <= self.max_hp * 0.2:
		spinesBattleField.total_hits = 8
		spinesBattleField.spikes_per_hit = {3: 50, 2: 30, 1: 20}
		spinesBattleField.spike_time = 0.8
	elif self.hp <= self.max_hp * 0.35:
		spinesBattleField.total_hits = 5
		spinesBattleField.spikes_per_hit = {3: 50, 2: 30, 1: 20}
		spinesBattleField.spike_time = 0.9
	elif self.hp <= self.max_hp * 0.5:
		spinesBattleField.total_hits = 4
		spinesBattleField.spikes_per_hit = {3: 20, 2: 50, 1: 20}
		spinesBattleField.spike_time = 0.9
	elif self.hp <= self.max_hp * 0.75:
		spinesBattleField.total_hits = 3
		spinesBattleField.spikes_per_hit = {3: 20, 2: 50, 1: 20}
		spinesBattleField.spike_time = 1
	else:
		spinesBattleField.total_hits = 2
		spinesBattleField.spikes_per_hit = {3: 10, 2: 30, 1: 60}
		spinesBattleField.spike_time = 1.1

func _on_spinesBattleField_player_hit(_hit_force):
	.deal_damage(GameConstants.HIT_FORCE.STRONG)

func _on_spinesBattleField_player_miss():
	.deal_damage(null, 0)

func _on_spinesBattleField_player_done():
	emit_signal("end_turn")
