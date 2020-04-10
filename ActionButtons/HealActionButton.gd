extends "res://ActionButtons/BaseActionButton.gd"

func _on_pressed():
	if(is_player_ready()):
		if player.mp >= 8:
			player.hp += 5
			player.mp -= 8
			player.ap -= ap_cost
