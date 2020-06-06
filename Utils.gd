extends Node

func value_from_float_range(min_f, max_f):
	return min_f + (randf() * (max_f - min_f))

func pick_from_list(list):
	randomize()
	return list[randi() % list.size()]

func pick_from_weighted(distribution):
	var values = distribution.values()
	var total_size = 0
	for v in values:
		total_size += v
	randomize()
	var pct = rand_range(0, total_size)
	var last_index = 0
	var ranges = []
	for k in distribution:
		var val = distribution[k]
		var end_range = last_index + val
		ranges.append([last_index, end_range, k])
		last_index = end_range
	var winner = null
	for r in ranges:
		var start_range = r[0]
		var end_range = r[1]
		var item = r[2]
		if pct >= start_range and pct < end_range:
			winner = item
			break
	return winner
