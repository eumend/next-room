extends "res://BattleFields/BaseBattleField.gd"

var direction = 1
var current_area = null
var current_pointer = 1

onready var pointer1 = $Field/Pointer1
onready var pointer2 = $Field/Pointer2
var total_pointers = 2
var speed = 60

func _ready():
	var pointer = get_current_pointer()
	pointer.show()

func _physics_process(delta):
	var motion = Vector2(direction, 0)
	var pointer = get_current_pointer()
	pointer.position += motion * delta * speed * current_pointer

func _on_FieldButton_pressed():
	var overlapping_area_names = []
	var pointer = get_current_pointer()
	for area in pointer.get_overlapping_areas():
		overlapping_area_names.append(area.name)
	if overlapping_area_names.has("CritZone"):
		emit_signal("hit", GameConstants.HIT_FORCE.CRIT)
	elif overlapping_area_names.has("StrongZone"):
		emit_signal("hit", GameConstants.HIT_FORCE.STRONG)
	elif overlapping_area_names.has("NormalZone"):
		emit_signal("hit", GameConstants.HIT_FORCE.NORMAL)
	else:
		emit_signal("miss")
	if current_pointer < total_pointers:
		current_pointer += 1
		pointer = get_current_pointer()
		direction = 1
		pointer.show()
	else:
		done()

func get_current_pointer():
	if current_pointer == 1:
		return pointer1
	else:
		return pointer2

func _on_BorderL_area_entered(_area):
	if direction == -1:
		direction = 1

func _on_BorderR_area_entered(_area):
	if direction == 1:
		direction = -1
