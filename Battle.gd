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
			"skull": 40,
			"rat": 20,
			"bat": 20,
			"slime": 20,
		},
		"boss": "boss2",
		"mook_count": 4,
		"background": preload("res://Images/Dungeon2.png")
	}
}

var skill_tree = {
	GameConstants.PLAYER_SKILLS.SWORD: {
		"name": "SWORD",
		"level": 1,
		"learned": false,
		"button": preload("res://ActionButtons/SwordActionButton.tscn")
	},
	GameConstants.PLAYER_SKILLS.HEAL: {
		"name": "HEAL",
		"level": 2,
		"learned": false,
		"button": preload("res://ActionButtons/HealActionButton.tscn")
	},
#	GameConstants.PLAYER_SKILLS.SHIELD: {
#		"name": "SHIELD",
#		"level": 1,
#		"learned": false,
#		"button": preload("res://ActionButtons/ShieldActionButton.tscn")
#	},
	GameConstants.PLAYER_SKILLS.COMBO: {
		"name": "COMBO",
		"level": 3,
		"learned": false,
		"button": preload("res://ActionButtons/ComboActionButton.tscn")
	},
}

var current_level = 1
var kill_streak = 0

func _ready():
	create_player()
	randomize()
	start_battle()

func start_battle():
	update_level_layout()
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

func _on_Boss_died(exp_points):
	current_level += 1
	kill_streak = 0
	if current_level in Levels:
		_on_Enemy_died(exp_points)
	else:
		# No more levels, player won!
		ActionBattle.force_end_of_battle()
		BattleSummary.show_summary("GAME\nCOMPLETE", "YOU ROCK!")
		actionButtons.hide()
		restartButton.show()

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
	show_level_up_summary(playerStats.last_level_up_summary)
	check_learned_skills(playerStats)

func _on_NextRoomButton_pressed():
	nextRoomButton.hide()
	nextRoomButton.text = "ENTER NEXT ROOM"
	BattleSummary.hide_summary()
	animationPlayer.play("FadeToNewRoom")
	yield(animationPlayer, "animation_finished")
	start_battle()

func game_over():
	ActionBattle.force_end_of_battle()
	BattleSummary.show_summary("GAME OVER", "")

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
	var playerStats = BattleUnits.PlayerStats
	playerStats.reset()
	current_level = 1
	check_learned_skills(playerStats)
	start_battle()
	
