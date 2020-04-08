extends Panel

onready var hpLabel = $StatsContainer/HP
onready var apLabel = $StatsContainer/AP
onready var mpLabel = $StatsContainer/MP
onready var lvLabel = $StatsContainer/LV


func _on_PlayerStats_hp_changed(value):
	hpLabel.text = "HP\n" + str(value)


func _on_PlayerStats_mp_changed(value):
	mpLabel.text = "MP\n" + str(value)


func _on_PlayerStats_ap_changed(value):
	apLabel.text = "AP\n" + str(value)


func _on_PlayerStats_level_changed(value):
	lvLabel.text = "LV\n" + str(value)
	# Show lvl up message


func _on_PlayerStats_get_status(value):
	print("Player status updated", value)
	# TODO: Display status on stats?
	pass # Replace with function body.
