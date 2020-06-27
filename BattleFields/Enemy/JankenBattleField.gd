extends "res://BattleFields/BaseBattleField.gd"

onready var playerOptions = $Field/VBoxContainer/PlayerOptions
onready var showOutcomeTimer = $ShowOutcomeTimer

enum CHOICES{ROCK, PAPER, SCISSORS}
enum OUTCOMES{WIN, LOSE, DRAW}

var max_turns = 3
var play_until = [OUTCOMES.WIN, OUTCOMES.LOSE]
var turns = 0

var choice_map = null
var outcome = null

signal player_win
signal player_lose
signal player_draw

var icon_map = {
	CHOICES.ROCK: preload("res://Images/BattleFields/JanKenPon/shield_button.png"),
	CHOICES.SCISSORS: preload("res://Images/BattleFields/JanKenPon/sword_button.png"),
	CHOICES.PAPER: preload("res://Images/BattleFields/JanKenPon/paper_button.png"),
}

const QuestionIcon = preload("res://Images/BattleFields/JanKenPon/question_button.png")

func _ready():
	playerOptions.find_node("PaperButton").connect("pressed", self, "_on_player_selected", [CHOICES.PAPER])
	playerOptions.find_node("RockButton").connect("pressed", self, "_on_player_selected", [CHOICES.ROCK])
	playerOptions.find_node("ScissorButton").connect("pressed", self, "_on_player_selected", [CHOICES.SCISSORS])
	showOutcomeTimer.connect("timeout", self, "_on_showOutcomeTimer_timeout")

func _on_player_selected(choice):
	var enemy_choice = pick_enemy_choice()
	outcome = check_win(choice, enemy_choice)
	$Field/VBoxContainer/EnemyChoice/Sprite.texture = icon_map[enemy_choice]
	$Field/VBoxContainer/PlayerChoice/Sprite.texture = icon_map[choice]
	$Field/VBoxContainer/PlayerOptions.hide()
	$Field/VBoxContainer/PlayerChoice.show()
	show_outcome(outcome)
	showOutcomeTimer.start()

func _on_showOutcomeTimer_timeout():
	emit_outcome(outcome)
	turns += 1
	if turns == max_turns or outcome in play_until:
		done()
	else:
		reset_gui()

func pick_enemy_choice():
	if choice_map:
		return Utils.pick_from_weighted(choice_map)
	randomize()
	return [CHOICES.ROCK, CHOICES.SCISSORS, CHOICES.PAPER][randi() % 3]

func reset_gui():
		$Field/VBoxContainer/EnemyChoice/Sprite.texture = QuestionIcon
		$Field/VBoxContainer/PlayerOptions.show()
		$Field/VBoxContainer/PlayerChoice.hide()
		$Field/VBoxContainer/Outcome.hide()

func emit_outcome(outcome_val):
	match(outcome_val):
		OUTCOMES.WIN:
			emit_signal("player_win")
		OUTCOMES.LOSE:
			emit_signal("player_lose")
		OUTCOMES.DRAW:
			emit_signal("player_draw")

func show_outcome(outcome_val):
	match(outcome_val):
		OUTCOMES.WIN:
			$Field/VBoxContainer/Outcome/Text.text = "YOU WIN!"
			$Field/VBoxContainer/Outcome.show()
			$SFXWin.play()
		OUTCOMES.LOSE:
			$Field/VBoxContainer/Outcome/Text.text = "YOU LOSE!"
			$Field/VBoxContainer/Outcome.show()
			$SFXLose.play()
		OUTCOMES.DRAW:
			$Field/VBoxContainer/Outcome/Text.text = "DRAW!"
			$Field/VBoxContainer/Outcome.show()
			$SFXDraw.play()
			

func check_win(player_choice, enemy_choice):
	if player_choice == enemy_choice:
		return OUTCOMES.DRAW
	match([player_choice, enemy_choice]):
		[CHOICES.ROCK, CHOICES.SCISSORS]: return OUTCOMES.WIN
		[CHOICES.PAPER, CHOICES.ROCK]: return OUTCOMES.WIN
		[CHOICES.SCISSORS, CHOICES.PAPER]: return OUTCOMES.WIN
		_: return OUTCOMES.LOSE
