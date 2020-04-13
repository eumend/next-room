extends Node2D

const BattleUnits = preload("res://BattleUnits.tres")
const DialogBox = preload("res://DialogBox.tres")
const ActionBattle = preload("res://ActionBattle.tres")

export(int) var hp = 10 setget set_hp
export(int) var power = 4
export(int) var exp_points = 1
export(bool) var is_boss = false
export (String, MULTILINE) var entry_text = ""
onready var hpLabel = $HPLabel
onready var animationPlayer = $AnimationPlayer
const NumberAnimation = preload("res://Animations/NumberAnimation.tscn")

signal died(exp_points)
signal end_turn
var max_hp = hp

var attack_pattern = {
	"default_attack": 100,
}

var hit_force_pattern = {
	GameConstants.HIT_FORCE.NORMAL: 60,
	GameConstants.HIT_FORCE.STRONG: 30,
	GameConstants.HIT_FORCE.CRIT: 10,
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
	animationPlayer.play("Attack") # Calls "deal_damage" mid animation
	yield(animationPlayer, "animation_finished")
	emit_signal("end_turn")


func deal_damage(hit_force = null): #Connected to animations
	$SFXBlow.play()
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		hit_force = hit_force if hit_force else Utils.pick_from_weighted(hit_force_pattern)
		var amount = get_attack_damage_amount(power, hit_force)
		playerStats.take_damage(amount)

func heal_damage(amount):
	self.hp += amount
	$SFXHeal.play()
	animate_heal(amount)

func take_damage(amount, hit_force = null):
	self.hp -= amount
	if is_dead():
		on_dead()
	else:
		animate_damage(amount, hit_force)
		animationPlayer.play("Shake")
		yield(animationPlayer, "animation_finished")

func on_dead():
	if is_boss:
		$SFXBossDeath.play()
	var death_animation_name = "ShakeFade" if is_boss else "Fade"
	animationPlayer.play(death_animation_name)
	yield(animationPlayer, "animation_finished")
	emit_signal("died", exp_points)
	queue_free()

func animate_heal(amount):
	var numberAnimation = NumberAnimation.instance()
	hpLabel.add_child(numberAnimation)
	numberAnimation.play_heal(amount)

func animate_damage(amount, hit_force):
	var numberAnimation = NumberAnimation.instance()
	hpLabel.add_child(numberAnimation)
	if amount == 0:
		numberAnimation.play_miss()
	else:
		numberAnimation.play_damage(amount, get_hit_force_text(hit_force))

func get_attack_damage_amount(amount, hit_force):
	match(hit_force):
		GameConstants.HIT_FORCE.CRIT: return amount + ceil(amount / 3)
		GameConstants.HIT_FORCE.STRONG: return amount + ceil(amount / 5)
		_: return amount

func get_hit_force_text(hit_force):
	match(hit_force):
		GameConstants.HIT_FORCE.CRIT: return "!!"
		GameConstants.HIT_FORCE.STRONG: return "!"
		_: return ""

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
	DialogBox.show_timeout(entry_text, 2)

func _exit_tree():
	BattleUnits.Enemy = null
