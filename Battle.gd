extends Node

const BattleUnits = preload("res://BattleUnits.tres")
const DialogBox = preload("res://DialogBox.tres")
const ActionBattle = preload("res://ActionBattle.tres")

export(Array, PackedScene) var enemies = []

onready var actionButtons = $UI/BattleActionButtons
onready var animationPlayer = $AnimationPlayer
onready var nextRoomButton = $UI/OverworldActionButtons/NextRoomButton
onready var enemyStartPosition = $EnemyPosition

signal _done

var skill_tree = {
	GameConstants.PLAYER_SKILLS.SWORD: {
		"name": "SWORD",
		"level": 1,
		"learned": false,
		"button": preload("res://ActionButtons/SwordActionButton.tscn")
	},
	GameConstants.PLAYER_SKILLS.HEAL: {
		"name": "HEAL",
		"level": 1,
		"learned": false,
		"button": preload("res://ActionButtons/HealActionButton.tscn")
	},
	GameConstants.PLAYER_SKILLS.SHIELD: {
		"name": "SHIELD",
		"level": 1,
		"learned": false,
		"button": preload("res://ActionButtons/ShieldActionButton.tscn")
	},
	GameConstants.PLAYER_SKILLS.COMBO: {
		"name": "COMBO",
		"level": 1,
		"learned": false,
		"button": preload("res://ActionButtons/ComboActionButton.tscn")
	},
}

func _ready():
	randomize()
	create_player()
	start_battle()

func start_battle():
	create_new_enemy()
	start_player_turn()

func start_player_turn():
	var playerStats = BattleUnits.PlayerStats
	actionButtons.show()
	playerStats.ap = playerStats.max_ap

func create_player():
	var playerStats = BattleUnits.PlayerStats
	playerStats.connect("end_turn", self, "_on_Player_end_turn")
	playerStats.connect("status_changed", self, "_on_Player_status_changed")
	check_learned_skills(playerStats)

func start_enemy_turn():
	var enemy = BattleUnits.Enemy
	if enemy != null and not enemy.is_queued_for_deletion():
		enemy.start_turn()

func create_new_enemy():
	enemies.shuffle()
	var Enemy = enemies.front()
	var enemy = Enemy.instance()
	enemyStartPosition.add_child(enemy)
	enemy.connect("died", self, "_on_Enemy_died")
	enemy.connect("end_turn", self, "_on_Enemy_end_turn")

func handle_status_eot():
	var player = BattleUnits.PlayerStats
	if player.has_status(GameConstants.STATUS.POISON):
		DialogBox.show_timeout("Damage by poison!", 1)
		player.hp -= 1
		yield(DialogBox, "done")
	emit_signal("_done")

func _on_Player_end_turn():
	var enemy = BattleUnits.Enemy
	if enemy != null and !enemy.is_dead():
		actionButtons.hide()
		start_enemy_turn()

func _on_Enemy_end_turn():
	var player = BattleUnits.PlayerStats
	if player.is_under_status():
		yield(get_tree().create_timer(0.3), "timeout")
		handle_status_eot()
		yield(self, "_done")
	start_player_turn()

func _on_Player_status_changed(status):
	if status.size() > 0:
		var new_status = status.back()
		match(new_status):
			GameConstants.STATUS.POISON:
				DialogBox.show_timeout("You got poisoned!")
				return
			_: return

func _on_Enemy_died(exp_points):
	ActionBattle.force_end_of_battle()
	actionButtons.hide()
	nextRoomButton.show()
	var playerStats = BattleUnits.PlayerStats
	playerStats.clear_status()
	var level_before = playerStats.level
	playerStats.exp_points += exp_points
	show_battle_summary(exp_points)
	yield(get_tree().create_timer(1), "timeout")
	if playerStats.level > level_before:
		show_level_up_summary(playerStats.last_level_up_summary)

func _on_NextRoomButton_pressed():
	nextRoomButton.hide()
	close_battle_summary()
	animationPlayer.play("FadeToNewRoom")
	yield(animationPlayer, "animation_finished")
	start_battle()

func check_learned_skills(player):
	var learned_skills = []
	for k in skill_tree:
		var skill = skill_tree[k]
		if player.level >= skill["level"] and not skill["learned"]:
			learned_skills.append(k)
	for k in learned_skills:
		var skill = skill_tree[k]
		var new_skill_button = skill["button"].instance()
		actionButtons.add_child(new_skill_button)
		DialogBox.show_timeout("Learned " + skill["name"], 2)
		skill_tree[k]["learned"] = true

func show_level_up_summary(level_up_summary):
	var resultsPanel = $UI/BattleResultsPanel
	var resultsHeading = $UI/BattleResultsPanel/BattleResultsContainer/BattleHeadingContainer/BattleHeadingText
	var resultsStats = $UI/BattleResultsPanel/BattleResultsContainer/BattleSummaryContainer/BattleSummary/BattleSummaryStats
	var resultsNumbers = $UI/BattleResultsPanel/BattleResultsContainer/BattleSummaryContainer/BattleSummary/BattleSummaryNumbers
	
	resultsHeading.text = "LEVEL UP!"
	var stats_text = ""
	var numbers_text = ""
	
	if level_up_summary["hp"]:
		stats_text += "HP\n"
		numbers_text += "+" + str(level_up_summary["hp"]) + "\n"
	
	if level_up_summary["power"]:
		stats_text += "POW\n"
		numbers_text += "+" + str(level_up_summary["power"]) + "\n"

	resultsStats.text = stats_text
	resultsNumbers.text = numbers_text
	resultsPanel.show()

func show_battle_summary(exp_points):
	var resultsPanel = $UI/BattleResultsPanel
	var resultsHeading = $UI/BattleResultsPanel/BattleResultsContainer/BattleHeadingContainer/BattleHeadingText
	var resultsStats = $UI/BattleResultsPanel/BattleResultsContainer/BattleSummaryContainer/BattleSummary/BattleSummaryStats
	var resultsNumbers = $UI/BattleResultsPanel/BattleResultsContainer/BattleSummaryContainer/BattleSummary/BattleSummaryNumbers
	
	resultsHeading.text = "YOU WIN!"
	resultsStats.text = "EXP"
	resultsNumbers.text = "+" + str(exp_points)
	resultsPanel.show()

func close_battle_summary():
	var resultsPanel = $UI/BattleResultsPanel
	resultsPanel.hide()
