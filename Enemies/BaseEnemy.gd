extends Node2D

const BattleUnits = preload("res://BattleUnits.tres")
const DialogBox = preload("res://DialogBox.tres")

export(int) var hp = 25 setget set_hp
export(int) var power = 4
export(int) var exp_points = 1
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
	selected_attack = pick_from_weighted(attack_pattern)
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

func _exit_tree():
	BattleUnits.Enemy = null

# TODO: Get out to a helpers function
func pick_from_weighted(distribution):
	var values = distribution.values()
	var total_size = 0
	for v in values:
		total_size += v
	var pct = rand_range(0, total_size)
	var last_index = 0
	var ranges = []
	for k in distribution:
		var val = distribution[k]
		var end_range = last_index + val
		ranges.append([last_index, end_range, k])
		last_index += end_range + 1
	var winner = null
	for r in ranges:
		var start_range = r[0]
		var end_range = r[1]
		var item = r[2]
		if pct >= start_range and pct <= end_range:
			winner = item
			break
	return winner
