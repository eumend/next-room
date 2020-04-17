extends Node2D

signal hit(force)
signal enemy_hit(force)
signal miss
signal heal(force)
signal enemy_heal(force)
signal done

onready var fieldButton = $FieldButton

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: Some animation?
	fieldButton.connect("pressed", self, "_on_FieldButton_pressed")

func done():
	# TODO: Some animation?
	emit_signal("done")
	queue_free()

func hit(hit_force = GameConstants.HIT_FORCE.NORMAL):
	emit_signal("hit", hit_force)

func enemy_hit(hit_force = GameConstants.HIT_FORCE.NORMAL):
	emit_signal("enemy_hit", hit_force)

func heal(hit_force = GameConstants.HIT_FORCE.NORMAL):
	emit_signal("heal", hit_force)

func enemy_heal(hit_force = GameConstants.HIT_FORCE.NORMAL):
	emit_signal("enemy_heal", hit_force)

func miss():
	emit_signal("miss")

func _on_FieldButton_pressed():
	# Field button pressed
	pass
