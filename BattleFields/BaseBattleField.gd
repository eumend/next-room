extends Node2D

signal hit(damage)
signal miss
signal heal(amount)
signal done

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: Some animation?
	$FieldButton.connect("pressed", self, "_on_FieldButton_pressed")

func done():
	# TODO: Some animation?
	emit_signal("done")
	queue_free()

func hit(damage):
	emit_signal("hit", damage)

func _on_FieldButton_pressed():
	print("BaseBattleField: _on_FieldButton_pressed")
	pass
