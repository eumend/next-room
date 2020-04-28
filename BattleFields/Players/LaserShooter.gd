extends Node2D

const Laser = preload("res://BattleFields/Players/Laser.tscn")
onready var laserSFX = $LaserSFX

func fire():
	var laser = Laser.instance()
	laser.position.y = -30
	# TODO: set position
	add_child(laser)
	laserSFX.play()
