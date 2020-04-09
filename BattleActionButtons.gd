extends GridContainer

#const SlashAttack = preload("res://Attacks/SlashAttack.tscn")
const ActionBattle = preload("res://ActionBattle.tres")

func _ready():
	ActionBattle.MidPanel = self
