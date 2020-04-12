extends Node2D

onready var label = $Number

func play_miss(text = "MISS!!"):
	label.text = text
	label.set("custom_colors/font_color", "ffffff")
	play_animation()

func play_damage(number, extra_text = ""):
	label.text = "-" + str(number) + extra_text
	label.set("custom_colors/font_color", "ff0000")
	play_animation()

func play_heal(number, extra_text = ""):
	label.text = "+" + str(number) + extra_text
	label.set("custom_colors/font_color", "33ff00")
	play_animation()

func play_animation():
	label.show()
	$AnimationPlayer.play("Fade")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
