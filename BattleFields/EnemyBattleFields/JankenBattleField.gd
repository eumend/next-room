extends "res://BattleFields/BaseBattleField.gd"

onready var playerOptions = $Field/VBoxContainer/PlayerOptions

enum CHOICES{ROCK, PAPER, SCISSORS}
enum OUTCOMES{WIN, LOSE, DRAW}

var icon_map = {
	CHOICES.ROCK: preload("res://Images/Buttons/shield_button.png"),
	CHOICES.SCISSORS: preload("res://Images/Buttons/sword_button.png"),
	CHOICES.PAPER: preload("res://Images/Buttons/paper_button.png"),
}

const QuestionIcon = preload("res://Images/Buttons/question_button.png")

func _ready():
	playerOptions.find_node("PaperButton").connect("pressed", self, "_on_player_selected", [CHOICES.PAPER])
	playerOptions.find_node("RockButton").connect("pressed", self, "_on_player_selected", [CHOICES.ROCK])
	playerOptions.find_node("ScissorButton").connect("pressed", self, "_on_player_selected", [CHOICES.SCISSORS])

func _on_player_selected(choice):
	randomize()
	var enemy_choice = [CHOICES.ROCK, CHOICES.SCISSORS, CHOICES.PAPER][randi() % 3]
	var outcome = check_win(choice, enemy_choice)
	$Field/VBoxContainer/EnemyChoice/Sprite.texture = icon_map[enemy_choice]
	$Field/VBoxContainer/PlayerChoice/Sprite.texture = icon_map[choice]
	$Field/VBoxContainer/PlayerOptions.hide()
	$Field/VBoxContainer/PlayerChoice.show()
	handle_outcome(outcome)

func handle_outcome(outcome):
	match(outcome):
		OUTCOMES.WIN:
			$Field/VBoxContainer/Outcome/Text.text = "YOU WIN!"
			$Field/VBoxContainer/Outcome.show()
			$SFXWin.play()
			yield(get_tree().create_timer(1), "timeout")
			hit()
			done()
		OUTCOMES.LOSE:
			$Field/VBoxContainer/Outcome/Text.text = "YOU LOSE!"
			$Field/VBoxContainer/Outcome.show()
			$SFXLose.play()
			yield(get_tree().create_timer(1), "timeout")
			enemy_hit()
			done()
		OUTCOMES.DRAW:
			$Field/VBoxContainer/Outcome/Text.text = "DRAW!"
			$Field/VBoxContainer/Outcome.show()
			$SFXDraw.play()
			yield(get_tree().create_timer(1), "timeout")
			enemy_heal()
			$Field/VBoxContainer/EnemyChoice/Sprite.texture = QuestionIcon
			$Field/VBoxContainer/PlayerOptions.show()
			$Field/VBoxContainer/PlayerChoice.hide()
			$Field/VBoxContainer/Outcome.hide()
			return

func check_win(player_choice, enemy_choice):
	if player_choice == enemy_choice:
		return OUTCOMES.DRAW
	match([player_choice, enemy_choice]):
		[CHOICES.ROCK, CHOICES.SCISSORS]: return OUTCOMES.WIN
		[CHOICES.PAPER, CHOICES.ROCK]: return OUTCOMES.WIN
		[CHOICES.SCISSORS, CHOICES.PAPER]: return OUTCOMES.WIN
		_: return OUTCOMES.LOSE
