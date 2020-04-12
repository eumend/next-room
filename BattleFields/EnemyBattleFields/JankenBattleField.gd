extends "res://BattleFields/BaseBattleField.gd"

var heal_amount = 4
var damage_amount = 2

enum CHOICES{ROCK, PAPER, SCISSORS}
enum OUTCOMES{WIN, LOSE, DRAW}

var icon_map = {
	CHOICES.ROCK: preload("res://Images/Buttons/shield_button.png"),
	CHOICES.SCISSORS: preload("res://Images/Buttons/sword_button.png"),
	CHOICES.PAPER: preload("res://Images/Buttons/paper_button.png"),
}

const QuestionIcon = preload("res://Images/Buttons/question_button.png")

func _ready():
	$Field/VBoxContainer/PlayerOptions/PaperButton.connect("pressed", self, "_on_player_selected", [CHOICES.PAPER])
	$Field/VBoxContainer/PlayerOptions/RockButton.connect("pressed", self, "_on_player_selected", [CHOICES.ROCK])
	$Field/VBoxContainer/PlayerOptions/ScissorButton.connect("pressed", self, "_on_player_selected", [CHOICES.SCISSORS])

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
			emit_signal("hit", damage_amount)
			yield(get_tree().create_timer(2), "timeout")
			done()
		OUTCOMES.LOSE:
			$Field/VBoxContainer/Outcome/Text.text = "YOU LOSE!"
			$Field/VBoxContainer/Outcome.show()
			emit_signal("enemy_heal", heal_amount)
			yield(get_tree().create_timer(2), "timeout")
			done()
		OUTCOMES.DRAW:
			$Field/VBoxContainer/Outcome/Text.text = "DRAW!"
			$Field/VBoxContainer/Outcome.show()
			yield(get_tree().create_timer(2), "timeout")
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
