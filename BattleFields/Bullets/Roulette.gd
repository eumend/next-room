extends Node2D

export (Array, Texture) var faces

var current_face = 0
var speed = 100
onready var timer = $Timer
onready var face = $Face

signal show_face(index, texture)

func _ready():
	change_face(0)
	timer.connect("timeout", self, "on_timeout")

func on_timeout():
	var new_index = (current_face + 1) % faces.size()
	self.change_face(new_index)

func change_face(new_index):
	# TODO: Play some sfx?
	current_face = new_index
	var new_texture = faces[current_face]
	face.texture = faces[current_face]
	emit_signal("show_face", current_face, new_texture)

func set_time(time):
	timer.wait_time = time

func stop():
	timer.stop()