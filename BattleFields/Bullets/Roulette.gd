extends Node2D

export (Array, Texture) var faces

var current_face = 0
var time = 0.5 setget set_time
onready var timer = $Timer
onready var face = $Face

signal show_face(index, texture)

func _ready():
	timer.connect("timeout", self, "on_timeout")

func on_timeout():
	var new_index = (current_face + 1) % faces.size()
	self.change_face(new_index)

func change_face(new_index):
	# TODO: Play some sfx?
	current_face = new_index
	var new_texture = faces[current_face]
	face.texture = faces[current_face]
	if not face.visible:
		face.show()
	emit_signal("show_face", current_face, new_texture)

func set_time(new_time):
	time = new_time
	timer.wait_time = time

func start():
	change_face(0)
	timer.start()

func stop():
	timer.stop()
