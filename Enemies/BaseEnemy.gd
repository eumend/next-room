extends Node2D

const BattleUnits = preload("res://BattleUnits.tres")
const DialogBox = preload("res://DialogBox.tres")
const ActionBattle = preload("res://ActionBattle.tres")

export(int) var max_hp = 10
export(int) var power = 4
export(int) var exp_points = 1
export(bool) var is_boss = false
export(bool) var is_big_boss = false
export (String, MULTILINE) var entry_text = ""
onready var hpLabel = $HPLabel
onready var animationPlayer = $AnimationPlayer
onready var attackAnimationPlayer = $AttackAnimationPlayer
onready var startTurnTimer = $StartTurnTimer
onready var sfxMiss = $SFXMiss
const NumberAnimation = preload("res://Animations/NumberAnimation.tscn")

signal died
signal end_turn
signal fled
signal death_animation_done

var hp = max_hp setget set_hp
var on_death_animation = false
var turn_count = 0

var hit_force_pattern = {
	GameConstants.HIT_FORCE.NORMAL: 60,
	GameConstants.HIT_FORCE.STRONG: 30,
	GameConstants.HIT_FORCE.CRIT: 10,
}

const ENEMY_DIALOGS = GameConstants.ENEMY_DIALOGS

var dialog_lengths = {
	ENEMY_DIALOGS.SHORT: 1.5,
	ENEMY_DIALOGS.MEDIUM: 2,
	ENEMY_DIALOGS.LONG: 3,
}

var selected_attack = null # Used when calling an attack during an animation

func start_turn():
	startTurnTimer.start()

func on_startTurnTimer_timeout():
	on_start_turn()

func on_start_turn():
	turn_count += 1
	attack()

func attack():
	var attack_pattern = get_attack_pattern()
	selected_attack = Utils.pick_from_weighted(attack_pattern)
	if selected_attack:
		call(selected_attack)

func get_attack_pattern():
	return {
		"default_attack": 100,
	}

func default_attack():
	animationPlayer.play("Attack") # Calls "deal_damage" mid animation
	yield(animationPlayer, "animation_finished")
	emit_signal("end_turn")


func deal_damage(hit_force = null, fixed_amount = null): #Connected to animations
	$SFXBlow.play()
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		hit_force = hit_force if hit_force else Utils.pick_from_weighted(get_hit_force_pattern())
		var amount = fixed_amount if fixed_amount != null else get_attack_damage_amount(power, hit_force)
		playerStats.take_damage(amount, hit_force)
		if playerStats.is_dead():
			emit_signal("end_turn")

func get_hit_force_pattern():
	return hit_force_pattern

func heal_damage(amount):
	var old_hp = hp
	self.hp = clamp(old_hp + amount, 0, self.max_hp)
	var healed = self.hp - old_hp
	if healed > 0:
		$SFXHeal.play()
		animate_heal(healed)

func take_damage(amount, hit_force = null):
	if amount > 0:
		$SFXBlow.play()
	self.hp -= amount
	animate_damage(amount, hit_force)
	if is_dead():
		on_death()
	else:
		animationPlayer.play("Shake")
		yield(animationPlayer, "animation_finished")

func heal_player(amount):
	var playerStats = BattleUnits.PlayerStats
	if playerStats:
		playerStats.heal_damage(amount)

func flee():
	$SFXFlee.play()
	hpLabel.hide()
	animationPlayer.play("Flee")
	yield(animationPlayer, "animation_finished")
	emit_signal("fled")

func on_death():
	on_death_animation = true
	emit_signal("died")
	var death_animation_name = "Fade"
	if is_big_boss:
		$SFXBigBossDeath.play()
		death_animation_name = "BigBossDeath"
	elif is_boss:
		$SFXBossDeath.play()
		death_animation_name = "ShakeFade"
	animationPlayer.play(death_animation_name)
	yield(animationPlayer, "animation_finished")
	on_death_animation = false
	emit_signal("death_animation_done")
	self.hide()
	if BattleUnits.is_enemy_turn():
		emit_signal("end_turn")

func animate_heal(amount):
	var numberAnimation = NumberAnimation.instance()
	hpLabel.add_child(numberAnimation)
	numberAnimation.play_heal(amount)

func animate_damage(amount, hit_force):
	var numberAnimation = NumberAnimation.instance()
	hpLabel.add_child(numberAnimation)
	if amount == 0:
		numberAnimation.play_miss()
		sfxMiss.play()
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
	self.hp = self.max_hp
	attackAnimationPlayer.connect("animation_finished", self, "on_attack_animation_finished")
	startTurnTimer.connect("timeout", self, "on_startTurnTimer_timeout")
	on_start_of_battle()

func on_start_of_battle():
	DialogBox.show_timeout(entry_text, 2.5)

func show_attack_text(text, l = ENEMY_DIALOGS.SHORT):
	DialogBox.show_timeout(text, dialog_lengths[l], true)
	return DialogBox

func on_attack_animation_finished(_animation_name):
	pass

func _exit_tree():
	BattleUnits.Enemy = null
