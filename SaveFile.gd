extends Node

var save_state = false

func load_save(store_key):
	_load()
	if save_state and store_key in save_state:
		return save_state[store_key]

func _load():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var node_data = parse_json(save_game.get_line())
		save_state = node_data
	save_game.close()

func save(store_key, data):
	if not save_state:
		save_state = {}
	save_state[store_key] = data
	_save()

func _save():
	var data = save_state
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(data))
	save_game.close()

func reset():
	save_state = false
	_save()
