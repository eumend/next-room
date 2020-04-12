extends Node2D

const BattleUnits = preload("res://BattleUnits.tres")
const DialogBox = preload("res://DialogBox.tres")
const ActionBattle = preload("res://ActionBattle.tres")

export(int) var hp = 10 setget set_hp
export(int) var power = 4
export(int) var exp_points = 1
export (String, MULTILINE) var entry_text = ""
onready var hpLabel = $HPLabel
onready var animationPlayer = $AnimationPlayer
const NumberAnimation = preload("res://Animations/NumberAnimation.tscn")
const blow_sfx = preload("res://Music/SFX/blow_2.wav")
const heal_sfx = preload("res://Music/SFX/heal_1.wav")
signal died(exp_points)
signal end_turn
var max_hp = hp
var death_animation_name = "Fade"

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
	animationPlayer.play("Attack") # Calls "deal_damage" mid animation
	yield(animationPlayer, "animation_finished")
	emit_signal("end_turn")


func deal_damage(hit_force = null): #Connected to animations
	play_sfx(blow_sfx)
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		var amount = get_attack_damage_amount(power, hit_force)
		playerStats.take_damage(amount)

func heal_damage(amount):
	self.hp += amount
	play_sfx(heal_sfx)
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
		GameConstants.HIT_FORCE.CRIT: return amount + round(amount / 3)
		GameConstants.HIT_FORCE.STRONG: return amount + round(amount / 5)
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

func play_sfx(sfx_stream):
	$SFXPlayer.stream = sfx_stream
	$SFXPlayer.play()
