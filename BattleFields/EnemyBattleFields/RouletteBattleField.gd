extends "res://BattleFields/BaseBattleField.gd"

#export (Array, Texture) var faces
onready var roulette = $Field/Roulette
onready var showSelectedTimer = $ShowSelectedTimer
onready var selectedFaces = $Field/SelectedFaces
onready var sfxWin = $SFXWin
onready var sfxLose = $SFXLose
onready var sfxNeutral = $SFXNeutral

var previous_index = null
var current_face_index = 0
var taking_presses = true
var face_data = []
signal face_selected(index)
signal face_displayed(index)

func _ready():
	roulette.connect("show_face", self, "on_Roulette_show_face")
	showSelectedTimer.connect("timeout", self, "on_ShowSelectedTimer_timeout")

func start_roulette(new_face_data, timer_speed):
	face_data = new_face_data
	if previous_index != null:
		display_previous_face()
	var faces = []
	for option in face_data:
		faces.append(option["sprite"])
	current_face_index = 0
	taking_presses = true
	roulette.faces = faces
	roulette.time = timer_speed
	roulette.start()

func on_Roulette_show_face(index):
	current_face_index = index

func _on_FieldButton_pressed():
	if taking_presses:
		taking_presses = false
		roulette.stop()
		var selected_face = face_data[current_face_index]
		play_sfx(selected_face)
		emit_signal("face_selected", current_face_index)
		showSelectedTimer.start()

func play_sfx(selected_face):
	if "type" in selected_face:
		if selected_face["type"] == "good":
			sfxWin.play()
		elif selected_face["type"] == "bad":
			sfxLose.play()
		else:
			sfxNeutral.play()
	else:
		sfxNeutral.play()

func display_previous_face():
	var previous_face = face_data[previous_index]
	var face_texture = TextureRect.new()
	face_texture.texture = previous_face["sprite"]
	face_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selectedFaces.add_child(face_texture)
	previous_index = null

func on_ShowSelectedTimer_timeout():
	emit_signal("face_displayed", current_face_index)
