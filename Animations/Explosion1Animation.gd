extends Node2D

onready var sprite = $AnimatedSprite

signal done
signal boom

var boom_frame = 3

func _ready():
	$BoomSFX.play()
	sprite.play("explosion")

func _on_AnimatedSprite_animation_finished():
	emit_signal("done")
	queue_free()

func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.get_frame() == boom_frame:
		emit_signal("boom")
