extends Node

const BattleUnits = preload("res://BattleUnits.tres")

export(Array, PackedScene) var enemies = []

onready var actionButtons = $UI/BattleActionButtons
onready var animationPlayer = $AnimationPlayer
onready var nextRoomButton = $UI/StatsPanel/CenterContainer/NextRoomButton
onready var enemyStartPosition = $EnemyPosition

func _ready():
	randomize()
	start_battle()

func start_battle():
	create_new_enemy()
	start_player_turn()

func start_enemy_turn():
	var enemy = BattleUnits.Enemy
	actionButtons.hide()
	if enemy != null and not enemy.is_queued_for_deletion():
		enemy.attack()
		yield(enemy, "end_turn")
		start_player_turn()

func start_player_turn():
	var playerStats = BattleUnits.PlayerStats
	actionButtons.show()
	playerStats.ap = playerStats.max_ap
	yield(playerStats, "end_turn")
	start_enemy_turn()

func create_new_enemy():
	enemies.shuffle()
	var Enemy = enemies.front()
	var enemy = Enemy.instance()
	enemyStartPosition.add_child(enemy)
	enemy.connect("died", self, "_on_Enemy_died")

func _on_Enemy_died(exp_points):
	var playerStats = BattleUnits.PlayerStats
	playerStats.exp_points += exp_points
	nextRoomButton.show()
	actionButtons.hide()

func _on_NextRoomButton_pressed():
	nextRoomButton.hide()
	animationPlayer.play("FadeToNewRoom")
	yield(animationPlayer, "animation_finished")
	start_battle()
