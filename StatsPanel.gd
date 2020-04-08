extends Panel

onready var hpLabel = $StatsContainer/HP
onready var apLabel = $StatsContainer/AP
onready var mpLabel = $StatsContainer/MP
onready var lvLabel = $StatsContainer/LV
onready var statusContainer = $StatsContainer/Status


func _on_PlayerStats_hp_changed(value):
	hpLabel.text = "HP\n" + str(value)


func _on_PlayerStats_mp_changed(value):
	mpLabel.text = "MP\n" + str(value)


func _on_PlayerStats_ap_changed(value):
	apLabel.text = "AP\n" + str(value)


func _on_PlayerStats_level_changed(value):
	lvLabel.text = "LV\n" + str(value)

func _on_PlayerStats_status_changed(statuses):
	if statuses.size() > 0:
		lvLabel.hide()
		display_status(statuses)
		statusContainer.show()
	else:
		statusContainer.hide()
		display_status(statuses)
		lvLabel.show()

func display_status(statuses):
	if statuses.size() > 0:
		var first_status = statuses[0]
		statusContainer.get_node("Icon").texture = get_status_icon(first_status)
	else:
		statusContainer.get_node("Icon").texture = null

func get_status_icon(status):
	match(status):
		GameConstants.STATUS.POISON: return load("res://Images/skull.png")
		_: return null
