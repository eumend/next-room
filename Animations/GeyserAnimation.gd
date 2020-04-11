extends Node2D

onready var sprite = $AnimatedSprite
export var time = 1

signal done
signal fired

func set_time(new_time):
	time = new_time

func _ready():
	sprite.play("erupt")
	yield(sprite, "animation_finished")
	sprite.play("loop")
	emit_signal("fired")
	yield(get_tree().create_timer(time), "timeout")
	emit_signal("done")
	queue_free()
