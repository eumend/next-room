extends Node2D

const BattleUnits = preload("res://BattleUnits.tres")
const DialogBox = preload("res://DialogBox.tres")
const ActionBattle = preload("res://ActionBattle.tres")

export(int) var hp = 10 setget set_hp
export(int) var power = 4
export(int) var exp_points = 1
export (String, MULTILINE) var entry_text = ""
onready var hpLabel = $HPLabel
onready var damageLabel = $Damage
onready var animationPlayer = $AnimationPlayer
onready var damageAnimationPlayer = $DamageAnimationPlayer

signal died(exp_points)
signal end_turn

var attack_pattern = {
	"default_attack": 100,
}

var selected_attack = null

func start_turn():
	yield(get_tree().create_timer(0.4), "timeout")
	attack()

func attack():
	randomize()
	selected_attack = Utils.pick_from_weighted(attack_pattern)
	if selected_attack:
		call(selected_attack)

func default_attack():
	animationPlayer.play("Attack")
	yield(animationPlayer, "animation_finished")
	emit_signal("end_turn")


func deal_damage(): #Connected to animations
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		playerStats.take_damage(power)

func take_damage(amount, hit_force = null):
	self.hp -= amount
	print("Took damage", amount)
	if is_dead():
		emit_signal("died", exp_points)
		animationPlayer.play("Fade")
		yield(animationPlayer, "animation_finished")
		queue_free()
	else:
		animate_damage(amount, hit_force)
		animationPlayer.play("Shake")
		yield(animationPlayer, "animation_finished")

func animate_damage(amount, hit_force):
	damageLabel.text = get_text_for_damage(amount, hit_force)
	damageAnimationPlayer.play("DamageNormal")

func get_text_for_damage(amount, hit_force):
	if amount == 0:
		return "MISS!"
	var extra_text = ""
	if hit_force == GameConstants.HIT_FORCE.CRIT:
		extra_text = "!!"
	elif hit_force == GameConstants.HIT_FORCE.STRONG:
		extra_text = "!"
	return "-" + str(amount) + extra_text

func is_dead():
	return hp <= 0

func set_hp(new_hp):
	hp = new_hp
	if hpLabel != null:
		if new_hp > 0:
			hpLabel.text = str(hp) + 'hp'
		else:
			hpLabel.text = ""

func _ready():
	BattleUnits.Enemy = self
	set_hp(self.hp) # Updated label
	DialogBox.show_timeout(entry_text, 3)

func _exit_tree():
	BattleUnits.Enemy = null

