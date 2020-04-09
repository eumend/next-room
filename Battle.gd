extends Node

const BattleUnits = preload("res://BattleUnits.tres")
const DialogBox = preload("res://DialogBox.tres")

export(Array, PackedScene) var enemies = []

onready var actionButtons = $UI/BattleActionButtons
onready var animationPlayer = $AnimationPlayer
onready var nextRoomButton = $UI/StatsPanel/CenterContainer/NextRoomButton
onready var enemyStartPosition = $EnemyPosition

signal _done

var skill_tree = {
	GameConstants.PLAYER_SKILLS.SWORD: {
		"name": "SWORD",
		"level": 1,
		"learned": false,
		"button": preload("res://Actions/SwordActionButton.tscn")
	},
	GameConstants.PLAYER_SKILLS.HEAL: {
		"name": "HEAL",
		"level": 1,
		"learned": false,
		"button": preload("res://Actions/HealActionButton.tscn")
	},
	GameConstants.PLAYER_SKILLS.SHIELD: {
		"name": "SHIELD",
		"level": 1,
		"learned": false,
		"button": preload("res://Actions/ShieldActionButton.tscn")
	},
}

func _ready():
	randomize()
	start_battle()

func start_battle():
	create_new_enemy()
	create_player()
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
	# TODO: Start action buttons depending on level, mp etc

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
	DialogBox.show_timeout("You won!", 2)
	nextRoomButton.show()
	actionButtons.hide()
	var playerStats = BattleUnits.PlayerStats
	playerStats.exp_points += exp_points
	playerStats.clear_status()

func _on_NextRoomButton_pressed():
	nextRoomButton.hide()
	animationPlayer.play("FadeToNewRoom")
	yield(animationPlayer, "animation_finished")
	start_battle()

func _on_PlayerStats_level_up(value):
	var playerStats = BattleUnits.PlayerStats
	DialogBox.show_timeouts([
		["Level UP!", 2],
		["HP + {hp}\nMP + {mp}\nPOW + {power}".format(value), 2],
	])
	check_learned_skills(playerStats)

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
