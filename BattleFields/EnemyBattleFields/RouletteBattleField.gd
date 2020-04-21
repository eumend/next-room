extends "res://BattleFields/BaseBattleField.gd"

export (Array, Texture) var faces
onready var roulette = $Field/Roulette
onready var showSelectedTimer = $ShowSelectedTimer

var current_face_index = 0
var current_face_texture = null
var timer_speed = 1
var taking_presses = true
signal face_selected(index, texture)

func _ready():
	roulette.faces = faces
	roulette.set_time(timer_speed)
	roulette.connect("show_face", self, "on_Roulette_show_face")
	showSelectedTimer.connect("timeout", self, "on_ShowSelectedTimer_timeout")
	roulette.start()

func on_Roulette_show_face(index, texture):
	current_face_index = index
	current_face_texture = texture

func _on_FieldButton_pressed():
	if taking_presses:
		taking_presses = false
		# TODO: play some SFX
		roulette.stop()
		emit_signal("face_selected", current_face_index, current_face_texture)
		showSelectedTimer.start()

func on_ShowSelectedTimer_timeout():
	done()
