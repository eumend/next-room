extends Area2D

onready var animationPlayer = $AnimationPlayer

func _ready():
	animationPlayer.connect("animation_finished", self, "_on_animationPlayer_animation_finished")
	animationPlayer.play("Fire")

func _on_animationPlayer_animation_finished(_anim_name):
	queue_free()
