extends Node

const DIALOG_GRAY = Color8(85, 85, 85)

var bar_textures = []

func _ready():
	randomize()

func fill_screen_bars(top_color, bottom_color):
	bar_textures = [solid_texture(top_color), solid_texture(bottom_color)]
	VisualServer.black_bars_set_images(RID(), bar_textures[0].get_rid(), RID(), bar_textures[1].get_rid())

func top_center_color(texture):
	var image = texture.get_data()
	image.lock()
	var color = image.get_pixel(int(image.get_width() / 2), 0)
	image.unlock()
	return color

func solid_texture(color):
	var image = Image.new()
	image.create(1, 1, false, Image.FORMAT_RGB8)
	image.lock()
	image.set_pixel(0, 0, color)
	image.unlock()
	var texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	return texture

func rand_int(min_i, max_i): # Inclusive on both ends
	return min_i + randi() % int(max(max_i - min_i + 1, 1))

func value_from_float_range(min_f, max_f):
	return min_f + (randf() * (max_f - min_f))

func pick_from_list(list):
	return list[randi() % list.size()]

func pick_from_weighted(distribution):
	var total_size = 0
	var last_index = 0
	var ranges = []
	for k in distribution:
		var val = distribution[k]
		total_size += val
		var end_range = last_index + val
		ranges.append([last_index, end_range, k])
		last_index = end_range
	var winner = null
	var pct = rand_range(0, total_size)
	for r in ranges:
		var start_range = r[0]
		var end_range = r[1]
		var item = r[2]
		if pct >= start_range and pct < end_range:
			winner = item
			break
	if winner == null and ranges.size() > 0:
		winner = ranges.back()[2] # rand_range can return total_size itself
	return winner
