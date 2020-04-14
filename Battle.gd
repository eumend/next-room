extends Node

const BattleUnits = preload("res://BattleUnits.tres")
const DialogBox = preload("res://DialogBox.tres")
const ActionBattle = preload("res://ActionBattle.tres")
const BattleSummary = preload("res://BattleSummary.tres")

export(Array, PackedScene) var enemies = []

onready var actionButtons = $UI/BattleActionButtons
onready var animationPlayer = $AnimationPlayer
onready var nextRoomButton = $UI/OverworldActionButtons/NextRoomButton
onready var restartButton = $UI/OverworldActionButtons/RestartButton
onready var enemyStartPosition = $EnemyPosition

signal _done

# Enemies
const Enemies = {
	"rat": preload("res://Enemies/Rat.tscn"),
	"bat": preload("res://Enemies/Bat.tscn"),
	"slime": preload("res://Enemies/Slime.tscn"),
	"skull": preload("res://Enemies/Skull.tscn"),
	"boss1": preload("res://Enemies/Boss1.tscn"),
	"boss2": preload("res://Enemies/Boss2.tscn"),
}

var Levels = {
	1: {
		"enemies": {
			"rat": 40,
			"bat": 30,
			"slime": 30,
		},
		"boss": "boss1",
		"mook_count": 4,
		"background": preload("res://Images/Dungeon.png")
	},
	2: {
		"enemies": {
			"skull": 50,
			"rat": 20,
			"bat": 10,
			"slime": 20,
		},
		"boss": "boss2",
		"mook_count": 4,
		"background": preload("res://Images/Dungeon2.png")
	}
}

# Score vars
var kill_streak = 0
var current_level = 1
var turns_taken = 0
var total_turns_taken = 0
var current_run = 0

func _ready():
	$BGPlayer.play()
	create_player()
	randomize()
	start_battle()

func start_battle():
	update_level_layout()
	create_new_enemy()
	start_player_turn()

func start_player_turn():
	turns_taken += 1
	total_turns_taken += 1
	var playerStats = BattleUnits.PlayerStats
	actionButtons.show_skills()
	playerStats.ap = playerStats.max_ap

func create_player():
	var playerStats = BattleUnits.PlayerStats
	playerStats.connect("end_turn", self, "_on_Player_end_turn")
	playerStats.connect("status_changed", self, "_on_Player_status_changed")

func start_enemy_turn():
	var enemy = BattleUnits.Enemy
	if enemy != null and not enemy.is_queued_for_deletion():
		enemy.start_turn()

func create_new_enemy():
	var level_info = Levels[current_level]
	var is_boss_battle = kill_streak == level_info["mook_count"]
	var enemy_name = level_info["boss"] if is_boss_battle else Utils.pick_from_weighted(level_info["enemies"])
	var Enemy = Enemies[enemy_name]
	var enemy = Enemy.instance()
	enemyStartPosition.add_child(enemy)
	enemy.connect("end_turn", self, "_on_Enemy_end_turn")
	if is_boss_battle:
		enemy.connect("died", self, "_on_Boss_died")
	else:
		enemy.connect("died", self, "_on_Enemy_died")

func handle_status_eot():
	var player = BattleUnits.PlayerStats
	if player.has_status(GameConstants.STATUS.POISON):
		DialogBox.show_timeout("Damage by poison!", 1)
		player.hp -= 1
		yield(DialogBox, "done")
	emit_signal("_done")

func _on_Player_end_turn():
	actionButtons.hide()
	var enemy = BattleUnits.Enemy
	if enemy != null and !enemy.is_dead():
		start_enemy_turn()

func _on_Enemy_end_turn():
	var player = BattleUnits.PlayerStats
	if not player.is_dead():
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

func _on_Boss_died(exp_points):
	current_level += 1
	kill_streak = 0
	nextRoomButton.text = "NEXT FLOOR"
	if current_level in Levels:
		_on_Enemy_died(exp_points)
	else:
		# No more levels, player won!
		ActionBattle.force_end_of_battle()
		on_game_finished()

func on_game_finished():
	current_run += 1
	var text = "TURNS: " + str(turns_taken) + "\n" + "TOTAL: " + str(total_turns_taken) + "\n" + "STREAK: " + str(current_run)
	BattleSummary.show_summary("FINISHED!", text)
	actionButtons.hide()
	restartButton.show()
	$SFXLevelUp.play()

func update_level_layout():
	$Dungeon.texture = Levels[current_level]["background"]

func _on_Enemy_died(exp_points):
	ActionBattle.force_end_of_battle()
	actionButtons.hide()
	var playerStats = BattleUnits.PlayerStats
	playerStats.clear_status()
	var level_before = playerStats.level
	playerStats.exp_points += exp_points
	kill_streak += 1
	show_battle_summary(exp_points)
	yield(get_tree().create_timer(1), "timeout")
	if playerStats.level > level_before:
		on_level_up()
	
	var level_info = Levels[current_level]
	var is_boss_battle = kill_streak == level_info["mook_count"]
	if is_boss_battle:
		nextRoomButton.text = "BOSS BATTLE"
	nextRoomButton.show()

func on_level_up():
	var playerStats = BattleUnits.PlayerStats
	$SFXLevelUp.play()
	show_level_up_summary(playerStats.last_level_up_summary)

func _on_NextRoomButton_pressed():
	nextRoomButton.hide()
	nextRoomButton.text = "ENTER NEXT ROOM"
	BattleSummary.hide_summary()
	$SFXNextRoom.play()
	animationPlayer.play("FadeToNewRoom")
	yield(animationPlayer, "animation_finished")
	start_battle()

func game_over():
	ActionBattle.force_end_of_battle()
	$BGPlayer.stop()
	$SFXGameOver.play()
	var text = "TURNS: " + str(turns_taken) + "\n" + "TOTAL: " + str(total_turns_taken) + "\n" + "STREAK: " + str(current_run)
	BattleSummary.show_summary("GAME OVER", text)
	actionButtons.hide()
	restartButton.show()
	current_run = 0

func show_level_up_summary(level_up_summary):
	var body = ""
	
	if level_up_summary["hp"]:
		body += "HP + " + str(level_up_summary["hp"]) + "\n"
	
	if level_up_summary["power"]:
		body += "POW + " + str(level_up_summary["power"]) + "\n"

	BattleSummary.show_summary("LEVEL UP!", body)

func show_battle_summary(exp_points):
	var body = "EXP +" + str(exp_points)
	BattleSummary.show_summary("YOU WIN!", body)


func _on_PlayerStats_died():
	game_over()


func _on_RestartButton_pressed():
	restartButton.hide()
	BattleSummary.hide_summary()
	restart_game()

func restart_game():
	animationPlayer.play("FadeToNewRoom")
	var playerStats = BattleUnits.PlayerStats
	playerStats.reset()
	var enemy = BattleUnits.Enemy
	if enemy:
		BattleUnits.Enemy = null
		enemy.queue_free()
	current_level = 1
	turns_taken = 0
	kill_streak = 0
	yield(animationPlayer, "animation_finished")
	$BGPlayer.play()
	start_battle()
	
