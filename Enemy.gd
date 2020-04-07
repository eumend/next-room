extends Node2D

const BattleUnits = preload("res://BattleUnits.tres")

export(int) var hp = 25 setget set_hp
export(int) var power = 4
export(int) var exp_points = 1
onready var hpLabel = $HPLabel
onready var animationPlayer = $AnimationPlayer

signal died(exp_points)
signal end_turn

func attack():
	yield(get_tree().create_timer(0.4), "timeout")
	animationPlayer.play("Attack")
	yield(animationPlayer, "animation_finished")
	emit_signal("end_turn")

func deal_damage():
	if BattleUnits.PlayerStats:
		BattleUnits.PlayerStats.hp -= power

func take_damage(amount):
	self.hp -= amount
	if is_dead():
		queue_free()
		emit_signal("died", exp_points)
	else:
		animationPlayer.play("Shake")
		yield(animationPlayer, "animation_finished")

func is_dead():
	return hp <= 0

func set_hp(new_hp):
	hp = new_hp
	if hpLabel != null:
		hpLabel.text = str(hp) + 'hp'

func _ready():
	BattleUnits.Enemy = self
	set_hp(self.hp) # Updated label

func _exit_tree():
	BattleUnits.Enemy = null