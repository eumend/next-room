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
	"sewer_chimera": preload("res://Enemies/ChimeraRBS.tscn"),
	"skull": preload("res://Enemies/Skull.tscn"),
	"flame_head": preload("res://Enemies/FlameHead.tscn"),
	"fire_skull": preload("res://Enemies/FireSkull.tscn"),
	"ancient_sword": preload("res://Enemies/AncientSword.tscn"),
	"ancient_shield": preload("res://Enemies/AncientShield.tscn"),
	"ancient_tome": preload("res://Enemies/AncientTome.tscn"),
	"mummy_knight": preload("res://Enemies/MummyKnight.tscn"),
}

var Levels = {
	1: {
		"enemies": {
			"rat": 40,
			"bat": 30,
			"slime": 30,
		},
		"boss": "sewer_chimera",
		"mook_count": 4,
		"background": preload("res://Images/Dungeon.png")
	},
	2: {
		"enemies": {
			"skull": 50,
			"flame_head": 50,
		},
		"boss": "fire_skull",
		"mook_count": 4,
		"background": preload("res://Images/Dungeon2.png")
	},
	3: {
		"enemies": {
			"ancient_sword": 50,
			"ancient_shield": 40,
			"ancient_tome": 10,
		},
		"boss": "mummy_knight",
		"mook_count": 5,
		"background": preload("res://Images/Dungeon3.png")
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


func create_player():
	var playerStats = BattleUnits.PlayerStats
	playerStats.connect("end_turn", self, "_on_Player_end_turn")
	playerStats.connect("died", self, "_on_Player_died")
	playerStats.connect("status_changed", self, "_on_Player_status_changed")

func start_player_turn():
	BattleUnits.set_current_turn(GameConstants.UNITS.PLAYER)
	turns_taken += 1
	total_turns_taken += 1
	var playerStats = BattleUnits.PlayerStats
	actionButtons.start_turn()
	playerStats.ap = playerStats.max_ap

func _on_Player_end_turn():
	if BattleUnits.is_player_turn(): # We trigger this early if the enemy dies, so this can get called twice
		BattleUnits.set_current_turn(null)
		actionButtons.hide()
		var battle_continues = eot_checks()
		if battle_continues:
			start_enemy_turn()

func _on_PlayerStats_died():
	ActionBattle.force_end_of_battle()
	if BattleUnits.is_player_turn():
		actionButtons.hide()
	# TODO: We could show game_over instantly here

func _on_Player_status_changed(status):
	if status.size() > 0:
		var new_status = status.back()
		match(new_status):
			GameConstants.STATUS.POISON:
				DialogBox.show_timeout("You got poisoned!")
				return
			_: return

func create_new_enemy():
	var level_info = Levels[current_level]
	var is_boss_battle = kill_streak == level_info["mook_count"]
	var enemy_name = level_info["boss"] if is_boss_battle else Utils.pick_from_weighted(level_info["enemies"])
	var Enemy = Enemies[enemy_name]
	var enemy = Enemy.instance()
	enemyStartPosition.add_child(enemy)
	enemy.connect("end_turn", self, "_on_Enemy_end_turn")
	enemy.connect("died", self, "_on_Enemy_died")

func _on_Enemy_end_turn():
	BattleUnits.set_current_turn(null)
	handle_status_eot()
	yield(self, "_done")
	var battle_continues = eot_checks()
	if battle_continues:
		start_player_turn()

func _on_Enemy_died():
	ActionBattle.force_end_of_battle()
	if BattleUnits.is_player_turn():
		_on_Player_end_turn()

func start_enemy_turn():
	var enemy = BattleUnits.Enemy
	if enemy != null and not enemy.is_queued_for_deletion(): # TODO: Check fi still needed
		BattleUnits.set_current_turn(GameConstants.UNITS.ENEMY)
		enemy.start_turn()

func handle_status_eot():
	var player = BattleUnits.PlayerStats
	if not player.is_dead():
		if player.has_status(GameConstants.STATUS.POISON):
			yield(get_tree().create_timer(0.5), "timeout")
			DialogBox.show_timeout("Damage by poison!", 1)
			player.take_damage(1)
			yield(DialogBox, "done")
			emit_signal("_done")
		else:
			yield(get_tree().create_timer(0.1), "timeout")
			emit_signal("_done")
	else:
		yield(get_tree().create_timer(0.1), "timeout")
		emit_signal("_done")

func eot_checks():
	var player = BattleUnits.PlayerStats
	var enemy = BattleUnits.Enemy
	if player.is_dead():
		game_over()
		return false
	if enemy.is_dead():
		if enemy.is_boss:
			kill_streak = 0
			handle_boss_death_eot(enemy)
		else:
			kill_streak += 1
			handle_enemy_death_eot(enemy)
		return false
	return true

func handle_boss_death_eot(enemy):
	current_level += 1
	nextRoomButton.text = "NEXT FLOOR"
	if current_level in Levels:
		handle_enemy_death_eot(enemy)
	else:
		if enemy.on_death_animation:
			yield(enemy, "death_animation_done")
		on_game_finished()
		enemy.queue_free()

func handle_enemy_death_eot(enemy):
	if enemy.on_death_animation:
		yield(enemy, "death_animation_done")
	increase_player_exp(enemy.exp_points)
	
	# Battle over cleanup
	reset_player_status()
	enemy.queue_free()
	
	var level_info = Levels[current_level]
	var is_boss_battle = kill_streak == level_info["mook_count"]
	var boss_battle_is_next = kill_streak == level_info["mook_count"] - 1
	if is_boss_battle:
		nextRoomButton.text = "BOSS BATTLE"
	elif boss_battle_is_next:
		nextRoomButton.text = "YOU ARE CLOSE..."
	nextRoomButton.show()

func reset_player_status():
	var playerStats = BattleUnits.PlayerStats
	playerStats.clear_status()

func increase_player_exp(exp_points):
	var playerStats = BattleUnits.PlayerStats
	var level_before = playerStats.level
	playerStats.exp_points += exp_points
	BattleSummary.show_summary("YOU WIN!", "EXP +" + str(exp_points))
	if playerStats.level > level_before:
		$SFXLevelUp.play()
		show_level_up_summary(playerStats.last_level_up_summary)

func show_level_up_summary(level_up_summary):
	var body = ""
	
	if level_up_summary["hp"]:
		body += "HP + " + str(level_up_summary["hp"]) + "\n"
	
	if level_up_summary["power"]:
		body += "POW + " + str(level_up_summary["power"]) + "\n"

	BattleSummary.show_summary("LEVEL UP!", body)

func _on_NextRoomButton_pressed():
	nextRoomButton.hide()
	nextRoomButton.text = "NEXT ROOM"
	BattleSummary.hide_summary()
	$SFXNextRoom.play()
	animationPlayer.play("FadeToNewRoom")
	yield(animationPlayer, "animation_finished")
	start_battle()

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

func game_over():
	$BGPlayer.stop()
	$SFXGameOver.play()
	var text = "TURNS: " + str(turns_taken) + "\n" + "TOTAL: " + str(total_turns_taken) + "\n" + "STREAK: " + str(current_run)
	BattleSummary.show_summary("GAME OVER", text)
	restartButton.show()
	current_run = 0

func on_game_finished():
	current_run += 1
	var text = "TURNS: " + str(turns_taken) + "\n" + "TOTAL: " + str(total_turns_taken) + "\n" + "STREAK: " + str(current_run)
	BattleSummary.show_summary("FINISHED!", text)
	actionButtons.hide()
	restartButton.show()
	$SFXLevelUp.play()

func update_level_layout():
	$Dungeon.texture = Levels[current_level]["background"]
