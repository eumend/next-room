extends "res://BattleFields/BaseBattleField.gd"

var direction = 1

onready var pointer = $Field/Pointer

func _physics_process(_delta):
	var motion = Vector2(direction, 0)
	pointer.position += motion

func _on_FieldButton_pressed():
	var overlapping_area_names = []
	for area in pointer.get_overlapping_areas():
		overlapping_area_names.append(area.name)
	if overlapping_area_names.has("CritZone"):
		hit(GameConstants.HIT_FORCE.CRIT)
	elif overlapping_area_names.has("StrongZone"):
		hit(GameConstants.HIT_FORCE.STRONG)
	elif overlapping_area_names.has("NormalZone"):
		hit(GameConstants.HIT_FORCE.NORMAL)
	else:
		miss()
	done()

func _on_BorderL_area_entered(_area):
	if direction == -1:
		direction = 1

func _on_BorderR_area_entered(_area):
	if direction == 1:
		direction = -1
