extends Node

const BattleUnits = preload("res://BattleUnits.tres")
const DialogBox = preload("res://DialogBox.tres")
const ActionBattle = preload("res://ActionBattle.tres")
const BattleSummary = preload("res://BattleSummary.tres")

onready var actionButtons = $UI/BattleActionButtons
onready var animationPlayer = $AnimationPlayer
onready var nextRoomButton = $UI/OverworldActionButtons/NextRoomButton
onready var restartButton = $UI/OverworldActionButtons/RestartButton
onready var continueButton = $UI/OverworldActionButtons/ContinueButton
onready var enemyStartPosition = $EnemyPosition
onready var playerScore = $PlayerScore

signal _done

# Enemies
const Enemies = {
	"rat": preload("res://Enemies/Rat.tscn"),
	"bat": preload("res://Enemies/Bat.tscn"),
	"slime": preload("res://Enemies/Slime.tscn"),
	"sewer_chimera": preload("res://Enemies/ChimeraRBS.tscn"),
	"skull": preload("res://Enemies/Skull.tscn"),
	"flame_head": preload("res://Enemies/FlameHead.tscn"),
	"candle": preload("res://Enemies/Candle.tscn"),
	"fire_skull": preload("res://Enemies/FireSkull.tscn"),
	"ancient_sword": preload("res://Enemies/AncientSword.tscn"),
	"ancient_shield": preload("res://Enemies/AncientShield.tscn"),
	"ancient_tome": preload("res://Enemies/AncientTome.tscn"),
	"mummy_knight": preload("res://Enemies/MummyKnight.tscn"),
	"sea_horse": preload("res://Enemies/SeaHorse.tscn"),
	"mermaid": preload("res://Enemies/Mermaid.tscn"),
	"starfish": preload("res://Enemies/StarFish.tscn"),
	"sea_horse_rider": preload("res://Enemies/SeaHorseRider.tscn"),
	"spider": preload("res://Enemies/Spider.tscn"),
	"spectre": preload("res://Enemies/Spectre.tscn"),
	"voodoo_doll": preload("res://Enemies/VoodooDoll.tscn"),
	"voodoo_curse": preload("res://Enemies/VoodooCurse.tscn"),
	"worm": preload("res://Enemies/Worm.tscn"),
	"bug": preload("res://Enemies/Bug.tscn"),
	"saucer": preload("res://Enemies/Saucer.tscn"),
	"cosmic_menagerie": preload("res://Enemies/CosmicMenagerie.tscn"),
	"feather_angel": preload("res://Enemies/FeatherAngel.tscn"),
	"ring_angel": preload("res://Enemies/RingAngel.tscn"),
	"face_angel": preload("res://Enemies/FaceAngel.tscn"),
	"archangel": preload("res://Enemies/Archangel.tscn"),
	"rat_chimera": preload("res://Enemies/RatChimera.tscn"),
	"bat_chimera": preload("res://Enemies/BatChimera.tscn"),
	"slime_chimera": preload("res://Enemies/SlimeChimera.tscn"),
	"dragon_chimera": preload("res://Enemies/ChimeraDragon.tscn"),
}

var Levels = {
	1: {
		"enemies": {
			"rat": 45,
			"bat": 40,
			"slime": 15,
		},
		"boss": "sewer_chimera",
		"mook_count": 4,
		"background": preload("res://Images/Dungeons/Dungeon.png")
	},
	2: {
		"enemies": {
			"flame_head": 45,
			"skull": 40,
			"candle": 15,
		},
		"boss": "fire_skull",
		"mook_count": 4,
		"background": preload("res://Images/Dungeons/Dungeon2.png")
	},
	3: {
		"enemies": {
			"ancient_sword": 45,
			"ancient_shield": 40,
			"ancient_tome": 15,
		},
		"boss": "mummy_knight",
		"mook_count": 5,
		"background": preload("res://Images/Dungeons/Dungeon3.png")
	},
	4: {
		"enemies": {
			"sea_horse": 45,
			"mermaid": 40,
			"starfish": 15,
		},
		"boss": "sea_horse_rider",
		"mook_count": 5,
		"background": preload("res://Images/Dungeons/Dungeon4.png")
	},
	5: {
		"enemies": {
			"spider": 45,
			"spectre": 40,
			"voodoo_doll": 15
		},
		"boss": "voodoo_curse",
		"mook_count": 5,
		"background": preload("res://Images/Dungeons/Dungeon5.png")
	},
	6: {
		"enemies": {
			"worm": 45,
			"bug": 40,
			"saucer": 15,
		},
		"boss": "cosmic_menagerie",
		"mook_count": 0,
		"background": preload("res://Images/Dungeons/Dungeon6.png")
	},
	7: {
		"enemies": {
			"feather_angel": 45,
			"ring_angel": 40,
			"face_angel": 15,
		},
		"boss": "archangel",
		"mook_count": 4,
		"background": preload("res://Images/Dungeons/Dungeon7.png")
	},
	8: {
		"enemies": { # Handled by code
			"rat_chimera": 1,
			"bat_chimera": 1,
			"slime_chimera": 1,
		},
		"boss": "dragon_chimera",
		"mook_count": 3,
		"background": preload("res://Images/Dungeons/Dungeon8.png")
	}
}
var enemy_encounter_rate = null
var last_enemy = null

func _ready():
	$BGPlayer.play()
	# skip_to_level(1, 10) # Debugging
	update_level_layout()
	create_player()
	start_battle()

func start_battle():
	create_new_enemy()
	start_player_turn()

func create_player():
	var playerStats = BattleUnits.PlayerStats
	playerStats.connect("end_turn", self, "_on_Player_end_turn")
	playerStats.connect("died", self, "_on_Player_died")
	playerStats.connect("status_changed", self, "_on_Player_status_changed")

func start_player_turn():
	BattleUnits.set_current_turn(GameConstants.UNITS.PLAYER)
	playerScore.turns_taken += 1
	var playerStats = BattleUnits.PlayerStats
	playerStats.clear_buffs()
	actionButtons.start_turn()

func _on_Player_end_turn():
	if BattleUnits.is_player_turn(): # We trigger this early if the enemy dies, so this can get called twice
		BattleUnits.set_current_turn(null)
		actionButtons.hide()
		var battle_continues = eot_checks()
		if battle_continues:
			start_enemy_turn()

func _on_Player_died():
	ActionBattle.force_end_of_battle()
	if BattleUnits.is_player_turn():
		actionButtons.hide()

func _on_Player_status_changed(status):
	if status.size() > 0:
		var new_status = status.back()
		match(new_status):
			GameConstants.STATUS.POISON:
				DialogBox.show_timeout("You got poisoned!")
				return
			_: return

func create_new_enemy():
	var enemy_name = pick_next_enemy()
	var enemy = Enemies[enemy_name].instance()
	enemyStartPosition.add_child(enemy)
	enemy.connect("end_turn", self, "_on_Enemy_end_turn")
	enemy.connect("died", self, "_on_Enemy_died")
	enemy.connect("fled", self, "_on_Enemy_fled")

func pick_next_enemy():
	var enemy_name = null
	var level_info = Levels[playerScore.current_level]
	var is_boss_battle = playerScore.kill_streak == level_info["mook_count"]
	if is_boss_battle:
		enemy_name = level_info["boss"]
	elif playerScore.current_level == 8:
		enemy_name = ["rat_chimera", "bat_chimera", "slime_chimera"][playerScore.kill_streak]
	else:
		var level_enemies = level_info["enemies"]
		if not enemy_encounter_rate:
			enemy_encounter_rate = level_enemies
		if last_enemy in enemy_encounter_rate:
			enemy_encounter_rate[last_enemy] = enemy_encounter_rate[last_enemy] - 5
		else:
			enemy_encounter_rate = level_enemies
		enemy_name = Utils.pick_from_weighted(enemy_encounter_rate)
		last_enemy = enemy_name
	return enemy_name

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
	else:
		reset_player_status()

func _on_Enemy_fled():
	var enemy = BattleUnits.Enemy
	ActionBattle.force_end_of_battle()
	end_battle(enemy)

func start_enemy_turn():
	var enemy = BattleUnits.Enemy
	if enemy != null:
		BattleUnits.set_current_turn(GameConstants.UNITS.ENEMY)
		enemy.start_turn()

func handle_status_eot():
	var player = BattleUnits.PlayerStats
	if not player.is_dead():
		if player.has_status(GameConstants.STATUS.POISON):
			yield(get_tree().create_timer(0.5), "timeout")
			DialogBox.show_timeout("Damage by poison!", 1.5)
			player.take_status_damage(round(player.max_hp / 8))
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
			playerScore.kill_streak = 0
			handle_boss_death_eot(enemy)
		else:
			playerScore.kill_streak += 1
			handle_enemy_death_eot(enemy)
		return false
	return true

func handle_boss_death_eot(enemy):
	# Reset level vars
	playerScore.current_level += 1
	enemy_encounter_rate = null
	last_enemy = null
	nextRoomButton.text = "SAVE"
	if playerScore.current_level in Levels:
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
	end_battle(enemy)

func end_battle(enemy):
	# Battle over cleanup
	reset_player_status()
	if enemy.is_boss or playerScore.current_level == 8:
		# Save current progress
		playerScore.save()
		var playerStats = BattleUnits.PlayerStats
		if playerStats:
			playerStats.save()
	enemy.queue_free()
	
	var level_info = Levels[playerScore.current_level]
	var is_boss_battle = playerScore.kill_streak == level_info["mook_count"]
	var boss_battle_is_next = playerScore.kill_streak == level_info["mook_count"] - 1
	if is_boss_battle:
		nextRoomButton.text = "BOSS BATTLE"
	elif boss_battle_is_next:
		nextRoomButton.text = "YOU ARE CLOSE..."
	elif playerScore.current_level == 8:
		nextRoomButton.text = "SAVE"
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
	else :
		$SFXWin.play()

func show_level_up_summary(level_up_summary):
	var body = ""
	
	if level_up_summary["hp"]:
		body += "HP + " + str(level_up_summary["hp"]) + "\n"
	
	if level_up_summary["power"]:
		body += "POW + " + str(level_up_summary["power"]) + "\n"

	BattleSummary.show_summary("LEVEL UP!", body)

func _on_NextRoomButton_pressed():
	animationPlayer.play("FadeOut")
	yield(animationPlayer, "animation_finished")
	var is_next_floor = playerScore.kill_streak == 0
	if is_next_floor:
		var player = BattleUnits.PlayerStats
		player.heal_all()
	$SFXNextRoom.play()
	nextRoomButton.hide()
	update_level_layout()
	nextRoomButton.text = "NEXT ROOM"
	BattleSummary.hide_summary()
	yield(get_tree().create_timer(0.2), "timeout")
	animationPlayer.play("FadeIn")
	yield(animationPlayer, "animation_finished")
	start_battle()

func _on_RestartButton_pressed():
	animationPlayer.play("FadeOut")
	yield(animationPlayer, "animation_finished")
	restartButton.hide()
	continueButton.hide()
	BattleSummary.hide_summary()
	var playerStats = BattleUnits.PlayerStats
	if playerScore.current_run > 0:
		playerStats.reset_plus()
	else:
		playerStats.reset()
	var enemy = BattleUnits.Enemy
	if enemy:
		BattleUnits.Enemy = null
		enemy.queue_free()
	playerScore.reset()
	update_level_layout()
	yield(get_tree().create_timer(0.3), "timeout")
	animationPlayer.play("FadeIn")
	yield(animationPlayer, "animation_finished")
	$BGPlayer.play()
	start_battle()

func game_over():
	$BGPlayer.stop()
	$SFXGameOver.play()
	var text = "RUN: " + str(playerScore.current_run) + "\n" + "CONT: " + str(playerScore.continues_taken) + "\n" + "TURNS: " + str(playerScore.turns_taken)
	BattleSummary.show_summary("GAME OVER", text)
	restartButton.show()
	continueButton.show()

func on_game_finished():
	playerScore.current_run += 1
	var text = "RUN: " + str(playerScore.current_run) + "\n" + "CONT: " + str(playerScore.continues_taken) + "\n" + "TURNS: " + str(playerScore.turns_taken)
	BattleSummary.show_summary("FINISHED!", text)
	actionButtons.hide()
	restartButton.show()
	$SFXLevelUp.play()

func update_level_layout():
	$Dungeon.texture = Levels[playerScore.current_level]["background"]

func skip_to_level(lvl, player_lvl):
	var playerStats = BattleUnits.PlayerStats
	playerScore.current_level = lvl
	for _i in range(1, player_lvl):
		playerStats.level_up(1)
	playerStats.hp = playerStats.max_hp

func _on_ContinueButton_pressed():
	animationPlayer.play("FadeOut")
	yield(animationPlayer, "animation_finished")
	restartButton.hide()
	continueButton.hide()
	BattleSummary.hide_summary()
	var playerStats = BattleUnits.PlayerStats
	playerStats.heal_all()
	var enemy = BattleUnits.Enemy
	if enemy:
		BattleUnits.Enemy = null
		enemy.queue_free()
	if playerScore.current_level != 8:
		playerScore.kill_streak = 0
	playerScore.continues_taken += 1
	update_level_layout()
	yield(get_tree().create_timer(0.3), "timeout")
	actionButtons.recharge_all()
	$BGPlayer.play()
	start_battle()
	animationPlayer.play("FadeIn")
	yield(animationPlayer, "animation_finished")
