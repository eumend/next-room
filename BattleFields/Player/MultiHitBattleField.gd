extends "res://BattleFields/BaseBattleField.gd"

var direction = 1
var current_area = null
var current_pointer = 1

onready var pointer1 = $Field/Pointer1
onready var pointer2 = $Field/Pointer2
var total_pointers = 2
var speed = 90
var speed_increase = {
	1: 0,
	2: 20
}
var paused = false

func _ready():
	var pointer = get_current_pointer()
	pointer.show()

func _physics_process(delta):
	if not paused:
		var motion = Vector2(direction, 0)
		var pointer = get_current_pointer()
		pointer.position += motion * delta * (speed + speed_increase[current_pointer])

func _on_FieldButton_pressed():
	var overlapping_area_names = []
	var pointer = get_current_pointer()
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
	if current_pointer < total_pointers:
		current_pointer += 1
		pointer = get_current_pointer()
		direction = 1
		pointer.show()
	else:
		paused = true
		doneTimer.start()

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
