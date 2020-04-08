extends Node

const BattleUnits = preload("res://BattleUnits.tres")
const DialogBox = preload("res://DialogBox.tres")

export(Array, PackedScene) var enemies = []

onready var actionButtons = $UI/BattleActionButtons
onready var animationPlayer = $AnimationPlayer
onready var nextRoomButton = $UI/StatsPanel/CenterContainer/NextRoomButton
onready var enemyStartPosition = $EnemyPosition

signal _done

func _ready():
	randomize()
	start_battle()

func start_battle():
	create_player()
	create_new_enemy()
	start_player_turn()

func start_player_turn():
	var playerStats = BattleUnits.PlayerStats
	actionButtons.show()
	playerStats.ap = playerStats.max_ap

func create_player():
	var playerStats = BattleUnits.PlayerStats
	playerStats.connect("end_turn", self, "_on_Player_end_turn")
	playerStats.connect("get_status", self, "_on_Player_get_status")
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

func _on_Player_get_status(status):
	match(status):
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
	DialogBox.show_timeouts([
		["LEVEL UP!", 2],
		["HP + {hp}\nMP + {mp}\nPOW + {power}".format(value), 2],
	])
