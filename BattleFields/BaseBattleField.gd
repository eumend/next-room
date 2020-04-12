extends Node2D

signal hit(force)
signal enemy_hit(force)
signal miss
signal heal(force)
signal enemy_heal(force)
signal done

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: Some animation?
	$FieldButton.connect("pressed", self, "_on_FieldButton_pressed")

func done():
	# TODO: Some animation?
	emit_signal("done")
	queue_free()

func _on_FieldButton_pressed():
	print("BaseBattleField: _on_FieldButton_pressed")
	pass
