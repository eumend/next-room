extends Node

onready var startButton = $UI/Buttons/StartButton
onready var continueButton = $UI/Buttons/ContinueButton

func _ready():
	startButton.connect("pressed", self, "on_startButton_pressed")
	continueButton.connect("pressed", self, "on_continueButton_pressed")
	SaveFile._load()
	if SaveFile.save_state:
		continueButton.visible = true

func on_startButton_pressed():
	SaveFile.reset()
	go_to_battle()

func on_continueButton_pressed():
	go_to_battle()

func go_to_battle():
	var _result = get_tree().change_scene("res://Battle.tscn")
