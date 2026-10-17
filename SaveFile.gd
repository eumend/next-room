extends Node

const SAVE_PATH = "user://savegame.save"
const TMP_PATH = "user://savegame.tmp"

var save_state = false

func load_save(store_key):
	_load()
	if save_state and store_key in save_state and typeof(save_state[store_key]) == TYPE_DICTIONARY:
		return save_state[store_key]

func _load():
	var save_game = File.new()
	if not save_game.file_exists(SAVE_PATH):
		return # Error! We don't have a save to load.
	if save_game.open(SAVE_PATH, File.READ) != OK:
		return
	var data = parse_json(save_game.get_line())
	save_game.close()
	# Ignore corrupt or truncated saves instead of crashing on them
	save_state = data if typeof(data) == TYPE_DICTIONARY else false

func save(store_key, data):
	if not save_state:
		save_state = {}
	save_state[store_key] = data
	_save()

func _save():
	# Write to a temp file first so a killed app can't leave a truncated save
	var save_game = File.new()
	if save_game.open(TMP_PATH, File.WRITE) != OK:
		return
	save_game.store_line(to_json(save_state))
	save_game.close()
	var dir = Directory.new()
	if dir.open("user://") == OK:
		dir.rename(TMP_PATH, SAVE_PATH)

func reset():
	save_state = false
	_save()
