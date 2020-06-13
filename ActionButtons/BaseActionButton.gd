extends Button

const BattleUnits = preload("res://BattleUnits.tres")
const ActionBattle = preload("res://ActionBattle.tres")
var player = null
var enemy = null

export(int) var level_required = 1
export(int) var recharge_turns = 1

var charge = 0

var progress_map = {
	1: preload("res://Images/ProgressBars/progress_over_1.png"),
	2: preload("res://Images/ProgressBars/progress_over_2.png"),
	3: preload("res://Images/ProgressBars/progress_over_3.png"),
	4: preload("res://Images/ProgressBars/progress_over_4.png"),
	5: preload("res://Images/ProgressBars/progress_over_5.png"),
}

onready var sfxBeep = $SFXBeep

func _ready():
	if recharge_turns > 1:
		recharge_by(recharge_turns) # We start off the skill charged already!
		$ProgressContainer/ProgressBar.texture_over = progress_map[recharge_turns]
		$ProgressContainer/ProgressBar.max_value = recharge_turns
	else:
		$ProgressContainer/ProgressBar.hide()

func recharge_by(num = 1):
	charge = min(charge + num, recharge_turns)
	$ProgressContainer/ProgressBar.value = charge

func is_learned():
	player = BattleUnits.PlayerStats
	return player and player.level >= level_required

func is_disabled():
	var disabled = charge < recharge_turns
	return disabled
	
func is_battle_ready():
	enemy = BattleUnits.Enemy
	player = BattleUnits.PlayerStats
	return enemy != null and player != null

func is_player_ready():
	player = BattleUnits.PlayerStats
	return player != null

func finish_turn():
	if(is_battle_ready()):
		player.ap -= player.max_ap # TODO: Change into something else, really


func _on_ActionButton_pressed():
	charge = 0
	sfxBeep.play()
	_on_pressed()

func _on_pressed():
	pass # Replace with function body.
