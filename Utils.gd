extends Node

func value_from_float_range(min_f, max_f):
	return min_f + (randf() * (max_f - min_f))

func pick_from_list(list):
	randomize()
	return list[randi() % list.size()]

func pick_from_weighted(distribution):
	randomize()
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
	return winner
