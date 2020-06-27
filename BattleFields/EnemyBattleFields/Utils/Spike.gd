extends Node2D

signal fired

onready var animationPlayer = $AnimationPlayer
var shooting = false

func _ready():
	animationPlayer.connect("animation_finished", self, "on_animationPlayer_animation_finished")
#	shoot()

func on_animationPlayer_animation_finished(anim_name):
	if anim_name == "Peek":
		animationPlayer.play("Shoot")
	elif anim_name == "Shoot":
		shooting = false
		

func shoot():
	shooting = true
	$SFXCrack.play()
	animationPlayer.play("Peek")
	
func on_hit_animation():
	emit_signal("fired")
