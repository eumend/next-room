extends Node2D

onready var sprite = $AnimatedSprite
export var time = 1

signal done
signal fired

onready var timer = $Timer

func set_time(new_time):
	time = new_time

func _ready():
	timer.wait_time = time
	sprite.play("erupt")
	yield(sprite, "animation_finished")
	sprite.play("loop")
	emit_signal("fired")
	timer.connect("timeout", self, "on_timeout")
	timer.start()

func on_timeout():
	emit_signal("done")
	queue_free()
