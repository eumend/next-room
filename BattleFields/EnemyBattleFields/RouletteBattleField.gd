extends "res://BattleFields/BaseBattleField.gd"

#export (Array, Texture) var faces
onready var roulette = $Field/Roulette
onready var showSelectedTimer = $ShowSelectedTimer
onready var selectedFaces = $Field/SelectedFaces

var current_face_index = 0
var current_face_texture = null
#var timer_speed = 1
var taking_presses = true
var previous_face = null
#var presses = 1
signal face_selected(index, texture)
signal face_displayed(index, texture)

func _ready():
	roulette.connect("show_face", self, "on_Roulette_show_face")
	showSelectedTimer.connect("timeout", self, "on_ShowSelectedTimer_timeout")
#	start_roulette(self.faces)

func start_roulette(faces, timer_speed):
	if previous_face:
		display_previous_face()
	current_face_index = 0
	current_face_texture = null
	taking_presses = true
	roulette.faces = faces
	roulette.time = timer_speed
	roulette.start()

func on_Roulette_show_face(index, texture):
	current_face_index = index
	current_face_texture = texture

func _on_FieldButton_pressed():
	if taking_presses:
#		presses -= 1
		taking_presses = false
		# TODO: play some SFX
		roulette.stop()
		previous_face = current_face_texture
		emit_signal("face_selected", current_face_index, current_face_texture)
		showSelectedTimer.start()

func display_previous_face():
	var selected_face = TextureRect.new()
	selected_face.texture = previous_face
	selectedFaces.add_child(selected_face)
	previous_face = null

func on_ShowSelectedTimer_timeout():
	emit_signal("face_displayed", current_face_index, current_face_texture)
#	if presses == 0:
#		done()
#	else:
##		roulette.hide()
