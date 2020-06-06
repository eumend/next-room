extends Node2D

signal hit(force)
signal enemy_hit(force)
signal miss
signal heal(force)
signal heal_status
signal enemy_heal(force)
signal done

onready var fieldButton = $FieldButton

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: Some animation?
	fieldButton.connect("pressed", self, "_on_FieldButton_pressed")

func done():
	# TODO: Some animation?
	print("BF: DONE")
	emit_signal("done")
	self.hide()
#	queue_free()

func hit(hit_force = GameConstants.HIT_FORCE.NORMAL):
	print("BF: HIT", hit_force)
	emit_signal("hit", hit_force)

func enemy_hit(hit_force = GameConstants.HIT_FORCE.NORMAL):
	print("BF: ENEMY HIT", hit_force)
	emit_signal("enemy_hit", hit_force)

func heal(hit_force = GameConstants.HIT_FORCE.NORMAL):
	print("BF: HEAL", hit_force)
	emit_signal("heal", hit_force)

func heal_status():
	print("BF: HEAL STATUS")
	emit_signal("heal_status")

func enemy_heal(hit_force = GameConstants.HIT_FORCE.NORMAL):
	print("BF: ENEMY HEAL", hit_force)
	emit_signal("enemy_heal", hit_force)

func miss():
	print("BF: MISS")
	emit_signal("miss")

func _on_FieldButton_pressed():
	# Field button pressed
	print("BF: PRESSED")
	on_pressed()
	pass

func on_pressed():
	pass
