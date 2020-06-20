extends Node

onready var startButton = $UI/Buttons/StartButton
onready var continueButton = $UI/Buttons/ContinueButton
onready var sfxMove = $SFXMove
onready var bgMusic = $BGMusic
onready var animationPlayer = $AnimationPlayer
onready var tween = $Tween
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
	fade_out()
	sfxMove.play()
	animationPlayer.play("FadeIn")
	yield(animationPlayer, "animation_finished")
	bgMusic.stop()
	var _result = get_tree().change_scene("res://Battle.tscn")

func fade_out():
	tween.interpolate_property(bgMusic, "volume_db", 0, -80, 1, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
