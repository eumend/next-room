extends Node

var kill_streak = 0
var current_level = 1
var turns_taken = 0
var current_run = 0
var continues_taken = 0

#func _ready():
#	load_save()

func load_save():
	var saved_state = SaveFile.load_save("player_score")
	if saved_state:
		set_data_from_json(saved_state)

func save():
	var data = get_data_json()
	SaveFile.save("player_score", data)

func reset():
	kill_streak = 0
	current_level = 1
	turns_taken = 0
	current_run = 0
	continues_taken = 0

func get_data_json():
	return {
		"kill_streak": kill_streak,
		"current_level": current_level,
		"turns_taken": turns_taken,
		"current_run": current_run,
		"continues_taken": continues_taken,
	}

func set_data_from_json(json):
	kill_streak = int(json["kill_streak"])
	current_level = int(json["current_level"])
	turns_taken = int(json["turns_taken"])
	current_run = int(json["current_run"])
	continues_taken = int(json["continues_taken"])
